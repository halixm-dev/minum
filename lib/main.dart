import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:minum/src/app.dart';
import 'package:minum/firebase_options.dart';
import 'package:minum/src/core/di/injection_container.dart';
import 'package:minum/src/core/utils/logger.dart';
import 'package:minum/src/core/utils/user_id_resolver.dart';
import 'package:minum/src/services/i_notification_service.dart';
import 'package:minum/src/services/hydration_service.dart';
import 'package:minum/src/services/i_health_service.dart';
import 'package:minum/src/services/prefs/i_prefs_service.dart';
import 'package:minum/src/features/user/data/repositories/user_repository.dart';
import 'package:minum/src/features/hydration/data/repositories/hydration_repository.dart';
import 'package:minum/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:minum/src/presentation/providers/theme_provider.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_bloc.dart';
import 'package:minum/src/features/user/presentation/bloc/user_bloc.dart';
import 'package:minum/src/presentation/providers/bottom_nav_provider.dart';
import 'package:minum/src/features/settings/presentation/bloc/reminder_settings_cubit.dart';
import 'package:minum/src/features/settings/presentation/bloc/next_reminder_cubit.dart';
import 'package:minum/src/features/hydration/presentation/bloc/hydration_history_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.i("Firebase initialized successfully");
  } catch (e) {
    logger.e("Firebase initialization failed: $e");
  }

  await init();

  final notificationService = sl<INotificationService>();
  await notificationService.init();
  logger.i("NotificationService initialized");

  try {
    await notificationService.scheduleDailyRemindersIfNeeded();
    logger.i("Attempted to schedule daily reminders on startup.");
  } catch (e) {
    logger.e("Error calling scheduleDailyRemindersIfNeeded on startup: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<HydrationService>.value(value: sl<HydrationService>()),
        Provider<IHealthService>.value(value: sl<IHealthService>()),
        Provider<INotificationService>.value(value: sl<INotificationService>()),
        Provider<UserRepository>.value(value: sl<UserRepository>()),
        Provider<HydrationRepository>.value(value: sl<HydrationRepository>()),
        Provider<IPrefsService>.value(value: sl<IPrefsService>()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),
        BlocProvider(create: (_) => ReminderSettingsCubit()),
        BlocProvider<AuthBloc>.value(
          value: sl<AuthBloc>(),
        ),
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(
            authBloc: context.read<AuthBloc>(),
            userRepository: context.read<UserRepository>(),
            prefsService: context.read<IPrefsService>(),
          ),
        ),
        BlocProvider<HydrationBloc>(
          create: (context) => HydrationBloc(
            authBloc: context.read<AuthBloc>(),
            hydrationService: context.read<HydrationService>(),
            prefsService: context.read<IPrefsService>(),
            userIdResolver: sl<UserIdResolver>(),
          ),
        ),
        BlocProvider<HydrationHistoryCubit>(
          create: (context) => HydrationHistoryCubit(
            hydrationService: context.read<HydrationService>(),
          ),
        ),
        BlocProvider<NextReminderCubit>(
          create: (context) => NextReminderCubit(
            notificationService: context.read<INotificationService>(),
          ),
        ),
      ],
      child: const MinumApp(),
    ),
  );
}
