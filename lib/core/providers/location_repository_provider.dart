import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/location_repository_impl.dart';

final locationRepositoryProvider = Provider<LocationRepositoryImpl>((ref) {
  return LocationRepositoryImpl();
});
