import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kiosk/core/colors.dart';

import '../../bloc/services/services_bloc.dart';
import '../../bloc/timer/timer_bloc.dart';
import '../../core/defined_code.dart';
import '../../utils/widget/helper_widget.dart';

const lowHigMagazinesImages = <String>[
  'assets/images/magazine/none.png',
  'assets/images/magazine/cover_01.png',
  'assets/images/magazine/cover_02.png',
  'assets/images/magazine/cover_03.png',
];

const lowHigMagazinesSelectImages = <String>[
  'assets/images/magazine/none.png',
  'assets/images/magazine/cover_01.png',
  'assets/images/magazine/cover_02_select.png',
  'assets/images/magazine/cover_03.png',
];

class LowHighMagazineStyleScreen extends StatefulWidget {
  const LowHighMagazineStyleScreen({
    super.key,
    required this.zoneType,
  });

  final KindZoneType zoneType;

  @override
  State<LowHighMagazineStyleScreen> createState() =>
      LowHighMagazineStyleScreenState();
}

class LowHighMagazineStyleScreenState extends State<LowHighMagazineStyleScreen>
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

    final selectedmagazineImage = context
            .read<ServicesBloc>()
            .state
            .selectedMagazineImages[widget.zoneType] ??
        lowHigMagazinesImages[0];

    final index = lowHigMagazinesImages.indexOf(selectedmagazineImage);
    selectedIndex = index < 0 ? 0 : index;
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
    final selectButtonName =
        AppLocalizations.of(context)?.lowhigh_magazine_style_select_button ??
            "";
    // final descriptionName =
    //     AppLocalizations.of(context)?.lowhigh_magazine_style_high_description ??
    //         "";
    final styleHighDescriptionName =
        AppLocalizations.of(context)?.lowhigh_magazine_style_high_description ??
            "";
    final styleLowDescriptionName =
        AppLocalizations.of(context)?.lowhigh_magazine_style_low_description ??
            "";
    //다언어대책
    var descSize = 30.sp;
    if (Localizations.localeOf(context).toLanguageTag() == "fr-FR") {
      descSize = 27.sp;
    }
    if (Localizations.localeOf(context).toLanguageTag() == "de-DE") {
      descSize = 27.sp;
    }


    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            titleWidget(titleName, enabledBack: true),
            _displayHead(),
            BlocBuilder<ServicesBloc, ServicesState>(
              builder: (context, state) {
                final selectedImages = state.selectedimages;
                final imageUrl = selectedImages[state.zone]?.image ?? '';

                if (selectedIndex != 1) {
                  return SizedBox(
                    height: 825.h,
                    child: Stack(
                      children: [
                        Padding(
                            padding:
                                EdgeInsets.fromLTRB(34.w, 160.w, 0.w, 20.w),
                            child: imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    cacheKey: imageUrl,
                                    fit: BoxFit.fill,
                                  )
                                : null),
                        Image.asset(
                          lowHigMagazinesImages[selectedIndex],
                          fit: BoxFit.fill,
                        ),
                      ],
                    ),
                  );
                } else {
                  return SizedBox(
                      height: 825.h,
                      child: Stack(children: [
                        ClipRect(
                            child: Align(
                                alignment: Alignment.center,
                                widthFactor: 0.885,
                                heightFactor: 1.0,
                                child: imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        cacheKey: imageUrl,
                                        fit: BoxFit.fill,
                                      )
                                    : null)),
                        if (selectedIndex != 0)
                          Image.asset(
                            lowHigMagazinesImages[selectedIndex],
                            fit: BoxFit.fill,
                          ),
                      ]));
                }
              },
            ),
            SizedBox(height: 50.h),
            BlocBuilder<ServicesBloc, ServicesState>(
              builder: (context, state) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 237.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 744.w,
                            height: 237.h,
                            child: CarouselSlider(
                              carouselController: _carouselController,
                              options: CarouselOptions(
                                padEnds: false,
                                initialPage: selectedIndex,
                                aspectRatio: 1 / 2,
                                viewportFraction: 0.25,
                                autoPlayCurve: Curves.fastOutSlowIn,
                                enableInfiniteScroll: false,
                              ),
                              items: List.generate(
                                lowHigMagazinesSelectImages.length,
                                (index) => InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = index;
                                    });
                                  },
                                  child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      child: Stack(
                                        children: [
                                          Image.asset(
                                            width: 168.w,
                                            height: 237.h,
                                            lowHigMagazinesSelectImages[index],
                                            fit: BoxFit.fill,
                                          ),
                                          Container(
                                            width: 168.w,
                                            height: 237.h,
                                            decoration: BoxDecoration(
                                              border: index == selectedIndex
                                                  ? Border.all(
                                                      strokeAlign: BorderSide
                                                          .strokeAlignInside,
                                                      width: 5,
                                                      color: GColors.cyanAccent,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Positioned(
                    //   left: 178.w,
                    //   child: Container(
                    //     width: 168.w,
                    //     height: 237.h,
                    //     decoration: BoxDecoration(
                    //       border: Border.all(
                    //         strokeAlign: BorderSide.strokeAlignCenter,
                    //         width: 5.w,
                    //         color: const Color(0xFF9AFFEC),
                    //       ),
                    //     ),
                    //   ),
                    // )
                  ],
                );
              },
            ),
            SizedBox(height: 30.h),
            textWidget(
                widget.zoneType == KindZoneType.high
                    ? styleHighDescriptionName
                    : styleLowDescriptionName,
                fontColor: Colors.white,
                fontSize: descSize),
            const Spacer(),
            button(
              selectButtonName,
              onPressed: () async {
                context.read<ServicesBloc>().add(
                      ServicesEvent.finalOnResult(
                        selectedMagazineImages: selectedIndex != 0
                            ? lowHigMagazinesImages[selectedIndex]
                            : '',
                        zone: widget.zoneType,
                      ),
                    );
              },
              textSize : 60.sp
            ),
            SizedBox(height: 182.h),
          ],
        ),
      ),
    );
  }

  Widget _displayHead() {
    final styleHighName =
        AppLocalizations.of(context)?.lowhigh_magazine_style_high ?? "";

    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        final is20Down = state.duration <= 20;
        final color = is20Down ? const Color(0xffb74093) : GColors.cyanAccent;

        return SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(height: 10.h),
              textEngWidget(' ${state.duration}"',
                  fontColor: color, fontSize: 100.sp, fontHeight: 1.26),
              textEngWidget(styleHighName, fontSize: 70.sp),
              SizedBox(height: 60.h),
            ],
          ),
        );
      },
    );
  }
}
