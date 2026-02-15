import 'package:chest_disease_app/core/components/widgets/custom_auth_container.dart';
import 'package:chest_disease_app/core/utils/extenstions/image_extentions.dart';
import 'package:chest_disease_app/core/utils/extenstions/nb_extenstions.dart';
import 'package:flutter/material.dart';
import 'package:chest_disease_app/core/utils/extenstions/responsive_design_extenstions.dart';
import 'package:chest_disease_app/core/utils/theme/text_styles/app_text_styles.dart';
import '../../../../../core/components/widgets/custom_image_view.dart';
import '../../../../../core/utils/assets/assets_png.dart';
import '../../../../../generated/l10n.dart';
import 'login_form_widget.dart';

class LoginScreenWidget extends StatelessWidget {
  const LoginScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // CustomAppLogoContainer(),
          CustomImageView(
            imagePath: AssetsPng.loginScreen.toPng(),
            width: double.infinity,
          ),
          15.toHeight,
          Text(
            S.of(context).login,
            style: AppTextStyles.font20GreenW500
                .copyWith(fontWeight: FontWeight.w700),
          ),
          8.toHeight,
          Text(
            S.of(context).heyThereLogin,
            style: AppTextStyles.font15LightGreenW500,
            textAlign: TextAlign.center,
          ),
          16.toHeight,
          const CustomAuthContainerWidget(
            child: LoginFormWidget(),
          ).paddingSymmetric(horizontal: 10.w),
        ],
      ),
    );
  }
}

