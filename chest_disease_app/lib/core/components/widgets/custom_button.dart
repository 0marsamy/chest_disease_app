import 'package:chest_disease_app/core/utils/extenstions/responsive_design_extenstions.dart';
import 'package:chest_disease_app/core/utils/theme/colors/app_colors.dart';
import 'package:chest_disease_app/core/utils/theme/text_styles/app_text_styles.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final BorderSide? borderSide;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final double? raduis;
  final TextStyle? textStyle;
  final Color? circularInticatorColor;
  final bool? isLoading;
  final String text;
  final void Function() onTap;

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.raduis,
    this.isLoading = false,
    this.circularInticatorColor,
    this.backgroundColor,
    this.textStyle,
    this.height,
    this.width,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // عند التحميل، نضع null لمنع أي ضغط إضافي
      onTap: (isLoading ?? false) ? null : onTap,
      child: Container(
        width: width ?? 300.w,
        height: height ?? 55.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(raduis ?? 30.r),
          color: backgroundColor ?? AppColors.buttonsAndNav,
          border: borderSide == null
              ? null
              : Border.fromBorderSide(borderSide!),
        ),
        alignment: Alignment.center,
        child: (isLoading ?? false)
            ? SizedBox(
                height: 20.w,
                width: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    circularInticatorColor ?? AppColors.background,
                  ),
                ),
              )
            : Text(
                text,
                textAlign: TextAlign.center,
                style: textStyle ?? AppTextStyles.font20WhiteW500,
              ),
      ),
    );
  }
}
