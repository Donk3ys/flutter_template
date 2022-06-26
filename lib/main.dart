import 'package:flutter/material.dart';
import 'package:flutter_frontend/service_locator.dart';
import 'package:flutter_frontend/widgets/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // GetIt -> Setup dependency injetion & run setup code
  await initApp(env: Env.dev);

  runApp(ProviderScope(child: App()));
}
