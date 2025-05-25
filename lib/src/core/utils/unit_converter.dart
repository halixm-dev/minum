import 'package:minum/src/data/models/user_model.dart'; // For MeasurementUnit
import 'package:minum/src/core/constants/app_strings.dart'; // For AppStrings.ml and AppStrings.oz

const double _mlPerOz = 29.5735;

double convertMlToOz(double ml) {
  return ml / _mlPerOz;
}

double convertOzToMl(double oz) {
  return oz * _mlPerOz;
}

String formatVolume(double volumeMl, MeasurementUnit unit, {bool includeUnitString = true, int decimalPlaces = 1}) {
  double displayVolume;
  String unitString;

  if (unit == MeasurementUnit.oz) {
    displayVolume = convertMlToOz(volumeMl);
    unitString = AppStrings.oz;
  } else {
    displayVolume = volumeMl;
    unitString = AppStrings.ml;
  }

  String formattedVolume;
  if (unit == MeasurementUnit.oz) {
    // For oz, usually 1 or 2 decimal places are fine.
    formattedVolume = displayVolume.toStringAsFixed(decimalPlaces);
  } else {
    // For mL, typically whole numbers are used.
    formattedVolume = displayVolume.toInt().toString();
  }

  return includeUnitString ? '$formattedVolume $unitString' : formattedVolume;
}

// It's also good to move the MeasurementUnit extension here
// if it's going to be used more globally with these conversion utilities.
// However, the plan mentions putting it in user_model.dart later. For now, just the functions.
