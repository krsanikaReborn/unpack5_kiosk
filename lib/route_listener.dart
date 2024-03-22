import 'package:flutter/material.dart';
import 'package:kiosk/utils/alert/kiosk_error.dart';

import 'bloc/services/services_bloc.dart';
import 'core/route_code.dart';
import 'navi_router.dart';

void listenerRoute(BuildContext context, ServicesState state) {
  RouteSettings? routeSettings;
  final zone = state.zone;
  var isOnePage = true;
  switch (state.status) {
    case ServiceStatus.guide:
      routeSettings =
          RouteSettings(name: RouteCode.guideScreen, arguments: zone);
      break;
    case ServiceStatus.settings:
      routeSettings = const RouteSettings(name: RouteCode.settingsScrren);
      break;
    case ServiceStatus.ready:
      routeSettings =
          RouteSettings(name: RouteCode.standbyScreen, arguments: zone);
      break;
    case ServiceStatus.waitLowHigh:
      routeSettings =
          RouteSettings(name: RouteCode.waitLowHighShotScreen, arguments: zone);
      break;
    case ServiceStatus.quickLowHighShot:
      routeSettings =
          RouteSettings(name: RouteCode.shotScreen, arguments: zone);
      break;
    case ServiceStatus.photoNotication:
      routeSettings = RouteSettings(
          name: RouteCode.photoNotificationScreen, arguments: zone);
      break;
    case ServiceStatus.shotComplate:
      routeSettings =
          RouteSettings(name: RouteCode.photoResultScreen, arguments: zone);
      break;
    case ServiceStatus.selectMagazine:
      isOnePage = false;
      routeSettings =
          RouteSettings(name: RouteCode.magazineStyleScreen, arguments: zone);
      break;
    case ServiceStatus.finalResult:
      isOnePage = false;
      routeSettings =
          RouteSettings(name: RouteCode.finalScreen, arguments: zone);
      break;
    case ServiceStatus.loading:
      routeSettings =
          RouteSettings(name: RouteCode.saveAndPrintScreen, arguments: zone);
      break;
    case ServiceStatus.fileNotFound:
      kioskErrorAlert(getContext, ServiceStatus.fileNotFound.name);
      return;
    default:
      return;
  }

  final route = NaviRouter.generateRoute(routeSettings);

  if (route == null) return;

  isOnePage
      ? NaviRouter.navigatorKey.currentState!
          .pushAndRemoveUntil(route, (route) => false)
      : NaviRouter.navigatorKey.currentState!.push(
          route,
        );
}
