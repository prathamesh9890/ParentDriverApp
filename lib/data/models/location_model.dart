import '../../domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  LocationModel({required super.latitude, required super.longitude});

  factory LocationModel.fromJson(Map<dynamic, dynamic> json) {
    return LocationModel(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}
