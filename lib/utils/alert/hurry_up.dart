import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/core/colors.dart';

import './blinking_button.dart';
import '../widget/helper_widget.dart';

void hurryUpAlert(BuildContext context, String text,
    {VoidCallback? onPressed, bool isAutoClose = false}) {
  if (isAutoClose) {
    Future.delayed(const Duration(seconds: 3)).then((value) {
      if (onPressed != null) {
        onPressed();
        Navigator.of(context).pop();
      }
    });
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.2),
    builder: (BuildContext context) {
      final hurryName =
          AppLocalizations.of(context)?.utils_alert_hurry_up_hurry ?? "";
      final agreeName =
          AppLocalizations.of(context)?.utils_alert_hurry_up_agree ?? "";

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
                  hurryName,
                  fontSize: 80.sp,
                  fontColor: Colors.black,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 40.h, top: 20.h),
                  child: textWidget(
                    text,
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w700,
                    fontColor: Colors.black,
                  ),
                ),
                // SizedBox(

                // 깜빡이는 버튼으로 대체
                if (isAutoClose == false)
                  BlinkingButton(buttonText: agreeName, onPressed: onPressed)
              ],
            ),
          ),
        ),
      );
    },
  );
}
