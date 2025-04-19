import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'provider/parent_location_provider.dart';

class ParentScreen extends ConsumerStatefulWidget {
  const ParentScreen({super.key});

  @override
  ConsumerState<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends ConsumerState<ParentScreen> {
  GoogleMapController? _mapController;
  Marker? _driverMarker;
  LatLng? _lastPosition;
  BitmapDescriptor? _busIcon;
  @override
  void initState() {
    super.initState();
    _loadBusIcon();
  }
  Future<void> _loadBusIcon() async {
    _busIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(10, 10


      )),
      'assets/img.png',
    );
  }
  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(parentLocationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Live Bus Tracker")),
      body: locationAsync.when(
        data: (loc) {
          // If first time, set marker immediately
          if (_driverMarker == null) {
            _driverMarker = Marker(
              markerId: const MarkerId("driver"),
              position: loc,
              // icon: BitmapDescriptor.defaultMarkerWithHue(
              //     BitmapDescriptor.hueRed),
              icon: _busIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              anchor: const Offset(0.5, 0.5),
              flat: true,
            );
            _lastPosition = loc;
            // Move camera on first load
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(loc, 16),
            );
          }

          // Animate marker & camera when position changes
          if (_lastPosition != loc) {
            _driverMarker = _driverMarker!.copyWith(
              positionParam: loc,
            );

            _mapController?.animateCamera(
              CameraUpdate.newLatLng(loc),
            );
            _lastPosition = loc;
          }

          return GoogleMap(
            initialCameraPosition:
            CameraPosition(target: loc, zoom: 16),
            onMapCreated: (controller) => _mapController = controller,
            markers: {_driverMarker!},
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text("Error loading location: $e")),
      ),
    );
  }
}
