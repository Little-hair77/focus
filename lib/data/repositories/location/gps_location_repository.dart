import 'package:geolocator/geolocator.dart';
import 'contracts/location_repository.dart';

class GpsLocationRepository implements LocationRepository {
  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<Map<String, double>> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return {'latitude': position.latitude, 'longitude': position.longitude};
  }
}
