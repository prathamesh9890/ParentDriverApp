import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'provider/parent_location_provider.dart';

class ParentScreen extends ConsumerWidget {
  const  ParentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(parentLocationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Live Bus Tracking")),
      body: locationAsync.when(
        data: (location) => GoogleMap(
          initialCameraPosition: CameraPosition(
            target: location,
            zoom: 16,
          ),
          markers: {
            Marker(
              markerId: const MarkerId("bus"),
              position: location,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            ),
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
