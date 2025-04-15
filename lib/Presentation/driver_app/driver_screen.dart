import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'provider/driver_location_provider.dart';

class DriverScreen extends ConsumerStatefulWidget {
  const DriverScreen({super.key});

  @override
  ConsumerState<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends ConsumerState<DriverScreen> {
  late GoogleMapController _mapController;
  Marker? _busMarker;
  bool isSharing = false;
  StreamSubscription<LatLng>? locationSub;

  void _startSharingLocation() {
    isSharing = true;
    locationSub = ref.read(driverLocationProvider.notifier).startSharing().listen((loc) {
      setState(() {
        _busMarker = Marker(
          markerId: const MarkerId("bus"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          position: loc,
        );
        _mapController.animateCamera(CameraUpdate.newLatLng(loc));
      });
    });
  }

  void _stopSharingLocation() {
    isSharing = false;
    locationSub?.cancel();
    ref.read(driverLocationProvider.notifier).stopSharing();
  }

  @override
  void dispose() {
    locationSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initialPosition = ref.watch(driverLocationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Driver Location")),
      body: initialPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: initialPosition, zoom: 16),
            onMapCreated: (controller) => _mapController = controller,
            markers: _busMarker != null ? {_busMarker!} : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              icon: Icon(isSharing ? Icons.stop : Icons.play_arrow),
              label: Text(isSharing ? 'Stop Sharing Location' : 'Start Sharing Location'),
              onPressed: () {
                isSharing ? _stopSharingLocation() : _startSharingLocation();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: isSharing ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          )
        ],
      ),
    );
  }
}
