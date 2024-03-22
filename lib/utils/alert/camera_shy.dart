import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/core/colors.dart';

import '../../bloc/services/services_bloc.dart';
import '../../bloc/websocket/web_socket_bloc.dart';
import '../../injection_container.dart';
import '../widget/helper_widget.dart';

void cameraShyAlert(BuildContext context, String uid,
    {bool isEndShot = false}) async {
  if (isEndShot) {
    it<WebSocketBloc>().add(WebSocketEvent.endShot(uid));
    await Future.delayed(const Duration(seconds: 1));
  }

  // ignore: use_build_context_synchronously
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.2),
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          shape: const RoundedRectangleBorder(
            // 둥근 모서리 설정
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          backgroundColor: GColors.cyanAccent.withOpacity(0.7),
          child: SizedBox(
            width: 916.w,
            height: 547.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                textEngWidget(
                  AppLocalizations.of(context)?.utils_shy_title ?? '',
                  fontSize: 85.sp,
                  fontColor: Colors.black,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 40.h, top: 14.h),
                  child: textWidget(
                    AppLocalizations.of(context)?.utils_shy_description ?? '',
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w700,
                    fontColor: Colors.black,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      button(
                        AppLocalizations.of(context)?.utils_shy_quit_button ??
                            '',
                        isAlert: true,
                        width: 370.w,
                        onPressed: () => context
                            .read<ServicesBloc>()
                            .add(const ServicesEvent.goinitScreen()),
                        textSize : 60.sp,    
                      ),
                      SizedBox(width: 25.w),
                      button(
                        AppLocalizations.of(context)?.utils_shy_return_button ??
                            '',
                        isAlert: true,
                        width: 370.w,
                        onPressed: () => context
                            .read<ServicesBloc>()
                            .add(const ServicesEvent.quickReturn()),
                        textSize : 60.sp,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
