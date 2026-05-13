import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minum/main.dart'; // For logger
import 'package:minum/src/features/user/data/models/user_model.dart';
import 'package:minum/src/features/user/data/repositories/user_repository.dart';
import 'package:minum/src/services/auth_service.dart';
import 'package:minum/src/core/constants/app_constants.dart' show guestUserId;
import 'package:minum/src/features/user/presentation/bloc/user_event.dart';
import 'package:minum/src/features/user/presentation/bloc/user_state.dart';

// --- SharedPreferences Keys for Guest User Settings ---
const String prefsGuestDailyGoalMl = 'prefs_guest_daily_goal_ml';
const String prefsGuestPreferredUnit = 'prefs_guest_preferred_unit';
const String prefsGuestFavoriteVolumes = 'prefs_guest_favorite_volumes';
const String prefsGuestDateOfBirth = 'prefs_guest_date_of_birth';
const String prefsGuestGender = 'prefs_guest_gender';
const String prefsGuestWeightKg = 'prefs_guest_weight_kg';
const String prefsGuestHeightCm = 'prefs_guest_height_cm';
const String prefsGuestActivityLevel = 'prefs_guest_activity_level';
const String prefsGuestHealthConditions = 'prefs_guest_health_conditions';
const String prefsGuestSelectedWeather = 'prefs_guest_selected_weather';

class UserBloc extends Bloc<UserEvent, UserState> {
  final AuthService authService;
  final UserRepository userRepository;
  StreamSubscription<UserModel?>? _authSubscription;

  UserBloc({
    required this.authService,
    required this.userRepository,
  }) : super(UserInitial()) {
    on<UserAuthChanged>(_onUserAuthChanged);
    on<LoadGuestProfile>(_onLoadGuestProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);

    _authSubscription = authService.authStateChanges.listen((authUser) {
      add(UserAuthChanged(authUser));
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  T? _parseEnum<T extends Enum>(String? enumString, List<T> enumValues) {
    if (enumString == null || enumString.isEmpty) return null;
    try {
      return enumValues.firstWhere((e) => e.toString() == enumString);
    } catch (e) {
      logger.w("UserBloc: Could not parse enum string '$enumString'.");
      return null;
    }
  }

  Future<void> _onUserAuthChanged(
      UserAuthChanged event, Emitter<UserState> emit) async {
    final authUser = event.authUser;
    if (authUser != null &&
        authUser.id.isNotEmpty &&
        authUser.id != guestUserId) {
      logger.i(
          "UserBloc: Auth user detected (ID: ${authUser.id}). Setting profile.");
      emit(UserLoading());

      UserModel? firebaseProfile = await userRepository.getUser(authUser.id);
      final prefs = await SharedPreferences.getInstance();

      if (firebaseProfile != null) {
        firebaseProfile =
            await _migrateGuestSettingsToFirebaseUser(firebaseProfile, prefs);
        emit(UserLoaded(user: firebaseProfile, isGuest: false));
      } else {
        logger.w(
            "UserBloc: Firestore document not found for user ${authUser.id}. Constructing temporary profile.");
        UserModel tempProfile = UserModel(
          id: authUser.id,
          email: authUser.email,
          displayName: authUser.displayName,
          photoUrl: authUser.photoUrl,
          createdAt: authUser.createdAt,
        );
        final migratedProfile =
            await _migrateGuestSettingsToFirebaseUser(tempProfile, prefs);
        emit(UserLoaded(user: migratedProfile, isGuest: false));
      }
    } else {
      logger.i(
          "UserBloc: No authenticated Firebase user. Loading guest profile.");
      add(LoadGuestProfile());
    }
  }

  Future<void> _onLoadGuestProfile(
      LoadGuestProfile event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final prefs = await SharedPreferences.getInstance();

      final guestGoal = prefs.getDouble(prefsGuestDailyGoalMl) ?? 2000.0;
      final guestUnit = _parseEnum(prefs.getString(prefsGuestPreferredUnit),
              MeasurementUnit.values) ??
          MeasurementUnit.ml;
      final guestFavorites = prefs.getStringList(prefsGuestFavoriteVolumes) ??
          const ['250', '500', '750'];

      DateTime? guestDob;
      final dobString = prefs.getString(prefsGuestDateOfBirth);
      if (dobString != null) guestDob = DateTime.tryParse(dobString);

      final guestGender =
          _parseEnum(prefs.getString(prefsGuestGender), Gender.values);
      final guestWeight = prefs.getDouble(prefsGuestWeightKg);
      final guestHeight = prefs.getDouble(prefsGuestHeightCm);
      final guestActivity = _parseEnum(
          prefs.getString(prefsGuestActivityLevel), ActivityLevel.values);

      List<HealthCondition> guestHealth = [HealthCondition.none];
      final healthStrings = prefs.getStringList(prefsGuestHealthConditions);
      if (healthStrings != null) {
        guestHealth = healthStrings
            .map((s) =>
                _parseEnum(s, HealthCondition.values) ?? HealthCondition.none)
            .where((item) =>
                item != HealthCondition.none || healthStrings.length == 1)
            .toList();
        if (guestHealth.isEmpty) guestHealth = [HealthCondition.none];
      }

      final guestWeather = _parseEnum(
              prefs.getString(prefsGuestSelectedWeather),
              WeatherCondition.values) ??
          WeatherCondition.temperate;

      final guestProfile = UserModel(
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

      emit(UserLoaded(user: guestProfile, isGuest: true));
    } catch (e) {
      logger.e("UserBloc: Error loading guest profile: $e");
      emit(UserError("Failed to load guest profile"));
    }
  }

  Future<void> _onUpdateUserProfile(
      UpdateUserProfile event, Emitter<UserState> emit) async {
    final updatedProfile = event.updatedUser;
    final isGuest = updatedProfile.id == guestUserId;

    // We do not change state to Loading if we just want sequential optimistic updates,
    // but the provider did change status. It's safer to keep the old UI but we can't emit loaded yet.
    // Provider did notifyListeners() basically setting it to loading. We might skip if we want smooth UI.

    try {
      if (isGuest) {
        final prefs = await SharedPreferences.getInstance();
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

        emit(UserLoaded(user: updatedProfile, isGuest: true));
      } else {
        await userRepository
            .updateUser(updatedProfile)
            .timeout(const Duration(seconds: 5));
        emit(UserLoaded(user: updatedProfile, isGuest: false));
      }
    } on TimeoutException {
      logger.w(
          "UserBloc: Timeout waiting for profile update for ${updatedProfile.id}. Proceeding locally.");
      emit(UserLoaded(user: updatedProfile, isGuest: false));
    } catch (e) {
      logger.e("UserBloc: Error updating profile: $e");
      emit(UserError("Failed to update profile: $e"));
    }
  }

  Future<UserModel> _migrateGuestSettingsToFirebaseUser(
      UserModel firebaseUser, SharedPreferences prefs) async {
    bool needsUpdate = false;
    UserModel userToUpdate = firebaseUser;

    double? migrateDouble(String key, double? firebaseVal, double? defaultVal) {
      double? guestVal = prefs.getDouble(key);
      if (guestVal != null &&
          (firebaseVal == defaultVal ||
              firebaseVal == null ||
              firebaseVal != guestVal)) {
        return guestVal;
      }
      return firebaseVal;
    }

    T? migrateEnum<T extends Enum>(
        String prefKey, T? firebaseVal, List<T> enumValues, T? defaultVal) {
      String? guestValString = prefs.getString(prefKey);
      if (guestValString != null) {
        T? guestVal = _parseEnum(guestValString, enumValues);
        if (guestVal != null &&
            (firebaseVal == null ||
                firebaseVal == defaultVal ||
                firebaseVal != guestVal)) {
          return guestVal;
        }
      }
      return firebaseVal;
    }

    userToUpdate = userToUpdate.copyWith(
      dailyGoalMl: migrateDouble(
          prefsGuestDailyGoalMl, firebaseUser.dailyGoalMl, 2000.0),
      preferredUnit: migrateEnum(
              prefsGuestPreferredUnit,
              firebaseUser.preferredUnit,
              MeasurementUnit.values,
              MeasurementUnit.ml) ??
          MeasurementUnit.ml,
      dateOfBirth:
          DateTime.tryParse(prefs.getString(prefsGuestDateOfBirth) ?? "") ??
              firebaseUser.dateOfBirth,
      gender: migrateEnum(
          prefsGuestGender, firebaseUser.gender, Gender.values, null),
      weightKg: migrateDouble(prefsGuestWeightKg, firebaseUser.weightKg, null),
      heightCm: migrateDouble(prefsGuestHeightCm, firebaseUser.heightCm, null),
      activityLevel: migrateEnum(prefsGuestActivityLevel,
          firebaseUser.activityLevel, ActivityLevel.values, null),
    );

    final guestFavorites = prefs.getStringList(prefsGuestFavoriteVolumes);
    if (guestFavorites != null && guestFavorites.isNotEmpty) {
      final defaultFavs = const ['250', '500', '750'];
      bool firebaseIsDefaultFavs =
          listEquals(firebaseUser.favoriteIntakeVolumes, defaultFavs);
      if (firebaseIsDefaultFavs ||
          !listEquals(firebaseUser.favoriteIntakeVolumes, guestFavorites)) {
        userToUpdate =
            userToUpdate.copyWith(favoriteIntakeVolumes: guestFavorites);
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
      if (guestHealth.isEmpty) guestHealth = [HealthCondition.none];
      if (!listEquals(firebaseUser.healthConditions, guestHealth)) {
        userToUpdate = userToUpdate.copyWith(healthConditions: guestHealth);
      }
    }

    userToUpdate = userToUpdate.copyWith(
      selectedWeatherCondition: migrateEnum(
              prefsGuestSelectedWeather,
              firebaseUser.selectedWeatherCondition,
              WeatherCondition.values,
              WeatherCondition.temperate) ??
          WeatherCondition.temperate,
    );

    if (userToUpdate != firebaseUser) needsUpdate = true;

    if (needsUpdate) {
      try {
        await userRepository.updateUser(userToUpdate);
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
        return userToUpdate;
      } catch (e) {
        logger.e("UserBloc: Error migrating guest settings: $e");
      }
    }
    return userToUpdate;
  }
}
