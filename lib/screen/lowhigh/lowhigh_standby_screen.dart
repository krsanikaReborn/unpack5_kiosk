import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/core/colors.dart';
import 'package:kiosk/core/defined_code.dart';

import '../../utils/svg_icons.dart';

class LowHighStandbyScreen extends StatefulWidget {
  const LowHighStandbyScreen({super.key});

  @override
  State<LowHighStandbyScreen> createState() => LowHighStandbyScreenState();
}

class LowHighStandbyScreenState extends State<LowHighStandbyScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final standbyTitleName =
        AppLocalizations.of(context)?.lowhigh_standby_title ?? "";
    final description1Name =
        AppLocalizations.of(context)?.lowhigh_standby_description1 ?? "";
    final description2Name =
        AppLocalizations.of(context)?.lowhigh_standby_description2 ?? "";
    final description3Name =
        AppLocalizations.of(context)?.lowhigh_standby_description3 ?? "";
    final nextName = AppLocalizations.of(context)?.lowhigh_standby_next ?? "";
    double degree = gQrReaderDegree;

    //아랍어 화살표 뒤집기 대책
    if (Localizations.localeOf(context).toLanguageTag() == "ar-AR") {
      degree = gQrReaderDegree + math.pi;
    }

    //밑글 다국어대책
    var standbyFont = gFontSamsungsharpsans;

    var nextSize = 55.sp;
    var nextPadding = EdgeInsets.fromLTRB(55.w, 0, 55.w, 60.h);

    if(Localizations.localeOf(context).toLanguageTag() == 'fr-FR'){
      nextSize = 50.sp;
      nextPadding = EdgeInsets.fromLTRB(55.w, 0, 30.w, 30.h);
    }

    if(Localizations.localeOf(context).toLanguageTag() == 'de-DE'){
      nextSize = 50.sp;
      nextPadding = EdgeInsets.fromLTRB(220.w, 0, 30.w, 30.h);
    }
    if(Localizations.localeOf(context).toLanguageTag() == 'th-TH'){
      standbyFont = 'notothai';
      nextPadding = EdgeInsets.fromLTRB(100.w, 0, 30.w, 60.h);
    }

    if(Localizations.localeOf(context).toLanguageTag() == 'ar-AR'){
      standbyFont = 'secnaskh';
      nextSize = 50.sp;
      nextPadding = EdgeInsets.fromLTRB(30.w, 0, 30.w, 60.h);
    }

    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5771,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 82.w,
                    vertical: 77.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        standbyTitleName,
                        style: TextStyle(
                            fontFamily: standbyFont,
                            fontSize: 200.w,
                            fontWeight: FontWeight.w700,
                            color: GColors.cyanAccent,
                            height: 1.03),
                      ),
                      SizedBox(height: 42.h),
                      Text(
                        description1Name,
                        style: TextStyle(
                            fontFamily: standbyFont,
                            fontSize: 55.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      Text(
                        description2Name,
                        style: TextStyle(
                            fontFamily: standbyFont,
                            fontSize: 55.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      SizedBox(height: 42.h),
                      Text(
                        description3Name,
                        style: TextStyle(
                            fontSize: 55.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4229,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.bottomCenter,
                  color: GColors.cyanAccent,
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(62.w, 0, 62.w, 124.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: nextPadding,
                            child: Text(nextName,
                                textAlign: TextAlign.end,
                                style: TextStyle(                                    
                                    fontFamily: standbyFont,
                                    fontSize: nextSize,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black)),
                          ),
                        ],
                      )),
                ),
              ),
              Container(
                height: 2,
                width: double.infinity,
                color: Colors.black,
              ),
            ],
          ),
          PositionedDirectional(
            bottom: 48.h,
            end: -24.w,
            child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationZ(degree),
                child: Image.asset('assets/images/standby_arrow.gif',
                    width: 360.w, height: 360.h, fit: BoxFit.fill)),
          )
        ]));
  }
}
