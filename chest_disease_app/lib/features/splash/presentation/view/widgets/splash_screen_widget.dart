import 'package:chest_disease_app/core/components/widgets/custom_image_view.dart';
import 'package:chest_disease_app/core/components/widgets/custom_onboarding_background.dart';
import 'package:chest_disease_app/core/config/app_routing.dart';
import 'package:chest_disease_app/core/utils/extenstions/image_extentions.dart';
import 'package:chest_disease_app/core/utils/extenstions/responsive_design_extenstions.dart';
import 'package:chest_disease_app/foundations/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/utils/assets/assets_png.dart';

class SplashScreenWidget extends StatefulWidget {
  const SplashScreenWidget({super.key});

  @override
  State<SplashScreenWidget> createState() => _SplashScreenWidgetState();
}

class _SplashScreenWidgetState extends State<SplashScreenWidget> {
  @override
  void initState() {
    super.initState();
    navigateToHome();
  }

  @override
  Widget build(BuildContext context) {
    return CustomOnboardingBackground(
        widget: Center(
      child: CustomImageView(
        imagePath: AssetsPng.appLogo.toPng(),
        height: 250.h,
      ).animate().fadeIn(duration: const Duration(seconds: 2)),
    ));
  }

  void navigateToHome() async {
    await Future.delayed(const Duration(seconds: 4));

    final onBoardingCompleted = await AppConstants.getOnBoardingBoolean();
    if (!onBoardingCompleted) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.onBoardingScreen);
      }
      return;
    }

    if (AppConstants.accessToken.isNotEmpty && AppConstants.user != null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
      }
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
      }
    }
  }
}

