import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/services/services_bloc.dart';
import '../../utils/widget/guide_step_content_view.dart';
import '../../utils/widget/helper_widget.dart';
import '../../utils/widget/step_dot_progress.dart';

class QuickGuideScreen extends StatefulWidget {
  const QuickGuideScreen({Key? key}) : super(key: key);

  @override
  State<QuickGuideScreen> createState() => QuickGuideScreenState();
}

class QuickGuideScreenState extends State<QuickGuideScreen> {
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
          index = page;
        });
      }
    });
    //2초후 자동 흘러가기
    // _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
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
    final titleName = AppLocalizations.of(context)?.quick_shot_title ?? '';
    final quickGuideStep1Name =
        AppLocalizations.of(context)?.quick_guide_step1 ?? '';
    final quickGuideStep2Name =
        AppLocalizations.of(context)?.quick_guide_step2 ?? '';
    final quickGuideStep3Name =
        AppLocalizations.of(context)?.quick_guide_step3 ?? '';
    final quickGuideDescription1Name =
        AppLocalizations.of(context)?.quick_guide_description1 ?? '';
    final quickGuideDescription2Name =
        AppLocalizations.of(context)?.quick_guide_description2 ?? '';
    final quickGuideDescription3Name =
        AppLocalizations.of(context)?.quick_guide_description3 ?? '';
    final next = AppLocalizations.of(context)?.quick_guide_next ?? "";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          PageView(
            controller: controller,
            children: [
              GuideStepContentView(
                  title: quickGuideStep1Name,
                  description: quickGuideDescription1Name,
                  assetName: 'quick_guide_01.gif'),
              GuideStepContentView(
                  title: quickGuideStep2Name,
                  description: quickGuideDescription2Name,
                  assetName: 'quick_guide_02.gif'),
              GuideStepContentView(
                title: quickGuideStep3Name,
                description: quickGuideDescription3Name,
                assetName: 'quick_guide_03.gif',
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              titleWidget(titleName, enabledHome: true),
              const Spacer(),
              index == 2
                  ? button(next,
                      onPressed: () => context
                          .read<ServicesBloc>()
                          .add(const ServicesEvent.ready()),
                      textSize: 60.sp)
                  : button(next, onPressed: () => _pageMove(), textSize: 60.sp),
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
                    isVisibled: index != 0,
                    callback: () {
                      // _timer.cancel();
                      _pageMove(isNext: false);
                    },
                  ),
                  const Spacer(),
                  arrowActionButton(
                    isForward: false,
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
