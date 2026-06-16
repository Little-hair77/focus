class AccessLog {
  final String id;
  final DateTime accessedAt;
  final double? latitude;
  final double? longitude;

  const AccessLog({
    required this.id,
    required this.accessedAt,
    this.latitude,
    this.longitude,
  });

  bool get hasLocation => latitude != null && longitude != null;
}
