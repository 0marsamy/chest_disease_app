import 'package:chest_disease_app/core/config/app_routing.dart';
import 'package:chest_disease_app/core/utils/extenstions/navigation_extenstions.dart';
import 'package:chest_disease_app/features/register/presentation/view/widgets/rigester_screen_widget.dart';
import 'package:chest_disease_app/features/register/presentation/view_model/rigester_screen_cubit.dart';
import 'package:chest_disease_app/features/register/presentation/view_model/rigester_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chest_disease_app/core/utils/extenstions/toast_string_extenstion.dart';

class RigesterScreen extends StatelessWidget {
  const RigesterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<RigesterScreenCubit, RigesterScreenState>(
        listener: (context, state) {
          if (state is RegisterDataMissingState) {
            state.message.showToast();
          } else if (state is RegisterErrorState) {
            state.message.showToast();
          } else if (state is RegisterSuccessState) {
            
            // 1. نجلب الإيميل من الـ Controller مباشرة (أضمن طريقة لتجنب الـ Null)
            final currentEmail = context.read<RigesterScreenCubit>().emailController.text;

            // 2. نرسل البيانات كـ Map كما يطلب الـ Router عندك
            context.navigateTo(
              AppRoutes.verificationCodeScreen,
              arguments: {
                'email': currentEmail,  // الإيميل (String)
                'isResetPass': false,   // نحدد أنها ليست استعادة كلمة مرور (bool)
              },
            );
          }
        },
        child: const RigesterScreenWidget(),
      ),
    );
  }
}