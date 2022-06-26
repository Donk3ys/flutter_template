import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_frontend/core/constants.dart';
import 'package:flutter_frontend/core/logging.dart';
import 'package:flutter_frontend/core/util_core.dart';
import 'package:flutter_frontend/external_services/local_data_src.dart';
import 'package:flutter_frontend/external_services/remote_auth_src.dart';
import 'package:flutter_frontend/repositories/auth_repo.dart';
import 'package:flutter_frontend/view_providers/_providers.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
import 'package:loggy/loggy.dart';

enum Env { dev, stage, prod }

final sl = GetIt.instance;

Future<void> initApp({required Env env}) async {
  // Init logging
  Loggy.initLoggy(
    logPrinter: CustomLogPrinter(),
    //logOptions: const LogOptions(LogLevel.all, stackTraceLevel: LogLevel.off)
  );

  // Init local storage
  await Hive.initFlutter();
  final _hiveBox = await Hive.openBox("hive");

  // Init .config
  final configFile = await rootBundle.loadString('config.json');
  final configJson = (jsonDecode(configFile) as JsonMap)[env.name] as JsonMap;

  // NOTE: Notifiers
  sl.registerLazySingleton(
    () => CurrentUserNotifier(authRepo: sl()),
  );
  sl.registerLazySingleton(
    () => ThemeNotifier(localDataSource: sl()),
  );

  // NOTE: Repositories
  sl.registerLazySingleton(
    () => AuthRepository(
      localDataSource: sl(),
      remoteAuthSource: sl(),
      jwtUtil: sl(),
    ),
  );

  // NOTE: Services
  sl.registerLazySingleton(() => LocalDataSource(_hiveBox));
  final apiUrl = configJson["server_api_prefix"] as String;
  sl.registerLazySingleton(() => RemoteAuthSource(sl(), apiUrl));
  sl.registerLazySingleton(() => JwtUtil());

  // NOTE: External
  sl.registerLazySingleton<Client>(() => Client());

  // NOTE: App Boostrap
  await Future.wait([
    sl<CurrentUserNotifier>().getCurrentUser(),
    sl<ThemeNotifier>().getThemeModeFromStorage(),
  ]);
}

// class CommunityController {
//   final CommunityViewModel communityVm;
//   final ChangeNotifierProvider<CommunityViewModel> communityVmProvider;
//
//   CommunityController({
//     required this.communityVm,
//     required this.communityVmProvider,
//   });
// }
//
// Future<CommunityController> getCommunityController(String communityUuid) async {
//   // Fetch relevant community viewModel & ChangeNotifierProvider
//   return comControllerMap.putIfAbsent(communityUuid, () {
//     final vm = CommunityViewModel(
//       communityUuid: communityUuid,
//       communityRepository: sl(),
//       messageRepository: sl(),
//     );
//
//     print(
//       "getCommunityController: com->${comControllerMap.length + 1} usr->${userControllerMap.length}",
//     );
//     return CommunityController(
//       communityVm: vm,
//       communityVmProvider: ChangeNotifierProvider((ref) => vm),
//     );
//   });
// }


// Future<void> clearControllers() async {
//   comControllerMap.clear();
//   userControllerMap.clear();
//   print(
//     "clearControllers: com->${comControllerMap.length} usr->${userControllerMap.length}",
//   );
// }

// void clearData() {
//   clearControllers();
//   authVm.currentUser = kUserGuest;
//
//   communityUtilVm.followedCommunityList.clear();
//   communityUtilVm.searchedCommunityList.clear();
//
//   messageVm.messageCreated = false;
//   messageVm.messageFeedList.clear();
// }
