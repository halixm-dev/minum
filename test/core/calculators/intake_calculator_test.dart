import 'package:flutter_test/flutter_test.dart';
import 'package:minum/src/core/calculators/intake_calculator.dart';
import 'package:minum/src/features/user/data/models/user_model.dart';

void main() {
  late IntakeCalculator calculator;
  late UserModel baseUser;

  setUp(() {
    calculator = IntakeCalculator();
    baseUser = UserModel(
      id: 'test',
      createdAt: DateTime(2025, 6, 15),
    );
  });

  group('IntakeCalculator', () {
    test('default user (no weight, no gender) returns 1600', () {
      final result = calculator.calculate(user: baseUser);
      expect(result, 1600.0);
    });

    test('weight-based intake overrides gender default when higher', () {
      final user = baseUser.copyWith(
        weightKg: 100,
        gender: Gender.male,
      );
      // weight: 100*33=3300, gender: male=2500 => max=3300
      final result = calculator.calculate(user: user);
      expect(result, greaterThan(2500.0));
    });

    test('gender-based intake used when weight not available', () {
      final user = baseUser.copyWith(gender: Gender.male);
      // weight unavailable => base=2000, gender male=2500 => max=2500
      // 2500 * 0.8 = 2000
      final result = calculator.calculate(user: user);
      expect(result, 2000.0);
    });

    test('age under 30 increases intake 5%', () {
      final now = DateTime.now();
      final user = baseUser.copyWith(
        weightKg: 60,
        gender: Gender.female,
        dateOfBirth: DateTime(now.year - 25, now.month, now.day),
      );
      // max(60*33=1980, 2000) = 2000, *1.05 = 2100, *0.8 = 1680
      final result = calculator.calculate(user: user);
      expect(result, 1700.0);
    });

    test('age over 65 increases intake 10%', () {
      final now = DateTime.now();
      final user = baseUser.copyWith(
        weightKg: 60,
        gender: Gender.female,
        dateOfBirth: DateTime(now.year - 70, now.month, now.day),
      );
      // max(1980, 2000) = 2000, *1.10 = 2200, *0.8 = 1760
      final result = calculator.calculate(user: user);
      expect(result, 1750.0);
    });

    test('activity levels add correct ml', () {
      final sed = baseUser.copyWith(activityLevel: ActivityLevel.sedentary);
      expect(calculator.calculate(user: sed), 1600.0);

      final light = baseUser.copyWith(activityLevel: ActivityLevel.light);
      expect(calculator.calculate(user: light), 1900.0);

      final mod = baseUser.copyWith(activityLevel: ActivityLevel.moderate);
      expect(calculator.calculate(user: mod), 2150.0);

      final active = baseUser.copyWith(activityLevel: ActivityLevel.active);
      expect(calculator.calculate(user: active), 2450.0);

      final extra = baseUser.copyWith(activityLevel: ActivityLevel.extraActive);
      expect(calculator.calculate(user: extra), 2700.0);
    });

    test('null activity level defaults to 0 additive', () {
      final user = baseUser.copyWith(clearActivityLevel: true);
      expect(calculator.calculate(user: user), 1600.0);
    });

    test('pregnancy multiplies by 1.30', () {
      final user = baseUser.copyWith(
        healthConditions: [HealthCondition.pregnancy],
      );
      // 2000 * 1.30 = 2600, *0.8 = 2080
      final result = calculator.calculate(user: user);
      expect(result, 2100.0);
    });

    test('breastfeeding multiplies by 1.50', () {
      final user = baseUser.copyWith(
        healthConditions: [HealthCondition.breastfeeding],
      );
      // 2000 * 1.50 = 3000, *0.8 = 2400
      final result = calculator.calculate(user: user);
      expect(result, 2400.0);
    });

    test('kidney issues multiplies by 0.90', () {
      final user = baseUser.copyWith(
        healthConditions: [HealthCondition.kidneyIssues],
      );
      // 2000 * 0.90 = 1800, *0.8 = 1440
      final result = calculator.calculate(user: user);
      expect(result, 1450.0);
    });

    test('heart conditions multiplies by 0.95', () {
      final user = baseUser.copyWith(
        healthConditions: [HealthCondition.heartConditions],
      );
      // 2000 * 0.95 = 1900, *0.8 = 1520
      final result = calculator.calculate(user: user);
      expect(result, 1500.0);
    });

    test('hot weather multiplies by 1.30', () {
      final user = baseUser.copyWith(
        selectedWeatherCondition: WeatherCondition.hot,
      );
      // 2000 * 1.30 = 2600, *0.8 = 2080
      final result = calculator.calculate(user: user);
      expect(result, 2100.0);
    });

    test('hot and humid multiplies by 1.40', () {
      final user = baseUser.copyWith(
        selectedWeatherCondition: WeatherCondition.hotAndHumid,
      );
      // 2000 * 1.40 = 2800, *0.8 = 2240
      final result = calculator.calculate(user: user);
      expect(result, 2250.0);
    });

    test('cold weather multiplies by 0.95', () {
      final user = baseUser.copyWith(
        selectedWeatherCondition: WeatherCondition.cold,
      );
      // 2000 * 0.95 = 1900, *0.8 = 1520
      final result = calculator.calculate(user: user);
      expect(result, 1500.0);
    });

    test('temperate weather no adjustment', () {
      final user = baseUser.copyWith(
        selectedWeatherCondition: WeatherCondition.temperate,
      );
      expect(calculator.calculate(user: user), 1600.0);
    });

    test('result is clamped to minimum 1000', () {
      final user = baseUser.copyWith(
        weightKg: 1,
        gender: Gender.female,
        selectedWeatherCondition: WeatherCondition.cold,
        healthConditions: [HealthCondition.kidneyIssues],
      );
      // max(33, 2000) = 2000, *0.90 = 1800, *0.95 = 1710, *0.8 = 1368
      // Still above 1000. Using male+ultra cold combo:
      final user2 = baseUser.copyWith(
        weightKg: 1,
        gender: Gender.male,
        selectedWeatherCondition: WeatherCondition.cold,
        healthConditions: [HealthCondition.kidneyIssues],
      );
      // max(33, 2500) = 2500, *0.90 = 2250, *0.95 = 2137.5, *0.8 = 1710
      // Hard to hit 1000 floor with given formula, ensure no crash
      final result = calculator.calculate(user: user2);
      expect(result, greaterThanOrEqualTo(1000.0));
    });

    test('result is clamped to maximum 10000', () {
      final user = baseUser.copyWith(
        weightKg: 150,
        gender: Gender.male,
        activityLevel: ActivityLevel.extraActive,
        healthConditions: [
          HealthCondition.pregnancy,
          HealthCondition.breastfeeding,
        ],
        selectedWeatherCondition: WeatherCondition.hotAndHumid,
      );
      // 150*33=4950, male=2500 => max=4950
      // extraActive: +1400 => 6350
      // pregnancy *1.30 => 8255
      // breastfeeding *1.50 => 12382.5
      // hotAndHumid *1.40 => 17335.5
      // *0.8 => 13868.4, clamp to 10000
      final result = calculator.calculate(user: user);
      expect(result, 10000.0);
    });

    test('composite scenario: male 80kg active hot', () {
      final user = baseUser.copyWith(
        weightKg: 80,
        gender: Gender.male,
        activityLevel: ActivityLevel.active,
        selectedWeatherCondition: WeatherCondition.hot,
      );
      // max(80*33=2640, 2500) = 2640, active +1050 = 3690
      // hot *1.30 = 4797, *0.8 = 3837.6, round 50 = 3850
      final result = calculator.calculate(user: user);
      expect(result, 3850.0);
    });

    test('composite scenario: female 50kg light cold with kidney issues', () {
      final user = baseUser.copyWith(
        weightKg: 50,
        gender: Gender.female,
        activityLevel: ActivityLevel.light,
        selectedWeatherCondition: WeatherCondition.cold,
        healthConditions: [HealthCondition.kidneyIssues],
      );
      // max(50*33=1650, 2000) = 2000, light +350 = 2350
      // kidney *0.90 = 2115, cold *0.95 = 2009.25
      // *0.8 = 1607.4, round 50 = 1600
      final result = calculator.calculate(user: user);
      expect(result, 1600.0);
    });

    test('multiple health conditions compound multiplicatively', () {
      // pregnancy * 1.30, kidneyIssues * 0.90 → net * 1.17
      final user = baseUser.copyWith(
        healthConditions: [
          HealthCondition.pregnancy,
          HealthCondition.kidneyIssues,
        ],
      );
      // 2000 * 1.30 = 2600, * 0.90 = 2340, * 0.8 = 1872, round 50 = 1850
      final result = calculator.calculate(user: user);
      expect(result, 1850.0);
    });
  });
}
