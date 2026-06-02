import 'permission_service.dart';

class MockPermissionService implements PermissionService {
  bool _locationGranted = true;

  @override
  Future<bool> hasLocationPermission() async {
    return _locationGranted;
  }

  @override
  Future<bool> requestLocationPermission() async {
    // Simula o tempo que o usuário levaria para clicar em "Permitir"
    await Future.delayed(const Duration(seconds: 500));
    _locationGranted = true;
    return _locationGranted;
  }

  @override
  Future<bool> hasSensorPermission() async {
    return true; // Sensores liberados por padrão no ambiente Mock/Web
  }
}