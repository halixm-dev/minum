// lib/src/presentation/providers/user_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:minum/src/data/models/user_model.dart';
import 'package:minum/src/services/auth_service.dart';
import 'package:minum/src/data/repositories/user_repository.dart';
import 'package:minum/src/data/repositories/local/local_hydration_repository.dart'
    show guestUserId;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minum/main.dart'; // For logger

/// An enumeration of the possible statuses for loading a user profile.
enum UserProfileStatus { idle, loading, loaded, error }

// --- SharedPreferences Keys for Guest User Settings ---
/// Key for storing the guest's daily goal in milliliters.
const String prefsGuestDailyGoalMl = 'prefs_guest_daily_goal_ml';
/// Key for storing the guest's preferred measurement unit.
const String prefsGuestPreferredUnit = 'prefs_guest_preferred_unit';
/// Key for storing the guest's favorite intake volumes.
const String prefsGuestFavoriteVolumes = 'prefs_guest_favorite_volumes';
/// Key for storing the guest's date of birth.
const String prefsGuestDateOfBirth = 'prefs_guest_date_of_birth';
/// Key for storing the guest's gender.
const String prefsGuestGender = 'prefs_guest_gender';
/// Key for storing the guest's weight in kilograms.
const String prefsGuestWeightKg = 'prefs_guest_weight_kg';
/// Key for storing the guest's height in centimeters.
const String prefsGuestHeightCm = 'prefs_guest_height_cm';
/// Key for storing the guest's activity level.
const String prefsGuestActivityLevel = 'prefs_guest_activity_level';
/// Key for storing the guest's health conditions.
const String prefsGuestHealthConditions = 'prefs_guest_health_conditions';
/// Key for storing the guest's selected weather condition.
const String prefsGuestSelectedWeather = 'prefs_guest_selected_weather';

/// A `ChangeNotifier` that manages the user's profile data.
///
/// This provider handles loading the user profile based on authentication state,
/// managing a guest profile, and updating user settings.
class UserProvider with ChangeNotifier {
  final AuthService _authService;
  final UserRepository _userRepository;

  UserModel? _userProfile;
  UserProfileStatus _status = UserProfileStatus.idle;
  String? _errorMessage;
  StreamSubscription<UserModel?>? _authSubscription;
  bool _isDisposed = false;

  /// The current user's profile. Can be a logged-in user or a guest profile.
  UserModel? get userProfile => _userProfile;

  /// The current status of loading the user profile.
  UserProfileStatus get status => _status;

  /// The last error message related to user profile operations.
  String? get errorMessage => _errorMessage;

  /// A boolean indicating if the current user is a guest.
  bool get isGuestUser =>
      _userProfile != null && _userProfile!.id == guestUserId;

  /// Creates a `UserProvider` instance.
  UserProvider(
      {required AuthService authService,
      required UserRepository userRepository})
      : _authService = authService,
        _userRepository = userRepository {
    _subscribeToAuthChanges();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    } else {
      logger.w(
          "UserProvider: Attempted to call notifyListeners() after dispose.");
    }
  }

  T? _parseEnum<T extends Enum>(String? enumString, List<T> enumValues) {
    if (enumString == null || enumString.isEmpty) return null;
    try {
      return enumValues.firstWhere((e) => e.toString() == enumString);
    } catch (e) {
      logger.w(
          "UserProvider: Could not parse enum string '$enumString' for type $T. Returning null.");
      return null;
    }
  }

  void _subscribeToAuthChanges() {
    _authSubscription = _authService.authStateChanges
        .listen((UserModel? authUserFromService) async {
      if (_isDisposed) return;

      if (authUserFromService != null &&
          authUserFromService.id.isNotEmpty &&
          authUserFromService.id != guestUserId) {
        logger.i(
            "UserProvider: Auth user detected (ID: ${authUserFromService.id}). Setting profile.");

        _status = UserProfileStatus.loading;
        _safeNotifyListeners();

        UserModel? firebaseProfile =
            await _userRepository.getUser(authUserFromService.id);
        if (_isDisposed) return;

        final prefs = await SharedPreferences.getInstance();
        if (_isDisposed) return;

        if (firebaseProfile != null) {
          firebaseProfile =
              await _migrateGuestSettingsToFirebaseUser(firebaseProfile, prefs);
          _userProfile = firebaseProfile;
        } else {
          logger.w(
              "UserProvider: Firestore document not found for user ${authUserFromService.id}. Constructing temporary profile and migrating guest settings.");
          UserModel tempProfile = UserModel(
            id: authUserFromService.id,
            email: authUserFromService.email,
            displayName: authUserFromService.displayName,
            photoUrl: authUserFromService.photoUrl,
            createdAt: authUserFromService.createdAt,
          );
          _userProfile =
              await _migrateGuestSettingsToFirebaseUser(tempProfile, prefs);
        }
        _status = UserProfileStatus.loaded;
        _errorMessage = null;
        logger.i(
            "UserProvider: User profile set/updated: ${_userProfile?.displayName}");
      } else {
        logger.i(
            "UserProvider: No authenticated Firebase user. Loading/creating guest profile.");
        await _loadGuestProfile();
      }
      _safeNotifyListeners();
    });
  }

  Future<void> _loadGuestProfile() async {
    if (_isDisposed) return;
    _status = UserProfileStatus.loading;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed) return;

      final double guestGoal = prefs.getDouble(prefsGuestDailyGoalMl) ?? 2000.0;
      final MeasurementUnit guestUnit = _parseEnum(
              prefs.getString(prefsGuestPreferredUnit),
              MeasurementUnit.values) ??
          MeasurementUnit.ml;
      final List<String> guestFavorites =
          prefs.getStringList(prefsGuestFavoriteVolumes) ??
              const ['250', '500', '750'];
      DateTime? guestDob;
      final String? dobString = prefs.getString(prefsGuestDateOfBirth);
      if (dobString != null) guestDob = DateTime.tryParse(dobString);
      final Gender? guestGender =
          _parseEnum(prefs.getString(prefsGuestGender), Gender.values);
      final double? guestWeight = prefs.getDouble(prefsGuestWeightKg);
      final double? guestHeight = prefs.getDouble(prefsGuestHeightCm);
      final ActivityLevel? guestActivity = _parseEnum(
          prefs.getString(prefsGuestActivityLevel), ActivityLevel.values);
      List<HealthCondition> guestHealth = [HealthCondition.none];
      final List<String>? healthStrings =
          prefs.getStringList(prefsGuestHealthConditions);
      if (healthStrings != null) {
        guestHealth = healthStrings
            .map((s) =>
                _parseEnum(s, HealthCondition.values) ?? HealthCondition.none)
            .where((item) =>
                item != HealthCondition.none || healthStrings.length == 1)
            .toList();
        if (guestHealth.isEmpty) guestHealth = [HealthCondition.none];
      }
      final WeatherCondition guestWeather = _parseEnum(
              prefs.getString(prefsGuestSelectedWeather),
              WeatherCondition.values) ??
          WeatherCondition.temperate;

      _userProfile = UserModel(
        id: guestUserId,
        displayName: "Guest User",
        createdAt: DateTime.now(),
        dailyGoalMl: guestGoal,
        preferredUnit: guestUnit,
        favoriteIntakeVolumes: guestFavorites,
        dateOfBirth: guestDob,
        gender: guestGender,
        weightKg: guestWeight,
        heightCm: guestHeight,
        activityLevel: guestActivity,
        healthConditions: guestHealth,
        selectedWeatherCondition: guestWeather,
      );
      _status = UserProfileStatus.loaded;
      logger.i("UserProvider: Guest profile loaded/created: $_userProfile");
    } catch (e) {
      if (_isDisposed) return;
      _status = UserProfileStatus.error;
      _errorMessage = "Failed to load guest profile: $e";
      logger.e("UserProvider: Error loading guest profile: $e");
      _userProfile = UserModel(
          id: guestUserId, createdAt: DateTime.now(), displayName: "Guest");
    }
  }

  Future<UserModel> _migrateGuestSettingsToFirebaseUser(
      UserModel firebaseUser, SharedPreferences prefs) async {
    if (_isDisposed) return firebaseUser;
    bool needsUpdate = false;
    UserModel userToUpdateWithGuestSettings = firebaseUser;

    double? migrateDouble(
        String key, double? firebaseVal, double? defaultValFirebase) {
      double? guestVal = prefs.getDouble(key);
      if (guestVal != null &&
          (firebaseVal == defaultValFirebase ||
              firebaseVal == null ||
              firebaseVal != guestVal)) {
        return guestVal;
      }
      return firebaseVal;
    }

    T? migrateEnum<T extends Enum>(String prefKey, T? firebaseVal,
        List<T> enumValues, T? defaultEnumValFirebase) {
      String? guestValString = prefs.getString(prefKey);
      if (guestValString != null) {
        T? guestVal = _parseEnum(guestValString, enumValues);
        if (guestVal != null &&
            (firebaseVal == null ||
                firebaseVal == defaultEnumValFirebase ||
                firebaseVal != guestVal)) {
          return guestVal;
        }
      }
      return firebaseVal;
    }

    final initialProfileSnapshot = userToUpdateWithGuestSettings;

    userToUpdateWithGuestSettings = userToUpdateWithGuestSettings.copyWith(
        dailyGoalMl: migrateDouble(
            prefsGuestDailyGoalMl, initialProfileSnapshot.dailyGoalMl, 2000.0),
        preferredUnit: migrateEnum(
                prefsGuestPreferredUnit,
                initialProfileSnapshot.preferredUnit,
                MeasurementUnit.values,
                MeasurementUnit.ml) ??
            MeasurementUnit.ml,
        dateOfBirth:
            DateTime.tryParse(prefs.getString(prefsGuestDateOfBirth) ?? "") ??
                initialProfileSnapshot.dateOfBirth,
        gender: migrateEnum(prefsGuestGender, initialProfileSnapshot.gender,
            Gender.values, null),
        weightKg: migrateDouble(
            prefsGuestWeightKg, initialProfileSnapshot.weightKg, null),
        heightCm: migrateDouble(
            prefsGuestHeightCm, initialProfileSnapshot.heightCm, null),
        activityLevel: migrateEnum(prefsGuestActivityLevel,
            initialProfileSnapshot.activityLevel, ActivityLevel.values, null));

    final guestFavorites = prefs.getStringList(prefsGuestFavoriteVolumes);
    if (guestFavorites != null && guestFavorites.isNotEmpty) {
      final defaultFavs = const ['250', '500', '750'];
      bool firebaseIsDefaultFavs =
          listEquals(initialProfileSnapshot.favoriteIntakeVolumes, defaultFavs);
      if (firebaseIsDefaultFavs ||
          !listEquals(
              initialProfileSnapshot.favoriteIntakeVolumes, guestFavorites)) {
        userToUpdateWithGuestSettings = userToUpdateWithGuestSettings.copyWith(
            favoriteIntakeVolumes: guestFavorites);
      }
    }

    final healthStrings = prefs.getStringList(prefsGuestHealthConditions);
    if (healthStrings != null) {
      List<HealthCondition> guestHealth = healthStrings
          .map((s) =>
              _parseEnum(s, HealthCondition.values) ?? HealthCondition.none)
          .where((item) =>
              item != HealthCondition.none || healthStrings.length == 1)
          .toList();
      if (guestHealth.isEmpty) {
        guestHealth = [HealthCondition.none];
      }
      if (!listEquals(initialProfileSnapshot.healthConditions, guestHealth)) {
        userToUpdateWithGuestSettings = userToUpdateWithGuestSettings.copyWith(
            healthConditions: guestHealth);
      }
    }

    userToUpdateWithGuestSettings = userToUpdateWithGuestSettings.copyWith(
        selectedWeatherCondition: migrateEnum(
                prefsGuestSelectedWeather,
                initialProfileSnapshot.selectedWeatherCondition,
                WeatherCondition.values,
                WeatherCondition.temperate) ??
            WeatherCondition.temperate);

    if (userToUpdateWithGuestSettings != initialProfileSnapshot) {
      needsUpdate = true;
    }

    if (needsUpdate) {
      logger.i(
          "UserProvider: Migrating guest settings to user ${firebaseUser.id}");
      try {
        await _userRepository.updateUser(userToUpdateWithGuestSettings);
        if (_isDisposed) return firebaseUser;
        logger.i(
            "UserProvider: Successfully migrated/updated Firebase profile with guest settings for user ${firebaseUser.id}.");

        await prefs.remove(prefsGuestDailyGoalMl);
        await prefs.remove(prefsGuestPreferredUnit);
        await prefs.remove(prefsGuestFavoriteVolumes);
        await prefs.remove(prefsGuestDateOfBirth);
        await prefs.remove(prefsGuestGender);
        await prefs.remove(prefsGuestWeightKg);
        await prefs.remove(prefsGuestHeightCm);
        await prefs.remove(prefsGuestActivityLevel);
        await prefs.remove(prefsGuestHealthConditions);
        await prefs.remove(prefsGuestSelectedWeather);
        logger.i(
            "UserProvider: Cleared all migrated guest settings from SharedPreferences.");
        return userToUpdateWithGuestSettings;
      } catch (e) {
        logger.e(
            "UserProvider: Error migrating guest settings to Firebase for user ${firebaseUser.id}: $e");
      }
    } else {
      logger.i(
          "UserProvider: No guest settings needed migration for user ${firebaseUser.id}.");
    }
    return userToUpdateWithGuestSettings;
  }

  /// Fetches the user profile for a given [uid].
  ///
  /// If the user is a guest, it loads the guest profile from local storage.
  Future<void> fetchUserProfile(String uid) async {
    if (_isDisposed) {
      return;
    }
    if (uid == guestUserId) {
      await _loadGuestProfile();
      _safeNotifyListeners();
      return;
    }
    if (uid.isEmpty) {
      _status = UserProfileStatus.idle;
      _userProfile = null;
      _safeNotifyListeners();
      return;
    }

    _status = UserProfileStatus.loading;
    _errorMessage = null;
    _safeNotifyListeners();
    try {
      _userProfile = await _userRepository.getUser(uid);
      if (_isDisposed) {
        return;
      }
      if (_userProfile == null) {
        final fbAuthUser = _authService.currentUser;
        if (fbAuthUser != null && fbAuthUser.id == uid) {
          UserModel newProfileFromAuth = UserModel(
              id: uid,
              email: fbAuthUser.email,
              displayName: fbAuthUser.displayName,
              photoUrl: fbAuthUser.photoUrl,
              createdAt: fbAuthUser.createdAt);
          final prefsForMigration = await SharedPreferences.getInstance();
          if (_isDisposed) {
            return;
          }
          _userProfile = await _migrateGuestSettingsToFirebaseUser(
              newProfileFromAuth, prefsForMigration);
          _status = UserProfileStatus.loaded;
        } else {
          _status = UserProfileStatus.error;
          _errorMessage = "User profile not found and no auth user.";
        }
      } else {
        _status = UserProfileStatus.loaded;
      }
    } catch (e) {
      if (_isDisposed) {
        return;
      }
      _status = UserProfileStatus.error;
      _errorMessage = "Failed to fetch user profile: ${e.toString()}";
    }
    _safeNotifyListeners();
  }

  /// Updates the user profile.
  ///
  /// For guest users, it saves the data locally. For logged-in users, it
  /// updates the data in the remote repository.
  Future<void> updateUserProfile(UserModel updatedProfile) async {
    if (_isDisposed) return;

    _status = UserProfileStatus.loading;
    _safeNotifyListeners();

    try {
      if (updatedProfile.id == guestUserId) {
        final prefs = await SharedPreferences.getInstance();
        if (_isDisposed) {
          _status = UserProfileStatus.idle;
          return;
        }

        await prefs.setDouble(
            prefsGuestDailyGoalMl, updatedProfile.dailyGoalMl);
        await prefs.setString(
            prefsGuestPreferredUnit, updatedProfile.preferredUnit.toString());
        await prefs.setStringList(
            prefsGuestFavoriteVolumes, updatedProfile.favoriteIntakeVolumes);
        if (updatedProfile.dateOfBirth != null) {
          await prefs.setString(prefsGuestDateOfBirth,
              updatedProfile.dateOfBirth!.toIso8601String());
        } else {
          await prefs.remove(prefsGuestDateOfBirth);
        }
        if (updatedProfile.gender != null) {
          await prefs.setString(
              prefsGuestGender, updatedProfile.gender.toString());
        } else {
          await prefs.remove(prefsGuestGender);
        }
        if (updatedProfile.weightKg != null) {
          await prefs.setDouble(prefsGuestWeightKg, updatedProfile.weightKg!);
        } else {
          await prefs.remove(prefsGuestWeightKg);
        }
        if (updatedProfile.heightCm != null) {
          await prefs.setDouble(prefsGuestHeightCm, updatedProfile.heightCm!);
        } else {
          await prefs.remove(prefsGuestHeightCm);
        }
        if (updatedProfile.activityLevel != null) {
          await prefs.setString(
              prefsGuestActivityLevel, updatedProfile.activityLevel.toString());
        } else {
          await prefs.remove(prefsGuestActivityLevel);
        }
        if (updatedProfile.healthConditions != null &&
            updatedProfile.healthConditions!.isNotEmpty &&
            !(updatedProfile.healthConditions!.length == 1 &&
                updatedProfile.healthConditions!
                    .contains(HealthCondition.none))) {
          await prefs.setStringList(
              prefsGuestHealthConditions,
              updatedProfile.healthConditions!
                  .map((e) => e.toString())
                  .toList());
        } else {
          await prefs.remove(prefsGuestHealthConditions);
        }
        if (updatedProfile.selectedWeatherCondition != null) {
          await prefs.setString(prefsGuestSelectedWeather,
              updatedProfile.selectedWeatherCondition.toString());
        } else {
          await prefs.remove(prefsGuestSelectedWeather);
        }

        if (!_isDisposed) {
          _userProfile = updatedProfile;
          _status = UserProfileStatus.loaded;
          _errorMessage = null;
          logger.i("UserProvider: Guest profile updated locally.");
        }
      } else {
        if (_userProfile == null || _userProfile!.id != updatedProfile.id) {
          _errorMessage = "Cannot update profile: No user or mismatched ID.";
          _status = UserProfileStatus.error;
        } else {
          try {
            await _userRepository
                .updateUser(updatedProfile)
                .timeout(const Duration(seconds: 5));
            if (!_isDisposed) {
              _userProfile = updatedProfile;
              _status = UserProfileStatus.loaded;
              _errorMessage = null;
              logger.i(
                  "UserProvider: Profile updated successfully for user ${updatedProfile.id}");
            }
          } on TimeoutException {
            if (!_isDisposed) {
              logger.w(
                  "UserProvider: Timeout waiting for user profile update for ${updatedProfile.id}. Assuming offline and data queued.");
              _userProfile = updatedProfile;
              _status = UserProfileStatus.loaded;
              _errorMessage = "Profile saved locally. Will sync when online.";
            }
          }
        }
      }
    } catch (e) {
      if (_isDisposed) {
        _status = UserProfileStatus.idle;
        return;
      }
      _status = UserProfileStatus.error;
      _errorMessage = "Failed to update profile: ${e.toString()}";
      logger.e("UserProvider: Error updating profile: $e");
    }
    _safeNotifyListeners();
  }

  Future<void> _ensureGuestProfileLoaded() async {
    if (_userProfile == null && !_isDisposed) {
      await _loadGuestProfile();
    }
  }

  /// Updates the user's daily hydration goal.
  Future<void> updateDailyGoal(double newGoalMl) async {
    await _ensureGuestProfileLoaded();
    if (_userProfile == null || _isDisposed) {
      return;
    }
    final updated = _userProfile!.copyWith(dailyGoalMl: newGoalMl);
    await updateUserProfile(updated);
  }

  /// Updates the user's preferred measurement unit.
  Future<void> updatePreferredUnit(MeasurementUnit newUnit) async {
    await _ensureGuestProfileLoaded();
    if (_userProfile == null || _isDisposed) {
      return;
    }
    final updated = _userProfile!.copyWith(preferredUnit: newUnit);
    await updateUserProfile(updated);
  }

  /// Updates the user's list of favorite intake volumes.
  Future<void> updateFavoriteIntakeVolumes(List<String> newVolumes) async {
    await _ensureGuestProfileLoaded();
    if (_userProfile == null || _isDisposed) {
      return;
    }
    final validatedVolumes = newVolumes
        .where((v) => double.tryParse(v) != null && double.parse(v) > 0)
        .toList();
    final updated = _userProfile!.copyWith(
        favoriteIntakeVolumes: validatedVolumes.isEmpty
            ? const ['250', '500', '750']
            : validatedVolumes);
    await updateUserProfile(updated);
  }

  /// Updates the user's date of birth.
  Future<void> updateDateOfBirth(DateTime? newDob) async {
    await _ensureGuestProfileLoaded();
    if (_userProfile == null || _isDisposed) {
      return;
    }
    await updateUserProfile(_userProfile!
        .copyWith(dateOfBirth: newDob, clearDateOfBirth: newDob == null));
  }

  /// Updates the user's gender.
  Future<void> updateGender(Gender? newGender) async {
    await _ensureGuestProfileLoaded();
    if (_userProfile == null || _isDisposed) {
      return;
    }
    await updateUserProfile(_userProfile!
        .copyWith(gender: newGender, clearGender: newGender == null));
  }

  /// Updates the user's height.
  Future<void> updateHeight(double? newHeightCm) async {
    await _ensureGuestProfileLoaded();
    if (_userProfile == null || _isDisposed) {
      return;
    }
    await updateUserProfile(_userProfile!
        .copyWith(heightCm: newHeightCm, clearHeightCm: newHeightCm == null));
  }

  /// Updates the user's weight.
  Future<void> updateWeight(double? newWeightKg) async {
    await _ensureGuestProfileLoaded();
    if (_userProfile == null || _isDisposed) {
      return;
    }
    final updated = _userProfile!
        .copyWith(weightKg: newWeightKg, clearWeightKg: newWeightKg == null);
    await updateUserProfile(updated);
  }

  /// Updates the user's activity level.
  Future<void> updateActivityLevel(ActivityLevel? level) async {
    await _ensureGuestProfileLoaded();
    if (_userProfile == null || _isDisposed) {
      return;
    }
    final updated = _userProfile!
        .copyWith(activityLevel: level, clearActivityLevel: level == null);
    await updateUserProfile(updated);
  }

  /// Updates the user's health conditions.
  Future<void> updateHealthConditions(
      List<HealthCondition> newConditions) async {
    await _ensureGuestProfileLoaded();
    if (_userProfile == null || _isDisposed) {
      return;
    }
    List<HealthCondition> processedConditions = newConditions;
    if (newConditions.contains(HealthCondition.none) &&
        newConditions.length > 1) {
      processedConditions =
          newConditions.where((c) => c != HealthCondition.none).toList();
    }
    if (processedConditions.isEmpty) {
      processedConditions = [HealthCondition.none];
    }
    await updateUserProfile(
        _userProfile!.copyWith(healthConditions: processedConditions));
  }

  /// Updates the user's selected weather condition.
  Future<void> updateSelectedWeather(WeatherCondition newWeather) async {
    await _ensureGuestProfileLoaded();
    if (_userProfile == null || _isDisposed) {
      return;
    }
    await updateUserProfile(
        _userProfile!.copyWith(selectedWeatherCondition: newWeather));
  }

  @override
  void dispose() {
    logger.d("UserProvider: dispose called.");
    _isDisposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }

  /// A utility method to compare two lists for equality.
  @visibleForTesting
  bool listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
