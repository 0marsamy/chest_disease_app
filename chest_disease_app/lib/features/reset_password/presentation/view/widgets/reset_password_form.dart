import 'package:chest_disease_app/core/utils/extenstions/nb_extenstions.dart';
import 'package:chest_disease_app/core/utils/extenstions/responsive_design_extenstions.dart';
import 'package:chest_disease_app/features/reset_password/presentation/view_model/reset_password_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/components/widgets/custom_button.dart';
import '../../../../../core/components/widgets/custom_text_field.dart';
import '../../../../../core/utils/assets/assets_svg.dart';
import '../../../../../foundations/validations.dart';
import '../../../../../generated/l10n.dart';

class ResetPasswordForm extends StatelessWidget {
  const ResetPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ResetPasswordCubit>();
    return Form(
      key: cubit.formKey,
      child: BlocListener<ResetPasswordCubit, ResetPasswordState>(
        listener: (context, state) {
          if (state is ResetPasswordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(state.message),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
          builder: (context, state) {
            return Column(
              children: [
                CustomTextField(
                  label: S.of(context).email,
                  hintText: S.of(context).enterYourEmail,
                  controller: cubit.emailController,
                  focusNode: cubit.emailFocusNode,
                  readOnly: true,
                  onSubmit: (value) {
                    FocusScope.of(
                      context,
                    ).requestFocus(cubit.passwordFocusNode);
                  },
                  validator: (value) => checkFieldValidation(
                    val: cubit.emailController.text,
                    fieldName: S.of(context).email,
                    fieldType: ValidationType.email,
                  ),
                ),
                20.toHeight,
                CustomTextField(
                  label: S.of(context).newPassword,
                  hintText: S.of(context).enterYourPassword,
                  controller: cubit.passwordController,
                  obscureText: cubit.isObscure,
                  suffixIcon: AssetsSvg.password,
                  onSuffixTap: () {
                    cubit.changeVisiblePassword();
                  },
                  focusNode: cubit.passwordFocusNode,
                  onSubmit: (p0) {
                    FocusScope.of(
                      context,
                    ).requestFocus(cubit.confirmPasswordFocusNode);
                  },
                  validator: (value) => checkFieldValidation(
                    val: cubit.passwordController.text,
                    fieldName: S.of(context).newPassword,
                    fieldType: ValidationType.password,
                  ),
                ),
                20.toHeight,
                CustomTextField(
                  label: S.of(context).confirmPassword,
                  hintText: S.of(context).confirmPassword,
                  controller: cubit.confirmPasswordController,
                  obscureText: cubit.isConfirmObscure,
                  suffixIcon: AssetsSvg.password,
                  onSuffixTap: () {
                    cubit.changeVisibleConfirmPassword();
                  },
                  focusNode: cubit.confirmPasswordFocusNode,
                  onSubmit: (p0) {
                    // No OTP field anymore, focus on submit button or do nothing
                  },
                  validator: (value) => checkFieldValidation(
                    val: cubit.confirmPasswordController.text,
                    fieldName: S.of(context).confirmPassword,
                    fieldType: ValidationType.confirmPassword,
                    confirmPass: cubit.passwordController.text,
                  ),
                ),
                25.toHeight,
                CustomButton(
                      isLoading: state is ResetPasswordLoadingState,
                      text: S.of(context).resetPassword,
                      onTap: () {
                        cubit.submitNewPassword();
                      },
                    )
                    .animate()
                    .flipV(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                    )
                    .paddingOnly(bottom: 15.h),
              ],
            );
          },
        ),
      ),
    );
  }
}
