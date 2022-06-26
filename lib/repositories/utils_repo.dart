import 'dart:async';

import 'package:flutter_frontend/repositories/auth_repo.dart';
import 'package:flutter_frontend/service_locator.dart';
import 'package:loggy/loggy.dart';

final exceptionLogger = Loggy("Exception");

mixin RepoUtil {
  // AUTH FUNCTIONS TO REMOTE SERVER WITHOUT AUTH TOKEN
  static Future<R> remoteCall<R>(
    Function() function,
  ) async {
    // final authRepo = sl<AuthRepository>();

    // Check if online
    // if (!await authRepo.networkInfo.hasInternetConnection) {
    //   return left(OfflineFailure());
    // }

    return await function() as R;
  }

  // AUTH FUNCTIONS TO REMOTE SERVER WITH AUTH TOKEN
  static Future<R> remoteCallWithAuthToken<R>(
    Function(String) function,
  ) async {
    final authRepo = sl<AuthRepository>();

    // Check if online
    // if (!await authRepo.networkInfo.hasInternetConnection) {
    //   return left(OfflineFailure());
    // }

    // Get jwt
    final jwt = await authRepo.fetchAuthToken;

    return await function(jwt) as R;
  }
}
