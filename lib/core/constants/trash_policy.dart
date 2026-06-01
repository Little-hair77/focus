class TrashPolicy {
  static const retentionDays = 15;
  static const retentionPeriod = Duration(days: retentionDays);

  static DateTime expiresAt(DateTime deletedAt) {
    return deletedAt.add(retentionPeriod);
  }

  static bool isExpired(DateTime deletedAt, DateTime now) {
    return !expiresAt(deletedAt).isAfter(now);
  }

  static int daysRemaining(DateTime deletedAt, DateTime now) {
    final remaining = expiresAt(deletedAt).difference(now);
    return (remaining.inHours / Duration.hoursPerDay).ceil().clamp(
      0,
      retentionDays,
    );
  }
}
