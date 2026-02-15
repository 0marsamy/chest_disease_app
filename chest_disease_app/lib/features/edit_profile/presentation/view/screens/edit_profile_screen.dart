import 'package:chest_disease_app/core/components/widgets/custom_button.dart';
import 'package:chest_disease_app/core/components/widgets/custom_image_view.dart';
import 'package:chest_disease_app/core/components/widgets/custom_profile_image.dart';
import 'package:chest_disease_app/core/components/widgets/custom_text_field.dart';
import 'package:chest_disease_app/core/utils/extenstions/responsive_design_extenstions.dart';
import 'package:chest_disease_app/core/utils/extenstions/toast_string_extenstion.dart';
import 'package:chest_disease_app/core/utils/theme/colors/app_colors.dart';
import 'package:chest_disease_app/core/utils/theme/text_styles/app_text_styles.dart';
import 'package:chest_disease_app/features/edit_profile/presentation/view_model/cubit/edit_profile_cubit.dart';
import 'package:chest_disease_app/foundations/app_constants.dart';
import 'package:chest_disease_app/foundations/validations.dart';
import 'package:chest_disease_app/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/components/widgets/custom_upload_image_icon.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<EditProfileCubit>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          S.of(context).accountSetting,
          style: AppTextStyles.font20BlueW700.copyWith(color: AppColors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: BlocConsumer<EditProfileCubit, EditProfileState>(
          listener: (context, state) {
            if (state is EditProfileSuccess) {
              'Profile updated successfully'.showToast();
            }
            if (state is EditProfileError) {
              'Failed to update profile'.showToast();
            }
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () =>
                      state.isEditing ? cubit.pickProfileImage() : null,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      state.profileImage != null
                          ? CustomImageView(
                              file: state.profileImage,
                              width: 100.w,
                              height: 100.w,
                              radius: BorderRadius.circular(100.w),
                            ).animate().flipH(duration: 500.ms)
                          : AppConstants.user!.profilePicture == null
                              ? const CustomUploadImageIcon()
                                  .animate()
                                  .flipH(duration: 500.ms)
                              : CustomProfileImage(
                                  imageUrl: AppConstants.user!.profilePicture,
                                  size: 100.w,
                                ).animate().flipH(duration: 500.ms),
                      if (state.isEditing)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: AppColors.buttonsAndNav,
                            size: 16.sp,
                          ),
                        )
                    ],
                  ),
                ),
                24.toHeight,
                CustomTextField(
                    readOnly: !state.isEditing,
                    label: S.of(context).fullName,
                    validator: (value) => checkFieldValidation(
                        val: cubit.nameController.text,
                        fieldName: S.of(context).fullName,
                        fieldType: ValidationType.text),
                    controller: cubit.nameController,
                    hintText: S.of(context).fullName),
                16.toHeight,
                CustomTextField(
                  readOnly: !state.isEditing,
                  label: S.of(context).email,
                  validator: (value) => checkFieldValidation(
                    val: cubit.emailController.text,
                    fieldName: S.of(context).email,
                    fieldType: ValidationType.email,
                  ),
                  controller: cubit.emailController,
                  hintText: S.of(context).email,
                ),
                16.toHeight,
                CustomTextField(
                  readOnly: !state.isEditing,
                  label: S.of(context).userName,
                  validator: (value) => checkFieldValidation(
                    val: cubit.userNameController.text,
                    fieldName: S.of(context).userName,
                    fieldType: ValidationType.phone,
                  ),
                  controller: cubit.userNameController,
                  hintText: S.of(context).userName,
                ),
                48.toHeight,
                if (state is EditProfileLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  CustomButton(
                    raduis: 8.r,
                    width: 100.w,
                    text: state.isEditing
                        ? S.of(context).save
                        : S.of(context).edit,
                    onTap: () {
                      if (state.isEditing) {
                        cubit.editProfile();
                      } else {
                        cubit.toggleEditMode();
                      }
                    },
                  ).animate().flipV(duration: 500.ms)
              ],
            ).animate().fadeIn(duration: 300.ms);
          },
        ),
      ),
    );
  }
}

