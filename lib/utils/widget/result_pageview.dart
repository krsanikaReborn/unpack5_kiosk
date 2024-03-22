import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResultPageView extends StatelessWidget {
  const ResultPageView(
      {super.key,
      required this.selectedImage,
      required this.selectedBackgroundImage});

  final String selectedImage;
  final String selectedBackgroundImage;
  @override
  Widget build(BuildContext context) {
    final imageEmptyName =
        AppLocalizations.of(context)?.quick_magazin_style_image_empty ?? "";
    if (selectedImage.isEmpty) {
      return Text(imageEmptyName);
    }

    if (selectedBackgroundImage.contains("01")) {
      return SizedBox(
          height: 1017.h,
          child: Stack(children: [
            Padding(
                padding: EdgeInsets.fromLTRB(34.w, 160.w, 0.w, 20.w),
                child: selectedImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: selectedImage,
                        cacheKey: selectedImage,
                        fit: BoxFit.fill,
                      )
                    : null),
            Image.asset(
              selectedBackgroundImage,
              fit: BoxFit.fill,
            ),
          ]));
    } else {
      return SizedBox(
        height: 1017.h,
        child: Stack(
          children: [
            ClipRect(
              child: Align(
                alignment: Alignment.center,
                widthFactor: 0.885,
                heightFactor: 1.0,
                child: selectedImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: selectedImage,
                        cacheKey: selectedImage,
                        height: 1017.h,
                        fit: BoxFit.fill,
                      )
                    : null,
              ),
            ),
            if (selectedBackgroundImage.isNotEmpty)
              Image.asset(
                selectedBackgroundImage,
                fit: BoxFit.fill,
              ),
          ],
        ),
      );
    }
  }
}
