import 'package:permission_handler/permission_handler.dart';
import 'permission_service.dart';

class DevicePermissionService implements PermissionService {
  @override
  Future<bool> hasLocationPermission() async {
    return await Permission.location.isGranted;
  }

  @override
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  @override
  Future<bool> hasSensorPermission() async {
    // Sensores comuns de proximidade não exigem pop-up de permissão no Android
    return true;
  }
}