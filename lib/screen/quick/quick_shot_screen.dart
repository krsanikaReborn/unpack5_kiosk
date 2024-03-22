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

final quickShotSampleImages = <String>[
  'assets/images/quick_sample3.png',
  'assets/images/quick_sample2.png',
  'assets/images/quick_sample1.png',
  'assets/images/quick_sample3.png',
  'assets/images/quick_sample2.png',
];

class QuickShotScreen extends StatefulWidget {
  const QuickShotScreen({super.key, required this.ticker});

  final TimeTicker ticker;

  @override
  State<QuickShotScreen> createState() => QuickShotScreenState();
}

class QuickShotScreenState extends State<QuickShotScreen> {
  StreamSubscription<int>? _tickerSubscription;

  bool isMore30 = false;

  @override
  void initState() {
    _tickerSubscription = widget.ticker.tick(ticks: 70).listen((duration) {
      if (duration == 30) {
        _tickerSubscription?.cancel();
        setState(() {
          isMore30 = true;
        });
      }

      if (duration <= 0) {
        
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
    final titleName = AppLocalizations.of(context)?.quick_shot_title ?? "";
    final headline1Name =
        AppLocalizations.of(context)?.quick_shot_headline1 ?? "";
    final headline2Name =
        AppLocalizations.of(context)?.quick_shot_headline2 ?? "";
    final description1Name =
        AppLocalizations.of(context)?.quick_shot_description1 ?? "";
    final description2Name =
        AppLocalizations.of(context)?.quick_shot_description2 ?? "";
    final pleaseStartName =
        AppLocalizations.of(context)?.quick_shot_please_start ?? "";
    final startButtonName =
        AppLocalizations.of(context)?.quick_shot_start_button ?? "";

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            titleWidget(titleName, enabledHome: true),
            SizedBox(height: 73.h),
            textWidget(headline1Name, fontSize: 180.sp),
            // SizedBox(height: 10.h),
            textWidget(headline2Name,
                fontSize: 210.sp, fontWeight: FontWeight.w700, fontHeight: 0.9),
            SizedBox(height: 136.h),
            textWidget(
              description1Name,
              fontSize: 40.sp,
              // fontFamily: gFontSamsungsharpsans,
              fontColor: Colors.white,
            ),
            // const SizedBox(height: 10),
            textWidget(
              description2Name,
              fontSize: 40.sp,
              // fontFamily: gFontSamsungsharpsans,
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
              items: quickShotSampleImages
                  .map((e) => Image.asset(
                        e,
                      ))
                  .toList(),
            ),
            SizedBox(height: 82.h),
            if (isMore30)
              textWidget(
                pleaseStartName,
                fontFamily: gFontSamsungsharpsans,
                fontSize: 50.sp,
                durationBlink: 2000,
              ),
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
