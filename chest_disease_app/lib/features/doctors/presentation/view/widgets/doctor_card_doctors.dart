import 'package:chest_disease_app/core/components/widgets/custom_button.dart';
import 'package:chest_disease_app/core/components/widgets/stars_generator.dart';
import 'package:chest_disease_app/core/config/app_routing.dart';
import 'package:chest_disease_app/core/data/models/doctor_clinic_model.dart';
import 'package:flutter/material.dart';
import 'package:chest_disease_app/core/utils/extenstions/responsive_design_extenstions.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/components/widgets/custom_image_view.dart';
import '../../../../../core/utils/theme/text_styles/app_text_styles.dart';
import '../../../../../generated/l10n.dart';

class DoctorCardDoctors extends StatelessWidget {
  final DoctorClinicModel doctor; // Rating value (out of 5)

  const DoctorCardDoctors({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
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
        children: [
          Row(
            children: [
              CustomImageView(
                url: doctor.doctorProfilePicture,
                fit: BoxFit.cover,
                width: 120.w,
                height: 160.h,
                radius: BorderRadius.all(Radius.circular(10.r)),
              ),
              15.toWidth,
              SizedBox(
                width: 130.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dr: ${doctor.doctorFullName}",
                      style: AppTextStyles.font20GreenW700,
                    ),
                    5.toHeight,
                    Text(
                      "${S.of(context).address}${doctor.address}",
                      style: AppTextStyles.font12GreenW500,
                    ),
                    5.toHeight,
                    StarsGenerator(rating: doctor.averageStarRating),
                    20.toHeight,
                    CustomButton(
                      raduis: 8.r,
                      text: S.of(context).viewProfile,
                      onTap: () {
                        Navigator.pushNamed(
                            context, AppRoutes.doctorProfileScreen,
                            arguments: doctor);
                      },
                      textStyle: AppTextStyles.font15WhiteW500,
                      height: 44.h,
                      width: 135.w,
                    )
                  ],
                ),
              )
            ],
          ),
          25.toHeight,
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

