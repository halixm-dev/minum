// lib/src/services/hydration_service.dart
import 'dart:math' as math; // For math.max and math.min
import 'package:minum/src/data/models/hydration_entry_model.dart';
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/data/repositories/hydration_repository.dart';
import 'package:minum/main.dart'; // For logger

class HydrationService {
  final HydrationRepository _hydrationRepository;

  HydrationService({
    required HydrationRepository hydrationRepository,
  }) : _hydrationRepository = hydrationRepository;

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
      logger.i("HydrationService: Entry added for user $userId, amount ${amountMl}ml.");
    } catch (e) {
      logger.e("HydrationService: Error adding hydration entry for $userId: $e");
      throw Exception("Failed to log water intake.");
    }
  }

  Future<void> updateHydrationEntry(String userId, HydrationEntry entry) async {
    try {
      await _hydrationRepository.updateHydrationEntry(userId, entry);
      logger.i("HydrationService: Entry ${entry.id ?? entry.localDbId} updated for user $userId.");
    } catch (e) {
      logger.e("HydrationService: Error updating entry ${entry.id ?? entry.localDbId} for $userId: $e");
      throw Exception("Failed to update water intake log.");
    }
  }

  Future<void> deleteHydrationEntry(String userId, HydrationEntry entryToDelete) async {
    try {
      await _hydrationRepository.deleteHydrationEntry(userId, entryToDelete);
      logger.i("HydrationService: Entry ${entryToDelete.id ?? entryToDelete.localDbId} delete initiated for user $userId.");
    } catch (e) {
      logger.e("HydrationService: Error deleting entry ${entryToDelete.id ?? entryToDelete.localDbId} for $userId: $e");
      throw Exception("Failed to delete water intake log.");
    }
  }

  Stream<List<HydrationEntry>> getHydrationEntriesForDay(String userId, DateTime date) {
    try {
      return _hydrationRepository.getHydrationEntriesForDay(userId, date);
    } catch (e) {
      logger.e("HydrationService: Error fetching entries for day for $userId: $e");
      return Stream.value([]);
    }
  }

  Stream<List<HydrationEntry>> getHydrationEntriesForDateRange(
      String userId, DateTime startDate, DateTime endDate) {
    try {
      return _hydrationRepository.getHydrationEntriesForDateRange(userId, startDate, endDate);
    } catch (e) {
      logger.e("HydrationService: Error fetching entries for date range for $userId: $e");
      return Stream.value([]);
    }
  }

  double calculateTotalIntake(List<HydrationEntry> entries) {
    if (entries.isEmpty) return 0.0;
    return entries.fold(0.0, (sum, entry) => sum + entry.amountMl);
  }

  Future<double> calculateRecommendedDailyIntake({
    required UserModel user,
  }) async {
    logger.i("Calculating recommended intake for user: ${user.id}, Weight: ${user.weightKg}kg, Gender: ${user.gender}, Age: ${user.age}, Activity: ${user.activityLevel}, Weather: ${user.selectedWeatherCondition}, Health: ${user.healthConditions}");

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
    logger.d("Base (Weight): ${baseIntakeWeight.toInt()}mL, Base (Gender): ${baseIntakeGender.toInt()}mL, Final Base: ${finalBaseIntake.toInt()}mL");

    double calculatedTotalNeed = finalBaseIntake;

    // 2. Age Adjustment
    if (user.age != null) {
      if (user.age! < 30) {
        calculatedTotalNeed *= 1.05;
        logger.d("Age < 30 adjustment (+5%): ${calculatedTotalNeed.toInt()}mL");
      } else if (user.age! > 65) {
        calculatedTotalNeed *= 1.10;
        logger.d("Age > 65 adjustment (+10%): ${calculatedTotalNeed.toInt()}mL");
      }
    }

    // 3. Activity Level Adjustment (Additive Approach)
    // These are suggested additive values and can be further tuned.
    // They represent additional daily fluid needs beyond baseline for sustained activity levels.
    double activityAdditiveMl = 0;
    switch (user.activityLevel) {
      case ActivityLevel.sedentary:
        activityAdditiveMl = 0; // No significant extra activity
        break;
      case ActivityLevel.light: // e.g., light exercise/sports 1-3 days/week
        activityAdditiveMl = 350; // Approx. +1.5 cups
        break;
      case ActivityLevel.moderate: // e.g., moderate exercise/sports 3-5 days/week
        activityAdditiveMl = 700; // Approx. +3 cups
        break;
      case ActivityLevel.active: // e.g., hard exercise/sports 6-7 days a week
        activityAdditiveMl = 1050; // Approx. +4.5 cups
        break;
      case ActivityLevel.extraActive: // e.g., very hard exercise/sports & physical job or 2x training
        activityAdditiveMl = 1400; // Approx. +6 cups
        break;
      case null:
        activityAdditiveMl = 0; // Default to no extra if not set
        logger.d("Activity level not set, no additive adjustment.");
        break;
    }
    calculatedTotalNeed += activityAdditiveMl;
    logger.d("Activity adjustment: Additive ${activityAdditiveMl.toInt()}mL. Intake after activity: ${calculatedTotalNeed.toInt()}mL");

    // 4. Health Conditions Adjustment
    if (user.healthConditions != null && user.healthConditions!.isNotEmpty && !user.healthConditions!.contains(HealthCondition.none)) {
      for (var condition in user.healthConditions!) {
        switch (condition) {
          case HealthCondition.pregnancy:
            calculatedTotalNeed *= 1.30;
            logger.d("Health (Pregnancy) adjustment (+30%): ${calculatedTotalNeed.toInt()}mL");
            break;
          case HealthCondition.breastfeeding:
            calculatedTotalNeed *= 1.50;
            logger.d("Health (Breastfeeding) adjustment (+50%): ${calculatedTotalNeed.toInt()}mL");
            break;
          case HealthCondition.kidneyIssues:
            calculatedTotalNeed *= 0.90;
            logger.d("Health (Kidney) adjustment (-10%): ${calculatedTotalNeed.toInt()}mL - Advise Doctor Consultation");
            break;
          case HealthCondition.heartConditions:
            calculatedTotalNeed *= 0.95;
            logger.d("Health (Heart) adjustment (-5%): ${calculatedTotalNeed.toInt()}mL - Advise Doctor Consultation");
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
          logger.d("Weather (Hot) adjustment (+30%): ${calculatedTotalNeed.toInt()}mL");
          break;
        case WeatherCondition.hotAndHumid:
          calculatedTotalNeed *= 1.40;
          logger.d("Weather (Hot & Humid) adjustment (+40%): ${calculatedTotalNeed.toInt()}mL");
          break;
        case WeatherCondition.cold:
          calculatedTotalNeed *= 0.95;
          logger.d("Weather (Cold) adjustment (-5%): ${calculatedTotalNeed.toInt()}mL");
          break;
        case WeatherCondition.temperate:
          logger.d("Weather (Temperate) adjustment: None");
          break;
      }
    }

    // 6. Final Goal from Beverages (80% of total physiological need)
    double finalGoalFromBeverages = calculatedTotalNeed * 0.80;
    logger.d("Total physiological water need (100%): ${calculatedTotalNeed.toInt()}mL. Target from beverages (80%): ${finalGoalFromBeverages.toInt()}mL");

    finalGoalFromBeverages = finalGoalFromBeverages.clamp(1000.0, 10000.0);
    finalGoalFromBeverages = (finalGoalFromBeverages / 50).round() * 50.0;

    logger.i("HydrationService: Final Calculated Recommended Intake (from beverages) for user ${user.id}: ${finalGoalFromBeverages.toInt()}mL");

    return finalGoalFromBeverages;
  }
}
