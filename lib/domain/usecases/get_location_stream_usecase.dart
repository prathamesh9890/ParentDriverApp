import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../repository/location_repository.dart';

class GetLocationStreamUseCase {
  final LocationRepository repository;

  GetLocationStreamUseCase(this.repository);

  Stream<Map<String, dynamic>> call() => repository.getLocationStream();
}
