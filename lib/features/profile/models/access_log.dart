/// Registro de acesso usado na auditoria do perfil.
class AccessLog {
  /// Identificador único do registro.
  final String id;

  /// Momento em que o acesso foi registrado.
  final DateTime accessedAt;

  /// Latitude do acesso, quando disponível.
  final double? latitude;

  /// Longitude do acesso, quando disponível.
  final double? longitude;

  const AccessLog({
    required this.id,
    required this.accessedAt,
    this.latitude,
    this.longitude,
  });

  /// Indica se o registro possui coordenadas completas.
  bool get hasLocation => latitude != null && longitude != null;
}
