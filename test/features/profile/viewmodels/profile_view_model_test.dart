import 'package:flutter_test/flutter_test.dart';
import 'package:focus/data/repositories/access_log_repository.dart';
import 'package:focus/features/profile/models/access_log.dart';
import 'package:focus/features/profile/viewmodels/profile_view_model.dart';
import 'package:mocktail/mocktail.dart';

class MockAccessLogRepository extends Mock implements AccessLogRepository {}

void main() {
  late MockAccessLogRepository repository;
  late ProfileViewModel viewModel;

  setUp(() {
    repository = MockAccessLogRepository();
    viewModel = ProfileViewModel(accessLogRepository: repository);
  });

  test('carrega os acessos recentes ao sincronizar o usuário', () async {
    final accessLogs = [
      AccessLog(
        id: 'access-1',
        accessedAt: DateTime(2026, 6, 11, 10, 30),
        latitude: -14.2239,
        longitude: -42.7692,
      ),
    ];
    when(
      () => repository.getRecentAccessLogs('user-1'),
    ).thenAnswer((_) async => accessLogs);

    viewModel.syncUser('user-1');
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.accessLogs, accessLogs);
    expect(viewModel.isLoadingAccessLogs, isFalse);
    expect(viewModel.accessLogsError, isNull);
  });

  test('recarrega os acessos quando a versão da auditoria muda', () async {
    when(
      () => repository.getRecentAccessLogs('user-1'),
    ).thenAnswer((_) async => []);

    viewModel.syncUser('user-1');
    await Future<void>.delayed(Duration.zero);
    viewModel.syncUser('user-1', accessLogVersion: 1);
    await Future<void>.delayed(Duration.zero);

    verify(() => repository.getRecentAccessLogs('user-1')).called(2);
  });
}
