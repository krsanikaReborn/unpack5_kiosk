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

class QuickPhotoResultScreen extends StatefulWidget {
  const QuickPhotoResultScreen({super.key, required this.ticker});

  final TimeTicker ticker;

  @override
  State<QuickPhotoResultScreen> createState() => QuickPhotoResultScreenState();
}

class QuickPhotoResultScreenState extends State<QuickPhotoResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ShootingImage? selectImage;
  final selectImagesCarouselController = CarouselController();

  late AudioPlayer player;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    player = AudioPlayer();
    player.setUrl('http://192.168.0.10:8080/images/sound/delay_short.mp3');

    final timerBloc = context.read<TimerBloc>();
    timerBloc.add(const TimerStarted(duration: gQuickWaitTimer));
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
    final titleName = AppLocalizations.of(context)?.quick_shot_title ?? "";
    return Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              titleWidget(titleName),
              _displayHead(context),
              BlocBuilder<ServicesBloc, ServicesState>(
                builder: (context, state) {
                  final shotedImages = state.shotedImages.map<Widget>(
                    (e) {
                      final isSelected = selectImage?.image == e.image;
                      final imageWidget = CachedNetworkImage(
                        imageUrl: e.image,
                        cacheKey: e.image,
                        width: gQuickSize.width.w,
                        height: gQuickSize.height.h,
                        fit: BoxFit.fill,
                      );
                      return InkWell(
                        onTap: () {
                          it<TimerBloc>().add(const TimerOffAlert());
                          setState(() {
                            selectImage = isSelected ? null : e;
                          });
                        },
                        child: isSelected || selectImage == null
                            ? Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  imageWidget,
                                  if (isSelected) ...{
                                    Container(
                                      width: gQuickSize.width.w,
                                      height: gQuickSize.height.h,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          strokeAlign:
                                              BorderSide.strokeAlignInside,
                                          width: 10.w,
                                          color: GColors.cyanAccent,
                                        ),
                                      ),
                                    ),
                                    SvgIcons.checkBox
                                        .widget(width: 58.w, height: 58.h),
                                  },
                                ],
                              )
                            : ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.5),
                                    BlendMode.darken),
                                child: imageWidget,
                              ),
                      );
                    },
                  ).toList();
                  final remaining =
                      state.zone.totalShootCnt - shotedImages.length;
                  for (var i = 0; i < remaining; i++) {
                    shotedImages.add(Container(
                      alignment: Alignment.center,
                      width: (gQuickSize.width).w,
                      child: SvgIcons.dotlineAddSquare.widget(
                        width: gQuickSize.width.w,
                        height: gQuickSize.height.h,
                      ),
                    ));
                  }

                  return SizedBox(
                    width: 851.w,
                    height: 775.h, //피그마는 746이나 왠지 가운데가 좁음
                    // padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: shotedImages.isEmpty
                          ? []
                          : [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  shotedImages[0],
                                  SizedBox(width: 50.25.w),
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
                                  SizedBox(width: 50.25.w),
                                  shotedImages[3],
                                ],
                              ),
                            ],
                    ),
                  );
                },
              ),
              const Spacer(),
              _nextButton(),
              SizedBox(height: 182.h),
            ],
          ),
        ));
  }

  Widget _nextButton() {
    final selectButtonName =
        AppLocalizations.of(context)?.quick_photo_result_select_button ?? "";

    return selectImage != null
        ? button(
            selectButtonName,
            onPressed: () async {
              it<TimerBloc>().add(const TimerOffAlert());
              context.read<ServicesBloc>().add(ServicesEvent.selectMagazine(
                  selectedImages: {KindZoneType.quick: selectImage!}));
            },
            textSize: 60.sp,
          )
        : button(selectButtonName, onPressed: null, textSize: 60.sp);
  }

  Widget _displayHead(context) {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        final is20Down = state.duration <= 20;
        final color = is20Down ? const Color(0xffb74093) : GColors.cyanAccent;
        final headlineName =
            AppLocalizations.of(context)?.quick_photo_result_headline ?? "";
        final descriptionName =
            AppLocalizations.of(context)?.quick_photo_result_description ?? "";
        final shootingResultName =
            AppLocalizations.of(context)?.quick_photo_result_shooting_result ??
                "";

        return SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(height: 42.h),
              SizedBox(
                  width: double.infinity,
                  child: textEngWidget(' ${state.duration}"',
                      fontColor: color, fontSize: 100.sp)),
              textEngWidget(headlineName, fontSize: 70.sp),
              textWidget(descriptionName, fontColor: Colors.white),
              SizedBox(height: 133.h),
              textEngWidget(shootingResultName,
                  fontColor: Colors.white, fontSize: 35.sp),
              SizedBox(height: 70.h),
            ],
          ),
        );
      },
    );
  }
}
