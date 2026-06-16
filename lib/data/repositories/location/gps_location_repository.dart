import 'package:geolocator/geolocator.dart';
import 'contracts/location_repository.dart';

/// Implementação baseada no pacote Geolocator para acesso ao GPS.
class GpsLocationRepository implements LocationRepository {
  /// Verifica se o serviço de localização está ativo no aparelho.
  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Obtém as coordenadas atuais com alta precisão.
  @override
  Future<Map<String, double>> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return {'latitude': position.latitude, 'longitude': position.longitude};
  }
}
