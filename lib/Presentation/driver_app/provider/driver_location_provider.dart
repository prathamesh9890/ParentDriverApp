import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/providers/location_repository_provider.dart';
import '../../../domain/usecases/update_location_usecase.dart';

final driverLocationProvider =
StateNotifierProvider<DriverLocationNotifier, LatLng?>((ref) {
  final updateUseCase = UpdateLocationUseCase(ref.watch(locationRepositoryProvider));
  return DriverLocationNotifier(updateUseCase);
});

class DriverLocationNotifier extends StateNotifier<LatLng?> {
  final UpdateLocationUseCase _updateUseCase;
  StreamSubscription<Position>? _positionStream;

  DriverLocationNotifier(this._updateUseCase) : super(null) {
    _initCurrentLocation();
  }
  Future<void> _initCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        // Permission still denied, can't proceed
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition();
    state = LatLng(position.latitude, position.longitude);
  }


  // Future<void> _initCurrentLocation() async {
  //   final position = await Geolocator.getCurrentPosition();
  //   state = LatLng(position.latitude, position.longitude);
  // }

  Stream<LatLng> startSharing() {
    final locationStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    _positionStream = locationStream.listen((position) {
      final latLng = LatLng(position.latitude, position.longitude);
      state = latLng;
      _updateUseCase(latLng.latitude, latLng.longitude);
    });

    return locationStream.map((position) => LatLng(position.latitude, position.longitude));
  }

  void stopSharing() {
    _positionStream?.cancel();
  }
}
