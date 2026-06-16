/// Contrato para obtenção de informações de localização do dispositivo.
abstract class LocationRepository {
  Future<bool> isLocationServiceEnabled();

  Future<Map<String, double>> getCurrentLocation();
}
