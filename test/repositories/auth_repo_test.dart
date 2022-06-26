import 'package:flutter_frontend/core/success.dart';
import 'package:flutter_frontend/core/util_core.dart';
import 'package:flutter_frontend/data_models/user.dart';
import 'package:flutter_frontend/external_services/local_data_src.dart';
import 'package:flutter_frontend/external_services/remote_auth_src.dart';
import 'package:flutter_frontend/repositories/auth_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalDataSource extends Mock implements LocalDataSource {}

class MockRemoteAuthSource extends Mock implements RemoteAuthSource {}

class MockJwtUtil extends Mock implements JwtUtil {}

void main() {
  late MockLocalDataSource mockLocalDataSource;
  late MockRemoteAuthSource mockRemoteAuthSource;
  late MockJwtUtil mockJwtUtil;
  late AuthRepository authRepo;

  setUp(() {
    mockLocalDataSource = MockLocalDataSource();
    mockRemoteAuthSource = MockRemoteAuthSource();
    mockJwtUtil = MockJwtUtil();
    authRepo = AuthRepository(
      localDataSource: mockLocalDataSource,
      remoteAuthSource: mockRemoteAuthSource,
      jwtUtil: mockJwtUtil,
    );
  });

  const mAuthToken = "Auth-Token";
  const mRefreshToken = "Refresh-Token";
  const mNewAuthToken = "New-Auth-Token";
  const mNewRefreshToken = "New-Refresh-Token";
  const mTokenMap = {
    "authorization": mNewAuthToken,
    "refresh_token": mNewRefreshToken,
  };
  const mNullString = 'null';
  const mEmail = "email";
  const mPassword = "password";
  final mUser = User(
    uuid: "1",
    email: mEmail,
    password: mPassword,
    username: "username",
    profileImageUrl: "url",
    createdAt: DateTime(1970),
    status: UserStatus.activated,
  );
  final mCacheSuccess = CacheSuccess();
  final mServerSucessUser = ServerSuccess(
    object: mUser,
    authToken: mAuthToken,
    refreshToken: mRefreshToken,
  );
  final mServerSucessEmpty = ServerSuccess();

  void _verifyNoMoreInteractions() {
    verifyNoMoreInteractions(mockLocalDataSource);
    verifyNoMoreInteractions(mockRemoteAuthSource);
    verifyNoMoreInteractions(mockJwtUtil);
  }

  group('fetchAuthToken', () {
    test('should get auth-token from local source', () async {
      // Arrange
      when(() => mockLocalDataSource.authToken)
          .thenAnswer((_) async => mAuthToken);
      when(() => mockJwtUtil.isNotExpired(mAuthToken)).thenReturn(true);

      // Act
      final result = await authRepo.fetchAuthToken;

      // Assert
      expect(result, mAuthToken);
      verify(() => mockLocalDataSource.authToken);
      verify(() => mockJwtUtil.isNotExpired(mAuthToken));
      _verifyNoMoreInteractions();
    });

    test(
        'should get new-auth-token from remote storage when auth-token has expired and refresh-token has not expired',
        () async {
      // Arrange
      when(() => mockLocalDataSource.authToken)
          .thenAnswer((_) async => mAuthToken);
      when(() => mockJwtUtil.isNotExpired(mAuthToken)).thenReturn(false);
      when(() => mockLocalDataSource.refreshToken)
          .thenAnswer((_) async => mRefreshToken);
      when(() => mockJwtUtil.isExpired(mRefreshToken)).thenReturn(false);
      when(() => mockRemoteAuthSource.refreshAuthToken(mRefreshToken))
          .thenAnswer((_) async => mNewAuthToken);
      when(() => mockLocalDataSource.storeAuthToken(mNewAuthToken))
          .thenAnswer((_) async => ServerSuccess());

      // Act
      final result = await authRepo.fetchAuthToken;

      // Assert
      expect(result, mNewAuthToken);
      verify(() => mockLocalDataSource.authToken);
      verify(() => mockJwtUtil.isNotExpired(mAuthToken));
      verify(() => mockLocalDataSource.refreshToken);
      verify(() => mockJwtUtil.isExpired(mRefreshToken));
      verify(() => mockRemoteAuthSource.refreshAuthToken(mRefreshToken));
      verify(() => mockLocalDataSource.storeAuthToken(mNewAuthToken));
      verifyNever(() => mockRemoteAuthSource.updateRefreshToken(any()));
      verifyNever(() => mockLocalDataSource.storeRefreshToken(any()));
      _verifyNoMoreInteractions();
    });

    test(
        'should get new-auth-token and new-refresh-token from remote storage when auth-token has expired and refresh-token has expired',
        () async {
      // Arrange
      when(() => mockLocalDataSource.authToken)
          .thenAnswer((_) async => mAuthToken);
      when(() => mockJwtUtil.isNotExpired(mAuthToken)).thenReturn(false);
      when(() => mockLocalDataSource.refreshToken)
          .thenAnswer((_) async => mRefreshToken);
      when(() => mockJwtUtil.isExpired(mRefreshToken)).thenReturn(true);
      when(() => mockRemoteAuthSource.updateRefreshToken(mRefreshToken))
          .thenAnswer((_) async => mTokenMap);
      when(() => mockLocalDataSource.storeRefreshToken(mNewRefreshToken))
          .thenAnswer((_) async => CacheSuccess());
      when(() => mockLocalDataSource.storeAuthToken(mNewAuthToken))
          .thenAnswer((_) async => ServerSuccess());

      // Act
      final result = await authRepo.fetchAuthToken;

      // Assert
      expect(result, mNewAuthToken);
      verify(() => mockLocalDataSource.authToken);
      verify(() => mockJwtUtil.isNotExpired(mAuthToken));
      verify(() => mockLocalDataSource.refreshToken);
      verify(() => mockJwtUtil.isExpired(mRefreshToken));
      verify(() => mockRemoteAuthSource.updateRefreshToken(mRefreshToken));
      verify(() => mockLocalDataSource.storeRefreshToken(mNewRefreshToken));
      verify(() => mockLocalDataSource.storeAuthToken(mNewAuthToken));
      verifyNever(() => mockRemoteAuthSource.refreshAuthToken(any()));
      _verifyNoMoreInteractions();
    });
  });

  test('should set tokens and user to "null"/null when logging out', () async {
    // Arrange
    when(() => mockLocalDataSource.storeAuthToken(mNullString))
        .thenAnswer((_) async => mCacheSuccess);
    when(() => mockLocalDataSource.storeRefreshToken(mNullString))
        .thenAnswer((_) async => mCacheSuccess);
    when(() => mockLocalDataSource.storeCurrentUser(null))
        .thenAnswer((_) async => mCacheSuccess);

    // Act
    final result = await authRepo.logout("");

    // Assert
    expect(result, mCacheSuccess);
    verify(() => mockLocalDataSource.storeAuthToken(mNullString));
    verify(() => mockLocalDataSource.storeRefreshToken(mNullString));
    verify(() => mockLocalDataSource.storeCurrentUser(null));
    _verifyNoMoreInteractions();
  });

  group('login & signup', () {
    void _setUpLoginAndRegisterSuccess() {
      when(() => mockLocalDataSource.storeAuthToken(mAuthToken))
          .thenAnswer((_) async => mCacheSuccess);
      when(() => mockLocalDataSource.storeRefreshToken(mRefreshToken))
          .thenAnswer((_) async => mCacheSuccess);
      when(() => mockLocalDataSource.storeCurrentUser(mUser))
          .thenAnswer((_) async => mCacheSuccess);
    }

    void _verifyLoginAndregisterSuccess() {
      verify(() => mockLocalDataSource.storeAuthToken(mAuthToken));
      verify(() => mockLocalDataSource.storeRefreshToken(mRefreshToken));
      verify(() => mockLocalDataSource.storeCurrentUser(mUser));
      _verifyNoMoreInteractions();
    }

    test('should return a user when login success', () async {
      // Arrange
      when(() => mockRemoteAuthSource.login(mUser))
          .thenAnswer((_) async => mServerSucessUser);
      _setUpLoginAndRegisterSuccess();

      // Act
      final result = await authRepo.login(mUser);

      // Assert
      expect(result, mUser);
      verify(() => mockRemoteAuthSource.login(mUser));
      _verifyLoginAndregisterSuccess();
    });

    test('should return a user when login success', () async {
      // Arrange
      when(() => mockRemoteAuthSource.signup(mUser))
          .thenAnswer((_) async => mServerSucessUser);
      _setUpLoginAndRegisterSuccess();

      // Act
      final result = await authRepo.signup(mUser);

      // Assert
      expect(result, mUser);
      verify(() => mockRemoteAuthSource.signup(mUser));
      _verifyLoginAndregisterSuccess();
    });
  });

  group('password reset', () {
    test('should return Success when password reset request sent', () async {
      // Arrange
      when(() => mockRemoteAuthSource.passwordResetRequest(mEmail))
          .thenAnswer((_) async => mServerSucessEmpty);

      // Act
      final result = await authRepo.passwordResetRequest(mEmail);

      // Assert
      expect(result, mServerSucessEmpty);
      verify(() => mockRemoteAuthSource.passwordResetRequest(mEmail));
    });

    const mPasswordResetCode = "code";
    test('should return Success when password reset sent', () async {
      // Arrange
      when(() =>
              mockRemoteAuthSource.passwordReset(mPassword, mPasswordResetCode))
          .thenAnswer((_) async => mServerSucessEmpty);

      // Act
      final result =
          await authRepo.passwordReset(mPassword, mPasswordResetCode);

      // Assert
      expect(result, mServerSucessEmpty);
      verify(() =>
          mockRemoteAuthSource.passwordReset(mPassword, mPasswordResetCode));
    });
  });
}

// test('should throw NoTokenException when auth-token not stored localy',
//     () async {
//   // Arrange
//   when(() => mockLocalDataSource.authToken).thenThrow(NoTokenException());
//
//   // Assert
//   expect(
//     () => authRepo.fetchAuthToken,
//     throwsA(isA<NoTokenException>()),
//   );
//   verify(() => mockLocalDataSource.authToken);
//   _verifyNoMoreInteractions();
// });
//
// test('should throw NoTokenException when refresh-token not stored localy',
//     () async {
//   // Arrange
//   when(() => mockLocalDataSource.authToken)
//       .thenAnswer((_) async => mAuthToken);
//   when(() => mockJwtUtil.isNotExpired(mAuthToken)).thenReturn(false);
//   when(() => mockLocalDataSource.refreshToken)
//       .thenThrow(NoTokenException());
//
//   expect(
//     () => authRepo.fetchAuthToken,
//     throwsA(isA<NoTokenException>()),
//   );
// });
