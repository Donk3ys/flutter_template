import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants.dart';
import 'package:flutter_frontend/core/exception.dart';
import 'package:flutter_frontend/core/success.dart';
import 'package:flutter_frontend/data_models/user.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loggy/loggy.dart';

const _currentUserKey = 'currentUser';
const _jwtKey = 'jwt';
const _refreshTokenKey = 'refresh_token';
const _themeKey = "theme";

class LocalDataSource with UiLoggy {
  final Box _hiveBox;
  //String _userUuid = "";
  String? _currentJwt;
  String? _currentRefreshToken;

  LocalDataSource(Box hiveBox) : _hiveBox = hiveBox;

  //  Future<void> _getUserUuid() async {
  //   try {
  //     _userUuid = Jwt.parseJwt(await jwt)["uuid"] as String;
  //     // loggy.info("userUuid: $_userUuid");
  //   } catch (e) {
  //     loggy.error("_getUserUuid: $e");
  //   }
  // }

  Future<void> clearLocalStorage() async => _hiveBox.deleteFromDisk();

  // NOTE: Theme
  Future<ThemeMode> get themeMode async {
    final theme = await _hiveBox.get(
      _themeKey,
      defaultValue: describeEnum(ThemeMode.system),
    ) as String;
    // loggy.warning(theme);
    if (theme == describeEnum(ThemeMode.system)) return ThemeMode.system;
    return theme == describeEnum(ThemeMode.dark)
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  Future<CacheSuccess> setTheme(String theme) async {
    //loggy.info("[STORING JWT] : $jwt");
    await _hiveBox.put(_themeKey, theme);
    return kCacheSuccess;
  }

  // NOTE: Json Web Token
  Future<String> get authToken async {
    if (_currentJwt != null) return _currentJwt!;

    // Get jwt
    String jwt = await _hiveBox.get(_jwtKey, defaultValue: "null") as String;
    jwt = await _parseToken(jwt);
    _currentJwt = jwt;

    // loggy.info("[FETCHED JWT] : $jwt");
    return jwt;
  }

  Future<Success> storeAuthToken(String jwt) async {
    //loggy.info("[STORING JWT] : $jwt");
    await _hiveBox.put(_jwtKey, jwt);
    return kCacheSuccess;
  }

  // NOTE: Refresh Token
  Future<String> get refreshToken async {
    if (_currentRefreshToken != null) return _currentRefreshToken!;

    // Get jwt
    String refreshToken =
        await _hiveBox.get(_refreshTokenKey, defaultValue: "null") as String;
    refreshToken = await _parseToken(refreshToken);
    _currentRefreshToken = refreshToken;

    // loggy.info("[FETCHED REFRESH TOKEN] : $refreshToken");
    return refreshToken;
  }

  Future<CacheSuccess> storeRefreshToken(String refreshToken) async {
    // loggy.info("[STORING REFRESH TOKEN] : $refreshToken");
    await _hiveBox.put(_refreshTokenKey, refreshToken);

    return kCacheSuccess;
  }

  Future<String> _parseToken(String token) async {
    if (token == "null" || token.isEmpty) {
      throw NoTokenException();
    }

    String parsedToken = token;
    if (parsedToken[0] == "'") {
      parsedToken = parsedToken.substring(1, parsedToken.length);
    }
    if (token[token.length - 1] == "'") {
      parsedToken = parsedToken.substring(0, parsedToken.length - 1);
    }

    return parsedToken;
  }

  // NOTE: Current User
  Future<User> get currentUser async {
    final userJson =
        await _hiveBox.get(_currentUserKey, defaultValue: "null") as String;
    if (userJson == "null") {
      throw AuthorizationException("No user stored in cache");
    }

    final jsonUser = jsonDecode(userJson);
    final currentUser = User.fromJson(jsonUser as Map<String, dynamic>);

    if (currentUser.uuid == "-1") {
      throw AuthorizationException('No user stored in cache');
    }

    //loggy.info("[FETCHED CURRENT USER] : $currentUser");
    return currentUser;
  }

  Future<Success> storeCurrentUser(User? user) async {
    // loggy.info("[STORING CURRENT USER] : $user");
    String userJson = "null";
    if (user != null) userJson = jsonEncode(user.toJson());
    await _hiveBox.put(_currentUserKey, userJson);

    return CacheSuccess();
  }
}
