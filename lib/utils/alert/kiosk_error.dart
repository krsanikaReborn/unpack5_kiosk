import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/core/colors.dart';

import 'package:just_audio/just_audio.dart';

import './blinking_button.dart';
import '../widget/helper_widget.dart';

var isErrorDialogShowing = false;

void kioskErrorAlert(BuildContext context, String code) {
  if (isErrorDialogShowing) {
    return;
  }

  isErrorDialogShowing = true;

  final title = AppLocalizations.of(context)?.utils_connection_lost_title ?? "";

  final confirm = AppLocalizations.of(context)?.confirm ?? "";

  final text = switch (code) {
    '3003' => AppLocalizations.of(context)?.kiosk_error_3003 ?? '',
    'fileNotFound' =>
      AppLocalizations.of(context)?.kiosk_error_print_fileNotFound ?? '',
    _ => AppLocalizations.of(context)?.kiosk_error_unknwon ?? ''
  };

  late AudioPlayer player;
  player = AudioPlayer();
  player.setUrl('http://192.168.0.10:8080/images/sound/notice.wav');

  player.play();
  
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.2),
    builder: (BuildContext context) {
      var titleSize = 85.sp;
      var descriptionSize = 30.sp;

      //다국어시 대책
      if (Localizations.localeOf(context).toLanguageTag() == "fr-FR") {
        titleSize = 80.h;
        descriptionSize = 40.sp;
      }      
      if (Localizations.localeOf(context).toLanguageTag() == "de-DE") {
        titleSize = 80.h;
        descriptionSize = 40.sp;
      }      

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
                  title,
                  fontSize: titleSize,
                  fontColor: Colors.black,
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 40.h, top: 20.h),
                  child: textWidget(
                    text,
                    fontSize: descriptionSize,
                    fontWeight: FontWeight.w700,
                    fontColor: Colors.black,
                  ),
                ),

                // 깜빡이는 버튼으로 대체
                BlinkingButton(
                  buttonText: confirm,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
    },
  ).then((value) {
    isErrorDialogShowing = false;
  });
}
