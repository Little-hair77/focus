import 'dart:async';
import './contracts/sensor_repository.dart';

/// Implementação simulada do sensor de proximidade.
class MockSensorRepository implements SensorRepository {
  /// Controlador usado para emitir mudanças simuladas.
  final _controller = StreamController<bool>.broadcast();

  /// Estado atual da proximidade simulada.
  bool _isNear = false;

  /// Fluxo de mudanças simuladas de proximidade.
  @override
  Stream<bool> get onProximityChanged => _controller.stream;

  /// Simula presença de sensor no ambiente mock.
  @override
  Future<bool> hasProximitySensor() async => true;

  /// Alterna o estado do sensor como se o celular tivesse virado.
  void simulateSensorTrigger() {
    _isNear = !_isNear;
    _controller.add(_isNear);
  }

  /// Libera o controlador do fluxo simulado.
  void dispose() {
    _controller.close();
  }
}
