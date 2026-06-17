import 'package:permission_handler/permission_handler.dart';
import 'permission_service.dart';

/// Implementação real de permissões usando os recursos do dispositivo.
class DevicePermissionService implements PermissionService {
  /// Verifica se a permissão de localização já foi concedida.
  @override
  Future<bool> hasLocationPermission() async {
    return await Permission.location.isGranted;
  }

  /// Solicita a permissão de localização ao sistema operacional.
  @override
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Verifica permissões necessárias para sensores do dispositivo.
  @override
  Future<bool> hasSensorPermission() async {
    // Sensores comuns de proximidade não exigem pop-up de permissão no Android
    return true;
  }
}
