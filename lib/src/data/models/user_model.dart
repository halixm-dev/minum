// lib/src/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:minum/main.dart'; // For logger
import 'package:minum/src/core/constants/app_strings.dart';

/// Represents the gender of the user.
enum Gender { male, female }

/// Represents health conditions that may affect hydration needs.
enum HealthCondition {
  none,
  pregnancy,
  breastfeeding,
  kidneyIssues,
  heartConditions,
}

/// Represents weather conditions that may affect hydration needs.
enum WeatherCondition {
  temperate,
  hot,
  hotAndHumid,
  cold,
}

/// Represents the measurement units for volume.
enum MeasurementUnit { ml, oz }

/// An extension on [MeasurementUnit] to get a display name.
extension MeasurementUnitDisplayName on MeasurementUnit {
  /// The display name of the measurement unit (e.g., "mL", "oz").
  String get displayName {
    switch (this) {
      case MeasurementUnit.ml:
        return AppStrings.ml;
      case MeasurementUnit.oz:
        return AppStrings.oz;
    }
  }
}

/// Represents the user's physical activity level.
enum ActivityLevel { sedentary, light, moderate, active, extraActive }

/// Represents a user of the application.
///
/// This model holds all user-related information, including authentication
/// details, profile information, and health data for hydration calculations.
class UserModel extends Equatable {
  /// The unique identifier for the user (typically from Firebase Auth).
  final String id;

  /// The user's email address.
  final String? email;

  /// The user's display name.
  final String? displayName;

  /// The URL of the user's profile photo.
  final String? photoUrl;

  /// The date and time when the user account was created.
  final DateTime createdAt;

  /// The date and time of the user's last login.
  final DateTime? lastLoginAt;

  // Hydration specific settings
  /// The user's daily hydration goal in milliliters.
  final double dailyGoalMl;

  /// The user's preferred measurement unit for displaying volumes.
  final MeasurementUnit preferredUnit;

  /// A list of favorite intake volumes for quick logging.
  final List<String> favoriteIntakeVolumes;

  // Health data for goal calculation
  /// The user's date of birth.
  final DateTime? dateOfBirth;

  /// The user's gender.
  final Gender? gender;

  /// The user's weight in kilograms.
  final double? weightKg;

  /// The user's height in centimeters.
  final double? heightCm;

  /// The user's physical activity level.
  final ActivityLevel? activityLevel;

  /// A list of the user's health conditions.
  final List<HealthCondition>? healthConditions;

  /// The user's selected weather condition.
  final WeatherCondition? selectedWeatherCondition;

  /// Creates a `UserModel` instance.
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
    this.gender,
    this.weightKg,
    this.heightCm,
    this.activityLevel,
    this.healthConditions = const [HealthCondition.none],
    this.selectedWeatherCondition = WeatherCondition.temperate,
  });

  /// Calculates the user's age based on their [dateOfBirth].
  ///
  /// Returns null if the date of birth is not set.
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  /// Creates a `UserModel` from a Firestore document snapshot.
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception("User data is null in Firestore document!");
    }

    ActivityLevel? parsedActivityLevel;
    final String? activityLevelString = data['activityLevel'] as String?;
    if (activityLevelString != null && activityLevelString.isNotEmpty) {
      try {
        parsedActivityLevel = ActivityLevel.values
            .firstWhere((e) => e.toString() == activityLevelString);
      } catch (e) {
        logger.w(
            "Invalid activity level string from Firestore: '$activityLevelString'. Defaulting to null.");
        parsedActivityLevel = null;
      }
    }

    Gender? parsedGender;
    final String? genderString = data['gender'] as String?;
    if (genderString != null && genderString.isNotEmpty) {
      try {
        if (genderString == Gender.male.toString() ||
            genderString == Gender.female.toString()) {
          parsedGender =
              Gender.values.firstWhere((e) => e.toString() == genderString);
        } else {
          logger.w(
              "Invalid or unsupported gender string from Firestore: '$genderString'. Defaulting to null.");
          parsedGender = null;
        }
      } catch (e) {
        logger.w(
            "Error parsing gender string from Firestore: '$genderString'. Defaulting to null.");
        parsedGender = null;
      }
    }

    List<HealthCondition> parsedHealthConditions = [HealthCondition.none];
    final List<dynamic>? healthConditionsDynamic =
        data['healthConditions'] as List<dynamic>?;
    if (healthConditionsDynamic != null) {
      List<HealthCondition> conditions = healthConditionsDynamic
          .map((s) {
            try {
              return HealthCondition.values
                  .firstWhere((e) => e.toString() == s.toString());
            } catch (e) {
              logger.w(
                  "Invalid health condition string from Firestore: '$s'. Skipping.");
              return null;
            }
          })
          .whereType<HealthCondition>()
          .toList();
      if (conditions.isNotEmpty) parsedHealthConditions = conditions;
    }

    WeatherCondition parsedWeatherCondition = WeatherCondition.temperate;
    final String? weatherString = data['selectedWeatherCondition'] as String?;
    if (weatherString != null && weatherString.isNotEmpty) {
      try {
        parsedWeatherCondition = WeatherCondition.values
            .firstWhere((e) => e.toString() == weatherString);
      } catch (e) {
        logger.w(
            "Invalid weather condition string from Firestore: '$weatherString'. Defaulting to temperate.");
      }
    }

    MeasurementUnit parsedPreferredUnit = MeasurementUnit.ml;
    final String? preferredUnitString = data['preferredUnit'] as String?;
    if (preferredUnitString != null && preferredUnitString.isNotEmpty) {
      try {
        parsedPreferredUnit = MeasurementUnit.values
            .firstWhere((e) => e.toString() == preferredUnitString);
      } catch (e) {
        logger.w(
            "Invalid preferred unit string: '$preferredUnitString'. Defaulting to mL.");
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

  /// Converts the `UserModel` instance to a map for storing in Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt':
          lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'dailyGoalMl': dailyGoalMl,
      'preferredUnit': preferredUnit.toString(),
      'favoriteIntakeVolumes': favoriteIntakeVolumes,
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'gender': gender?.toString(),
      'weightKg': weightKg,
      'heightCm': heightCm,
      'activityLevel': activityLevel?.toString(),
      'healthConditions': healthConditions?.map((e) => e.toString()).toList() ??
          [HealthCondition.none.toString()],
      'selectedWeatherCondition': selectedWeatherCondition?.toString() ??
          WeatherCondition.temperate.toString(),
    };
  }

  /// Creates a copy of this `UserModel` but with the given fields replaced with the new values.
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
      favoriteIntakeVolumes:
          favoriteIntakeVolumes ?? this.favoriteIntakeVolumes,
      dateOfBirth: clearDateOfBirth ? null : dateOfBirth ?? this.dateOfBirth,
      gender: clearGender ? null : gender ?? this.gender,
      weightKg: clearWeightKg ? null : weightKg ?? this.weightKg,
      heightCm: clearHeightCm ? null : heightCm ?? this.heightCm,
      activityLevel:
          clearActivityLevel ? null : activityLevel ?? this.activityLevel,
      healthConditions: healthConditions ?? this.healthConditions,
      selectedWeatherCondition:
          selectedWeatherCondition ?? this.selectedWeatherCondition,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        createdAt,
        lastLoginAt,
        dailyGoalMl,
        preferredUnit,
        favoriteIntakeVolumes,
        dateOfBirth,
        gender,
        weightKg,
        heightCm,
        activityLevel,
        healthConditions,
        selectedWeatherCondition
      ];

  /// A string representation of the preferred measurement unit (e.g., "mL", "oz").
  String get preferredUnitString =>
      preferredUnit == MeasurementUnit.ml ? 'mL' : 'oz';
}
