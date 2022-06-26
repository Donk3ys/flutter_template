import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_frontend/core/constants.dart';
import 'package:flutter_frontend/core/exception.dart';
import 'package:flutter_frontend/core/success.dart';
import 'package:flutter_frontend/data_models/_mock_data.dart';
import 'package:flutter_frontend/data_models/user.dart';
import 'package:flutter_frontend/external_services/utils_external_srv.dart';
import 'package:http/http.dart';
import 'package:loggy/loggy.dart';

class RemoteAuthSource with UiLoggy {
  final Client http;
  final String serverUrl;

  RemoteAuthSource(this.http, this.serverUrl);

  Future<String> getTerms() async {
    final uri = Uri.parse("$serverUrl/terms.php");
    //loggy.debug(uri);

    // Send get request
    final response = await http
        .get(
          uri,
          // headers: {"authorization" : authorization},
        )
        .timeout(kTimeOutDuration);

    // MOCK RESPONSE
    // await Future.delayed(const Duration(seconds: 2));
    // final response = Response(jsonEncode(mockStoreList), HttpStatus.ok,);
    //loggy.debug(json.decode(response.body).toString());

    // DEBUG -> Log status code
    ExternalServiceUtil.printResponseCode(uri, response.statusCode);

    if (response.statusCode == HttpStatus.ok) return response.body;

    throw ExternalServiceUtil.handleResponse(response: response);
  }

  Future<String> refreshAuthToken(String refreshToken) async {
    final uri = Uri.parse("$serverUrl/v1/auth/refresh-auth-token");
    //loggy.debug(uri);

    final refreshMap = {"refresh_token": refreshToken};

    // Send post request
    final response = await http
        .post(
          uri,
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
          body: jsonEncode(refreshMap),
        )
        .timeout(kTimeOutDuration);
    // MOCK RESPONSE
    // final response = Response("", HttpStatus.ok, headers: {"authorization" : "12345"});

    // DEBUG -> Log status code
    ExternalServiceUtil.printResponseCode(uri, response.statusCode);

    if (response.statusCode == HttpStatus.ok) {
      // loggy.debug("refresh token header: ${response.headers['authorization']}");
      return response.headers[kAuthHeader] ?? "null";
    }

    throw ExternalServiceUtil.handleResponse(response: response);
  }

  Future<Map<String, String>> updateRefreshToken(String refreshToken) async {
    final uri = Uri.parse("$serverUrl/v1/auth/update-refresh-token");
    //loggy.debug(uri);

    final refreshMap = {"refresh_token": refreshToken};

    // Send post request
    final response = await http
        .patch(
          uri,
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
          body: jsonEncode(refreshMap),
        )
        .timeout(kTimeOutDuration);
    // MOCK RESPONSE
    // final response = Response("", HttpStatus.ok, headers: {"authorization" : "12345"});

    // DEBUG -> Log status code
    ExternalServiceUtil.printResponseCode(uri, response.statusCode);

    if (response.statusCode == HttpStatus.ok) {
      final map = {
        "authorization": response.headers[kAuthHeader] ?? "null",
        "refresh_token": response.headers[kRefreshHeader] ?? "null",
      };
      return map;
    }

    throw ExternalServiceUtil.handleResponse(response: response);
  }

  Future<User> fetchCurrentUser(String authToken) async {
    final uri = Uri.parse("$serverUrl/v1/auth/current-user");
    //loggy.debug(uri);

    // Send get request
    final response = await http.get(
      uri,
      headers: {kAuthHeader: authToken},
    ).timeout(kTimeOutDuration);

    // MOCK RESPONSE
    // final response = Response(jsonEncode(mockUser), HttpStatus.ok, headers: {"authorization": authorization});
    // loggy.debug(json.decode(response.body).toString());

    // DEBUG -> Log status code
    ExternalServiceUtil.printResponseCode(uri, response.statusCode);

    if (response.statusCode == HttpStatus.ok) {
      final jsonResp = json.decode(response.body);
      final user = User.fromJson(jsonResp as JsonMap);

      return user;
    }

    throw ExternalServiceUtil.handleResponse(response: response);
  }

  Future<User> fetchUserByUuid(String authToken, String uuid) async {
    final uri = Uri.parse("$serverUrl/v1/user?id=$uuid");
    //loggy.debug(uri);

    // Send get request
    final response = await http.get(
      uri,
      headers: {
        kAuthHeader: authToken,
      },
    ).timeout(kTimeOutDuration);

    // DEBUG -> Log status code
    ExternalServiceUtil.printResponseCode(uri, response.statusCode);

    if (response.statusCode == HttpStatus.ok) {
      final jsonResp = json.decode(response.body);
      final user = User.fromJson(jsonResp as JsonMap);
      return user;
    }

    throw ExternalServiceUtil.handleResponse(response: response);
  }

  Future<ServerSuccess<User>> login(User user) async {
    final uri = Uri.parse("$serverUrl/v1/auth/login");

    final userMap = {
      "email": user.email,
      "password": user.password,
      // "firebaseToken": user.firebaseToken,
    };

    // // Send request
    // final response = await http
    //     .post(
    //       uri,
    //       headers: {HttpHeaders.contentTypeHeader: "application/json"},
    //       body: jsonEncode(userMap),
    //     )
    //     .timeout(kTimeOutDuration);

    // MOCK RESPONSE
    final response = Response(
      jsonEncode(mockuser),
      // mockUserParseError,
      HttpStatus.ok,
      headers: {"authorization": "23456", "refresh-token": "23456"},
    );

    // DEBUG -> Log status code
    ExternalServiceUtil.printResponseCode(uri, response.statusCode);

    if (response.statusCode == HttpStatus.ok) {
      final jsonResp = json.decode(response.body);
      final user = User.fromJson(jsonResp as JsonMap);

      final authorization = response.headers[kAuthHeader] ?? "null";
      final refreshToken = response.headers[kRefreshHeader] ?? "null";
      return ServerSuccess(
        authToken: authorization,
        refreshToken: refreshToken,
        object: user,
      );
    }

    throw ExternalServiceUtil.handleResponse(response: response);
  }

  Future<ServerSuccess<User>> signup(User user) async {
    final uri = Uri.parse("$serverUrl/v1/auth/signup");
    //loggy.debug(uri);

    final userMap = user.toJson();
    // loggy.debug(userMap.toString());

    // Send get request
    final response = await http
        .post(
          uri,
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
          body: jsonEncode(userMap),
        )
        .timeout(kTimeOutDuration);

    // MOCK RESPONSE
    // final response = Response(
    //     jsonEncode(mockUser),
    //     201,
    //     headers: {"authorization": "23456", "refresh-token": "23456"}
    // );

    // DEBUG -> Log status code
    ExternalServiceUtil.printResponseCode(uri, response.statusCode);

    if (response.statusCode == HttpStatus.created) {
      final jsonResp = json.decode(response.body);
      final user = User.fromJson(jsonResp as JsonMap);

      final authorization = response.headers[kAuthHeader] ?? "null";
      final refreshToken = response.headers[kRefreshHeader] ?? "null";
      // loggy.debug("authorization: $authorization");
      // loggy.debug("refresh-token: $refreshToken");
      return ServerSuccess(
        authToken: authorization,
        refreshToken: refreshToken,
        object: user,
      );
    } else if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.conflict) {
      throw AuthorizationException("Email already in use");
    }

    throw ExternalServiceUtil.handleResponse(response: response);
  }

  Future<ServerSuccess> logout(String email, String refreshToken) async {
    final uri = Uri.parse("$serverUrl/logout.php");
    //loggy.debug(uri);

    final userMap = {
      "email": email,
      "refresh_token": refreshToken,
    };

    // Send get request
    final response = await http
        .post(
          uri,
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
          body: jsonEncode(userMap),
        )
        .timeout(kTimeOutDuration);

    // MOCK RESPONSE
    // final response = Response("", HttpStatus.ok);

    // DEBUG -> Log status code
    ExternalServiceUtil.printResponseCode(uri, response.statusCode);

    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.unauthorized) {
      return ServerSuccess();
    }

    throw ExternalServiceUtil.handleResponse(response: response);
  }

  Future<User> updateEmail(String authToken, User user) async {
    final uri = Uri.parse("$serverUrl/updateUserEmail.php");
    //loggy.debug(uri);

    final userMap = {
      "password": user.password,
      "new_email": user.email,
    };

    // Send post request
    final response = await http
        .patch(
          uri,
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            kAuthHeader: authToken
          },
          body: jsonEncode(userMap),
        )
        .timeout(kTimeOutDuration);

    // DEBUG -> Log status code
    ExternalServiceUtil.printResponseCode(uri, response.statusCode);

    if (response.statusCode == HttpStatus.ok) return user;

    throw ExternalServiceUtil.handleResponse(response: response);
  }

  Future<User> updatePassword(
    String authToken,
    User user,
    String newPassword,
  ) async {
    final uri = Uri.parse("$serverUrl/updateUserPassword.php");
    //loggy.debug(uri);

    final userMap = {
      "password": user.password,
      "new_password": newPassword,
    };

    // Send post request
    final response = await http
        .patch(
          uri,
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            kAuthHeader: authToken
          },
          body: jsonEncode(userMap),
        )
        .timeout(kTimeOutDuration);

    // DEBUG -> Log status code
    ExternalServiceUtil.printResponseCode(uri, response.statusCode);

    if (response.statusCode == HttpStatus.ok) return user;

    throw ExternalServiceUtil.handleResponse(response: response);
  }

  Future<User> updateUsername(String authToken, User user) async {
    final uri = Uri.parse("$serverUrl/updateUserUsername.php");
    //loggy.debug(uri);

    final userMap = {
      "password": user.password,
      "username": user.username,
    };

    // Send post request
    final response = await http
        .patch(
          uri,
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            kAuthHeader: authToken
          },
          body: jsonEncode(userMap),
        )
        .timeout(kTimeOutDuration);

    // DEBUG -> Log status code
    ExternalServiceUtil.printResponseCode(uri, response.statusCode);

    if (response.statusCode == HttpStatus.ok) return user;

    throw ExternalServiceUtil.handleResponse(response: response);
  }

  Future<ServerSuccess> passwordResetRequest(String email) async {
    final uri = Uri.parse("$serverUrl/passwordResetRequest.php");
    //loggy.debug(uri);

    final emailMap = {
      "email": email,
    };

    // Send post request
    final response = await http
        .post(
          uri,
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
          body: jsonEncode(emailMap),
        )
        .timeout(kTimeOutDuration);

    // DEBUG -> Log status code
    ExternalServiceUtil.printResponseCode(uri, response.statusCode);

    if (response.statusCode == HttpStatus.ok) return kServerSuccess;

    throw ExternalServiceUtil.handleResponse(response: response);
  }

  Future<ServerSuccess> passwordReset(
    String password,
    String passwordResetCode,
  ) async {
    final uri = Uri.parse("$serverUrl/passwordReset.php");
    //loggy.debug(uri);

    final resetPasswordMap = {
      "password": password,
      "code": passwordResetCode,
    };

    // Send post request
    final response = await http
        .post(
          uri,
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
          body: jsonEncode(resetPasswordMap),
        )
        .timeout(kTimeOutDuration);

    // DEBUG -> Log status code
    ExternalServiceUtil.printResponseCode(uri, response.statusCode);

    if (response.statusCode == HttpStatus.ok) return kServerSuccess;

    throw ExternalServiceUtil.handleResponse(response: response);
  }

  Future<ServerSuccess> deleteCurrentUser(String authToken, User user) async {
    final uri = Uri.parse("$serverUrl/deleteAccount.php");
    //loggy.debug(uri);

    final userMap = {
      "password": user.password,
      "email": user.email,
    };

    // Send post request
    final response = await http
        .patch(
          uri,
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            kAuthHeader: authToken
          },
          body: jsonEncode(userMap),
        )
        .timeout(kTimeOutDuration);

    // DEBUG -> Log status code
    ExternalServiceUtil.printResponseCode(uri, response.statusCode);

    if (response.statusCode == HttpStatus.ok) return ServerSuccess();

    throw ExternalServiceUtil.handleResponse(response: response);
  }

  Future<String> updateProfileImage(
    String authToken,
    Uint8List imageByte,
    String imageExtension,
    User user,
  ) async {
    final uri = Uri.parse("$serverUrl/updateProfileImage.php");
    //loggy.debug(uri);

    final updateImageMap = {
      "userUuid": user.uuid,
      "imageUrl": user.profileImageUrl,
      "imageBytes": base64Encode(imageByte),
      "imageExtension": imageExtension,
    };

    // Send post request
    final response = await http
        .post(
          uri,
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            kAuthHeader: authToken
          },
          body: jsonEncode(updateImageMap),
        )
        .timeout(kTimeOutDuration);
    // MOCK RESPONSE
    //await Future.delayed(const Duration(milliseconds: 2700));
    //final mockPostNew = post.copyWith(uuid: Random().nextInt(1000).toString());
    // loggy.info(mockPostNew);
    //final response = Response(jsonEncode(mockPostNew), 201); // Good
    // final response = Response('{"Message" : "Get Feed Err"}', 500); // Good

    // DEBUG -> Log status code ExternalServiceUtil.printResponseCode(uri, response.statusCode);

    // Handle response
    if (response.statusCode == HttpStatus.ok) {
      final jsonResp = json.decode(response.body) as JsonMap;
      return jsonResp["profileImageUrl"] as String? ?? "";
    }

    throw ExternalServiceUtil.handleResponse(response: response);
  }

//   Future<List<FollowedUser>> searchUser(
//     String authorization,
//     String username,
//   ) async {
//     final uri = Uri.parse("$serverUrl/searchUser.php?username=$username");
//     //loggy.debug(uri);
//
//     // Send post request
//     final response = await http.get(
//       uri,
//       headers: {HttpHeaders.contentTypeHeader: "application/json", "authorization": authorization},
//     ).timeout(kTimeOutDuration);
//
//     // MOCK RESPONSE
// //     await Future.delayed(const Duration(milliseconds: 700));
// //     final response = Response(jsonEncode(mockFollowedList), HttpStatus.ok); // Good
//
//     // DEBUG -> Log status code
//     ExternalServiceUtil.printResponseCode(uri, response.statusCode);
//     // Handle response
//     if (response.statusCode == HttpStatus.ok) {
//       final jsonList = json.decode(response.body) as List;
//       return jsonList
//           .map((user) => FollowedUser.fromJson(user as JsonMap))
//           .toList();
//     }
//
//     throw ExternalServiceUtil.handleResponse(response: response);
//   }
}
