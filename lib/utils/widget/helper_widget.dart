import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/navi_router.dart';

import '../../core/colors.dart';
import '../../core/defined_code.dart';
import '../alert/return_main.dart';
import '../svg_icons.dart';

Widget arrowActionButton({
  bool isForward = true,
  bool isVisibled = true,
  required Function() callback,
  bool isRTL = false,
}) {
  final icon = isForward ? SvgIcons.smLeftArrow : SvgIcons.smRightArrow;

  return isVisibled
      ? InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: callback,
          child:
              icon.widget(width: 68.w, height: 68.h, color: GColors.cyanAccent),
        )
      : SizedBox(
          width: 68.w,
        );
}

Widget titleWidget(String title,
    {bool enabledBack = false,
    bool enabledHome = false,
    BuildContext? context}) {
  var backArrowWidget =
      SvgIcons.smLeftArrow.widget(width: 60.w, color: Colors.white);
  //아랍어 화살표 뒤집기 대책
  if (Localizations.localeOf(getContext).toLanguageTag() == "ar-AR") {
    backArrowWidget =
        SvgIcons.smRightArrow.widget(width: 60.w, color: Colors.white);
  }

  return Padding(
    padding: EdgeInsets.only(top: 57.h),
    child: SizedBox(
      width: double.infinity,
      height: 65.h,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 7.h),
            child: SizedBox(
              width: double.infinity,
              child: textWidget(title,
                  fontColor: Colors.white, // fontFamily: gFontSamsungsharpsans,
                  fontSize: 50.sp,
                  fontWeight: FontWeight.w700,
                  fontHeight: 1.26.sp),
            ),
          ),
          if (enabledBack)
            PositionedDirectional(
              start: 0,
              child: InkWell(
                onTap: () => Navigator.of(context ?? getContext).pop(),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48.w),
                  child: backArrowWidget,
                ),
              ),
            ),
          if (enabledHome)
            PositionedDirectional(
              end: 0,
              child: InkWell(
                onTap: () => returnToMainAlert(context ?? getContext),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48.w),
                  child: SvgIcons.home
                      .widget(width: 60.w, height: 60.w, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

Widget textEngWidget(
  String text, {
  Color fontColor = GColors.cyanAccent,
  double? fontSize,
  double? fontHeight,

  ///milliseconds, 1000 = 1초
  int durationBlink = 0,
}) {
  return textWidget(
    text,
    fontColor: fontColor,
    fontSize: fontSize ?? 90.sp,
    fontWeight: FontWeight.w700,
    fontHeight: fontHeight,
    fontFamily: gFontSamsungsharpsans,
    durationBlink: durationBlink,
  );
}

Widget textWidget(String text,
    {Color fontColor = GColors.cyanAccent,
    String? fontFamily,
    double? fontSize,
    double? fontHeight = 1.26,

    ///milliseconds, 1000 = 1초
    int durationBlink = 0,
    FontWeight fontWeight = FontWeight.w400}) {
  if (durationBlink > 0) {
    return AnimatedTextKit(
      repeatForever: true,
      animatedTexts: [
        FadeAnimatedText(
          duration: Duration(milliseconds: durationBlink),
          text,
          textAlign: TextAlign.center,
          textStyle: TextStyle(
            fontSize: fontSize ?? 19.sp,
            fontFamily: fontFamily,
            fontWeight: fontWeight,
            color: fontColor,
            height: fontHeight,
          ),
        ),
      ],
    );
  }

  return Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: fontSize ?? 19.sp,
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      color: fontColor,
      height: fontHeight,
    ),
  );
}

Widget button(
  String buttonName, {
  double? width,
  double? height,
  required VoidCallback? onPressed,
  bool isAlert = false,
  double? textSize = 60,
}) {
  return SizedBox(
    width: width ?? 601.w,
    height: height ?? 143.h,
    child: ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          isAlert
              ? Colors.black
              : onPressed != null
                  ? GColors.cyanAccent
                  : GColors.cyanAccent.withOpacity(0.4),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        buttonName,
        style: TextStyle(
          fontFamily: gFontSamsungsharpsans,
          fontSize: textSize,
          color: isAlert ? GColors.cyanAccent.withOpacity(0.7) : Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
