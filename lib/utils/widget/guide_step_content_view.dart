import 'package:flutter/material.dart';
import 'package:kiosk/core/colors.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/defined_code.dart';

class GuideStepContentView extends StatelessWidget {
  const GuideStepContentView({
    super.key,
    required this.assetName,
    required this.title,
    required this.description,
  });

  final String assetName;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 377.h,
          ),
          SizedBox(
            width : 700.w,
            height: 741.h,
            child: Image.asset(
            'assets/images/$assetName',
            fit: BoxFit.cover
            ),
          ),
          
          SizedBox(
            height: 190.h,
          ),
          Text(title,
              style: TextStyle(
                fontSize: 53.sp,
                fontWeight: FontWeight.w700,
                color: GColors.cyanAccent,
                fontFamily: gFontSamsungsharpsans,
              )),
          SizedBox(
            height: 18.h,
          ),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 35.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              fontFamily: gFontSamsungsharpsans,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
