import 'package:flutter/material.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/constants/colors.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final Color? color;
  final bool fullwidth;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  const CustomButton({
    super.key,
    this.onPressed,
    required this.title,
    this.color,
    this.fullwidth = false,
    this.textColor = Colors.white,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (fullwidth == true) ? context.width : null,
      height: 48,
      padding: padding,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          title,
          style: context.textTheme.titleSmall!.copyWith(
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
