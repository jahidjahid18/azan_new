import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:azan_app/features/mosque/data/models/mosque_place.dart';
import 'package:azan_app/features/mosque/data/mosque_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

enum _MosqueErrorAction { openLocationSettings, openAppSettings }

class MosqueFinderScreen extends StatefulWidget {
  const MosqueFinderScreen({super.key});

  @override
  State<MosqueFinderScreen> createState() => _MosqueFinderScreenState();
}

class _MosqueFinderScreenState extends State<MosqueFinderScreen> {
  final MosqueService _mosqueService = MosqueService();

  bool _isLoading = true;
  List<MosquePlace> _mosques = <MosquePlace>[];
  LatLng? _origin;
  String? _errorMessage;
  _MosqueErrorAction? _errorAction;

  @override
  void initState() {
    super.initState();
    _loadNearbyMosques();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('nearbyMosques')),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.tr('retry'),
            onPressed: _loadNearbyMosques,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = context.l10n;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: AppSurfaceCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(_errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                if (_errorAction != null)
                  OutlinedButton.icon(
                    onPressed: _handleErrorAction,
                    icon: Icon(
                      _errorAction == _MosqueErrorAction.openLocationSettings
                          ? Icons.location_on_rounded
                          : Icons.settings_rounded,
                    ),
                    label: Text(
                      _errorAction == _MosqueErrorAction.openLocationSettings
                          ? l10n.tr('openLocationSettings')
                          : l10n.tr('openAppSettings'),
                    ),
                  ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _loadNearbyMosques,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.tr('retry')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_origin == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: AppSurfaceCard(
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.mosque_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.tr('mosquesFound', <String, String>{
                      'count': '${_mosques.length}',
                    }),
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 245,
              child: FlutterMap(
                options: MapOptions(initialCenter: _origin!, initialZoom: 13),
                children: <Widget>[
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.azan_app',
                    maxZoom: 19,
                  ),
                  MarkerLayer(
                    markers: <Marker>[
                      Marker(
                        point: _origin!,
                        width: 40,
                        height: 40,
                        child: Tooltip(
                          message: l10n.tr('yourLocation'),
                          child: const Icon(
                            Icons.my_location_rounded,
                            color: Color(0xFF1A73E8),
                            size: 26,
                          ),
                        ),
                      ),
                      ..._mosques.map(
                        (mosque) => Marker(
                          point: LatLng(mosque.latitude, mosque.longitude),
                          width: 42,
                          height: 42,
                          child: GestureDetector(
                            onTap: () => _openInMaps(mosque),
                            child: Icon(
                              Icons.mosque_rounded,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _mosques.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomPadding),
                    child: Text(
                      l10n.tr('noMosqueFound'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottomPadding),
                  itemCount: _mosques.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final mosque = _mosques[index];
                    final distanceLabel = _distanceFromOrigin(mosque);
                    return AppSurfaceCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () => _openInMaps(mosque),
                        title: Text(
                          mosque.name,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('${mosque.address}\n$distanceLabel'),
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.navigation_rounded),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _loadNearbyMosques() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _errorAction = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setError(
          message: 'Location services are disabled. Please enable GPS.',
          action: _MosqueErrorAction.openLocationSettings,
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _setError(
          message:
              'Location permission is required to find nearby mosques.',
          action: _MosqueErrorAction.openAppSettings,
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _setError(
          message:
              'Location permission is permanently denied. Open app settings to allow it.',
          action: _MosqueErrorAction.openAppSettings,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 15));

      final origin = LatLng(position.latitude, position.longitude);
      final mosques = await _mosqueService.fetchNearbyMosques(
        latitude: position.latitude,
        longitude: position.longitude,
        radiusMeters: 3000,
        keyword: 'mosque',
      );
      mosques.sort(
        (a, b) =>
            _distanceMeters(origin, a).compareTo(_distanceMeters(origin, b)),
      );

      if (!mounted) return;
      setState(() {
        _origin = origin;
        _mosques = mosques;
        _isLoading = false;
      });
    } catch (error) {
      final errorText = error.toString();
      final message = errorText.contains('Google Places API key is missing')
          ? 'Google Places API key is missing. Set GOOGLE_MAPS_API_KEY to continue.'
          : context.l10n.tr('failedLoadMosques');
      _setError(message: message);
    }
  }

  void _setError({required String message, _MosqueErrorAction? action}) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _mosques = <MosquePlace>[];
      _errorMessage = message;
      _errorAction = action;
    });
  }

  Future<void> _handleErrorAction() async {
    if (_errorAction == _MosqueErrorAction.openLocationSettings) {
      await Geolocator.openLocationSettings();
      await _loadNearbyMosques();
      return;
    }

    if (_errorAction == _MosqueErrorAction.openAppSettings) {
      await Geolocator.openAppSettings();
      await _loadNearbyMosques();
    }
  }

  String _distanceFromOrigin(MosquePlace mosque) {
    final origin = _origin;
    if (origin == null) return '';
    final meters = _distanceMeters(origin, mosque);
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  double _distanceMeters(LatLng origin, MosquePlace mosque) {
    return Geolocator.distanceBetween(
      origin.latitude,
      origin.longitude,
      mosque.latitude,
      mosque.longitude,
    );
  }

  Future<void> _openInMaps(MosquePlace mosque) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${mosque.latitude},${mosque.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open Google Maps.')),
    );
  }
}
