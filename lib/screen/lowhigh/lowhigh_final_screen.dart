import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/core/defined_code.dart';

import '../../bloc/services/services_bloc.dart';
import '../../utils/widget/helper_widget.dart';
import '../../utils/widget/result_pageview.dart';
import '../../utils/widget/step_dot_progress.dart';

class LowHighFinalScreen extends StatefulWidget {
  const LowHighFinalScreen({super.key});

  @override
  State<LowHighFinalScreen> createState() => LowHighFinalScreenState();
}

class LowHighFinalScreenState extends State<LowHighFinalScreen> {
  var selectIndex = 0;

  Widget _displayHead() {
    final resultName = AppLocalizations.of(context)?.lowhigh_final_result ?? "";
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(height: 143.h),
      textEngWidget(resultName, fontSize: 70.sp),
      SizedBox(height: 70.h),
    ]);
  }

  Widget _bottomTexts() {
    // final resultMassageName =
    //     AppLocalizations.of(context)?.lowhigh_final_result_massage ?? "";
    // final description1Name =
    //     AppLocalizations.of(context)?.lowhigh_final_result_description1 ?? "";
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 30.h),
          // textWidget(description1Name, fontSize: 25.sp),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleName = AppLocalizations.of(context)?.lowhigh_title ?? "";
    final imageEmptyName =
        AppLocalizations.of(context)?.lowhigh_final_image_empty ?? "";
    final saveAndPrintName =
        AppLocalizations.of(context)?.lowhigh_final_save_and_print ?? "";
    final description2Name =
        AppLocalizations.of(context)?.lowhigh_final_result_description2 ?? "";

    //다국어대책    
    var buttonTextSize = 60.sp;
    if (Localizations.localeOf(context).toLanguageTag() == "fr-FR") {
      buttonTextSize = 42.sp;
    }
    if (Localizations.localeOf(context).toLanguageTag() == "de-DE") {
      buttonTextSize = 50.sp;
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          titleWidget(titleName,
              enabledBack: true, enabledHome: true, context: context),
          _displayHead(),
          BlocBuilder<ServicesBloc, ServicesState>(
            builder: (context, state) {
              final selectedImages = state.selectedimages;

              return CarouselSlider(
                options: CarouselOptions(
                  initialPage: 0,
                  viewportFraction: 1,
                  enableInfiniteScroll: false,
                  height: 1018.h,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  onPageChanged: (index, reason) {
                    setState(() {
                      selectIndex = index;
                    });
                  },
                ),
                items: [
                  ResultPageView(
                    selectedImage:
                        selectedImages[KindZoneType.high]?.image ?? '',
                    selectedBackgroundImage:
                        state.selectedMagazineImages[KindZoneType.high] ?? '',
                  ),
                  ResultPageView(
                    selectedImage:
                        selectedImages[KindZoneType.low]?.image ?? '',
                    selectedBackgroundImage:
                        state.selectedMagazineImages[KindZoneType.low] ?? '',
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 90.h),
          StepDotProgress(
            totoalCnt: 2,
            currentCnt: selectIndex,
          ),
          _bottomTexts(),
          const Spacer(),
          button(
            saveAndPrintName,
            onPressed: () => context
                .read<ServicesBloc>()
                .add(const ServicesEvent.saveAndPrint()),
            textSize: buttonTextSize,
          ),
          SizedBox(height: 30.h),
          textWidget(
            description2Name,
            fontColor: Colors.grey,
            fontSize: 25.sp,
          ),
          SizedBox(height: 120.h),
        ],
      ),
    );
  }
}
