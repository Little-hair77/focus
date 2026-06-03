import 'package:geolocator/geolocator.dart';
import 'contracts/location_repository.dart';

class GpsLocationRepository implements LocationRepository {
  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<Map<String, double>> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
    };
  }
}