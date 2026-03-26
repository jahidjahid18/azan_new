import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/core/localization/app_localizations.dart';
import 'package:azan_app/core/widgets/app_gradient_button.dart';
import 'package:azan_app/core/widgets/app_surface_card.dart';
import 'package:azan_app/features/mosque/data/models/mosque_place.dart';
import 'package:azan_app/features/mosque/data/mosque_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MosqueFinderScreen extends StatefulWidget {
  const MosqueFinderScreen({super.key});

  @override
  State<MosqueFinderScreen> createState() => _MosqueFinderScreenState();
}

class _MosqueFinderScreenState extends State<MosqueFinderScreen> {
  final MosqueService _mosqueService = MosqueService();
  late Future<List<MosquePlace>> _mosquesFuture;
  LatLng? _origin;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<AppController>();
    final location = controller.location;

    if (location == null) {
      _mosquesFuture = Future<List<MosquePlace>>.value(<MosquePlace>[]);
      return;
    }

    _origin = LatLng(location.latitude, location.longitude);
    _mosquesFuture = _mosqueService.fetchNearbyMosques(
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('nearbyMosques'))),
      body: FutureBuilder<List<MosquePlace>>(
        future: _mosquesFuture,
        builder: (context, snapshot) {
          if (_origin == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: AppSurfaceCard(
                  child: Text(
                    l10n.tr('setLocationFirst'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: AppSurfaceCard(
                  child: Text(
                    l10n.tr('failedLoadMosques'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          final mosques = snapshot.data ?? <MosquePlace>[];
          final markers = <Marker>{
            Marker(
              markerId: const MarkerId('you'),
              position: _origin!,
              infoWindow: InfoWindow(title: l10n.tr('yourLocation')),
            ),
            ...mosques.map(
              (mosque) => Marker(
                markerId: MarkerId(
                  '${mosque.latitude}_${mosque.longitude}_${mosque.name}',
                ),
                position: LatLng(mosque.latitude, mosque.longitude),
                onTap: () => _showMosqueDetails(mosque),
                infoWindow: InfoWindow(
                  title: mosque.name,
                  snippet: mosque.address,
                  onTap: () => _openInMaps(mosque),
                ),
              ),
            ),
          };

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
                            'count': '${mosques.length}',
                          }),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _origin!,
                        zoom: 13,
                      ),
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      markers: markers,
                    ),
                  ),
                ),
              ),
              if (mosques.isNotEmpty)
                SizedBox(
                  height: 190,
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      12,
                      10,
                      12,
                      10 + bottomPadding,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: mosques.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final mosque = mosques[index];
                      final distanceLabel = _distanceFromOrigin(mosque);
                      return SizedBox(
                        width: 280,
                        child: AppSurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                mosque.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                mosque.address,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const Spacer(),
                              Row(
                                children: <Widget>[
                                  Text(distanceLabel),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () => _showMosqueDetails(mosque),
                                    child: Text(l10n.tr('details')),
                                  ),
                                  const SizedBox(width: 6),
                                  SizedBox(
                                    height: 40,
                                    child: AppGradientButton(
                                      onPressed: () => _openInMaps(mosque),
                                      icon: Icons.navigation_rounded,
                                      label: l10n.tr('open'),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.fromLTRB(12, 10, 12, 12 + bottomPadding),
                  child: Text(l10n.tr('noMosqueFound')),
                ),
            ],
          );
        },
      ),
    );
  }

  String _distanceFromOrigin(MosquePlace mosque) {
    if (_origin == null) return '';
    final meters = Geolocator.distanceBetween(
      _origin!.latitude,
      _origin!.longitude,
      mosque.latitude,
      mosque.longitude,
    );
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  Future<void> _openInMaps(MosquePlace mosque) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${mosque.latitude},${mosque.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showMosqueDetails(MosquePlace mosque) {
    final distance = _distanceFromOrigin(mosque);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16 + MediaQuery.of(context).viewPadding.bottom,
          ),
          child: AppSurfaceCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  mosque.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(mosque.address),
                const SizedBox(height: 8),
                Text(
                  context.l10n.tr('distance', <String, String>{
                    'distance': distance,
                  }),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        label: Text(context.l10n.tr('close')),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppGradientButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _openInMaps(mosque);
                        },
                        icon: Icons.navigation_rounded,
                        label: context.l10n.tr('navigate'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
