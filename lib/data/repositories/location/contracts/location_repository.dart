abstract class LocationRepository{
  Future<bool> isLocationServiceEnabled();
  Future<Map<String, double>> getCurrentLocation();
}