import '../repository/location_repository.dart';

class UpdateLocationUseCase {
  final LocationRepository repository;

  UpdateLocationUseCase(this.repository);

  Future<void> call(double lat, double lng) {
    return repository.updateLocation(lat, lng);
  }
}
