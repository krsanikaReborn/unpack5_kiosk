import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kiosk/bloc/services/services_bloc.dart';
import 'package:kiosk/core/colors.dart';
import 'package:kiosk/core/defined_code.dart';

import '../../bloc/websocket/web_socket_bloc.dart';
import '../../injection_container.dart';
import '../../utils/svg_icons.dart';
import '../../utils/time_ticker.dart';
import '../../utils/widget/helper_widget.dart';

class LowHigPhotoNotificationScreen extends StatefulWidget {
  const LowHigPhotoNotificationScreen({
    super.key,
    required this.ticker,
    required this.zoneType,
  });

  final TimeTicker ticker;

  final KindZoneType zoneType;

  @override
  State<LowHigPhotoNotificationScreen> createState() =>
      LowHigPhotoNotificationScreenState();
}

class LowHigPhotoNotificationScreenState
    extends State<LowHigPhotoNotificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  StreamSubscription<int>? _shotTickerSubscription;
  late int tickTime;
  final totalImgCnt =
      KindZoneType.high.totalShootCnt + KindZoneType.low.totalShootCnt;

  late AudioPlayer sec3Player;
  late AudioPlayer donePlayer;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    tickTime = context.read<ServicesBloc>().state.zone.shotTime;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer();
    });

    sec3Player = AudioPlayer();
    donePlayer = AudioPlayer();

    _initSounds();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _shotTickerSubscription?.cancel();
    sec3Player.dispose();
    donePlayer.dispose();
    super.dispose();
  }

  void _initSounds() async {
    await sec3Player.setUrl('http://192.168.0.10:8080/images/sound/sec_3.mp3');
    await donePlayer.setUrl('http://192.168.0.10:8080/images/sound/shooting_done.wav');
  }

  void _startTimer() {
    _shotTickerSubscription?.cancel();
    it<WebSocketBloc>().add(WebSocketEvent.highRowIndicator(
        type: widget.zoneType.name, indicatorType: tickTime.toString()));
    _shotTickerSubscription =
        widget.ticker.tick(ticks: tickTime).listen((duration) {
      tickTime = duration;
      setState(() {});
      sec3Player.play();

      if (tickTime <= 0) {
        setState(() {});
        _shotTickerSubscription?.cancel();

        Future.delayed(const Duration(milliseconds: 500)).then((value) {
          context.read<ServicesBloc>().add(const ServicesEvent.shotPhoto());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleName = AppLocalizations.of(context)?.lowhigh_title ?? "";

    return BlocListener<ServicesBloc, ServicesState>(
      listener: (context, state) async {
        final shotedImages =
            state.shotedImages.where((e) => e.type == state.zone.name);

        //다음화면으로 가기전 6초대기
        if (state.status == ServiceStatus.photoDone) {
          donePlayer.play();
          return Future.delayed(const Duration(seconds: gFinishedTimer)).then(
              (value) => context
                  .read<ServicesBloc>()
                  .add(const ServicesEvent.shotComplated()));
        }

        if (tickTime <= 0 &&
            shotedImages.isNotEmpty &&
            shotedImages.length < state.zone.totalShootCnt &&
            state.status == ServiceStatus.onPictures &&
            mounted) {
          tickTime = context.read<ServicesBloc>().state.zone.shotTime;
          _startTimer();
          return;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              titleWidget(titleName),
              _displayHead(),
              _shootingsPhoto(KindZoneType.high),
              SizedBox(height: 26.h),
              _shootingsPhoto(KindZoneType.low),
              const Spacer(),
              //_nextButton(),
              const SizedBox(height: 94),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shootingsPhoto(KindZoneType zone) {
    final loadingName = AppLocalizations.of(context)?.save_print_loading ?? "";

    return BlocBuilder<ServicesBloc, ServicesState>(
      buildWhen: (previous, current) =>
          previous.shotedImages != current.shotedImages,
      builder: (context, state) {
        final shotedImages =
            state.shotedImages.where((e) => e.type == zone.name);
        final workShotedImages = shotedImages
            .map<Widget>(
              (e) => Container(
                alignment: Alignment.center,
                width: (gHighLowSize.width + 15).w,
                child: e.image.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: e.image,
                        cacheKey: e.image,
                        width: gHighLowSize.width.w,
                        height: gHighLowSize.height.h,
                        fit: BoxFit.fill,
                      )
                    : null,
              ),
            )
            .toList();
        final remaining = zone.totalShootCnt - workShotedImages.length;

        //기본상태인 존 요소
        var dotlineWidget = SvgIcons.dotlineAdd
            .widget(width: gHighLowSize.width.w, height: gHighLowSize.height.h);
        var backColor = Colors.black;
        var fontColor = Colors.white;
        var loadingMarker = Image.asset("assets/images/loading_small.gif",
            width: 150.w, height: 100.h, fit: BoxFit.fill);
        //주목중인 존 요소
        if (state.shotedImages.length != totalImgCnt && state.zone == zone) {
          dotlineWidget = SvgIcons.dotlineAddBlack.widget(
              width: gHighLowSize.width.w, height: gHighLowSize.height.h);
          backColor = GColors.cyanAccent;
          fontColor = Colors.black;
          loadingMarker = Image.asset("assets/images/loading_small_black.gif",
              width: 150.w, height: 100.h, fit: BoxFit.fill);
        }

        for (var i = 0; i < remaining; i++) {
          workShotedImages.add(Stack(
            alignment: Alignment.center,
            children: [
              Container(
                  alignment: Alignment.center,
                  width: (gHighLowSize.width + 15).w,
                  child: dotlineWidget),
              if (tickTime <= 0 &&
                  (zone.totalShootCnt - remaining) == workShotedImages.length &&
                  zone == state.zone)
                SizedBox(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [loadingMarker],
                  ),
                )
            ],
          ));
        }

        // final shootingCutName = '${zone.desc} $shootingCut  ( ${shotedImages.length}/${zone.totalShootCnt} )';
        final shootingCutName = zone.desc == 'High' ? 
          AppLocalizations.of(context) ?.lowhigh_photo_notification_shooting_cut_high ?? ""
          : AppLocalizations.of(context) ?.lowhigh_photo_notification_shooting_cut_low ?? "";
      
        return Container(
          width: 970.w,
          height: 571.h,
          decoration: BoxDecoration(
            color: backColor,
            borderRadius: BorderRadius.circular(15.w),
          ),
          padding: EdgeInsets.all(40.w),
          child: Column(
            children: [
              textEngWidget(
                shootingCutName,
                fontColor: fontColor,
                fontSize: 35.sp,
              ),
              SizedBox(height: 40.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: workShotedImages,
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
        const successStyle = TextStyle(
            fontSize: 40,
            color: GColors.cyanAccent,
            fontWeight: FontWeight.w500);
        final end1Name =
            AppLocalizations.of(context)?.lowhigh_photo_notification_end1 ?? "";
        final end2Name =
            AppLocalizations.of(context)?.lowhigh_photo_notification_end2 ?? "";

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: double.infinity,
              height: 276.h,
              child: state.shotedImages.length == totalImgCnt
                  ? Center(
                      child: Text.rich(TextSpan(style: successStyle, children: [
                        TextSpan(
                            text: end1Name,
                            style: successStyle.copyWith(
                                fontWeight: FontWeight.w700, fontSize: 70.sp)),
                        TextSpan(text: end2Name),
                      ])),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [textEngWidget(' $tickTime"', fontSize: 180.sp)],
                    ),
            ),
          ],
        );
      },
    );
  }
}
