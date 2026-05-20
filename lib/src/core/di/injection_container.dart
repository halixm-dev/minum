import 'package:get_it/get_it.dart';
import 'package:minum/src/features/auth/data/datasources/firebase_auth_repository.dart';
import 'package:minum/src/features/auth/data/repositories/auth_repository.dart';
import 'package:minum/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:minum/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:minum/src/features/user/data/datasources/firebase_user_repository.dart';
import 'package:minum/src/features/user/data/models/user_model.dart';
import 'package:minum/src/features/user/data/repositories/user_repository.dart';
import 'package:minum/src/features/hydration/data/datasources/firebase_hydration_repository.dart';
import 'package:minum/src/features/hydration/data/datasources/local_hydration_repository.dart';
import 'package:minum/src/features/hydration/data/repositories/hydration_repository.dart';
import 'package:minum/src/features/hydration/data/repositories/syncable_hydration_repository.dart';
import 'package:minum/src/services/auth_service.dart';
import 'package:minum/src/services/i_health_service.dart';
import 'package:minum/src/services/health_service.dart';
import 'package:minum/src/services/hydration_service.dart';
import 'package:minum/src/services/i_notification_service.dart';
import 'package:minum/src/services/notification_service.dart';
import 'package:minum/src/services/prefs/i_prefs_service.dart';
import 'package:minum/src/services/prefs/prefs_service.dart';
import 'package:minum/src/core/utils/user_id_resolver.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Prefs
  final prefsService = PrefsService();
  await prefsService.init();
  sl.registerLazySingleton<IPrefsService>(() => prefsService);

  // Services
  sl.registerLazySingleton<INotificationService>(
      () => AwesomeNotificationService(prefsService: sl<IPrefsService>()));
  sl.registerLazySingleton<IHealthService>(() => AndroidHealthService());

  // UserIdResolver
  sl.registerLazySingleton<UserIdResolver>(
      () => UserIdResolver(authService: sl<AuthService>()));

  // Data layer: Repositories
  sl.registerLazySingleton<UserRepository>(() => FirebaseUserRepository());
  sl.registerLazySingleton<AuthRepository>(
      () => FirebaseAuthRepository(userRepository: sl<UserRepository>()));
  sl.registerLazySingleton<LocalHydrationRepository>(
      () => LocalHydrationRepository());
  sl.registerLazySingleton<FirebaseHydrationRepository>(
      () => FirebaseHydrationRepository());

  // Auth Service
  sl.registerLazySingleton<AuthService>(
      () => AuthService(authRepository: sl<AuthRepository>(), userRepository: sl<UserRepository>()));

  // Auth Bloc
  sl.registerLazySingleton<AuthBloc>(
      () => AuthBloc(authService: sl<AuthService>()));

  // Hydration
  sl.registerLazySingleton<HydrationRepository>(() => SyncableHydrationRepository(
      localRepository: sl<LocalHydrationRepository>(),
      firebaseRepository: sl<FirebaseHydrationRepository>(),
      userIdResolver: sl<UserIdResolver>()));

  // Initialize the repository with auth stream from AuthBloc
  final authStream = sl<AuthBloc>().stream.map<UserModel?>((state) =>
      state is Authenticated ? state.user : null);
  (sl<HydrationRepository>() as SyncableHydrationRepository).init(authStream);

  sl.registerLazySingleton<HydrationService>(
      () => HydrationService(
          hydrationRepository: sl<HydrationRepository>(),
          healthService: sl<IHealthService>(),
          prefsService: sl<IPrefsService>()));
}
