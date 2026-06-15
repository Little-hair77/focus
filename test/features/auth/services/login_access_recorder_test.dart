import 'package:flutter_test/flutter_test.dart';
import 'package:focus/core/services/permission_service.dart';
import 'package:focus/data/repositories/access_log_repository.dart';
import 'package:focus/data/repositories/location/contracts/location_repository.dart';
import 'package:focus/features/auth/services/login_access_recorder.dart';
import 'package:focus/features/profile/models/access_log.dart';
import 'package:mocktail/mocktail.dart';

class MockPermissionService extends Mock implements PermissionService {}

class MockLocationRepository extends Mock implements LocationRepository {}

class MockAccessLogRepository extends Mock implements AccessLogRepository {}

void main() {
  late MockPermissionService permissionService;
  late MockLocationRepository locationRepository;
  late MockAccessLogRepository accessLogRepository;
  final accessedAt = DateTime(2026, 6, 11, 10, 30);

  setUpAll(() {
    registerFallbackValue(
      AccessLog(id: 'fallback', accessedAt: DateTime(2026)),
    );
  });

  setUp(() {
    permissionService = MockPermissionService();
    locationRepository = MockLocationRepository();
    accessLogRepository = MockAccessLogRepository();
    when(
      () => accessLogRepository.addAccessLog(any(), any()),
    ).thenAnswer((_) async {});
  });

  test(
    'registra data, latitude e longitude quando o GPS está disponível',
    () async {
      when(
        () => permissionService.hasLocationPermission(),
      ).thenAnswer((_) async => true);
      when(
        () => locationRepository.isLocationServiceEnabled(),
      ).thenAnswer((_) async => true);
      when(
        () => locationRepository.getCurrentLocation(),
      ).thenAnswer((_) async => {'latitude': -14.2239, 'longitude': -42.7692});

      final recorder = LoginAccessRecorder(
        permissionService: permissionService,
        locationRepository: locationRepository,
        accessLogRepository: accessLogRepository,
        now: () => accessedAt,
      );

      await recorder.record('user-1');

      final captured =
          verify(
                () => accessLogRepository.addAccessLog('user-1', captureAny()),
              ).captured.single
              as AccessLog;
      expect(captured.accessedAt, accessedAt);
      expect(captured.latitude, -14.2239);
      expect(captured.longitude, -42.7692);
    },
  );

  test(
    'registra o acesso sem coordenadas quando a permissão é negada',
    () async {
      when(
        () => permissionService.hasLocationPermission(),
      ).thenAnswer((_) async => false);
      when(
        () => permissionService.requestLocationPermission(),
      ).thenAnswer((_) async => false);

      final recorder = LoginAccessRecorder(
        permissionService: permissionService,
        locationRepository: locationRepository,
        accessLogRepository: accessLogRepository,
        now: () => accessedAt,
      );

      await recorder.record('user-1');

      final captured =
          verify(
                () => accessLogRepository.addAccessLog('user-1', captureAny()),
              ).captured.single
              as AccessLog;
      expect(captured.hasLocation, isFalse);
      verifyNever(() => locationRepository.getCurrentLocation());
    },
  );
}
