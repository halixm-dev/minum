import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minum/src/core/utils/logger.dart';
import 'package:minum/src/features/user/data/models/user_model.dart';
import 'package:minum/src/features/user/data/repositories/user_repository.dart';
import 'package:minum/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:minum/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:minum/src/services/prefs/i_prefs_service.dart';
import 'package:minum/src/core/constants/app_constants.dart' show guestUserId;
import 'package:minum/src/features/user/presentation/bloc/user_event.dart';
import 'package:minum/src/features/user/presentation/bloc/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final AuthBloc authBloc;
  final UserRepository userRepository;
  final IPrefsService prefsService;
  StreamSubscription<AuthState>? _authSubscription;

  UserBloc({
    required this.authBloc,
    required this.userRepository,
    required this.prefsService,
  }) : super(UserInitial()) {
    on<UserAuthChanged>(_onUserAuthChanged);
    on<LoadGuestProfile>(_onLoadGuestProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);

    // Handle initial auth state
    final initialState = authBloc.state;
    if (initialState is Authenticated) {
      add(UserAuthChanged(initialState.user));
    } else if (initialState is Unauthenticated) {
      add(UserAuthChanged(null));
    }

    // Listen for future changes
    _authSubscription = authBloc.stream.listen((authState) {
      if (authState is Authenticated) {
        add(UserAuthChanged(authState.user));
      } else if (authState is Unauthenticated) {
        add(UserAuthChanged(null));
      }
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

      if (firebaseProfile != null) {
        firebaseProfile =
            await _migrateGuestSettingsToFirebaseUser(firebaseProfile);
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
            await _migrateGuestSettingsToFirebaseUser(tempProfile);
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
      final guestGoal = await prefsService.getDouble(IPrefsService.keyGuestDailyGoalMl, defaultValue: 2000.0);
      final guestUnit = _parseEnum(
              await prefsService.getString(IPrefsService.keyGuestPreferredUnit),
              MeasurementUnit.values) ??
          MeasurementUnit.ml;
      final guestFavorites = await prefsService.getStringList(IPrefsService.keyGuestFavoriteVolumes,
          defaultValue: const ['250', '500', '750']);

      DateTime? guestDob;
      final dobString = await prefsService.getString(IPrefsService.keyGuestDateOfBirth);
      if (dobString.isNotEmpty) guestDob = DateTime.tryParse(dobString);

      final guestGender =
          _parseEnum(await prefsService.getString(IPrefsService.keyGuestGender), Gender.values);
      final guestWeight = await prefsService.getDouble(IPrefsService.keyGuestWeightKg);
      final guestHeight = await prefsService.getDouble(IPrefsService.keyGuestHeightCm);
      final guestActivity = _parseEnum(
          await prefsService.getString(IPrefsService.keyGuestActivityLevel), ActivityLevel.values);

      List<HealthCondition> guestHealth = [HealthCondition.none];
      final healthStrings = await prefsService.getStringList(IPrefsService.keyGuestHealthConditions);
      if (healthStrings.isNotEmpty) {
        guestHealth = healthStrings
            .map((s) =>
                _parseEnum(s, HealthCondition.values) ?? HealthCondition.none)
            .where((item) =>
                item != HealthCondition.none || healthStrings.length == 1)
            .toList();
        if (guestHealth.isEmpty) guestHealth = [HealthCondition.none];
      }

      final guestWeather = _parseEnum(
              await prefsService.getString(IPrefsService.keyGuestSelectedWeather),
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
        await prefsService.setDouble(
            IPrefsService.keyGuestDailyGoalMl, updatedProfile.dailyGoalMl);
        await prefsService.setString(
            IPrefsService.keyGuestPreferredUnit, updatedProfile.preferredUnit.toString());
        await prefsService.setStringList(
            IPrefsService.keyGuestFavoriteVolumes, updatedProfile.favoriteIntakeVolumes);

        if (updatedProfile.dateOfBirth != null) {
          await prefsService.setString(IPrefsService.keyGuestDateOfBirth,
              updatedProfile.dateOfBirth!.toIso8601String());
        } else {
          await prefsService.remove(IPrefsService.keyGuestDateOfBirth);
        }

        if (updatedProfile.gender != null) {
          await prefsService.setString(
              IPrefsService.keyGuestGender, updatedProfile.gender.toString());
        } else {
          await prefsService.remove(IPrefsService.keyGuestGender);
        }

        if (updatedProfile.weightKg != null) {
          await prefsService.setDouble(IPrefsService.keyGuestWeightKg, updatedProfile.weightKg!);
        } else {
          await prefsService.remove(IPrefsService.keyGuestWeightKg);
        }

        if (updatedProfile.heightCm != null) {
          await prefsService.setDouble(IPrefsService.keyGuestHeightCm, updatedProfile.heightCm!);
        } else {
          await prefsService.remove(IPrefsService.keyGuestHeightCm);
        }

        if (updatedProfile.activityLevel != null) {
          await prefsService.setString(
              IPrefsService.keyGuestActivityLevel, updatedProfile.activityLevel.toString());
        } else {
          await prefsService.remove(IPrefsService.keyGuestActivityLevel);
        }

        if (updatedProfile.healthConditions != null &&
            updatedProfile.healthConditions!.isNotEmpty &&
            !(updatedProfile.healthConditions!.length == 1 &&
                updatedProfile.healthConditions!
                    .contains(HealthCondition.none))) {
          await prefsService.setStringList(
              IPrefsService.keyGuestHealthConditions,
              updatedProfile.healthConditions!
                  .map((e) => e.toString())
                  .toList());
        } else {
          await prefsService.remove(IPrefsService.keyGuestHealthConditions);
        }

        if (updatedProfile.selectedWeatherCondition != null) {
          await prefsService.setString(IPrefsService.keyGuestSelectedWeather,
              updatedProfile.selectedWeatherCondition.toString());
        } else {
          await prefsService.remove(IPrefsService.keyGuestSelectedWeather);
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
      UserModel firebaseUser) async {
    bool needsUpdate = false;
    UserModel userToUpdate = firebaseUser;

    Future<double?> migrateDouble(String key, double? firebaseVal, double? defaultVal) async {
      double? guestVal = await prefsService.getDouble(key);
      if (guestVal != 0.0 &&
          (firebaseVal == defaultVal ||
              firebaseVal == null ||
              firebaseVal != guestVal)) {
        return guestVal;
      }
      return firebaseVal;
    }

    Future<T?> migrateEnum<T extends Enum>(
        String prefKey, T? firebaseVal, List<T> enumValues, T? defaultVal) async {
      String? guestValString = await prefsService.getString(prefKey);
      if (guestValString.isNotEmpty) {
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
      dailyGoalMl: await migrateDouble(
          IPrefsService.keyGuestDailyGoalMl, firebaseUser.dailyGoalMl, 2000.0),
      preferredUnit: await migrateEnum(
              IPrefsService.keyGuestPreferredUnit,
              firebaseUser.preferredUnit,
              MeasurementUnit.values,
              MeasurementUnit.ml) ??
          MeasurementUnit.ml,
      dateOfBirth:
          DateTime.tryParse(await prefsService.getString(IPrefsService.keyGuestDateOfBirth)) ??
              firebaseUser.dateOfBirth,
      gender: await migrateEnum(
          IPrefsService.keyGuestGender, firebaseUser.gender, Gender.values, null),
      weightKg: await migrateDouble(IPrefsService.keyGuestWeightKg, firebaseUser.weightKg, null),
      heightCm: await migrateDouble(IPrefsService.keyGuestHeightCm, firebaseUser.heightCm, null),
      activityLevel: await migrateEnum(IPrefsService.keyGuestActivityLevel,
          firebaseUser.activityLevel, ActivityLevel.values, null),
    );

    final guestFavorites = await prefsService.getStringList(IPrefsService.keyGuestFavoriteVolumes);
    if (guestFavorites.isNotEmpty) {
      final defaultFavs = const ['250', '500', '750'];
      bool firebaseIsDefaultFavs =
          listEquals(firebaseUser.favoriteIntakeVolumes, defaultFavs);
      if (firebaseIsDefaultFavs ||
          !listEquals(firebaseUser.favoriteIntakeVolumes, guestFavorites)) {
        userToUpdate =
            userToUpdate.copyWith(favoriteIntakeVolumes: guestFavorites);
      }
    }

    final healthStrings = await prefsService.getStringList(IPrefsService.keyGuestHealthConditions);
    if (healthStrings.isNotEmpty) {
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
      selectedWeatherCondition: await migrateEnum(
              IPrefsService.keyGuestSelectedWeather,
              firebaseUser.selectedWeatherCondition,
              WeatherCondition.values,
              WeatherCondition.temperate) ??
          WeatherCondition.temperate,
    );

    if (userToUpdate != firebaseUser) needsUpdate = true;

    if (needsUpdate) {
      try {
        await userRepository.updateUser(userToUpdate);
        await prefsService.remove(IPrefsService.keyGuestDailyGoalMl);
        await prefsService.remove(IPrefsService.keyGuestPreferredUnit);
        await prefsService.remove(IPrefsService.keyGuestFavoriteVolumes);
        await prefsService.remove(IPrefsService.keyGuestDateOfBirth);
        await prefsService.remove(IPrefsService.keyGuestGender);
        await prefsService.remove(IPrefsService.keyGuestWeightKg);
        await prefsService.remove(IPrefsService.keyGuestHeightCm);
        await prefsService.remove(IPrefsService.keyGuestActivityLevel);
        await prefsService.remove(IPrefsService.keyGuestHealthConditions);
        await prefsService.remove(IPrefsService.keyGuestSelectedWeather);
        return userToUpdate;
      } catch (e) {
        logger.e("UserBloc: Error migrating guest settings: $e");
      }
    }
    return userToUpdate;
  }
}
