import 'permission_service.dart';

/// Implementação simulada de permissões para web, testes e desenvolvimento.
class MockPermissionService implements PermissionService {
  /// Estado local que representa a permissão de localização no mock.
  bool _locationGranted = true;

  /// Retorna o estado atual da permissão simulada de localização.
  @override
  Future<bool> hasLocationPermission() async {
    return _locationGranted;
  }

  /// Simula a solicitação de permissão de localização.
  @override
  Future<bool> requestLocationPermission() async {
    // Simula o tempo que o usuário levaria para clicar em "Permitir"
    await Future.delayed(const Duration(seconds: 500));
    _locationGranted = true;
    return _locationGranted;
  }

  /// Retorna permissão positiva para sensores no ambiente mock.
  @override
  Future<bool> hasSensorPermission() async {
    return true; // Sensores liberados por padrão no ambiente Mock/Web
  }
}
