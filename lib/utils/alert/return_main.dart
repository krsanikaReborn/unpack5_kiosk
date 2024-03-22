import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/core/colors.dart';

import '../../bloc/services/services_bloc.dart';
import '../widget/helper_widget.dart';

void returnToMainAlert(BuildContext context) async {
  // ignore: use_build_context_synchronously

  //다국어대응
  var descSize = 78.sp;
  if(Localizations.localeOf(context).toLanguageTag() == 'fr-FR'){
    descSize = 70.sp;
  }
  if(Localizations.localeOf(context).toLanguageTag() == 'de-DE'){
    descSize = 69.sp;
  }
  if(Localizations.localeOf(context).toLanguageTag() == 'ar-AR'){
    descSize = 85.sp;
  }


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
                Padding(
                  padding: EdgeInsets.only(bottom: 40.h, top: 14.h),
                  child: textWidget(
                    AppLocalizations.of(context)?.return_main_menu ?? '',
                    fontSize: descSize,
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
                        AppLocalizations.of(context)?.yes ?? '',
                        isAlert: true,
                        width: 370.w,
                        onPressed: () => context
                            .read<ServicesBloc>()
                            .add(const ServicesEvent.goinitScreen()),
                        textSize : 60.sp,
                      ),
                      SizedBox(width: 25.w),
                      button(
                        AppLocalizations.of(context)?.no ?? '',
                        isAlert: true,
                        width: 370.w,
                        onPressed: () => Navigator.of(context).pop(),
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
