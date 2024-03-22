import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/core/defined_code.dart';
import 'package:kiosk/utils/svg_icons.dart';

import '../../utils/widget/helper_widget.dart';
import '../bloc/services/services_bloc.dart';
import '../utils/alert/qrcode.dart';

class SaveAndPrintScreen extends StatelessWidget {
  const SaveAndPrintScreen({super.key, required this.zone});

  final KindZoneType zone;

  @override
  Widget build(BuildContext context) {
    final titleName = zone == KindZoneType.quick
        ? AppLocalizations.of(context)?.quick_shot_title ?? ""
        : AppLocalizations.of(context)?.lowhigh_title ?? "";

    final inProgressName =
        AppLocalizations.of(context)?.save_print_in_progress ?? "";
    final pleaseWaitName =
        AppLocalizations.of(context)?.save_print_please_wait ?? "";
    final loadingName = AppLocalizations.of(context)?.save_print_loading ?? "";

    return BlocListener<ServicesBloc, ServicesState>(
      listener: (context, state) {
        if (state.omp != null) {
          qrCodeAlert(context, state.omp!);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              titleWidget(titleName),
              SizedBox(height: 596.h),
              SvgIcons.print.widget(
                width: 298.w,
                height: 288.w,
              ),
              //로딩 추가00000
              SizedBox(height: 30.h),
              // textWidget(loadingName,
              //     fontSize: 30.sp, fontWeight: FontWeight.normal),
              // SizedBox(height: 20.h),
              Image.asset("assets/images/loading_big.gif",
                  width: 233.w, height: 145.h, fit: BoxFit.fill),
              SizedBox(height: 90.h),
              textWidget(
                inProgressName,
                fontSize: 50.sp,
                fontWeight: FontWeight.w700,
              ),

              SizedBox(height: 96.h),
              textWidget(pleaseWaitName,
                  fontColor: Colors.white, fontSize: 40.sp),
            ],
          ),
        ),
      ),
    );
  }
}
