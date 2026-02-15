import 'package:chest_disease_app/core/utils/extenstions/responsive_design_extenstions.dart';
import 'package:chest_disease_app/core/utils/theme/colors/app_colors.dart';
import 'package:flutter/material.dart';

class CustomHorizentalDivider extends StatelessWidget {
  const CustomHorizentalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: const BoxDecoration(color: AppColors.background),
    );
  }
}

