import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SvgIcons {
  static final arrow = _SvgIcon('assets/svg/arrow.svg');
  static final smLeftArrow = _SvgIcon('assets/svg/small_left_arrow.svg');
  static final smRightArrow = _SvgIcon('assets/svg/small_right_arrow.svg');
  static final dotlineAdd = _SvgIcon('assets/svg/dotline_add.svg');
  static final dotlineAddBlack = _SvgIcon('assets/svg/dotline_add_black.svg');
  static final dotlineAddSquare = _SvgIcon('assets/svg/dotline_add_square.svg');
  static final print = _SvgIcon('assets/svg/print.svg');
  static final home = _SvgIcon('assets/svg/home.svg');
  static final checkBox = _SvgIcon('assets/svg/checkbox.svg');
  static final selectedCheckBox = _SvgIcon('assets/svg/selected_check_box.svg');
}

class _SvgIcon {
  final String path;

  _SvgIcon(this.path);

  SvgPicture get icon => SvgPicture.asset(path);

  SvgPicture widget({double? width, double? height, Color? color}) =>
      SvgPicture.asset(
        path,
        width: width,
        height: height,
        fit: BoxFit.fill,
        colorFilter:
            color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
      );
}
