import 'package:chest_disease_app/core/components/widgets/custom_button.dart';
import 'package:chest_disease_app/core/utils/extenstions/nb_extenstions.dart';
import 'package:chest_disease_app/core/utils/extenstions/responsive_design_extenstions.dart';
import 'package:chest_disease_app/core/utils/theme/text_styles/app_text_styles.dart';
import 'package:chest_disease_app/features/register/presentation/view/widgets/doctor_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../generated/l10n.dart';
import '../../view_model/rigester_screen_cubit.dart';
import '../../view_model/rigester_screen_state.dart';

class RigesterScreenWidget extends StatelessWidget {
  const RigesterScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<RigesterScreenCubit>();
    return SafeArea(
      child: BlocBuilder<RigesterScreenCubit, RigesterScreenState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(S.of(context).createYourAcc,
                    style: AppTextStyles.font20GreenW500),
                6.toHeight,
                Text(
                  S.of(context).welcomeAbroadSentence,
                  style: AppTextStyles.font15LightGreenW500,
                  textAlign: TextAlign.center,
                ),
                16.toHeight,
                const DoctorFormWidget(),
                24.toHeight,
                CustomButton(
                  isLoading: state is RigesterScreenLoadingState,
                  text: S.of(context).submit,
                  onTap: () {
                    if (cubit.formKey.currentState!.validate()) {
                      cubit.register();
                    }
                  },
                ).animate().flipV(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                    ),
                16.toHeight,
              ],
            ),
          );
        },
      ).paddingOnly(top: 24.h, left: 24.w, right: 24.w),
    );
  }
}
