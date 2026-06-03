import 'package:proximity_sensor/proximity_sensor.dart';
import 'contracts/sensor_repository.dart';

class DeviceSensorRepository implements SensorRepository {
  @override
  Future<bool> hasProximitySensor() async {
    return true;
  }

  @override
  Stream<bool> get onProximityChanged {
    return ProximitySensor.events.map((event) => event > 0);
  }
}