// lib/src/services/hydration_service.dart
import 'dart:math' as math; // For math.max and math.min
import 'package:minum/src/data/models/hydration_entry_model.dart';
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/data/repositories/hydration_repository.dart';
import 'package:minum/main.dart'; // For logger

/// A service layer for managing hydration data and business logic.
///
/// This class uses a [HydrationRepository] to interact with the data layer
/// and provides methods for adding, updating, deleting, and retrieving
/// hydration entries, as well as calculating recommended intake.
class HydrationService {
  final HydrationRepository _hydrationRepository;

  /// Creates a `HydrationService` instance.
  ///
  /// Requires a [hydrationRepository].
  HydrationService({
    required HydrationRepository hydrationRepository,
  }) : _hydrationRepository = hydrationRepository;

  /// Adds a new hydration entry.
  Future<void> addHydrationEntry({
    required String userId,
    required double amountMl,
    required DateTime timestamp,
    String? notes,
    String? source,
  }) async {
    try {
      final entry = HydrationEntry(
        userId: userId,
        amountMl: amountMl,
        timestamp: timestamp,
        notes: notes,
        source: source ?? 'manual',
      );
      await _hydrationRepository.addHydrationEntry(userId, entry);
      logger.i(
          "HydrationService: Entry added for user $userId, amount ${amountMl}ml.");
    } catch (e) {
      logger
          .e("HydrationService: Error adding hydration entry for $userId: $e");
      throw Exception("Failed to log water intake.");
    }
  }

  /// Updates an existing hydration entry.
  Future<void> updateHydrationEntry(String userId, HydrationEntry entry) async {
    try {
      await _hydrationRepository.updateHydrationEntry(userId, entry);
      logger.i(
          "HydrationService: Entry ${entry.id ?? entry.localDbId} updated for user $userId.");
    } catch (e) {
      logger.e(
          "HydrationService: Error updating entry ${entry.id ?? entry.localDbId} for $userId: $e");
      throw Exception("Failed to update water intake log.");
    }
  }

  /// Deletes a hydration entry.
  Future<void> deleteHydrationEntry(
      String userId, HydrationEntry entryToDelete) async {
    try {
      await _hydrationRepository.deleteHydrationEntry(userId, entryToDelete);
      logger.i(
          "HydrationService: Entry ${entryToDelete.id ?? entryToDelete.localDbId} delete initiated for user $userId.");
    } catch (e) {
      logger.e(
          "HydrationService: Error deleting entry ${entryToDelete.id ?? entryToDelete.localDbId} for $userId: $e");
      throw Exception("Failed to delete water intake log.");
    }
  }

  /// Retrieves a stream of hydration entries for a specific day.
  ///
  /// @return A stream of lists of `HydrationEntry` objects.
  Stream<List<HydrationEntry>> getHydrationEntriesForDay(
      String userId, DateTime date) {
    try {
      return _hydrationRepository.getHydrationEntriesForDay(userId, date);
    } catch (e) {
      logger.e(
          "HydrationService: Error fetching entries for day for $userId: $e");
      return Stream.value([]);
    }
  }

  /// Retrieves a stream of hydration entries for a date range.
  ///
  /// @return A stream of lists of `HydrationEntry` objects.
  Stream<List<HydrationEntry>> getHydrationEntriesForDateRange(
      String userId, DateTime startDate, DateTime endDate) {
    try {
      return _hydrationRepository.getHydrationEntriesForDateRange(
          userId, startDate, endDate);
    } catch (e) {
      logger.e(
          "HydrationService: Error fetching entries for date range for $userId: $e");
      return Stream.value([]);
    }
  }

  /// Calculates the total intake from a list of hydration entries.
  ///
  /// @return The total volume in milliliters.
  double calculateTotalIntake(List<HydrationEntry> entries) {
    if (entries.isEmpty) return 0.0;
    return entries.fold(0.0, (sum, entry) => sum + entry.amountMl);
  }

  /// Calculates the recommended daily water intake for a user based on their profile.
  ///
  /// The calculation considers weight, gender, age, activity level, health
  /// conditions, and weather.
  /// @return A `Future` that completes with the recommended intake in milliliters.
  Future<double> calculateRecommendedDailyIntake({
    required UserModel user,
  }) async {
    logger.i(
        "Calculating recommended intake for user: ${user.id}, Weight: ${user.weightKg}kg, Gender: ${user.gender}, Age: ${user.age}, Activity: ${user.activityLevel}, Weather: ${user.selectedWeatherCondition}, Health: ${user.healthConditions}");

    // 1. Base Calculation
    double baseIntakeWeight = 2000.0;
    if (user.weightKg != null && user.weightKg! > 0) {
      baseIntakeWeight = user.weightKg! * 33.0;
    }

    double baseIntakeGender = 2000.0;
    if (user.gender == Gender.male) {
      baseIntakeGender = 2500.0;
    } else if (user.gender == Gender.female) {
      baseIntakeGender = 2000.0;
    }

    double finalBaseIntake = math.max(baseIntakeWeight, baseIntakeGender);
    logger.d(
        "Base (Weight): ${baseIntakeWeight.toInt()}mL, Base (Gender): ${baseIntakeGender.toInt()}mL, Final Base: ${finalBaseIntake.toInt()}mL");

    double calculatedTotalNeed = finalBaseIntake;

    // 2. Age Adjustment
    if (user.age != null) {
      if (user.age! < 30) {
        calculatedTotalNeed *= 1.05;
        logger.d("Age < 30 adjustment (+5%): ${calculatedTotalNeed.toInt()}mL");
      } else if (user.age! > 65) {
        calculatedTotalNeed *= 1.10;
        logger
            .d("Age > 65 adjustment (+10%): ${calculatedTotalNeed.toInt()}mL");
      }
    }

    // 3. Activity Level Adjustment
    double activityAdditiveMl = 0;
    switch (user.activityLevel) {
      case ActivityLevel.sedentary:
        activityAdditiveMl = 0;
        break;
      case ActivityLevel.light:
        activityAdditiveMl = 350;
        break;
      case ActivityLevel.moderate:
        activityAdditiveMl = 700;
        break;
      case ActivityLevel.active:
        activityAdditiveMl = 1050;
        break;
      case ActivityLevel.extraActive:
        activityAdditiveMl = 1400;
        break;
      case null:
        activityAdditiveMl = 0;
        logger.d("Activity level not set, no additive adjustment.");
        break;
    }
    calculatedTotalNeed += activityAdditiveMl;
    logger.d(
        "Activity adjustment: Additive ${activityAdditiveMl.toInt()}mL. Intake after activity: ${calculatedTotalNeed.toInt()}mL");

    // 4. Health Conditions Adjustment
    if (user.healthConditions != null &&
        user.healthConditions!.isNotEmpty &&
        !user.healthConditions!.contains(HealthCondition.none)) {
      for (var condition in user.healthConditions!) {
        switch (condition) {
          case HealthCondition.pregnancy:
            calculatedTotalNeed *= 1.30;
            logger.d(
                "Health (Pregnancy) adjustment (+30%): ${calculatedTotalNeed.toInt()}mL");
            break;
          case HealthCondition.breastfeeding:
            calculatedTotalNeed *= 1.50;
            logger.d(
                "Health (Breastfeeding) adjustment (+50%): ${calculatedTotalNeed.toInt()}mL");
            break;
          case HealthCondition.kidneyIssues:
            calculatedTotalNeed *= 0.90;
            logger.d(
                "Health (Kidney) adjustment (-10%): ${calculatedTotalNeed.toInt()}mL - Advise Doctor Consultation");
            break;
          case HealthCondition.heartConditions:
            calculatedTotalNeed *= 0.95;
            logger.d(
                "Health (Heart) adjustment (-5%): ${calculatedTotalNeed.toInt()}mL - Advise Doctor Consultation");
            break;
          case HealthCondition.none:
            break;
        }
      }
    }

    // 5. Weather Adjustment
    if (user.selectedWeatherCondition != null) {
      switch (user.selectedWeatherCondition!) {
        case WeatherCondition.hot:
          calculatedTotalNeed *= 1.30;
          logger.d(
              "Weather (Hot) adjustment (+30%): ${calculatedTotalNeed.toInt()}mL");
          break;
        case WeatherCondition.hotAndHumid:
          calculatedTotalNeed *= 1.40;
          logger.d(
              "Weather (Hot & Humid) adjustment (+40%): ${calculatedTotalNeed.toInt()}mL");
          break;
        case WeatherCondition.cold:
          calculatedTotalNeed *= 0.95;
          logger.d(
              "Weather (Cold) adjustment (-5%): ${calculatedTotalNeed.toInt()}mL");
          break;
        case WeatherCondition.temperate:
          logger.d("Weather (Temperate) adjustment: None");
          break;
      }
    }

    // 6. Final Goal from Beverages (80% of total physiological need)
    double finalGoalFromBeverages = calculatedTotalNeed * 0.80;
    logger.d(
        "Total physiological water need (100%): ${calculatedTotalNeed.toInt()}mL. Target from beverages (80%): ${finalGoalFromBeverages.toInt()}mL");

    finalGoalFromBeverages = finalGoalFromBeverages.clamp(1000.0, 10000.0);
    finalGoalFromBeverages = (finalGoalFromBeverages / 50).round() * 50.0;

    logger.i(
        "HydrationService: Final Calculated Recommended Intake (from beverages) for user ${user.id}: ${finalGoalFromBeverages.toInt()}mL");

    return finalGoalFromBeverages;
  }
}
