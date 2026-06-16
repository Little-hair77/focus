import './contracts/location_repository.dart';

/// Implementação simulada de localização para testes e web.
class MockLocationRepository implements LocationRepository {
  /// Simula serviço de localização sempre habilitado.
  @override
  Future<bool> isLocationServiceEnabled() async => true;

  /// Retorna coordenadas fixas para ambiente mock.
  @override
  Future<Map<String, double>> getCurrentLocation() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'latitude': -14.2239, // Guanambi
      'longitude': -42.7692,
    };
  }
}
