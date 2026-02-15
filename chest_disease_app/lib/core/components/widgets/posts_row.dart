import 'package:chest_disease_app/core/utils/extenstions/nb_extenstions.dart';
import 'package:chest_disease_app/core/utils/extenstions/responsive_design_extenstions.dart';
import 'package:flutter/material.dart';
import '../../utils/theme/text_styles/app_text_styles.dart';

class PostsRow extends StatelessWidget {
  const PostsRow({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.font16BlueW700,
          ),
          6.toHeight,
        ],
      ),
    ).paddingSymmetric(horizontal: 19.w);
  }
}

