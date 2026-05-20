import 'dart:math' as math;
import 'package:minum/src/features/user/data/models/user_model.dart';

class IntakeCalculator {
  double calculate({required UserModel user}) {
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
    double calculatedTotalNeed = finalBaseIntake;

    if (user.age != null) {
      if (user.age! < 30) {
        calculatedTotalNeed *= 1.05;
      } else if (user.age! > 65) {
        calculatedTotalNeed *= 1.10;
      }
    }

    double activityAdditiveMl = 0;
    switch (user.activityLevel) {
      case ActivityLevel.sedentary:
        activityAdditiveMl = 0;
      case ActivityLevel.light:
        activityAdditiveMl = 350;
      case ActivityLevel.moderate:
        activityAdditiveMl = 700;
      case ActivityLevel.active:
        activityAdditiveMl = 1050;
      case ActivityLevel.extraActive:
        activityAdditiveMl = 1400;
      case null:
        activityAdditiveMl = 0;
    }
    calculatedTotalNeed += activityAdditiveMl;

    if (user.healthConditions != null &&
        user.healthConditions!.isNotEmpty &&
        !user.healthConditions!.contains(HealthCondition.none)) {
      for (var condition in user.healthConditions!) {
        switch (condition) {
          case HealthCondition.pregnancy:
            calculatedTotalNeed *= 1.30;
          case HealthCondition.breastfeeding:
            calculatedTotalNeed *= 1.50;
          case HealthCondition.kidneyIssues:
            calculatedTotalNeed *= 0.90;
          case HealthCondition.heartConditions:
            calculatedTotalNeed *= 0.95;
          case HealthCondition.none:
            break;
        }
      }
    }

    if (user.selectedWeatherCondition != null) {
      switch (user.selectedWeatherCondition!) {
        case WeatherCondition.hot:
          calculatedTotalNeed *= 1.30;
        case WeatherCondition.hotAndHumid:
          calculatedTotalNeed *= 1.40;
        case WeatherCondition.cold:
          calculatedTotalNeed *= 0.95;
        case WeatherCondition.temperate:
          break;
      }
    }

    double finalGoalFromBeverages = calculatedTotalNeed * 0.80;
    finalGoalFromBeverages = finalGoalFromBeverages.clamp(1000.0, 10000.0);
    finalGoalFromBeverages = (finalGoalFromBeverages / 50).round() * 50.0;

    return finalGoalFromBeverages;
  }
}
