import 'package:chest_disease_app/core/components/widgets/custom_auth_container.dart';
import 'package:chest_disease_app/core/utils/extenstions/responsive_design_extenstions.dart';
import 'package:chest_disease_app/features/register/presentation/view/widgets/profile_image_picker.dart';
import 'package:chest_disease_app/features/register/presentation/view/widgets/select_gender.dart';
import 'package:chest_disease_app/features/register/presentation/view_model/rigester_screen_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/components/widgets/custom_text_field.dart';
import '../../../../../core/utils/assets/assets_svg.dart';
import '../../../../../core/utils/extenstions/validators.dart';
import '../../../../../core/utils/strings/app_string.dart';
import '../../../../../core/utils/theme/colors/app_colors.dart';
import '../../../../../foundations/validations.dart';
import '../../../../../generated/l10n.dart';

class DoctorFormWidget extends StatelessWidget {
  const DoctorFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RigesterScreenCubit>();

    return CustomAuthContainerWidget(
      child: Form(
        key: cubit.formKey,
        child: Column(
          children: [
            ProfileImagePicker(cubit: cubit),
            16.toHeight,
            CustomTextField(
              focusNode: cubit.fullNameFocus,
              onSubmit: (p0) {
                FocusScope.of(context).requestFocus(cubit.userNameFocus);
              },
              label: S.of(context).fullName,
              hintText: S.of(context).enterYourFullName,
              controller: cubit.fullNameController,
              validator: (value) => checkFieldValidation(
                  val: value,
                  fieldName: S.of(context).fullName,
                  fieldType: ValidationType.name),
            ),
            16.toHeight,
            CustomTextField(
              focusNode: cubit.userNameFocus,
              onSubmit: (p0) {
                FocusScope.of(context).requestFocus(cubit.emailFocus);
              },
              label: S.of(context).userName,
              hintText: S.of(context).enterYourFullName,
              controller: cubit.userNameController,
              validator: (value) => checkFieldValidation(
                  val: value,
                  fieldName: S.of(context).userName,
                  fieldType: ValidationType.name),
            ),
            16.toHeight,
            CustomTextField(
                focusNode: cubit.emailFocus,
                onSubmit: (p0) {
                  FocusScope.of(context).requestFocus(cubit.imageFocus);
                },
                label: S.of(context).email,
                hintText: S.of(context).enterYourEmail,
                controller: cubit.emailController,
                validator: Validators.emailValidate),
            16.toHeight,
            CustomTextField(
              subLabel: S.of(context).uploadYourNationalMedical,
              controller: cubit.licenseFrontController,
              hintText: S.of(context).tapToAttachFile,
              label: S.of(context).medicalCertificateFrontImage,
              readOnly: true,
              suffixIcon: AssetsSvg.uploadDoc,
              onTap: () {
                cubit.pickDocument().then((v) {
                  if (v != null) {
                    cubit.setDoctorLicenseFrontFile(v);
                  }
                });
              },
            ),
            16.toHeight,
            CustomTextField(
              controller: cubit.licenseBackController,
              hintText: S.of(context).tapToAttachFile,
              label: S.of(context).medicalCertificateFrontImage,
              readOnly: true,
              suffixIcon: AssetsSvg.uploadDoc,
              onTap: () {
                cubit.pickDocument().then((v) {
                  if (v != null) {
                    cubit.setDoctorLicenseBackFile(v);
                  }
                });
              },
            ),
            16.toHeight,

            // Date Picker
            CustomTextField(
              controller: cubit.birthDateController,
              focusNode: cubit.birthDateFocus,
              onSubmit: (p0) {
                FocusScope.of(context).requestFocus(cubit.genderFocus);
              },
              hintText: S.of(context).selectDateOfBirth,
              readOnly: true,
              label: S.of(context).birthDate,
              suffixIcon: AssetsSvg.datePicker,
              validator: (value) =>
                  value!.isEmpty ? AppStrings.dateError : null,
              onTap: () => _selectDate(context, cubit),
            ),
            16.toHeight,
            const SelectGender(),
            16.toHeight,
             CustomTextField(
              label: "Clinic Address",
              hintText: "Enter your clinic address",
              controller: cubit.clinicAddressController,
              validator: (value) => checkFieldValidation(
                  val: value,
                  fieldName: "Clinic Address",
                  fieldType: ValidationType.text),
            ),
            16.toHeight,
            CustomTextField(
              focusNode: cubit.passwordFocus,
              label: S.of(context).password,
              hintText: S.of(context).enterYourPassword,
              controller: cubit.passwordController,
              validator: (value) => checkFieldValidation(
                  val: value,
                  fieldName: S.of(context).password,
                  fieldType: ValidationType.password),
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, RigesterScreenCubit cubit) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.typography,
              onPrimary: AppColors.background,
              onSurface: AppColors.navSecondary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      cubit.setSelectedDate(picked);
    }
  }
}

