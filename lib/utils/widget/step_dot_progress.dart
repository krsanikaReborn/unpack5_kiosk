import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/colors.dart';

class StepDotProgress extends StatelessWidget {
  const StepDotProgress(
      {super.key, required this.totoalCnt, required this.currentCnt});

  final int totoalCnt;
  final int currentCnt;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(
          totoalCnt,
          (index) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 13.w),
            child: Container(
              width: 22.w,
              height: 22.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentCnt == index ? GColors.cyanAccent : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
