abstract class SensorRepository {
  Future<bool> hasProximitySensor();
  Stream<bool> get onProximityChanged;
}