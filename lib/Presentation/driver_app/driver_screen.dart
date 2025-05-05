import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'provider/driver_location_provider.dart';
import 'dart:ui' as ui;

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
  BitmapDescriptor? _busIcon;
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};

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
  //
  // Future<void> _loadBusIcon() async {
  //   _busIcon = await BitmapDescriptor.fromAssetImage(
  //     const ImageConfiguration(size: Size(24, 24)), // 👈 Small icon size
  //     'assets/bus.png',
  //   );
  // }

  void _startSharingLocation() {
    isSharing = true;

    locationSub = ref.read(driverLocationProvider.notifier).startSharing().listen((loc) {
      setState(() {
        // Add current location to polyline path
        polylineCoordinates.add(loc);

        // Update polylines set
        _polylines = {
          Polyline(
            polylineId: const PolylineId("route"),
            color: Colors.blue,
            width: 5,
            points: polylineCoordinates,
          )
        };

        // Update bus marker position
        _busMarker = Marker(
          markerId: const MarkerId("bus"),
          position: loc,
          icon: _busIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), // fallback if icon not loaded
          anchor: Offset(0.5, 0.5),
          rotation: 0,
          flat: true,
        );

        // Move the camera to the new position
        _mapController.animateCamera(CameraUpdate.newLatLng(loc));
      });
    });
  }

  void _stopSharingLocation() {
    isSharing = false;
    locationSub?.cancel();
    ref.read(driverLocationProvider.notifier).stopSharing();
    setState(() {
      polylineCoordinates.clear();
      _polylines.clear();
    });
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
            polylines: _polylines, // ✅ Add this line
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
          ),
        ],
      ),
    );
  }
}
