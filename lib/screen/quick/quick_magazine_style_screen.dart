import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kiosk/core/colors.dart';
import 'package:kiosk/core/defined_code.dart';
import 'package:kiosk/utils/time_ticker.dart';

import '../../bloc/services/services_bloc.dart';
import '../../bloc/timer/timer_bloc.dart';
import '../../utils/widget/helper_widget.dart';

const magazinesImages = <String>[
  'assets/images/magazine/none.png',
  'assets/images/magazine/cover_01.png',
  'assets/images/magazine/cover_02.png',
  'assets/images/magazine/cover_03.png',
];

const magazinesSelectImages = <String>[
  'assets/images/magazine/none.png',
  'assets/images/magazine/cover_01.png',
  'assets/images/magazine/cover_02_select.png',
  'assets/images/magazine/cover_03.png',
];

class QuickMagazineStyleScreen extends StatefulWidget {
  const QuickMagazineStyleScreen({
    super.key,
    required this.ticker,
  });
  final TimeTicker ticker;

  @override
  State<QuickMagazineStyleScreen> createState() =>
      QuickMagazineStyleScreenState();
}

class QuickMagazineStyleScreenState extends State<QuickMagazineStyleScreen>
    with SingleTickerProviderStateMixin {
  late AudioPlayer player;

  late AnimationController _controller;

  late final CarouselController _carouselController;

  var selectedIndex = 0;

  @override
  void initState() {
    _carouselController = CarouselController();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    player = AudioPlayer();
    player.setUrl('http://192.168.0.10:8080/images/sound/delay_short.mp3');
    //player.setLoopMode(LoopMode.one);

    final selectedmagazineImage = context
            .read<ServicesBloc>()
            .state
            .selectedMagazineImages[KindZoneType.quick] ??
        magazinesImages[0];

    final index = magazinesImages.indexOf(selectedmagazineImage);
    selectedIndex = index < 0 ? 0 : index;

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    player.dispose();
    super.dispose();
  }

  Widget _displayHead(context) {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        final is20Down = state.duration <= 20;
        final color = is20Down ? const Color(0xffb74093) : GColors.cyanAccent;
        final headlineName =
            AppLocalizations.of(context)?.quick_magazin_style_headline ?? "";

        return SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height: 42.h),
              SizedBox(
                  width: double.infinity,
                  child: textEngWidget(' ${state.duration}"',
                      fontColor: color, fontSize: 100.sp)),
              textEngWidget(headlineName, fontSize: 70.sp),
              SizedBox(height: 70.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleName = AppLocalizations.of(context)?.quick_shot_title ?? "";
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            titleWidget(titleName, enabledBack: true),
            _displayHead(context),
            BlocBuilder<ServicesBloc, ServicesState>(
              builder: (context, state) {
                final selectedImages = state.selectedimages;
                final imageUrl =
                    selectedImages[KindZoneType.quick]?.image ?? '';

                if (selectedIndex != 1) {
                  return SizedBox(
                      height: 825.h,
                      child: Stack(children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(0.w, 170.w, 0.w, 20.w),
                            child: imageUrl.isNotEmpty
                                ? ClipRect(
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 0.875,
                                      heightFactor: 1.0,
                                      child: imageUrl.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              cacheKey: imageUrl,
                                              height: 825.h,
                                              fit: BoxFit.fill,
                                            )
                                          : null,
                                    ),
                                  )
                                : null),
                        Image.asset(
                          magazinesImages[selectedIndex],
                          fit: BoxFit.fill,
                        ),
                      ]));
                } else {
                  return SizedBox(
                    height: 825.h,
                    child: Stack(
                      children: [
                        ClipRect(
                          child: Align(
                            alignment: Alignment.center,
                            widthFactor: 0.66,
                            heightFactor: 1.0,
                            child: imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    cacheKey: imageUrl,
                                    height: 854.h,
                                    fit: BoxFit.fill,
                                  )
                                : null,
                          ),
                        ),
                        if (selectedIndex != 0)
                          Image.asset(
                            magazinesImages[selectedIndex],
                            fit: BoxFit.fill,
                          ),
                      ],
                    ),
                  );
                }
              },
            ),
            SizedBox(
              height: 40.h,
            ),
            BlocBuilder<ServicesBloc, ServicesState>(
              builder: (context, state) {
                return SizedBox(
                  width: 744.w,
                  height: 237.h,
                  child: CarouselSlider(
                    carouselController: _carouselController,
                    options: CarouselOptions(
                      padEnds: false,
                      enableInfiniteScroll: false,
                      initialPage: 0,
                      aspectRatio: 1 / 2,
                      viewportFraction: 0.25,
                      autoPlayCurve: Curves.fastOutSlowIn,
                    ),
                    items: List.generate(
                      magazinesSelectImages.length,
                      (index) => InkWell(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: Container(
                          color: Colors.white,
                          width: 168.w,
                          height: 237.h,
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              Image.asset(
                                width: 168.w,
                                height: 237.h,
                                magazinesSelectImages[index],
                                fit: BoxFit.fill,
                              ),
                              Container(
                                width: 168.w,
                                height: 237.h,
                                decoration: BoxDecoration(
                                  border: index == selectedIndex
                                      ? Border.all(
                                          strokeAlign:
                                              BorderSide.strokeAlignInside,
                                          width: 5,
                                          color: GColors.cyanAccent,
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            BlocBuilder<ServicesBloc, ServicesState>(
              builder: (context, state) {
                final selectButtonName = AppLocalizations.of(context)
                        ?.quick_magazin_style_select_button ??
                    "";
                return button(
                  selectButtonName,
                  onPressed: () async {
                    context.read<ServicesBloc>().add(
                        ServicesEvent.finalOnResult(
                            selectedMagazineImages: selectedIndex != 0
                                ? magazinesImages[selectedIndex]
                                : '',
                            zone: KindZoneType.quick));
                  },
                  textSize: 60.sp,
                );
              },
            ),
            SizedBox(height: 182.h),
          ],
        ),
      ),
    );
  }
}
