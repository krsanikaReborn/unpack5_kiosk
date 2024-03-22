import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kiosk/bloc/setting_manage/setting_manage_cubit.dart';
import 'package:kiosk/utils/time_ticker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'bloc/services/services_bloc.dart';
import 'bloc/timer/timer_bloc.dart';
import 'bloc/websocket/web_socket_bloc.dart';
import 'l10n/l10n.dart';

final it = GetIt.instance;

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // WindowOptions windowOptions = const WindowOptions(
  //   size: Size(800, 600),
  //   center: true,
  //   backgroundColor: Colors.transparent,
  //   skipTaskbar: false,
  //   titleBarStyle: TitleBarStyle.hidden,
  // );
  // windowManager.waitUntilReadyToShow(windowOptions, () async {
  //   await windowManager.show();
  //   await windowManager.focus();
  // });

  // await windowManager.setFullScreen(true);

  final pref = await SharedPreferences.getInstance();
  it.registerSingleton<SharedPreferences>(pref);
  it.registerLazySingleton(() => SettingManageCubit(locale: L10n.all.first));
  it.registerLazySingleton(() => WebSocketBloc());
  it.registerLazySingleton(() => ServicesBloc());
  it.registerLazySingleton(() => TimerBloc(ticker: const TimeTicker()));
}
