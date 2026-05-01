import 'package:bloc/bloc.dart';
import 'package:chest_disease_app/core/config/app_routing.dart';
import 'package:chest_disease_app/core/utils/extenstions/toast_string_extenstion.dart';
import 'package:chest_disease_app/foundations/app_constants.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../../../core/utils/extenstions/navigation_extenstions.dart';
import '../../../../core/data/local_services/app_caching_helper.dart';
import '../../data/models/login_model.dart';
import '../../data/repository/login_repository.dart';

part 'login_state.dart';

@injectable
class LoginCubit extends Cubit<LoginState> {
  final LoginRepository repository;

  LoginCubit({required this.repository}) : super(LoginInitial());
  bool isObscure = true;
  final formKey = GlobalKey<FormState>();
  final forgetPasswordFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final forgetPasswordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final LocalAuthentication auth = LocalAuthentication();
  bool rememberMe = false;
  bool isBiometricAvailable = false;
  BuildContext context = NavigationExtensions.navigatorKey.currentContext!;

  Future<void> forgetPassword() async {
    if (forgetPasswordFormKey.currentState!.validate()) {
      emit(ForgetPasswordLoadingState());
      final email = forgetPasswordController.text.trim();
      if (email.isEmpty || !email.contains('@')) {
        "Please enter a valid email".showToast();
        emit(LoginErrorState());
        return;
      }
      final response = await repository.forgetPassword(email);
      response.fold(
        (l) {
          l.message!.showToast();
          emit(LoginErrorState());
        },
        (r) {
          context.navigateTo(
            AppRoutes.verificationCodeScreen,
            arguments: {'email': r, 'isResetPass': true},
          );
        },
      );
    }
  }

  Future<void> login() async {
    if (formKey.currentState!.validate()) {
      emit(LoginLoadingState());
      final result = await repository.login(
        LoginRequestModel(
          email: emailController.text,
          password: passwordController.text,
        ),
      );
      result.fold(
        (l) {
          l.message!.showToast();
          emit(LoginErrorState());
        },
        (r) async {
          if (r.token == null || r.user == null) {
            "Invalid login response from server".showToast();
            emit(LoginErrorState());
            return;
          }
          if (rememberMe) {
            await AppConstants.setBiometricToken(r.token!);
            await AppConstants.setBiometricUser(r.user!);
          }
          await AppConstants.cacheString(
            key: AppCacheHelper.rememberMe,
            value: rememberMe.toString(),
          );
          await AppConstants.setToken(r.token!);
          await AppConstants.setUser(r.user!);
          AppConstants.user = r.user;
          await setLocation();
          NavigationExtensions.navigatorKey.currentState
              ?.pushNamedAndRemoveUntil(AppRoutes.homeScreen, (_) => false);
          emit(LoginSuccessState());
        },
      );
    }
  }

  void toggleRememberMe() {
    rememberMe = !rememberMe;
    emit(ChangeRememberMeState(rememberMe: rememberMe));
  }

  Future<void> checkBiometricAvailability() async {
    try {
      isBiometricAvailable = await auth.canCheckBiometrics;
      emit(
        BiometricAvailabilityState(isBiometricAvailable: isBiometricAvailable),
      );
    } catch (e) {
      isBiometricAvailable = false;
    }
  }

  Future<void> authenticateWithBiometrics() async {
    try {
      // Retrieve user token and data from secure storage
      String? userToken = await AppConstants.getBiometricToken();
      User? userDataJson = await AppConstants.getBiometricUser();

      if (userToken == null || userDataJson == null) {
        emit(LoginErrorState());
        return;
      }

      bool authenticated = await auth.authenticate(
        localizedReason: 'welcome back ${userDataJson.fullName}',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          sensitiveTransaction: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        await AppConstants.setToken(userToken);
        await AppConstants.setUser(userDataJson);
        NavigationExtensions.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.homeScreen,
          (_) => false,
        );
        emit(LoginSuccessState());
      }
    } catch (e) {
      emit(LoginErrorState());
    }
  }

  Future<void> setLocation() async {
    AppConstants.location = "Cairo, Egypt";
  }

  void changePassword() {
    isObscure = !isObscure;
    emit(ChangePasswordState(isObscure));
  }
}
