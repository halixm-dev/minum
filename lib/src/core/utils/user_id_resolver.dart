import 'package:minum/src/services/auth_service.dart';
import 'package:minum/src/core/constants/app_constants.dart';

class UserIdResolver {
  final AuthService _authService;

  UserIdResolver({required AuthService authService})
      : _authService = authService;

  String get effectiveUserId =>
      _authService.currentUser?.id ?? guestUserId;

  bool get isUserLoggedIn => _authService.currentUser != null;
}
