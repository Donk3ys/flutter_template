import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/success.dart';

const kVersion = 'Powered by Donk3y [0.0.0]'; // 16:40 14 Oct 2021

// TYPE DEF
typedef JsonMap = Map<String, dynamic>;

// NETWORKING
const kTimeOutDuration = Duration(seconds: 30);

// Objects
const kUndefined = Object();
final kCacheSuccess = CacheSuccess();
final kServerSuccess = ServerSuccess();

// COLORS
const kColorBackgroundDark = Colors.black;
final kColorBackgroundLight = Colors.grey[200];

const kColorAccent = Colors.amber;

const kColorAdd = Colors.green;
const kColorRemove = Colors.red;
const kColorUpdate = Colors.blue;

const kColorSuccess = Colors.green;
const kColorWarning = Colors.orange;
const kColorError = Colors.red;

const kColorTextContent = Color(0xfff9f5d7);
const kColorSecondaryText = Color(0xffa8a8a8);

/// SCREEN BREAK POINTS
const kTabletBreakPoint = 768.0;
const kMobileBreakPoint = 530.0;

/// MESSAGES
const kPasswordNotLongEnough = 'Password must be at least 6 characters long';
const kPasswordMissMatch = "Passwords don't match";

const kFieldNotEnteredMessage = 'Field cannot be left empty';
const kConnectionErrorMessage =
    "Connection error, please check your device has internet connection";

const kMessageOfflineError =
    'Could not reach server! Please check internet connection.';
const kMessageAuthError = 'Authorization Error';
const kMessageUnexpectedCacheError = 'Unexpected Cache Error';
const kMessageUnexpectedFormatError = 'Unexpected Format Error';
const kMessageUnexpectedServerError = 'Unexpected Server Error';

const kMessageEmailUpdateSuccess = 'Email update success';
const kMessagePasswordUpdateSuccess = 'Password update success';
const kMessageUsernameUpdateSuccess = 'Username update success';

const kMessagePasswordResetRequestEmailError = "[ERROR] Password Reset Request";
const kMessagePasswordResetUpdateSuccess = 'Password reset email sent success';

const kNullDateString = "1970-01-03T00:00:00Z";

/// Error Messages / Codes
const kXMLHttpRequestError = "XMLHttpRequest";

// Http Header Names
const kAuthHeader = "authorization";
const kRefreshHeader = "refresh-token";

final kUrlRegEx = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');

/// Support Email
final Uri kSupportEmailLaunchUri = Uri(
  scheme: 'mailto',
  path: 'support@email.co.za',
  query: 'subject=Support',
);
