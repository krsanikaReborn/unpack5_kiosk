import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kiosk/bloc/services/services_bloc.dart';
import 'package:kiosk/core/colors.dart';

import '../../core/defined_code.dart';
import '../../navi_router.dart';
import '../../utils/alert/camera_shy.dart';
import '../../utils/alert/hurry_up.dart';
import '../../utils/svg_icons.dart';
import '../../utils/time_ticker.dart';
import '../../utils/widget/helper_widget.dart';

class QuickPhotoNotificationScreen extends StatefulWidget {
  const QuickPhotoNotificationScreen({
    super.key,
    required this.ticker,
  });

  final TimeTicker ticker;

  @override
  State<QuickPhotoNotificationScreen> createState() =>
      QuickPhotoNotificationScreenState();
}

class QuickPhotoNotificationScreenState
    extends State<QuickPhotoNotificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int tickTime;
  StreamSubscription<int>? _shotTickerSubscription;
  late AudioPlayer _delayPlayer;
  late AudioPlayer _popupPlayer;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    tickTime = context.read<ServicesBloc>().state.zone.shotTime;
    _delayPlayer = AudioPlayer();
    _delayPlayer
        .setUrl('http://192.168.0.10:8080/images/sound/delay_short.mp3');
    _popupPlayer = AudioPlayer();
    _popupPlayer.setUrl('http://192.168.0.10:8080/images/sound/notice.wav');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer();
    });
    super.initState();
  }

  void _startTimer() {
    _shotTickerSubscription?.cancel();

    _shotTickerSubscription =
        widget.ticker.tick(ticks: tickTime).listen((duration) async {
      final state = context.read<ServicesBloc>().state;
      tickTime = duration;
      print(tickTime);

      setState(() {});
      //20초 남으면 소리 재생
      if (tickTime <= 20) {
        _delayPlayer.play();
      }
      // player.playerStateStream.listen((state) {
      //   if (tickTime <= 20) {
      //     if (!state.playing) {
      //       player.play();
      //     }
      //   }
      // });

      //잘못임. 40초는 맞지만 사진이 2
      if (tickTime == 40 && state.shotedImages.isEmpty) {
        final alertName =
            AppLocalizations.of(getContext)?.quick_photo_notification_alert ??
                "";
        _shotTickerSubscription?.pause();

        _popupPlayer.play();
        hurryUpAlert(getContext, alertName,
            isAutoClose: true,
            onPressed: () => _shotTickerSubscription?.resume());
      }

      if (tickTime <= 0) {
        setState(() {});
        _delayPlayer.pause();
        _popupPlayer.pause();
        _shotTickerSubscription?.cancel();

        if (state.shotedImages.isEmpty) {
          return cameraShyAlert(context, state.uid, isEndShot: true);
        }

        if (mounted) {
          Future.delayed(const Duration(seconds: gFinishedTimer)).then(
              (value) => context
                  .read<ServicesBloc>()
                  .add(const ServicesEvent.shotComplated(isEndShot: true)));
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _shotTickerSubscription?.cancel();
    _delayPlayer.dispose();
    _popupPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleName = AppLocalizations.of(context)?.quick_shot_title ?? "";
    return BlocListener<ServicesBloc, ServicesState>(
      listener: (context, state) async {
        if (state.status == ServiceStatus.photoDone) {
          _shotTickerSubscription?.cancel();
          if (mounted) {
            return Future.delayed(const Duration(seconds: gFinishedTimer)).then(
                (value) => context
                    .read<ServicesBloc>()
                    .add(const ServicesEvent.shotComplated()));
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              titleWidget(titleName),
              SizedBox(height: 42.h),
              _displayHead(),
              _shootingsPhoto(),
              const Spacer(),
              //_nextButton(),
              SizedBox(height: 182.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shootingsPhoto() {
    return BlocBuilder<ServicesBloc, ServicesState>(
      buildWhen: (previous, current) =>
          previous.shotedImages.hashCode != current.shotedImages.hashCode,
      builder: (context, state) {
        final shotedImages = state.shotedImages
            .map<Widget>((e) => Container(
                  alignment: Alignment.center,
                  // width: (gQuickSize.width + 2).w,
                  width: gQuickSize.width.w,
                  child: e.image.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: e.image,
                          cacheKey: e.image,
                          width: gQuickSize.width.w,
                          height: gQuickSize.height.h,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          fit: BoxFit.fill,
                        )
                      : null,
                ))
            .toList();
        final remaining = state.zone.totalShootCnt - shotedImages.length;
        for (var i = 0; i < remaining; i++) {
          shotedImages.add(
            Container(
              alignment: Alignment.center,
              width: (gQuickSize.width).w,
              // width: (gQuickSize.width + 2).w,
              child: SvgIcons.dotlineAddSquare.widget(
                width: gQuickSize.width.w,
                height: gQuickSize.height.h,
              ),
            ),
          );
        }

        return SizedBox(
          width: 850.w,
          height: 771.h, //피그마는 750,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  shotedImages[0],
                  SizedBox(width: 50.w),
                  shotedImages[1],
                ],
              ),
              SizedBox(
                height: 55.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  shotedImages[2],
                  SizedBox(width: 50.w),
                  shotedImages[3],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _displayHead() {
    return BlocBuilder<ServicesBloc, ServicesState>(
      builder: (context, state) {
        final is20Down = tickTime <= 20;
        final color = is20Down ? const Color(0xffb74093) : GColors.cyanAccent;
        final successStyle = TextStyle(
            fontSize: 80.sp,
            color: GColors.cyanAccent,
            fontWeight: FontWeight.w500);

        final endSoonName =
            AppLocalizations.of(context)?.quick_photo_notification_end_soon ??
                "";
        final shootingEnd1Name = AppLocalizations.of(context)
                ?.quick_photo_notification_shooting_end1 ??
            "";
        final shootingEnd2Name = AppLocalizations.of(context)
                ?.quick_photo_notification_shooting_end2 ??
            "";
        final shootingCutName = AppLocalizations.of(context)
                ?.quick_photo_notification_shooting_cut ??
            "";
        // final shootingCutName =
        //     '$shootingCut  (${state.shotedImages.length}/${state.zone.totalShootCnt})';

        if (state.shotedImages.length < state.zone.totalShootCnt) {
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: textEngWidget(
                  ' $tickTime"',
                  fontColor: color,
                  fontSize: 180.sp,
                  fontHeight: 0.9,
                ),
              ),
              SizedBox(
                height: 80.h,
                child: is20Down
                    ? textWidget(
                        endSoonName,
                        fontColor: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 45.sp,
                        durationBlink: is20Down ? 2000 : 0,
                      )
                    : null,
              ),
              SizedBox(height: 161.h),
              textEngWidget(shootingCutName,
                  fontColor: Colors.white, fontSize: 35.sp),
              SizedBox(height: 70.h),
            ],
          );
        }

        return Column(
          children: [
            SizedBox(height: 140.h),
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              child: Text.rich(TextSpan(style: successStyle, children: [
                TextSpan(
                    text: shootingEnd1Name,
                    style: successStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFamily: gFontSamsungsharpsans,
                    )),
                TextSpan(
                    text: shootingEnd2Name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: gFontSamsungsharpsans,
                    )),
              ])),
            ),
            SizedBox(height: 150.h),
            textEngWidget(shootingCutName,
                fontColor: Colors.white, fontSize: 35.sp),
            SizedBox(height: 70.h),
          ],
        );
      },
    );
  }
}
