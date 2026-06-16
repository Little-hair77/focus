import 'package:flutter/foundation.dart';
import 'package:focus/core/services/permission_service.dart';
import 'package:focus/data/repositories/access_log_repository.dart';
import 'package:focus/data/repositories/location/contracts/location_repository.dart';
import 'package:focus/features/profile/models/access_log.dart';
import 'package:uuid/uuid.dart';

class LoginAccessRecorder {
  final PermissionService _permissionService;
  final LocationRepository _locationRepository;
  final AccessLogRepository _accessLogRepository;
  final Uuid _uuid;
  final DateTime Function() _now;

  LoginAccessRecorder({
    required PermissionService permissionService,
    required LocationRepository locationRepository,
    required AccessLogRepository accessLogRepository,
    Uuid uuid = const Uuid(),
    DateTime Function()? now,
  }) : _permissionService = permissionService,
       _locationRepository = locationRepository,
       _accessLogRepository = accessLogRepository,
       _uuid = uuid,
       _now = now ?? DateTime.now;

  Future<void> record(String userId) async {
    final accessedAt = _now();
    double? latitude;
    double? longitude;

    try {
      var hasPermission = await _permissionService.hasLocationPermission();
      if (!hasPermission) {
        hasPermission = await _permissionService.requestLocationPermission();
      }

      if (hasPermission &&
          await _locationRepository.isLocationServiceEnabled()) {
        final location = await _locationRepository.getCurrentLocation();
        latitude = location['latitude'];
        longitude = location['longitude'];
      }
    } catch (error) {
      debugPrint('Não foi possível obter a localização do login: $error');
    }

    await _accessLogRepository.addAccessLog(
      userId,
      AccessLog(
        id: _uuid.v4(),
        accessedAt: accessedAt,
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }
}
