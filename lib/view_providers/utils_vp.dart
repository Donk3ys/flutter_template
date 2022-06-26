import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants.dart';
import 'package:flutter_frontend/core/exception.dart';
import 'package:flutter_frontend/widgets/snackbar.dart';
import 'package:loggy/loggy.dart';

final _exceptionLogger = Loggy("Exception_Parser");

mixin NotifierUtil {
  static void _logError(StackTrace? trace, Object e) {
    final message = e.toString();
    String errorMessage = "";
    if (e is NoTokenException) return;
    if (e is RemoteDataSourceException && e.errorMessage.isNotEmpty) {
      errorMessage = "\nerror:\t${e.errorMessage}";
    }
    _exceptionLogger.error(
      'type:\t${e.runtimeType}\nmessage:\t$message$errorMessage',
      null,
      trace,
    );
  }

  static void _handleOfflineError(BuildContext context) {
    InfoSnackBar.showError(context, kConnectionErrorMessage);
    // final networkVM = context.read(networkVMProvider);
    // networkVM.streamNetworkStatus();
    // return;
  }

  static Future<void> _handleException(
    Object err,
    StackTrace trace, {
    required BuildContext context,
    bool showErrorSnackbar = true,
  }) async {
    final message = err.toString();
    _logError(trace, message);

    // If not show snackbar, still handle offline exceptions
    if (message.contains(kXMLHttpRequestError) ||
        ((err.runtimeType == TimeoutException ||
                err.runtimeType == SocketException) &&
            !showErrorSnackbar)) _handleOfflineError(context);
    if (!showErrorSnackbar) return;

    if (err is Error) {
      InfoSnackBar.showError(context, kMessageUnexpectedFormatError);
      return;
    }
    switch (err.runtimeType) {
      case AuthorizationException:
        {
          InfoSnackBar.showError(context, message);
          // return AuthFailure(message);
          break;
        }
      case CacheException:
        {
          InfoSnackBar.showError(context, kMessageUnexpectedCacheError);
          // return CacheFailure(message);
          break;
        }
      case FormatException:
        {
          InfoSnackBar.showError(context, kMessageUnexpectedFormatError);
          // return FormatFailure(kMessageUnexpectedServerError);
          break;
        }
      case FromJsonException:
        {
          InfoSnackBar.showError(context, kMessageUnexpectedFormatError);
          // return FormatFailure(kMessageUnexpectedServerError);
          break;
        }
      case NoTokenException:
        {
          InfoSnackBar.showError(context, message);
          // return NoTokenFailure();
          break;
        }
      case SocketException:
        {
          _handleOfflineError(context);
          // return OfflineFailure();
          break;
        }
      case TimeoutException:
        {
          _handleOfflineError(context);
          // return OfflineFailure();
          break;
        }

      default:
        {
          InfoSnackBar.showError(context, kMessageUnexpectedServerError);
          // return ServerFailure(message);
        }
    }
  }

  // NOTE: wrapper for return requests that throw errors
  static Future<R?> makeCall<R>({
    required BuildContext context,
    required Future<R> Function() call,
    bool showError = false,
  }) async {
    try {
      //await Future.delayed(const Duration(milliseconds: 1000));
      final rValue = await call();
      return rValue;
    } catch (e, s) {
      _handleException(
        e,
        s,
        context: context,
        showErrorSnackbar: showError,
      );
      return null;
    }
  }
}
