import './contracts/location_repository.dart';

class MockLocationRepository implements LocationRepository {
  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<Map<String, double>> getCurrentLocation() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'latitude': -14.2239, // Guanambi
      'longitude': -42.7692,
    };
  }
}
