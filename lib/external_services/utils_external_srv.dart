import 'dart:convert';
import 'dart:io';

import 'package:flutter_frontend/core/constants.dart';
import 'package:flutter_frontend/core/exception.dart';
import 'package:http/http.dart';
import 'package:loggy/loggy.dart';

final _errorLogger = Loggy("External Data Source");

mixin ExternalServiceUtil {
  static Exception handleResponse({required Response response}) {
    if (response.body.isEmpty) {
      return RemoteDataSourceException(kMessageUnexpectedServerError);
    }
    final jsonResp = json.decode(response.body) as JsonMap;
    final message =
        jsonResp["message"] as String? ?? kMessageUnexpectedServerError;
    final errorMsg = jsonResp["error"] as String?;
    if (response.statusCode == 401) return AuthorizationException(message);
    if (response.statusCode == 502) return const SocketException("Bad Gateway");
    return RemoteDataSourceException(message, errorMessage: errorMsg ?? "");
  }

  static void printResponseCode(
    Uri uri,
    int responseCode, {
    StackTrace? trace,
  }) {
    _errorLogger.info("$uri -> Response Code: $responseCode", null, trace);
  }
}
