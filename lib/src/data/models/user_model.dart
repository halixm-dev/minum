// lib/src/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:minum/main.dart'; // For logger, ensure this is appropriate for your project structure.

enum Gender {
  male,
  female
}

enum HealthCondition {
  none,
  pregnancy,
  breastfeeding,
  kidneyIssues,
  heartConditions,
}

enum WeatherCondition {
  temperate,
  hot,
  hotAndHumid,
  cold,
}

// --- Existing Enums ---
enum MeasurementUnit { ml, oz }

// Add AppStrings import for the extension
import 'package:minum/src/core/constants/app_strings.dart';

extension MeasurementUnitDisplayName on MeasurementUnit {
  String get displayName {
    switch (this) {
      case MeasurementUnit.ml:
        return AppStrings.ml;
      case MeasurementUnit.oz:
        return AppStrings.oz;
    }
  }
}

enum ActivityLevel { sedentary, light, moderate, active, extraActive }

class UserModel extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  // Hydration specific settings
  final double dailyGoalMl;
  final MeasurementUnit preferredUnit;
  final List<String> favoriteIntakeVolumes;

  // Health data for goal calculation
  final DateTime? dateOfBirth;
  final Gender? gender; // This is nullable, so user can choose not to specify
  final double? weightKg;
  final double? heightCm;
  final ActivityLevel? activityLevel;
  final List<HealthCondition>? healthConditions;
  final WeatherCondition? selectedWeatherCondition;

  const UserModel({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.dailyGoalMl = 2000.0,
    this.preferredUnit = MeasurementUnit.ml,
    this.favoriteIntakeVolumes = const ['250', '500', '750'],
    this.dateOfBirth,
    this.gender, // Can be null if not set
    this.weightKg,
    this.heightCm,
    this.activityLevel,
    this.healthConditions = const [HealthCondition.none],
    this.selectedWeatherCondition = WeatherCondition.temperate,
  });

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception("User data is null in Firestore document!");
    }

    ActivityLevel? parsedActivityLevel;
    final String? activityLevelString = data['activityLevel'] as String?;
    if (activityLevelString != null && activityLevelString.isNotEmpty) {
      try {
        parsedActivityLevel = ActivityLevel.values.firstWhere((e) => e.toString() == activityLevelString);
      } catch (e) {
        logger.w("Invalid activity level string from Firestore: '$activityLevelString'. Defaulting to null.");
        parsedActivityLevel = null;
      }
    }

    Gender? parsedGender;
    final String? genderString = data['gender'] as String?;
    if (genderString != null && genderString.isNotEmpty) {
      try {
        // Only try to parse if it's 'Gender.male' or 'Gender.female'
        if (genderString == Gender.male.toString() || genderString == Gender.female.toString()) {
          parsedGender = Gender.values.firstWhere((e) => e.toString() == genderString);
        } else {
          logger.w("Invalid or unsupported gender string from Firestore: '$genderString'. Defaulting to null.");
          parsedGender = null; // If it's 'Gender.other' or something else, treat as null
        }
      } catch (e) { // Should not happen if check above is done, but as a safeguard
        logger.w("Error parsing gender string from Firestore: '$genderString'. Defaulting to null.");
        parsedGender = null;
      }
    }

    List<HealthCondition> parsedHealthConditions = [HealthCondition.none];
    final List<dynamic>? healthConditionsDynamic = data['healthConditions'] as List<dynamic>?;
    if (healthConditionsDynamic != null) {
      List<HealthCondition> conditions = healthConditionsDynamic.map((s) {
        try {
          return HealthCondition.values.firstWhere((e) => e.toString() == s.toString());
        } catch (e) {
          logger.w("Invalid health condition string from Firestore: '$s'. Skipping.");
          return null;
        }
      }).whereType<HealthCondition>().toList();
      if (conditions.isNotEmpty) parsedHealthConditions = conditions;
    }


    WeatherCondition parsedWeatherCondition = WeatherCondition.temperate;
    final String? weatherString = data['selectedWeatherCondition'] as String?;
    if (weatherString != null && weatherString.isNotEmpty) {
      try {
        parsedWeatherCondition = WeatherCondition.values.firstWhere((e) => e.toString() == weatherString);
      } catch (e) {
        logger.w("Invalid weather condition string from Firestore: '$weatherString'. Defaulting to temperate.");
      }
    }

    MeasurementUnit parsedPreferredUnit = MeasurementUnit.ml;
    final String? preferredUnitString = data['preferredUnit'] as String?;
    if (preferredUnitString != null && preferredUnitString.isNotEmpty) {
      try {
        parsedPreferredUnit = MeasurementUnit.values.firstWhere((e) => e.toString() == preferredUnitString);
      } catch (e) {
        logger.w("Invalid preferred unit string: '$preferredUnitString'. Defaulting to mL.");
      }
    }

    return UserModel(
      id: doc.id,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      dailyGoalMl: (data['dailyGoalMl'] as num?)?.toDouble() ?? 2000.0,
      preferredUnit: parsedPreferredUnit,
      favoriteIntakeVolumes: (data['favoriteIntakeVolumes'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          const ['250', '500', '750'],
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      gender: parsedGender,
      weightKg: (data['weightKg'] as num?)?.toDouble(),
      heightCm: (data['heightCm'] as num?)?.toDouble(),
      activityLevel: parsedActivityLevel,
      healthConditions: parsedHealthConditions,
      selectedWeatherCondition: parsedWeatherCondition,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'dailyGoalMl': dailyGoalMl,
      'preferredUnit': preferredUnit.toString(),
      'favoriteIntakeVolumes': favoriteIntakeVolumes,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'gender': gender?.toString(), // Will store null if gender is null
      'weightKg': weightKg,
      'heightCm': heightCm,
      'activityLevel': activityLevel?.toString(),
      'healthConditions': healthConditions?.map((e) => e.toString()).toList() ?? [HealthCondition.none.toString()],
      'selectedWeatherCondition': selectedWeatherCondition?.toString() ?? WeatherCondition.temperate.toString(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    double? dailyGoalMl,
    MeasurementUnit? preferredUnit,
    List<String>? favoriteIntakeVolumes,
    DateTime? dateOfBirth,
    bool clearDateOfBirth = false,
    Gender? gender,
    bool clearGender = false,
    double? weightKg,
    bool clearWeightKg = false,
    double? heightCm,
    bool clearHeightCm = false,
    ActivityLevel? activityLevel,
    bool clearActivityLevel = false,
    List<HealthCondition>? healthConditions,
    WeatherCondition? selectedWeatherCondition,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      preferredUnit: preferredUnit ?? this.preferredUnit,
      favoriteIntakeVolumes: favoriteIntakeVolumes ?? this.favoriteIntakeVolumes,
      dateOfBirth: clearDateOfBirth ? null : dateOfBirth ?? this.dateOfBirth,
      gender: clearGender ? null : gender ?? this.gender,
      weightKg: clearWeightKg ? null : weightKg ?? this.weightKg,
      heightCm: clearHeightCm ? null : heightCm ?? this.heightCm,
      activityLevel: clearActivityLevel ? null : activityLevel ?? this.activityLevel,
      healthConditions: healthConditions ?? this.healthConditions,
      selectedWeatherCondition: selectedWeatherCondition ?? this.selectedWeatherCondition,
    );
  }

  @override
  List<Object?> get props => [
    id, email, displayName, photoUrl, createdAt, lastLoginAt,
    dailyGoalMl, preferredUnit, favoriteIntakeVolumes,
    dateOfBirth, gender, weightKg, heightCm, activityLevel,
    healthConditions, selectedWeatherCondition
  ];

  String get preferredUnitString => preferredUnit == MeasurementUnit.ml ? 'mL' : 'oz';
}
