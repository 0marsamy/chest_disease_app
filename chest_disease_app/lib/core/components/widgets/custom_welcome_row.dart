import 'package:chest_disease_app/core/utils/extenstions/image_extentions.dart';
import 'package:chest_disease_app/core/utils/extenstions/responsive_design_extenstions.dart';
import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';
import '../../config/app_routing.dart';
import 'custom_image_view.dart';
import '../../utils/assets/assets_png.dart';
import '../../utils/theme/text_styles/app_text_styles.dart';
// ✅ 1. أعدنا إضافة هذا السطر المهم لجلب بيانات المستخدم
import 'package:chest_disease_app/foundations/app_constants.dart';

class CustomWelcomeAppBar extends StatelessWidget {

  const CustomWelcomeAppBar({super.key,});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      elevation: 0,
      pinned: false,
      snap: true,
      floating: true,
      expandedHeight: 75.h,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration:
            BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).welcomeBack,
                  style: AppTextStyles.font15LightGreenW500,
                ),
                SizedBox(
                  width: 150.w,
                  child: Text(
                    // ✅ 2. التصحيح هنا: استخدام الاسم الديناميكي
                    // إذا كان الاسم غير موجود، يظهر "Dr. Omar" كبديل
                    AppConstants.user?.userName ?? "Dr. Omar",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.font20GreenW700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                // زر الشات ما زال موجوداً هنا، إذا كنت تريد إزالته أيضاً يمكنك مسح هذا الجزء
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.chatsListScreen),
                  child: CustomImageView(
                    imagePath: AssetsPng.chat.toPng(),
                    width: 30.w,
                    height: 30.w,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}