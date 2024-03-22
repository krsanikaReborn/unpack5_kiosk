import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/bloc/services/services_bloc.dart';
import 'package:kiosk/bloc/websocket/web_socket_bloc.dart';
import 'package:kiosk/core/defined_code.dart';

import '../../injection_container.dart';
import '../../utils/time_ticker.dart';
import '../../utils/widget/helper_widget.dart';
import 'package:just_audio/just_audio.dart';

class LowHigWaitPhotoNotificationScreen extends StatefulWidget {
  const LowHigWaitPhotoNotificationScreen(
      {super.key, required this.ticker, required this.zoneType});

  final TimeTicker ticker;

  final KindZoneType zoneType;

  @override
  State<LowHigWaitPhotoNotificationScreen> createState() =>
      LowHigWaitPhotoNotificationScreenState();
}

class LowHigWaitPhotoNotificationScreenState
    extends State<LowHigWaitPhotoNotificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  StreamSubscription<int>? _tickerSubscription;
  var tickTime = 5;
  late AudioPlayer player;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer();
    });

    player = AudioPlayer();
    player.setUrl('http://192.168.0.10:8080/images/sound/sec_5.wav');
    player.play();

    super.initState();
  }

  void _startTimer() {
    _tickerSubscription?.cancel();
    it<WebSocketBloc>().add(WebSocketEvent.highRowIndicator(
        type: widget.zoneType.name, indicatorType: tickTime.toString()));
    _tickerSubscription =
        widget.ticker.tick(ticks: tickTime).listen((duration) {
      tickTime = duration;
      setState(() {});
      if (tickTime <= 0) {
        setState(() {});

        _tickerSubscription?.cancel();
        Future.delayed(const Duration(milliseconds: 500)).then((value) =>
            context.read<ServicesBloc>().add(const ServicesEvent.shotPhoto()));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _tickerSubscription?.cancel();
    _tickerSubscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleName = AppLocalizations.of(context)?.lowhigh_title ?? "";

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            titleWidget(titleName, enabledHome: true),
            SizedBox(height: 150.h),
            _displayHead(),
          ],
        ),
      ),
    );
  }

  Widget _displayHead() {
    ///로우 자세 준비 메시지
    if (widget.zoneType == KindZoneType.low) {
      final lowDescriptionName =
          AppLocalizations.of(context)?.lowhigh_wait_photo_low_description ??
              "";
      return Column(
        children: [
          SizedBox(height: 402.h),
          textWidget(
            lowDescriptionName,
            fontColor: Colors.white,
            fontSize: 45.sp,
            // fontWeight: FontWeight.w600,
          ),
          SizedBox(height: 60.h),
          textWidget(' $tickTime"',
              fontSize: 350.sp, fontWeight: FontWeight.w700),
          SizedBox(height: 10.h),
          Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationX(math.pi),
              child: Image.asset('assets/images/highlow_up_arrow_2.gif',
                  width: 360.w, height: 360.h, fit: BoxFit.fill)),
        ],
      );
    }

    ///하이 자세 준비 메시지
    final highDescriptionName =
        AppLocalizations.of(context)?.lowhigh_wait_photo_high_description ?? "";
    return Column(
      children: [
        Image.asset('assets/images/highlow_up_arrow_2.gif',
            width: 360.w, height: 360.h, fit: BoxFit.fill),
        SizedBox(height: 42.h),
        textWidget(
          highDescriptionName,
          fontColor: Colors.white,
          fontSize: 45.sp,
          // fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 50.h),
        textWidget(' $tickTime"', fontSize: 350.sp, fontWeight: FontWeight.w700),
      ],
    );
  }
}
