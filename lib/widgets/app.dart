import 'package:flutter/material.dart';
import 'package:flutter_frontend/service_locator.dart';
import 'package:flutter_frontend/view_providers/_providers.dart';
import 'package:flutter_frontend/widgets/pages/error_pg.dart';
import 'package:flutter_frontend/widgets/pages/home_pg.dart';
import 'package:flutter_frontend/widgets/pages/login_pg.dart';
import 'package:flutter_frontend/widgets/pages/second_pg.dart';
import 'package:flutter_frontend/widgets/pages/signup_pg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class App extends ConsumerWidget {
  App({super.key});

  final _currentUserNotifier = sl<CurrentUserNotifier>();
  final _themeNotifier = sl<ThemeNotifier>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeProvider);
    // ref.listen<ThemeMode>(themeProvider, (prev, next) {
    //   print("Theme Updated: o:$prev n:$next");
    // });

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routeInformationProvider: _router.routeInformationProvider,
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      title: 'Template',
      theme: _themeNotifier.isDarkMode
          ? _themeNotifier.dark
          : _themeNotifier.light,
    );
  }

  late final _router = GoRouter(
    initialLocation: "/",
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/pg2',
        builder: (context, state) => const SecondPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupPage(),
      ),
    ],
    errorBuilder: (context, state) =>
        ErrorPage(message: state.error.toString()),
    redirect: (state) {
      // Check if current user is logged in
      final isloggedIn = _currentUserNotifier.isLoggedIn;
      final isloggingIn = state.subloc == '/login' || state.subloc == '/signup';

      if (!isloggedIn) return isloggingIn ? null : '/login';
      if (isloggingIn) return '/';

      return null;
    },
  );
}
