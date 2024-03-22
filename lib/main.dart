import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/bloc/setting_manage/setting_manage_cubit.dart';
import 'package:kiosk/core/defined_code.dart';
import 'package:kiosk/l10n/l10n.dart';
import 'package:kiosk/route_listener.dart';
import 'package:kiosk/utils/alert/hurry_up.dart';
import 'package:kiosk/utils/alert/kiosk_error.dart';
import 'package:window_manager/window_manager.dart';

import 'bloc/services/services_bloc.dart';
import 'bloc/timer/timer_bloc.dart';
import 'bloc/websocket/web_socket_bloc.dart';
import 'core/route_code.dart';
import 'injection_container.dart' as ic;
import 'injection_container.dart';
import 'navi_router.dart';

void main() async {
  await ic.init();
  // Wakelock.enable();
  runApp(
    const App(),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool onEnterKey = false;
  bool onLeftAltKey = false;
  bool isFullScreen = false;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingManageCubit>(
          create: (context) => ic.it<SettingManageCubit>()..initSetting(),
        ),
        BlocProvider<WebSocketBloc>(
          create: (context) => ic.it<WebSocketBloc>(),
        ),
        BlocProvider<ServicesBloc>(
          create: (context) => ic.it<ServicesBloc>(),
        ),
        BlocProvider<TimerBloc>(
          create: (context) => ic.it<TimerBloc>(),
        ),
      ],
      child: BlocSelector<SettingManageCubit, SettingManageState, Locale>(
        selector: (state) => state.locale,
        builder: (context, locale) {
          return ScreenUtilInit(
              designSize: const Size(1080, 1980),
              builder: (context, child) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'B5 Selfie Kiosk',
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  scrollBehavior: const MaterialScrollBehavior().copyWith(
                    dragDevices: {
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.touch,
                      PointerDeviceKind.stylus,
                      PointerDeviceKind.unknown
                    },
                  ),
                  locale: locale,
                  supportedLocales: L10n.all,
                  theme: ThemeData(
                    fontFamily: (() {
                      switch (locale.countryCode) {
                        case 'KR':
                          return gFontSamsungonekorean;
                        case 'TH':
                          return 'notothai';
                        case 'AR':
                          return 'secnaskh';
                        default:
                          return gFontSamsungsharpsans;
                      }
                    }()),
                    colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
                    useMaterial3: true,
                  ),
                  navigatorKey: NaviRouter.navigatorKey,
                  initialRoute: RouteCode.splashScreen,
                  onGenerateRoute: NaviRouter.generateRoute,
                  builder: (context, child) =>
                      BlocListener<WebSocketBloc, WebSocketState>(
                    listenWhen: (previous, current) =>
                        current.error?.code != null &&
                        current.error?.code.isNotEmpty == true,
                    listener: (context, state) {
                      kioskErrorAlert(
                        getContext,
                        state.error?.code ?? '',
                      );
                    },
                    child: BlocListener<ServicesBloc, ServicesState>(
                      listenWhen: (previous, current) =>
                          current.status != ServiceStatus.onPictures,
                      listener: listenerRoute,
                      child: RawKeyboardListener(
                        focusNode: FocusNode(),
                        onKey: _onKeyEvent,
                        child: BlocListener<TimerBloc, TimerState>(
                            listenWhen: (prev, state) =>
                                state is TimerRunInProgress ||
                                state is TimerRunComplete,
                            listener: _timerListener,
                            child: child),
                      ),
                    ),
                  ),
                );
              });
        },
      ),
    );
  }

  void _onKeyEvent(RawKeyEvent event) async {
    if (kDebugMode) {
      routeSwitch(event.character);
    }

    if (event is! RawKeyDownEvent) {
      return;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      onEnterKey = true;
      _restoreisBoolKey(true);
    }

    if (event.logicalKey == LogicalKeyboardKey.altLeft) {
      onLeftAltKey = true;
      _restoreisBoolKey(false);
    }

    if (onEnterKey && onLeftAltKey) {
      isFullScreen = !isFullScreen;
      await windowManager.setFullScreen(isFullScreen);
    }
  }

  void _restoreisBoolKey(bool isEnterKey) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (isEnterKey) {
      onEnterKey = false;
    } else {
      onLeftAltKey = false;
    }
  }

  void routeSwitch(String? character) {
    final zone = it<ServicesBloc>().state.zone;
    RouteSettings? routeSettings;
    switch (character) {
      case '1':
        routeSettings =
            RouteSettings(name: RouteCode.standbyScreen, arguments: zone);
      case '2':
        routeSettings =
            RouteSettings(name: RouteCode.guideScreen, arguments: zone);
      case '3':
        routeSettings =
            RouteSettings(name: RouteCode.shotScreen, arguments: zone);
      case '4':
        routeSettings = RouteSettings(
            name: RouteCode.photoNotificationScreen, arguments: zone);
      case '5':
        routeSettings =
            RouteSettings(name: RouteCode.photoResultScreen, arguments: zone);
      case '6':
        routeSettings =
            RouteSettings(name: RouteCode.magazineStyleScreen, arguments: zone);
      case '7':
        routeSettings =
            RouteSettings(name: RouteCode.finalScreen, arguments: zone);
      case '8':
        routeSettings =
            RouteSettings(name: RouteCode.saveAndPrintScreen, arguments: zone);
      case '9':
        routeSettings = RouteSettings(
            name: RouteCode.waitLowHighShotScreen, arguments: zone);
      case '0':
        it<ServicesBloc>().add(const ServicesEvent.scannerPortClose());
        return;
      default:
        return;
    }

    final route = NaviRouter.generateRoute(routeSettings);

    if (route == null) return;

    NaviRouter.navigatorKey.currentState!
        .pushAndRemoveUntil(route, (route) => false);
  }

  ///타이머 리스너
  void _timerListener(BuildContext context, TimerState state) {
    final alertName =
        AppLocalizations.of(getContext)?.quick_photo_result_alert ?? "";
    final endAlertName =
        AppLocalizations.of(getContext)?.quick_magazin_style_alert ?? "";

    if (state.pastDuration == gTimeisTickingTimer && state.enabledFirstAlert) {
      getContext.read<TimerBloc>().add(const TimerPaused());
      return hurryUpAlert(getContext, alertName,
          onPressed: () =>
              getContext.read<TimerBloc>().add(const TimerResumed()));
    }

    if (state is TimerRunComplete) {
      return hurryUpAlert(
        getContext,
        endAlertName,
      );
    }
  }
}
