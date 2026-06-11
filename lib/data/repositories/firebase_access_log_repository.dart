import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus/data/repositories/access_log_repository.dart';
import 'package:focus/features/profile/models/access_log.dart';

class FirebaseAccessLogRepository implements AccessLogRepository {
  final FirebaseFirestore _firestore;

  FirebaseAccessLogRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('access_logs');
  }

  @override
  Future<void> addAccessLog(String userId, AccessLog accessLog) async {
    await _collection(userId).doc(accessLog.id).set({
      'accessed_at': Timestamp.fromDate(accessLog.accessedAt),
      'latitude': accessLog.latitude,
      'longitude': accessLog.longitude,
    });
  }

  @override
  Future<List<AccessLog>> getRecentAccessLogs(
    String userId, {
    int limit = 10,
  }) async {
    final snapshot = await _collection(
      userId,
    ).orderBy('accessed_at', descending: true).limit(limit).get();

    return snapshot.docs.map((document) {
      final data = document.data();
      final accessedAt = data['accessed_at'];

      return AccessLog(
        id: document.id,
        accessedAt: accessedAt is Timestamp
            ? accessedAt.toDate()
            : DateTime.tryParse(accessedAt?.toString() ?? '') ?? DateTime.now(),
        latitude: (data['latitude'] as num?)?.toDouble(),
        longitude: (data['longitude'] as num?)?.toDouble(),
      );
    }).toList();
  }
}
