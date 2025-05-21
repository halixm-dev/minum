// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

// App specific imports
import 'package:minum/src/app.dart';
import 'package:minum/firebase_options.dart';

// Data Layer: Repositories
import 'package:minum/src/data/repositories/auth_repository.dart';
import 'package:minum/src/data/repositories/firebase/firebase_auth_repository.dart';
import 'package:minum/src/data/repositories/user_repository.dart';
import 'package:minum/src/data/repositories/firebase/firebase_user_repository.dart';
import 'package:minum/src/data/repositories/hydration_repository.dart';
import 'package:minum/src/data/repositories/firebase/firebase_hydration_repository.dart';
import 'package:minum/src/data/repositories/local/local_hydration_repository.dart';
import 'package:minum/src/data/repositories/syncable_hydration_repository.dart';

// Service Layer
import 'package:minum/src/services/auth_service.dart';
import 'package:minum/src/services/notification_service.dart';
import 'package:minum/src/services/hydration_service.dart';

// Presentation Layer: Providers
import 'package:minum/src/presentation/providers/auth_provider.dart';
import 'package:minum/src/presentation/providers/theme_provider.dart';
import 'package:minum/src/presentation/providers/hydration_provider.dart';
import 'package:minum/src/presentation/providers/user_provider.dart';
import 'package:minum/src/presentation/providers/bottom_nav_provider.dart'; // Import BottomNavProvider


// Global logger instance
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 5,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    // Updated: Replaced 'printTime: false' with 'dateTimeFormat: DateTimeFormat.none'
    dateTimeFormat: DateTimeFormat.none,
  ),
);

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

  final notificationService = NotificationService();
  await notificationService.init();
  logger.i("NotificationService initialized");

  final UserRepository userRepository = FirebaseUserRepository();
  final AuthRepository authRepository = FirebaseAuthRepository(userRepository: userRepository);

  final LocalHydrationRepository localHydrationRepository = LocalHydrationRepository();
  final FirebaseHydrationRepository firebaseHydrationRepository = FirebaseHydrationRepository();

  final AuthService authService = AuthService(
    authRepository: authRepository,
    userRepository: userRepository,
  );

  final HydrationRepository syncableHydrationRepository = SyncableHydrationRepository(
    localRepository: localHydrationRepository,
    firebaseRepository: firebaseHydrationRepository,
    authService: authService,
  );

  final HydrationService hydrationService = HydrationService(
    hydrationRepository: syncableHydrationRepository,
  );


  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        Provider<HydrationService>.value(value: hydrationService),
        Provider<NotificationService>.value(value: notificationService),
        Provider<UserRepository>.value(value: userRepository),
        Provider<HydrationRepository>.value(value: syncableHydrationRepository),

        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavProvider()), // Add BottomNavProvider
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(
            authService: context.read<AuthService>(),
            userRepository: context.read<UserRepository>(),
          ),
        ),
        ChangeNotifierProvider<HydrationProvider>(
          create: (context) => HydrationProvider(
            authService: context.read<AuthService>(),
            hydrationService: context.read<HydrationService>(),
          ),
        ),
      ],
      child: const MinumApp(),
    ),
  );
}
