import 'package:chest_disease_app/core/config/app_routing.dart';
import 'package:chest_disease_app/core/utils/extenstions/navigation_extenstions.dart';
import 'package:chest_disease_app/core/utils/extenstions/toast_string_extenstion.dart';
import 'package:chest_disease_app/features/register/presentation/view/widgets/rigester_screen_widget.dart';
import 'package:chest_disease_app/features/register/presentation/view_model/rigester_screen_cubit.dart';
import 'package:chest_disease_app/features/register/presentation/view_model/rigester_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RigesterScreen extends StatelessWidget {
  const RigesterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<RigesterScreenCubit, RigesterScreenState>(
        listener: (context, state) {
          if (state is RegisterDataMissingState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(state.message),
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is RegisterErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(state.message),
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is RegisterSuccessState) {
            context.navigateTo(
              AppRoutes.verificationCodeScreen,
              arguments: {'email': state.email ?? '', 'isResetPass': false},
            );
          }
        },
        child: const RigesterScreenWidget(),
      ),
    );
  }
}
