import 'package:focus/features/profile/models/access_log.dart';

abstract class AccessLogRepository {
  Future<void> addAccessLog(String userId, AccessLog accessLog);

  Future<List<AccessLog>> getRecentAccessLogs(String userId, {int limit = 10});
}
