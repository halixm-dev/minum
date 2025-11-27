import 'dart:io';
import 'package:health/health.dart';
import 'package:minum/main.dart'; // For logger

/// Service to handle Health Connect integration.
class HealthService {
  final Health _health = Health();
  bool _isConfigured = false;

  /// Configures the Health service.
  /// Checks for Health Connect availability.
  Future<void> configure() async {
    if (!Platform.isAndroid) return;
    if (_isConfigured) return;

    try {
      HealthConnectSdkStatus? status =
          await _health.getHealthConnectSdkStatus();

      if (status == HealthConnectSdkStatus.sdkAvailable) {
        // configure() no longer takes arguments in newer versions or defaults correctly
        await _health.configure();
        _isConfigured = true;
        logger.i("HealthService: Configured to use Health Connect.");
      } else {
        logger.w(
            "HealthService: Health Connect not available (Status: $status).");
      }
    } catch (e) {
      logger.e("HealthService: Error configuring health service: $e");
    }
  }

  /// Checks if permissions are granted.
  Future<bool> hasPermissions() async {
    if (!Platform.isAndroid) return false;
    await configure();

    try {
      bool? hasPermissions = await _health.hasPermissions(
        [HealthDataType.WATER, HealthDataType.NUTRITION],
        permissions: [HealthDataAccess.READ_WRITE, HealthDataAccess.READ_WRITE],
      );
      return hasPermissions ?? false;
    } catch (e) {
      logger.e("HealthService: Error checking permissions: $e");
      return false;
    }
  }

  /// Requests permissions.
  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid) return false;
    await configure();

    try {
      // Check if Health Connect is installed
      HealthConnectSdkStatus? status =
          await _health.getHealthConnectSdkStatus();
      if (status != HealthConnectSdkStatus.sdkAvailable) {
        if (status ==
            HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired) {
          await _health.installHealthConnect();
        }
        return false;
      }

      bool requested = await _health.requestAuthorization(
        [HealthDataType.WATER, HealthDataType.NUTRITION],
        permissions: [HealthDataAccess.READ_WRITE, HealthDataAccess.READ_WRITE],
      );

      logger.i("HealthService: Permissions requested. Result: $requested");
      return requested;
    } catch (e) {
      logger.e("HealthService: Error requesting permissions: $e");
      return false;
    }
  }

  /// Reads hydration data from Health Connect for a given time range.
  Future<List<HealthDataPoint>> readHydrationData(
      DateTime startTime, DateTime endTime) async {
    if (!Platform.isAndroid) return [];
    await configure();

    try {
      // Fetch health data
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: [HealthDataType.WATER],
      );

      return healthData;
    } catch (e) {
      logger.e("HealthService: Error reading hydration data: $e");
      return [];
    }
  }

  /// Writes hydration data to Health Connect.
  Future<bool> writeHydrationData(double amountMl, DateTime timestamp,
      {String? clientRecordId}) async {
    if (!Platform.isAndroid) return false;
    await configure();

    try {
      if (!await hasPermissions()) {
        logger.w("HealthService: Permissions not granted. Cannot write.");
        return false;
      }

      // Health Connect expects water in Liters
      double amountLiters = amountMl / 1000.0;

      bool success = await _health.writeHealthData(
        value: amountLiters,
        type: HealthDataType.WATER,
        startTime: timestamp,
        endTime: timestamp.add(const Duration(minutes: 1)),
        recordingMethod: RecordingMethod.manual,
        clientRecordId: clientRecordId,
      );

      if (success) {
        logger.i(
            "HealthService: Successfully wrote ${amountLiters}L (${amountMl}ml) to Health Connect.");
      } else {
        logger.w("HealthService: Failed to write to Health Connect.");
      }
      return success;
    } catch (e) {
      logger.e("HealthService: Error writing hydration data: $e");
      return false;
    }
  }

  /// Deletes hydration data from Health Connect by time range.
  Future<bool> deleteHydrationData(DateTime startTime, DateTime endTime) async {
    if (!Platform.isAndroid) return false;
    await configure();

    try {
      if (!await hasPermissions()) {
        logger.w("HealthService: Permissions not granted. Cannot delete.");
        return false;
      }

      bool success = await _health.delete(
        type: HealthDataType.WATER,
        startTime: startTime,
        endTime: endTime,
      );

      if (success) {
        logger.i(
            "HealthService: Successfully deleted water data between $startTime and $endTime.");
      } else {
        logger.w(
            "HealthService: Failed to delete water data between $startTime and $endTime.");
      }
      return success;
    } catch (e) {
      logger.e("HealthService: Error deleting hydration data: $e");
      return false;
    }
  }

  /// Install Health Connect if not installed
  Future<void> installHealthConnect() async {
    await _health.installHealthConnect();
  }
}
