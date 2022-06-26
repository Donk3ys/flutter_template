import 'dart:typed_data';

import 'package:flutter_frontend/core/constants.dart';
import 'package:flutter_frontend/core/exception.dart';
import 'package:flutter_frontend/core/success.dart';
import 'package:flutter_frontend/core/util_core.dart';
import 'package:flutter_frontend/data_models/user.dart';
import 'package:flutter_frontend/external_services/local_data_src.dart';
import 'package:flutter_frontend/external_services/remote_auth_src.dart';
import 'package:flutter_frontend/main.mapper.g.dart';
import 'package:flutter_frontend/repositories/utils_repo.dart';

class AuthRepository {
  final LocalDataSource _localDataSource;
  final RemoteAuthSource _remoteAuthSource;
  final JwtUtil _jwt;
  final bool testMode;

  AuthRepository({
    required LocalDataSource localDataSource,
    required RemoteAuthSource remoteAuthSource,
    required JwtUtil jwtUtil,
    this.testMode = false,
  })  : _localDataSource = localDataSource,
        _remoteAuthSource = remoteAuthSource,
        _jwt = jwtUtil;

  bool _updatingToken = false;

  // AUTH FUNCTIONS WITHOUT CALL TO REMOTE SERVER
  Future<String> get fetchAuthToken async {
    if (testMode) return "";

    // Run to stop race condition -> "other call to get jwt" has finished
    int retryCounter = 100;
    while (_updatingToken && retryCounter >= 0) {
      await Future.delayed(const Duration(milliseconds: 50));
      retryCounter--;
    }

    // Get jwt
    final authToken = await _localDataSource.authToken;

    // Check if expired
    if (_jwt.isNotExpired(authToken)) return authToken;

    _updatingToken = true;
    final refreshToken = await _localDataSource.refreshToken;

    // Check if refreshToken expired
    late String newJwt;
    if (_jwt.isExpired(refreshToken)) {
      // Update refreshToken remotely
      final tokenMap = await _remoteAuthSource.updateRefreshToken(refreshToken);
      newJwt = tokenMap["authorization"] ?? "null";
      _localDataSource.storeRefreshToken(tokenMap["refresh_token"] ?? "null");
    } else {
      // Update jwt
      newJwt = await _remoteAuthSource.refreshAuthToken(refreshToken);
    }

    await _localDataSource.storeAuthToken(newJwt);
    _updatingToken = false;
    return newJwt;
  }

  Future<Success> logout(String email) async {
    // Store nullJwt & nullUser
    await Future.wait([
      _localDataSource.storeAuthToken('null'),
      _localDataSource.storeRefreshToken('null'),
      _localDataSource.storeCurrentUser(null),
    ]);
    return kCacheSuccess;
  }

  // AUTH FUNCTIONS TO REMOTE SERVER WITHOUT JWT AND STORE RETURN DATA -> LOGIN & REGISTER
  Future<User> _remoteCallToFetchUser(Function() function) async {
    final success = await function() as ServerSuccess<User>;
    // Success -> object == <User>
    final usr = success.object;
    if (usr == null) {
      throw AuthorizationException("No user returned with login");
    }

    // throw AuthorizationException("Wrong Pw");
    // final usr = User.init().copyWith(uuid: "1", username: "Donk3y");

    // Store jwt & user
    await Future.wait([
      _localDataSource.storeAuthToken(success.authToken),
      _localDataSource.storeRefreshToken(success.refreshToken),
      _localDataSource.storeCurrentUser(usr),
    ]);

    return usr;
  }

  Future<User> login(User user) =>
      _remoteCallToFetchUser(() => _remoteAuthSource.login(user));

  Future<User> signup(User user) =>
      _remoteCallToFetchUser(() => _remoteAuthSource.signup(user));

  // AUTH FUNCTIONS TO REMOTE SERVER WITHOUT JWT
  Future<Success> passwordResetRequest(String email) async =>
      _remoteAuthSource.passwordResetRequest(email);

  Future<Success> passwordReset(
    String password,
    String passwordResetCode,
  ) =>
      _remoteAuthSource.passwordReset(password, passwordResetCode);

  // Future<Either<Failure, String>> getTerms() async =>
  //     _remoteCallWithoutJwt(() => remoteAuthSource.getTerms());
  //
  // Future<Either<Failure, List<String>>> checkUsernameValid(
  //   String username,
  // ) async =>
  //     _remoteCallWithoutJwt(
  //       () => remoteAuthSource.checkUsernameValid(username),
  //     );

  // AUTH FUNCTIONS TO REMOTE SERVER WITH JWT AND SAVE USER
  Future<User> _remoteCallWithJwtAndSaveUser<R>(
    Function(String) function,
  ) async {
    // Get jwt
    final jwt = await fetchAuthToken;

    final user = await function(jwt) as User;
    await _localDataSource.storeCurrentUser(user);

    return user;
  }

  Future<User> updateEmail(User user) => _remoteCallWithJwtAndSaveUser(
        (jwt) => _remoteAuthSource.updateEmail(jwt, user),
      );

  Future<User> updatePassword(
    User user,
    String newPassword,
  ) async =>
      _remoteCallWithJwtAndSaveUser(
        (jwt) => _remoteAuthSource.updatePassword(jwt, user, newPassword),
      );

  Future<User> updateUsername(User user) => _remoteCallWithJwtAndSaveUser(
        (jwt) => _remoteAuthSource.updateUsername(jwt, user),
      );

  // AUTH FUNCTIONS TO REMOTE SERVER WITH JWT
  Future<ServerSuccess> deleteCurrentUser(User user) =>
      RepoUtil.remoteCallWithAuthToken(
        (jwt) => _remoteAuthSource.deleteCurrentUser(jwt, user),
      );

  Future<User> fetchUserByUuid(String uuid) => RepoUtil.remoteCallWithAuthToken(
        (jwt) => _remoteAuthSource.fetchUserByUuid(jwt, uuid),
      );

  Future<String> updateProfileImage(
    Uint8List imageByte,
    String imageExtension,
    User user,
  ) async =>
      RepoUtil.remoteCallWithAuthToken(
        (jwt) => _remoteAuthSource.updateProfileImage(
          jwt,
          imageByte,
          imageExtension,
          user,
        ),
      );

  // FULL FUNCTIONS
  Future<User> getCurrentUserLocal() async {
    // await Future.delayed(const Duration(seconds: 1));
    // // throw Exception("ERRROR GETTING USER");
    // _currentUser = User.init().copyWith(uuid: "1", username: "Donk3y");

    return _localDataSource.currentUser;
  }

  Future<User> fetchCurrentUserRemotely() async {
    final jwt = await fetchAuthToken;

    final user = await _remoteAuthSource.fetchCurrentUser(jwt);
    await _localDataSource.storeCurrentUser(user);

    return user;
  }
}
