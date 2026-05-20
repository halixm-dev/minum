import 'package:health/health.dart';

abstract class IHealthService {
  Future<void> configure();
  Future<bool> hasPermissions();
  Future<bool> requestPermissions();
  Future<List<HealthDataPoint>> readHydrationData(DateTime startTime, DateTime endTime);
  Future<bool> writeHydrationData(double amountMl, DateTime timestamp, {String? clientRecordId});
  Future<bool> deleteHydrationData(DateTime startTime, DateTime endTime);
  Future<void> installHealthConnect();
}
