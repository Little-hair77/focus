import 'package:focus/features/profile/models/access_log.dart';

/// Contrato de persistência para registros de acesso.
abstract class AccessLogRepository {
  /// Adiciona um registro de acesso para o usuário informado.
  Future<void> addAccessLog(String userId, AccessLog accessLog);

  /// Retorna os acessos recentes do usuário informado.
  Future<List<AccessLog>> getRecentAccessLogs(String userId, {int limit = 10});
}
