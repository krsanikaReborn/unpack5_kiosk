import 'package:flutter/material.dart';
import 'package:kiosk/core/defined_code.dart';
import 'package:kiosk/core/route_code.dart';
import 'package:kiosk/screen/lowhigh/lowhigh_wait_photo_notification_screen.dart';
import 'package:kiosk/screen/splash_screen.dart';

import 'screen/screen.dart';
import 'utils/time_ticker.dart';

BuildContext get getContext => NaviRouter.navigatorKey.currentContext!;

class NaviRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final routeName = settings.name;
    final zone = settings.arguments;

    if (zone is! KindZoneType) {
      return pageRoute(_nonParamSwitch(routeName));
    }

    if (zone == KindZoneType.quick) {
      return pageRoute(_quickSwitch(routeName));
    }

    return pageRoute(_lowHighSwitch(routeName, zone));
  }

  static Future<T?> push<T extends Object?>({
    required Widget child,
    Object? args,
    String? scName,
  }) {
    return navigatorKey.currentState!.push<T>(MaterialPageRoute(
      builder: (context) => child,
    ));
  }
}

Widget? _nonParamSwitch(String? routeName) {
  switch (routeName) {
    case RouteCode.splashScreen:
      return const SplashScreen();

    case RouteCode.settingsScrren:
      return const SettingsScreen();

    default:
      return null;
  }
}

Widget? _quickSwitch(String? routeName) {
  switch (routeName) {
    case RouteCode.saveAndPrintScreen:
      return const SaveAndPrintScreen(
        zone: KindZoneType.quick,
      );

    case RouteCode.standbyScreen:
      return const QuickStandbyScreen();

    case RouteCode.guideScreen:
      return const QuickGuideScreen();

    case RouteCode.shotScreen:
      return const QuickShotScreen(ticker: TimeTicker());

    case RouteCode.photoNotificationScreen:
      return const QuickPhotoNotificationScreen(ticker: TimeTicker());

    case RouteCode.photoResultScreen:
      return const QuickPhotoResultScreen(ticker: TimeTicker());

    case RouteCode.magazineStyleScreen:
      return const QuickMagazineStyleScreen(ticker: TimeTicker());

    case RouteCode.finalScreen:
      return const QuickFinalScreen();
    default:
      return null;
  }
}

Widget? _lowHighSwitch(String? routeName, KindZoneType zone) {
  switch (routeName) {
    case RouteCode.saveAndPrintScreen:
      return SaveAndPrintScreen(zone: zone);

    case RouteCode.standbyScreen:
      return const LowHighStandbyScreen();

    case RouteCode.guideScreen:
      return const LowHighGuideScreen();

    case RouteCode.shotScreen:
      return const LowHighShotScreen(ticker: TimeTicker());

    case RouteCode.photoNotificationScreen:
      return LowHigPhotoNotificationScreen(
        ticker: const TimeTicker(),
        zoneType: zone,
      );

    case RouteCode.photoResultScreen:
      return const LowHighPhotoResultScreen(ticker: TimeTicker());

    case RouteCode.magazineStyleScreen:
      return LowHighMagazineStyleScreen(zoneType: zone);

    case RouteCode.finalScreen:
      return const LowHighFinalScreen();

    case RouteCode.waitLowHighShotScreen:
      return LowHigWaitPhotoNotificationScreen(
          ticker: const TimeTicker(), zoneType: zone);

    default:
      return null;
  }
}

Route? pageRoute(Widget? screen) {
  if (screen == null) return null;

  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return screen;
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
    transitionDuration: const Duration(milliseconds: 100),
  );
}

// class FadeRoute extends PageRouteBuilder {
//   final Widget page;

//   FadeRoute({required this.page})
//       : super(
//           pageBuilder: (
//             BuildContext context,
//             Animation<double> animation,
//             Animation<double> secondaryAnimation,
//           ) =>
//               page,
//           transitionDuration: const Duration(milliseconds: 100),
//           transitionsBuilder: (
//             BuildContext context,
//             Animation<double> animation,
//             Animation<double> secondaryAnimation,
//             Widget child,
//           ) =>
//               FadeTransition(
//             opacity: animation,
//             child: child,
//           ),
//         );
// }
