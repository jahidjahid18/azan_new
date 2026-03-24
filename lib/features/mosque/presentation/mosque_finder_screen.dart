import 'package:azan_app/core/state/app_controller.dart';
import 'package:azan_app/features/mosque/data/models/mosque_place.dart';
import 'package:azan_app/features/mosque/data/mosque_service.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Mosques')),
      body: FutureBuilder<List<MosquePlace>>(
        future: _mosquesFuture,
        builder: (context, snapshot) {
          if (_origin == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Set your location first in Settings to use Mosque Finder.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Failed to load nearby mosques. Please try again.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final mosques = snapshot.data ?? <MosquePlace>[];
          final markers = <Marker>{
            Marker(
              markerId: const MarkerId('you'),
              position: _origin!,
              infoWindow: const InfoWindow(title: 'Your location'),
            ),
            ...mosques.map(
              (mosque) => Marker(
                markerId: MarkerId(
                  '${mosque.latitude}_${mosque.longitude}_${mosque.name}',
                ),
                position: LatLng(mosque.latitude, mosque.longitude),
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
              Expanded(
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
              if (mosques.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('No nearby mosque found in selected radius.'),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openInMaps(MosquePlace mosque) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${mosque.latitude},${mosque.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
