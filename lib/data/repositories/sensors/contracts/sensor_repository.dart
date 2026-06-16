/// Contrato para consultar sensores físicos do dispositivo.
abstract class SensorRepository {
  /// Indica se o dispositivo possui sensor de proximidade.
  Future<bool> hasProximitySensor();

  /// Emite mudanças de proximidade detectadas pelo sensor.
  Stream<bool> get onProximityChanged;
}
