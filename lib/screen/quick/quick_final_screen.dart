import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/services/services_bloc.dart';
import '../../core/defined_code.dart';
import '../../utils/widget/helper_widget.dart';

class QuickFinalScreen extends StatefulWidget {
  const QuickFinalScreen({super.key});

  @override
  State<QuickFinalScreen> createState() => QuickFinalScreenState();
}

class QuickFinalScreenState extends State<QuickFinalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _displayHead() {
    final doneName = AppLocalizations.of(context)?.quick_final_done ?? "";

    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      SizedBox(height: 200.h),
      textWidget(doneName, fontSize: 70.sp, fontWeight: FontWeight.w700),
      SizedBox(height: 80.h),
    ]);
  }

  Widget _bottomTexts() {
    final description2Name =
        AppLocalizations.of(context)?.quick_final_description2 ?? "";

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 30.h),
          textWidget(
            description2Name,
            fontColor: Colors.grey,
            fontSize: 25.sp,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleName = AppLocalizations.of(context)?.quick_shot_title ?? "";
    final saveAndPrintName =
        AppLocalizations.of(context)?.quick_final_save_and_print ?? "";
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          titleWidget(titleName, enabledBack: true, enabledHome: true),
          _displayHead(),
          BlocBuilder<ServicesBloc, ServicesState>(
            builder: (context, state) {
              final selectedImages = state.selectedimages;
              if (selectedImages.isEmpty) {
                return SizedBox(height: 1018.h);
              }

              return SizedBox(
                width: 680.w,
                height: 1018.h,
                child: Stack(
                  children: [
                    //확인용더미소스
                    // Image.asset(
                    //     'assets/images/quick_sample1.png', width : 680.w, height:1018.h, fit: BoxFit.fill,
                    // )
                    CachedNetworkImage(
                      imageUrl: selectedImages[KindZoneType.quick]?.image ?? '',
                      cacheKey: selectedImages[KindZoneType.quick]?.image ?? '',
                      width: 680.w,
                      height: 1018.h,
                      fit: BoxFit.fill,
                    )

                    // Padding(
                    //     padding: const EdgeInsets.fromLTRB(30, 126, 0, 10),
                    //     child: Image.network(
                    //       selectedImages[KindZoneType.quick]?.image ?? '',
                    //     )
                    // )
                    ,
                    if (state.selectedMagazineImages[KindZoneType.quick]
                            ?.isNotEmpty ==
                        true)
                      Image.asset(
                        state.selectedMagazineImages[KindZoneType.quick] ?? '',
                        width: 680.w,
                        height: 1018.h,
                        fit: BoxFit.fill,
                      ),
                  ],
                ),
              );
            },
          ),
          const Spacer(),
          button(saveAndPrintName,
              onPressed: () => context
                  .read<ServicesBloc>()
                  .add(const ServicesEvent.saveAndPrint()),
              textSize: 60.sp),
          _bottomTexts(),
          SizedBox(height: 120.h),
        ],
      ),
    );
  }
}
