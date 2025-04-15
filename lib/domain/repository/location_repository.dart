abstract class LocationRepository {
  Future<void> updateLocation(double lat, double lng);
  Stream<Map<String, dynamic>> getLocationStream();
}
