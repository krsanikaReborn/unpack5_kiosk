import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kiosk/core/colors.dart';
import 'package:kiosk/core/defined_code.dart';

import '../../bloc/services/services_bloc.dart';
import '../../bloc/timer/timer_bloc.dart';
import '../../data/shooting_image/shooting_image.dart';
import '../../injection_container.dart';
import '../../utils/svg_icons.dart';
import '../../utils/time_ticker.dart';
import '../../utils/widget/helper_widget.dart';

class LowHighPhotoResultScreen extends StatefulWidget {
  const LowHighPhotoResultScreen({super.key, required this.ticker});

  final TimeTicker ticker;

  @override
  State<LowHighPhotoResultScreen> createState() =>
      LowHighPhotoResultScreenState();
}

class LowHighPhotoResultScreenState extends State<LowHighPhotoResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ShootingImage? selectHighImage;
  ShootingImage? selectLowImage;
  final selectImagesCarouselController = CarouselController();
  late AudioPlayer player;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    player = AudioPlayer();
    player.setUrl('http://192.168.0.10:8080/images/sound/shooting_done.wav');
    final timerBloc = context.read<TimerBloc>();
    timerBloc.add(const TimerStarted(duration: gHighLowWaitTimer));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleName = AppLocalizations.of(context)?.lowhigh_title ?? "";
    final resultDescriptionName =
        AppLocalizations.of(context)?.lowhigh_photo_result_description ?? "";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          titleWidget(titleName),
          _displayHead(),
          SizedBox(height: 0.h),
          _selectPhotoList(KindZoneType.high),
          SizedBox(height: 60.h),
          _selectPhotoList(KindZoneType.low),
          SizedBox(height: 30.h),
          textWidget(resultDescriptionName,
              fontSize: 30.sp, fontColor: Colors.white),
          const Spacer(),
          _nextButton(),
          SizedBox(height: 183.h),
        ],
      ),
    );
  }

  BlocBuilder<ServicesBloc, ServicesState> _selectPhotoList(KindZoneType type) {
    return BlocBuilder<ServicesBloc, ServicesState>(
      builder: (context, state) {
        var selectImage =
            type == KindZoneType.high ? selectHighImage : selectLowImage;
        final shotedImages =
            state.shotedImages.where((e) => e.type == type.name).map<Widget>(
          (e) {
            final isSelected = selectImage?.image == e.image;
            final imageWidget = CachedNetworkImage(
              imageUrl: e.image,
              width: gHighLowSize.width.w,
              height: gHighLowSize.height.h,
              cacheKey: e.image,
              fit: BoxFit.fill,
            );
            return InkWell(
              onTap: () {
                it<TimerBloc>().add(const TimerOffAlert());
                setState(() {
                  if (type == KindZoneType.high) {
                    selectHighImage = isSelected ? null : e;
                  } else {
                    selectLowImage = isSelected ? null : e;
                  }
                });
              },
              child: isSelected || selectImage == null
                  ? Stack(
                      alignment: Alignment.topRight,
                      children: [
                        imageWidget,
                        if (isSelected) ...{
                          Container(
                            width: gHighLowSize.width.w,
                            height: gHighLowSize.height.h,
                            decoration: BoxDecoration(
                              border: Border.all(
                                strokeAlign: BorderSide.strokeAlignInside,
                                width: 10.w,
                                color: GColors.cyanAccent,
                              ),
                            ),
                          ),
                          SvgIcons.checkBox.widget(width: 58.w, height: 58.h),
                        }
                      ],
                    )
                  : ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.5), BlendMode.darken),
                      child: imageWidget,
                    ),
            );
          },
        ).toList();
        final remaining = state.zone.totalShootCnt - shotedImages.length;
        for (var i = 0; i < remaining; i++) {
          shotedImages.add(SvgIcons.dotlineAdd.widget(
              width: gHighLowSize.width.w, height: gHighLowSize.height.h));
        }
        
        final resultName = type.desc == 'High' ?
          AppLocalizations.of(context)?.lowhigh_photo_result_shooting_result_high ?? ""
          :AppLocalizations.of(context)?.lowhigh_photo_result_shooting_result_low ?? "";



        return Container(
          width: 970.w,
          padding: EdgeInsets.fromLTRB(54.25.w, 43.h, 54.25.w, 35.h),
          // padding: EdgeInsets.symmetric(horizontal: 105.w),
          child: Column(
            children: [
              textEngWidget(resultName,
                  fontColor: Colors.white, fontSize: 35.sp),
              SizedBox(height: 38.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: shotedImages,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _nextButton() {
    final selectButtonName =
        AppLocalizations.of(context)?.lowhigh_photo_result_select_button ?? "";
    return selectHighImage != null && selectLowImage != null
        ? button(selectButtonName, onPressed: () async {
            it<TimerBloc>().add(const TimerOffAlert());
            context.read<ServicesBloc>().add(ServicesEvent.selectMagazine(
                    selectedImages: {
                      KindZoneType.high: selectHighImage!,
                      KindZoneType.low: selectLowImage!
                    }));         
          }
          , textSize: 60.sp
          )
        : button(selectButtonName, onPressed: null, textSize: 60.sp);
  }

  Widget _displayHead() {
    final selectPhotoName =
        AppLocalizations.of(context)?.lowhigh_photo_result_select_photo ?? "";

    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        final is20Down = state.duration <= 20;
        final color = is20Down ? const Color(0xffb74093) : GColors.cyanAccent;

        return SizedBox(
          width: double.infinity,
          height: 276.h,
          // height: 276.h,
          child: Column(
            children: [
              SizedBox(height: 10.h),
              SizedBox(
                  width: double.infinity,
                  child: textEngWidget(' ${state.duration}"',
                      fontColor: color, fontSize: 100.sp, fontHeight: 1.26)),
              textEngWidget(selectPhotoName, fontSize: 70.h),
              SizedBox(height: 10.h),
              // textWidget(resultDescriptionName,
              //     fontColor: Colors.white, fontSize: 20.sp),
            ],
          ),
        );
      },
    );
  }
}
