import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:minum/src/data/repositories/firebase/firebase_auth_repository.dart';
import 'package:minum/src/data/repositories/user_repository.dart';

// Generate mocks
@GenerateNiceMocks([
  MockSpec<fb_auth.FirebaseAuth>(),
  MockSpec<GoogleSignIn>(),
  MockSpec<UserRepository>(),
  MockSpec<fb_auth.UserCredential>(),
  MockSpec<fb_auth.User>(),
  MockSpec<GoogleSignInAccount>(),
  MockSpec<GoogleSignInAuthentication>(),
])
import 'firebase_auth_repository_test.mocks.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockUserRepository mockUserRepository;
  late FirebaseAuthRepository authRepository;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockUserRepository = MockUserRepository();
    authRepository = FirebaseAuthRepository(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
      userRepository: mockUserRepository,
    );
  });

  group('signInWithGoogle', () {
    test('returns null when Google Sign-In is cancelled by user (exception)',
        () async {
      // Arrange
      when(mockGoogleSignIn.initialize()).thenAnswer((_) async => null);
      when(mockGoogleSignIn.authenticate()).thenThrow(
        GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
      );

      // Act
      final result = await authRepository.signInWithGoogle();

      // Assert
      expect(result, isNull);
      verify(mockGoogleSignIn.authenticate()).called(1);
      verifyNever(mockFirebaseAuth.signInWithCredential(any));
    });
  });
}
