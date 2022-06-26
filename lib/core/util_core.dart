import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants.dart';
import 'package:jwt_decode/jwt_decode.dart';

extension CapExtension on String {
  String get capitalizeFirst =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
  String get capitalizeFirstOfEach => replaceAll(RegExp(' +'), ' ')
      .split(" ")
      .map((str) => str.capitalizeFirst)
      .join(" ");
  String get camelCaseToString => replaceAllMapped(
        RegExp('(?<=[a-z])[A-Z]'),
        (Match m) => ' ${m.group(0) ?? ""}',
      );
}

extension DateTimeExtension on DateTime {
  // DateTime tryParseToLocal(String? dateTime) => DateTime.parse(
  //       "${dateTime ?? kNullDateString}Z",
  //     ).toLocal();

  String get toUtcForMySQL => toUtc()
      .toIso8601String()
      .substring(0, toUtc().toIso8601String().length - 1);

  String get toUtcISOString =>
      isUtc ? toIso8601String() : toUtc().toIso8601String();

  String dateTimeDiffFromNow({bool showCompact = true}) {
    final difference = DateTime.now().difference(this);
    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inHours < 1) {
      return "${difference.inMinutes}${showCompact ? "m" : " minutes"}";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}${showCompact ? "h" : " hours"}";
    } else if (difference.inDays < 365) {
      return "${difference.inDays}${showCompact ? "d" : " days"}";
    } else {
      return "${(difference.inDays / 365).floor()}${showCompact ? "y" : " years"}";
    }
  }
}

extension TimeOfDayExt on TimeOfDay {
  String get formatHHMM {
    String hr = hour.toString();
    if (hour < 10) hr = "0$hr";
    String min = minute.toString();
    if (minute < 10) min = "0$min";
    return "$hr:$min";
  }
}

extension DurationExt on Duration {
  /// Returns a formatted string for the given Duration [d] to be DD:HH:mm:ss
  /// and ignore if 0.
  String get formatDuration {
    var seconds = inSeconds;
    final days = seconds ~/ Duration.secondsPerDay;
    seconds -= days * Duration.secondsPerDay;
    final hours = seconds ~/ Duration.secondsPerHour;
    seconds -= hours * Duration.secondsPerHour;
    final minutes = seconds ~/ Duration.secondsPerMinute;
    seconds -= minutes * Duration.secondsPerMinute;

    final List<String> tokens = [];
    if (days != 0) {
      tokens.add('${days}d');
    }
    if (tokens.isNotEmpty || hours != 0) {
      tokens.add('${hours}h');
    }
    if (tokens.isNotEmpty || minutes != 0) {
      tokens.add('${minutes}m');
    }
    // tokens.add('${seconds}s');

    return tokens.join(' ');
  }
}

DateTime parseJsonDateTime(String name, JsonMap json) {
  final value = json[name];
  if (value.runtimeType == DateTime) return value as DateTime;

  return DateTime.parse(value as String? ?? kNullDateString);
}

// // const kUsernameRegExPattern = r"\[(@[^:]+):([^\]]+)\]";
// const kUsernameRegExPattern = r"\@[^:]+";
// final kUsernameRegEx = RegExp(kUsernameRegExPattern);
// MatchText kUsernameMatchText(BuildContext context) => MatchText(
//       pattern: kUsernameRegExPattern,
//       style: const TextStyle(
//         color: kColorAccent,
//       ),
//       renderText: ({required pattern, required str}) {
//         final Match _usernameRegExMatch = kUsernameRegEx.firstMatch(str)!;
//         return {'display': _usernameRegExMatch.group(0)!};
//       },
//       // onTap: (str) {
//       //   final Match _usernameRegExMatch = kUsernameRegEx.firstMatch(str)!;
//       //
//       //   final userUuid = _usernameRegExMatch[2]!;
//       //   if (userUuid.isEmpty) return;
//       //
//       //   Navigator.of(context).push(
//       //     MaterialPageRoute(
//       //       builder: (context) => UserPage(
//       //         uuid: userUuid,
//       //       ),
//       //     ),
//       //   );
//       // },
//     );

// MatchText kUrlMatchText(BuildContext context) => MatchText(
//       type: ParsedType.URL,
//       style: const TextStyle(
//         color: kColorAccent,
//       ),
//       onTap: (url) {
//         //print(url);
//         final uri = Uri.parse(url);
//         url_launcher.launchUrl(uri);
//       },
//     );

// INFO: Helper Functions
bool isEmail(String? string) {
  // Null or empty string is invalid
  if (string == null || string.isEmpty) {
    return false;
  }

  const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  final regExp = RegExp(pattern);

  if (regExp.hasMatch(string)) {
    return true;
  }
  return false;
}

bool paswordLengthToShort(String password) => password.length < 6;

bool checkPasswordsMatch(String password, String confirmPassword) =>
    password != confirmPassword;

class JwtUtil {
  bool isNotExpired(String token) => !Jwt.isExpired(token);
  bool isExpired(String token) => Jwt.isExpired(token);
}
