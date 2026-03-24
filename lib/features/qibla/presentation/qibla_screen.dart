import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  late Future<LocationStatus> _locationStatus;

  @override
  void initState() {
    super.initState();
    _locationStatus = _resolveLocationStatus();
  }

  @override
  void dispose() {
    FlutterQiblah().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocationStatus>(
      future: _locationStatus,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _QiblaErrorState(
            message: 'Unable to check Qibla requirements right now.',
            primaryActionLabel: 'Retry',
            onPrimaryAction: _refreshStatus,
          );
        }

        final status = snapshot.data!;
        if (!status.enabled) {
          return _QiblaErrorState(
            message: 'Please enable location service for Qibla compass.',
            primaryActionLabel: 'Open Location Settings',
            onPrimaryAction: () async {
              await Geolocator.openLocationSettings();
              await _refreshStatus();
            },
          );
        }

        if (status.status == LocationPermission.denied ||
            status.status == LocationPermission.deniedForever) {
          return _QiblaErrorState(
            message:
                'Location permission is required to calculate Qibla direction.',
            primaryActionLabel: 'Open App Settings',
            onPrimaryAction: () async {
              await Geolocator.openAppSettings();
              await _refreshStatus();
            },
          );
        }

        return _QiblaCompassView(onRetry: _refreshStatus);
      },
    );
  }

  Future<void> _refreshStatus() async {
    if (!mounted) return;
    setState(() {
      _locationStatus = _resolveLocationStatus();
    });
  }

  Future<LocationStatus> _resolveLocationStatus() async {
    var status = await FlutterQiblah.checkLocationStatus();
    if (status.enabled && status.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
      status = await FlutterQiblah.checkLocationStatus();
    }
    return status;
  }
}

class _QiblaCompassView extends StatelessWidget {
  const _QiblaCompassView({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _QiblaErrorState(
            message:
                'Compass data is unavailable. Move your phone in a figure-8 and try again.',
            primaryActionLabel: 'Retry',
            onPrimaryAction: onRetry,
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Loading Qibla compass...'),
              ],
            ),
          );
        }

        final data = snapshot.data!;
        return _CompassBody(
          qiblahAngle: _normalizeAngle(data.qiblah),
          northAngle: _normalizeAngle(data.direction),
          offset: data.offset,
        );
      },
    );
  }

  double _normalizeAngle(double value) {
    final normalized = value % 360;
    return normalized < 0 ? normalized + 360 : normalized;
  }
}

class _CompassBody extends StatelessWidget {
  const _CompassBody({
    required this.qiblahAngle,
    required this.northAngle,
    required this.offset,
  });

  final double qiblahAngle;
  final double northAngle;
  final double offset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Qibla Compass',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 290,
            height: 290,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                AnimatedRotation(
                  turns: -(northAngle / 360),
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: 270,
                    height: 270,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'N',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: -(qiblahAngle / 360),
                  duration: const Duration(milliseconds: 300),
                  child: Transform.rotate(
                    angle: -math.pi / 2,
                    child: Icon(
                      Icons.navigation_rounded,
                      size: 120,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Offset: ${offset.toStringAsFixed(1)} deg',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          _CompassQualityBadge(offset: offset),
          const SizedBox(height: 8),
          const Text(
            'Tip: If direction looks unstable, move your phone in a figure-8.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CompassQualityBadge extends StatelessWidget {
  const _CompassQualityBadge({required this.offset});

  final double offset;

  @override
  Widget build(BuildContext context) {
    final magnitude = offset.abs();
    final (label, color) = magnitude <= 5
        ? ('Sensor quality: Good', Colors.green)
        : magnitude <= 15
        ? ('Sensor quality: Medium', Colors.orange)
        : ('Sensor quality: Low', Colors.redAccent);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}

class _QiblaErrorState extends StatelessWidget {
  const _QiblaErrorState({
    required this.message,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
  });

  final String message;
  final String primaryActionLabel;
  final Future<void> Function() onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.explore_off_rounded, size: 44),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () async {
                await onPrimaryAction();
              },
              child: Text(primaryActionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
