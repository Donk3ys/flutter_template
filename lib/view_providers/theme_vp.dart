import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_frontend/core/constants.dart';
import 'package:flutter_frontend/external_services/local_data_src.dart';
import 'package:flutter_frontend/service_locator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers
late final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) => sl());

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final LocalDataSource _localDataSource;

  ThemeNotifier({
    required LocalDataSource localDataSource,
  })  : _localDataSource = localDataSource,
        super(ThemeMode.system);

  bool get isDarkMode => state == ThemeMode.dark;
  ThemeMode get mode => state;

  Future<void> getThemeModeFromStorage() async {
    final mode = await _localDataSource.themeMode;
    if (mode == ThemeMode.system) {
      final brightness = SchedulerBinding.instance.window.platformBrightness;
      state = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    } else {
      state = mode;
    }
  }

  final dark = ThemeData.dark().copyWith(
    primaryColorDark: kColorBackgroundDark,
    scaffoldBackgroundColor: kColorBackgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: kColorAccent,
      secondary: kColorAccent,
      background: kColorBackgroundDark,
      // surface: kColorCardDark, // background of widgets / cards
    ),
    // elevatedButtonTheme: ElevatedButtonThemeData(
    //   style: ElevatedButton.styleFrom(
    //     primary: Colors.black87,
    //     onPrimary: Colors.white,
    //   ),
    // ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    // cardColor: kColorCardDark,
    //focusColor: kColorAccent,
  );

  final light = ThemeData.light().copyWith(
    primaryColorDark: kColorBackgroundLight,
    scaffoldBackgroundColor: kColorBackgroundLight,
    colorScheme: const ColorScheme.light(
      primary: kColorAccent,
      secondary: kColorAccent,
      // background: kColorBackgroundLight,
      // surface: kColorCardLight, // background of widgets / cards
    ),
    // elevatedButtonTheme: ElevatedButtonThemeData(
    //   style: ElevatedButton.styleFrom(
    //     primary: kColorAccent,
    //     onPrimary: Colors.black87,
    //   ),
    // ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    //cardColor: kColorCardLight,
    //focusColor: kColorAccent,
  );

  void toggleMode() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final theme = state == ThemeMode.light
        ? describeEnum(ThemeMode.light)
        : describeEnum(ThemeMode.dark);
    _localDataSource.setTheme(theme);
    // loggy.info("CALLED: $_mode");
  }
}
