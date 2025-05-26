import 'package:flutter_test/flutter_test.dart';
import 'package:minum/src/core/constants/app_strings.dart';
import 'package:minum/src/core/utils/unit_converter.dart' as unit_converter;
import 'package:minum/src/data/models/user_model.dart'; // For MeasurementUnit

void main() {
  group('UnitConverter Tests', () {
    const double mlPerOz = 29.5735;

    group('convertMlToOz', () {
      test('should convert mL to oz correctly', () {
        expect(unit_converter.convertMlToOz(295.735), closeTo(10.0, 0.001));
        expect(unit_converter.convertMlToOz(0), closeTo(0.0, 0.001));
        expect(unit_converter.convertMlToOz(500), closeTo(500 / mlPerOz, 0.001));
      });
    });

    group('convertOzToMl', () {
      test('should convert oz to mL correctly', () {
        expect(unit_converter.convertOzToMl(10.0), closeTo(295.735, 0.001));
        expect(unit_converter.convertOzToMl(0), closeTo(0.0, 0.001));
        expect(unit_converter.convertOzToMl(16), closeTo(16 * mlPerOz, 0.001));
      });
    });

    group('formatVolume', () {
      test('should format volume in mL correctly', () {
        expect(
            unit_converter.formatVolume(2000, MeasurementUnit.ml), '2000 ${AppStrings.ml}');
        expect(
            unit_converter.formatVolume(2000, MeasurementUnit.ml, includeUnitString: false),
            '2000');
        expect(
            unit_converter.formatVolume(150.7, MeasurementUnit.ml), '150 ${AppStrings.ml}'); // Should be int for mL
      });

      test('should format volume in oz correctly with default 1 decimal place', () {
        expect(
            unit_converter.formatVolume(295.735, MeasurementUnit.oz), '10.0 ${AppStrings.oz}');
        expect(
            unit_converter.formatVolume(295.735, MeasurementUnit.oz, includeUnitString: false),
            '10.0');
        // Test rounding and decimal places
        expect(
            unit_converter.formatVolume(300, MeasurementUnit.oz), '10.1 ${AppStrings.oz}'); // 300ml is approx 10.14 oz
      });

      test('should format volume in oz correctly with specified decimal places', () {
        expect(
            unit_converter.formatVolume(295.735, MeasurementUnit.oz, decimalPlaces: 2),
            '10.00 ${AppStrings.oz}');
        expect(
            unit_converter.formatVolume(300, MeasurementUnit.oz, decimalPlaces: 2),
            '10.14 ${AppStrings.oz}');
         expect(
            unit_converter.formatVolume(300, MeasurementUnit.oz, decimalPlaces: 0),
            '10 ${AppStrings.oz}'); // Rounded to nearest whole number
      });

      test('should handle zero volume correctly', () {
        expect(
            unit_converter.formatVolume(0, MeasurementUnit.ml), '0 ${AppStrings.ml}');
        expect(
            unit_converter.formatVolume(0, MeasurementUnit.oz), '0.0 ${AppStrings.oz}');
      });
    });
  });
}
