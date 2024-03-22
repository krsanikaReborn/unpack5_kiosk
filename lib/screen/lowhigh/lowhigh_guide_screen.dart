import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/services/services_bloc.dart';
import '../../utils/widget/guide_step_content_view.dart';
import '../../utils/widget/helper_widget.dart';
import '../../utils/widget/step_dot_progress.dart';

class LowHighGuideScreen extends StatefulWidget {
  const LowHighGuideScreen({Key? key}) : super(key: key);

  @override
  State<LowHighGuideScreen> createState() => LowHighGuideScreenState();
}

class LowHighGuideScreenState extends State<LowHighGuideScreen> {
  final PageController controller = PageController();
  var index = 0;
  // late Timer _timer;

  @override
  void dispose() {
    controller.dispose();
    // _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    controller.addListener(() {
      final page = controller.page?.round();
      if (page != null) {
        setState(() {
          // _timer.cancel();
          index = page;
        });
      }
    });

    //2초후 자동 흘러가기
    // _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
    //   print(index);
    //   if (index != 2) {
    //     setState(() {
    //       index++;
    //     });
    //     _pageMove();
    //   } else {
    //     _timer.cancel();
    //   }
    // });

    super.initState();
  }

  void _pageMove({bool isNext = true}) {
    if (isNext) {
      controller.nextPage(
          duration: const Duration(seconds: 1), curve: Curves.ease);
    } else {
      controller.previousPage(
          duration: const Duration(seconds: 1), curve: Curves.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleName = AppLocalizations.of(context)?.lowhigh_title ?? "";
    final step1Name = AppLocalizations.of(context)?.lowhigh_guide_step1 ?? "";
    final step2Name = AppLocalizations.of(context)?.lowhigh_guide_step2 ?? "";
    final step3Name = AppLocalizations.of(context)?.lowhigh_guide_step3 ?? "";
    final description1Name =
        AppLocalizations.of(context)?.lowhigh_guide_description1 ?? "";
    final description2Name =
        AppLocalizations.of(context)?.lowhigh_guide_description2 ?? "";
    final description3Name =
        AppLocalizations.of(context)?.lowhigh_guide_description3 ?? "";
    // final agreeName = AppLocalizations.of(context)?.lowhigh_guide_agree ?? "";
    final nextName = AppLocalizations.of(context)?.lowhigh_guide_next ?? "";

    //아랍어 화살표뒤집기 대책
    var isArrowForward = true;
    if (Localizations.localeOf(context).toLanguageTag() == "ar-AR") {
      isArrowForward = !isArrowForward;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            controller: controller,
            children: [
              GuideStepContentView(
                  title: step1Name,
                  description: description1Name,
                  assetName: 'highlow_guide_01.gif'),
              GuideStepContentView(
                  title: step2Name,
                  description: description2Name,
                  assetName: 'highlow_guide_02.gif'),
              GuideStepContentView(
                  title: step3Name,
                  description: description3Name,
                  assetName: 'highlow_guide_03.gif'),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              titleWidget(titleName, enabledHome: true),
              const Spacer(),
              index == 2
                  ? button(nextName,
                      onPressed: () => context
                          .read<ServicesBloc>()
                          .add(const ServicesEvent.ready()),
                      textSize: 60.sp)
                  : button(nextName,
                      onPressed: () => _pageMove(), textSize: 60.sp),
              SizedBox(height: 182.h),
            ],
          ),
          Positioned(
            top: 1131.h,
            width: 200.w,
            child: StepDotProgress(
              totoalCnt: 3,
              currentCnt: index,
            ),
          ),
          Positioned(
            top: 710.h,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 42.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  arrowActionButton(
                    isForward: isArrowForward,
                    isVisibled: index != 0,
                    callback: () {
                      // _timer.cancel();
                      _pageMove(isNext: false);
                    },
                  ),
                  const Spacer(),
                  arrowActionButton(
                    isForward: !isArrowForward,
                    isVisibled: index != 2,
                    callback: () {
                      // _timer.cancel();
                      _pageMove();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
