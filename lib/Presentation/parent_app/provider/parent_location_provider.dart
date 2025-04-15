import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/providers/location_repository_provider.dart';

final parentLocationProvider = StreamProvider<LatLng>((ref) {
  final repo = ref.watch(locationRepositoryProvider);
  return repo.getLocationStream().map((data) {
    final lat = data['latitude'] as double;
    final lng = data['longitude'] as double;
    return LatLng(lat, lng);
  });
});
