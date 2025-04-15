import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'constants.dart';

class FirebaseService {
  final _db = FirebaseDatabase.instance.ref();

  Stream<LatLng> getLocationStream() {
    return _db.child(firebaseLocationPath).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return LatLng(data['latitude'], data['longitude']);
    });
  }

  Future<void> updateLocation(LatLng position) async {
    await _db.child(firebaseLocationPath).set({
      'latitude': position.latitude,
      'longitude': position.longitude,
    });
  }
}
