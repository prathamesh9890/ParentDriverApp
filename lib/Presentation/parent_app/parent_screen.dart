import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'provider/parent_location_provider.dart';
import 'dart:ui' as ui;

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
    final ByteData data = await rootBundle.load('assets/bus.png');
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 160,  // 👈 Resize width
      targetHeight: 160, // 👈 Resize height
    );
    final frame = await codec.getNextFrame();
    final byteData = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    final resizedBytes = byteData!.buffer.asUint8List();

    _busIcon = BitmapDescriptor.fromBytes(resizedBytes);
  }

  // Future<void> _loadBusIcon() async {
  //   _busIcon = await BitmapDescriptor.fromAssetImage(
  //     const ImageConfiguration(size: Size(24, 24)), // 👈 Small icon size
  //     'assets/bus.png',
  //   );
  //   setState(() {}); // Trigger rebuild after icon is loaded
  // }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(parentLocationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Live Bus Tracker")),
      body: locationAsync.when(
        data: (loc) {
          // If first time, set marker
          if (_driverMarker == null) {
            _driverMarker = Marker(
              markerId: const MarkerId("driver"),
              position: loc,
              icon: _busIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              anchor: const Offset(0.5, 0.5),
              flat: true,
            );
            _lastPosition = loc;

            // Move camera initially
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(loc, 16),
            );
          }

          // Update marker when location changes
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
            initialCameraPosition: CameraPosition(target: loc, zoom: 16),
            onMapCreated: (controller) => _mapController = controller,
            markers: {_driverMarker!},
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error loading location: $e")),
      ),
    );
  }
}
