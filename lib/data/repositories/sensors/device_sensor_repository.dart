import 'package:proximity_sensor/proximity_sensor.dart';
import 'contracts/sensor_repository.dart';

/// Implementação real do sensor de proximidade do dispositivo.
class DeviceSensorRepository implements SensorRepository {
  /// Indica suporte ao sensor de proximidade.
  @override
  Future<bool> hasProximitySensor() async {
    return true;
  }

  /// Emite verdadeiro quando o sensor detecta proximidade.
  @override
  Stream<bool> get onProximityChanged {
    return ProximitySensor.events.map((event) => event > 0);
  }
}
