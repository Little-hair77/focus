import 'dart:async';
import './contracts/sensor_repository.dart';

class MockSensorRepository implements SensorRepository {
  final _controller = StreamController<bool>.broadcast();
  bool _isNear = false;

  @override
  Stream<bool> get onProximityChanged => _controller.stream;

  @override
  Future<bool> hasProximitySensor() async => true;

  // Método para chamar no Chrome clicando em um botão e fingir que o celular virou
  void simulateSensorTrigger() {
    _isNear = !_isNear;
    _controller.add(_isNear);
  }

  void dispose() {
    _controller.close();
  }
}