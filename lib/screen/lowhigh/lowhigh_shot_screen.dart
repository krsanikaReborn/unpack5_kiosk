import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/utils/time_ticker.dart';
import 'package:kiosk/utils/widget/helper_widget.dart';

import '../../bloc/services/services_bloc.dart';
import '../../core/defined_code.dart';

final lowhighShotSampleImages = <String>[
  'assets/images/quick_sample3.png',
  'assets/images/quick_sample2.png',
  'assets/images/quick_sample1.png',
  'assets/images/quick_sample3.png',
  'assets/images/quick_sample2.png',
];

class LowHighShotScreen extends StatefulWidget {
  const LowHighShotScreen({super.key, required this.ticker});

  final TimeTicker ticker;

  @override
  State<LowHighShotScreen> createState() => LowHighShotScreenState();
}

class LowHighShotScreenState extends State<LowHighShotScreen> {
  StreamSubscription<int>? _tickerSubscription;

  bool isMore30 = false;

  @override
  void initState() {
    _tickerSubscription =
        widget.ticker.tick(ticks: gAreYouReadyTimer).listen((duration) {
      if (duration == gTapOnTheButtonTimer) {
        setState(() {          
          isMore30 = true;
        });
      }

      if (duration <= 0) {
        _tickerSubscription?.cancel();
        context.read<ServicesBloc>().add(const ServicesEvent.goinitScreen());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _tickerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleName = AppLocalizations.of(context)?.lowhigh_title ?? "";
    final headline1Name =
        AppLocalizations.of(context)?.quick_shot_headline1 ?? "";
    final headline2Name =
        AppLocalizations.of(context)?.quick_shot_headline2 ?? "";
    final description1Name =
        AppLocalizations.of(context)?.lowhigh_shot_description1 ?? "";
    final description2Name =
        AppLocalizations.of(context)?.lowhigh_shot_description2 ?? "";
    final pleaseStartName =
        AppLocalizations.of(context)?.lowhigh_shot_please_start ?? "";
    final startButtonName =
        AppLocalizations.of(context)?.lowhigh_shot_start_button ?? "";
    //다국어시 두줄 대책
    var head1 = textWidget(headline1Name, fontSize: 180.sp);
    var head2 = textWidget(headline2Name, fontSize: 210.sp, fontWeight: FontWeight.w700, fontHeight: 0.9);
    var head2AfterHeight = 136.h;
    var desc1Size = 40.h;
    var pleaseTop = 102.h;
    if (Localizations.localeOf(context).toLanguageTag() == "fr-FR") {
      head1 = textWidget(headline1Name, fontSize: 160.sp);
      head2 = textWidget(headline2Name, fontSize: 200.sp, fontWeight: FontWeight.w700, fontHeight: 1.45);
      head2AfterHeight = 70.h;
      desc1Size = 35.h;
      pleaseTop = 24.h;
    }
    if (Localizations.localeOf(context).toLanguageTag() == "de-DE") {
      head1 = textWidget(headline1Name, fontSize: 200.sp);
      head2 = textWidget(headline2Name, fontSize: 210.sp, fontWeight: FontWeight.w700, fontHeight: 1.0);
      head2AfterHeight = 102.h;
      desc1Size = 35.h;
      pleaseTop = 80.h;
    }

    if (Localizations.localeOf(context).toLanguageTag() == "th-TH") {
      head1 = textWidget(headline1Name, fontSize: 180.sp, fontHeight: 2.85);
      head2 = textWidget(headline2Name, fontSize: 0.sp, fontWeight: FontWeight.w700, fontHeight: 1.0);
      head2AfterHeight = 50.h;
      desc1Size = 35.h;
      pleaseTop = 120.h;
    }

    if (Localizations.localeOf(context).toLanguageTag() == "ar-AR") {
      head1 = textWidget(headline1Name, fontSize: 200.sp);
      head2 = textWidget(headline2Name, fontSize: 200.sp, fontWeight: FontWeight.w700, fontHeight: 1.0);
      head2AfterHeight = 120.h;
      desc1Size = 40.h;
      pleaseTop = 103.h;
    }



    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            titleWidget(titleName, enabledHome: true),
            SizedBox(height: 73.h),
            head1,
            head2,
            SizedBox(height: head2AfterHeight),
            textWidget(description1Name,
                fontSize: desc1Size, fontColor: Colors.white),
            // SizedBox(height: 188.h),
            textWidget(
              description2Name,
              fontColor: Colors.white,
            ),
            SizedBox(height: 200.h),
            CarouselSlider(
              options: CarouselOptions(
                aspectRatio: 3 / 4,
                initialPage: 2,
                height: 360.h,
                viewportFraction: 0.255,
                autoPlayCurve: Curves.fastOutSlowIn,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 1),
                autoPlayAnimationDuration: const Duration(milliseconds: 2000),
              ),
              items: lowhighShotSampleImages
                  .map((e) => Image.asset(
                        e,
                      ))
                  .toList(),
            ),
            isMore30 ?
              Padding(
                padding : EdgeInsets.only(top: pleaseTop),
                child: 
                  textWidget(
                    pleaseStartName,
                    fontFamily: gFontSamsungsharpsans,
                    fontSize: 50.sp,
                    fontWeight: FontWeight.w500,
                    durationBlink: 2000
                  )          
              ) :
              SizedBox(height:102.h),    
            const Spacer(),
            button(
              startButtonName,
              onPressed: () => context
                  .read<ServicesBloc>()
                  .add(const ServicesEvent.startShot()),
              textSize: 50.sp,
            ),
            SizedBox(height: 182.h),
          ],
        ),
      ),
    );
  }
}
