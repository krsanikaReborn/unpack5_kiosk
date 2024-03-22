import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kiosk/core/colors.dart';
import 'package:kiosk/utils/widget/helper_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../data/omp/ompinfo.dart';

void qrCodeAlert(BuildContext context, OMPInfo omp) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.2),
    builder: (BuildContext context) {
      var qrDescriptionName = AppLocalizations.of(context)?.utils_qrcode_description ?? '';
      

      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: SizedBox(
            width: 916.w,
            height: 709.w,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  top: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 92.w,
                      height: 92.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF717171),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 90,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    color: GColors.cyanAccent.withOpacity(0.7),
                  ),
                  width: 916.w,
                  height: 547.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          omp.urls.length,
                          (index) => Padding(
                            padding: EdgeInsets.only(
                                right:
                                    omp.urls.elementAtOrNull(index + 1) != null
                                        ? 20.w
                                        : 0),
                            child: Container(
                              color: Colors.white,
                              child: QrImageView(
                                data: omp.urls[index],
                                version: QrVersions.auto,
                                size: 212.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 51.w,
                      ),
                      textEngWidget(
                        qrDescriptionName,
                        fontColor: Colors.black,
                        fontSize: 40.sp,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}
