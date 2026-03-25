import 'dart:math' as math;

import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/theme/app_theme.dart';
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color(0xFF0F172A),
            Color(0xFF4F46E5),
            Color(0xFF6366F1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: FutureBuilder<LocationStatus>(
        future: _locationStatus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _QiblaErrorState(
              message: context.l10n.tr('unableCheckQibla'),
              primaryActionLabel: context.l10n.tr('retry'),
              onPrimaryAction: _refreshStatus,
            );
          }

          final status = snapshot.data!;
          if (!status.enabled) {
            return _QiblaErrorState(
              message: context.l10n.tr('enableLocationServiceQibla'),
              primaryActionLabel: context.l10n.tr('openLocationSettings'),
              onPrimaryAction: () async {
                await Geolocator.openLocationSettings();
                await _refreshStatus();
              },
            );
          }

          if (status.status == LocationPermission.denied ||
              status.status == LocationPermission.deniedForever) {
            return _QiblaErrorState(
              message: context.l10n.tr('locationPermissionRequiredQibla'),
              primaryActionLabel: context.l10n.tr('openAppSettings'),
              onPrimaryAction: () async {
                await Geolocator.openAppSettings();
                await _refreshStatus();
              },
            );
          }

          return _QiblaCompassView(onRetry: _refreshStatus);
        },
      ),
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
            message: context.l10n.tr('compassUnavailable'),
            primaryActionLabel: context.l10n.tr('retry'),
            onPrimaryAction: onRetry,
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  context.l10n.tr('loadingQiblaCompass'),
                  style: TextStyle(color: Colors.white70),
                ),
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
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final l10n = context.l10n;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 100 + bottomPadding),
      children: <Widget>[
        Text(
          l10n.tr('qiblaCompass'),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: const Color(0xFFE8EEF8)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.tr('qiblaInstruction'),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Center(
          child: SizedBox(
            width: 310,
            height: 310,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  width: 310,
                  height: 310,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        Colors.white.withValues(alpha: 0.12),
                        Colors.white.withValues(alpha: 0.03),
                      ],
                    ),
                    border: Border.all(color: Colors.white24, width: 1.5),
                  ),
                ),
                AnimatedRotation(
                  turns: -(northAngle / 360),
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  child: Container(
                    width: 268,
                    height: 268,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppThemeColors.gold.withValues(alpha: 0.8),
                        width: 2.2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Positioned(
                          top: 20,
                          child: Text(
                            'N',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: -(qiblahAngle / 360),
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  child: Transform.rotate(
                    angle: -math.pi / 2,
                    child: const Icon(
                      Icons.navigation_rounded,
                      size: 128,
                      color: AppThemeColors.softTeal,
                    ),
                  ),
                ),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppThemeColors.gold,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppThemeColors.gold.withValues(alpha: 0.6),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppThemeColors.gold.withValues(alpha: 0.45),
            ),
          ),
          child: Column(
            children: <Widget>[
              Text(
                l10n.tr('offsetDegrees', <String, String>{
                  'offset': offset.toStringAsFixed(1),
                }),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.tr('unstableDirectionTip'),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
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
        padding: const EdgeInsets.all(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.explore_off_rounded,
                size: 42,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await onPrimaryAction();
                },
                child: Text(primaryActionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
