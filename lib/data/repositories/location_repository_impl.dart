import 'package:firebase_database/firebase_database.dart';
import '../../domain/repository/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final dbRef = FirebaseDatabase.instance.ref('driver_location');

  @override
  Future<void> updateLocation(double lat, double lng) async {
    await dbRef.set({'latitude': lat, 'longitude': lng});
  }

  @override
  Stream<Map<String, dynamic>> getLocationStream() {
    return dbRef.onValue.map((event) {
      final data = event.snapshot.value as Map;
      return {
        'latitude': data['latitude'],
        'longitude': data['longitude'],
      };
    });
  }
}
