import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widget/helper_widget.dart';

class BlinkingButton extends StatefulWidget {
  const BlinkingButton(
      {Key? key, required this.buttonText, required this.onPressed})
      : super(key: key);
  final String buttonText;
  final VoidCallback? onPressed;
  @override
  State<BlinkingButton> createState() => _BlinkingButtonState();
}

/// [AnimationController]s can be created with `vsync: this` because of
/// [TickerProviderStateMixin].
class _BlinkingButtonState extends State<BlinkingButton>
    with TickerProviderStateMixin {
  // late final AnimationController _controller = AnimationController(
  //   duration: const Duration(seconds: 1),
  //   vsync: this,
  // )..repeat(reverse: true);
  // late final Animation<double> _animation = CurvedAnimation(
  //   parent: _controller,
  //   curve: Curves.easeIn,
  // );

  @override
  void dispose() {
    //  _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String buttonText = widget.buttonText;
    VoidCallback? onPressed = widget.onPressed;
    return
        //  FadeTransition(
        //   opacity: _animation,
        //   child:

        SizedBox(
      width: 605.w,
      height: 139.h,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
        ),
        onPressed: () {
          if (onPressed != null) {
            onPressed();
          }
          Navigator.of(context).pop();
        },
        child: textWidget(
          buttonText,
          // fontSize: 60.sp,
          fontSize: 50.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      // ),
    );
  }
}
