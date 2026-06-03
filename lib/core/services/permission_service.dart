abstract class PermissionService {
  /// Verifica se o usuário já deu permissão para acessar a localização
  Future<bool> hasLocationPermission();

  /// Solicita ao sistema operacional a permissão de localização
  Future<bool> requestLocationPermission();

  /// Checa/Solicita permissão para sensores de hardware, se necessário
  Future<bool> hasSensorPermission();
}