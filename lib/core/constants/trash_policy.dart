class TrashPolicy {
  /// Tempo que um item permanece na lixeira.
  static const retentionDays = 15;

  static const retentionPeriod = Duration(days: retentionDays);

  /// Retorna a data de expiração do item.
  static DateTime expiresAt(DateTime deletedAt) {
    return deletedAt.add(retentionPeriod);
  }

  /// Verifica se o item já expirou.
  static bool isExpired(DateTime deletedAt, DateTime now) {
    return !expiresAt(deletedAt).isAfter(now);
  }

  /// Calcula quantos dias restam até a exclusão definitiva.
  static int daysRemaining(DateTime deletedAt, DateTime now) {
    final remaining = expiresAt(deletedAt).difference(now);
    return (remaining.inHours / Duration.hoursPerDay).ceil().clamp(
      0,
      retentionDays,
    );
  }
}
