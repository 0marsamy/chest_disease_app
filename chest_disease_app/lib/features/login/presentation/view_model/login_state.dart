part of 'login_cubit.dart';

@immutable
sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

final class LoginInitial extends LoginState {}

final class ChangePasswordState extends LoginState {
  final bool visibilty;
  const ChangePasswordState(this.visibilty);
  @override
  List<Object> get props => [visibilty];
}

final class LoginLoadingState extends LoginState {}

final class ForgetPasswordLoadingState extends LoginState {}

// الحالة دي اللي ضفناها عشان النجاح
final class ForgetPasswordSuccessState extends LoginState {
  final String email;
  const ForgetPasswordSuccessState({required this.email});
  @override
  List<Object> get props => [email];
}

final class ForgetPasswordErrorState extends LoginState {
  final String message;
  const ForgetPasswordErrorState({required this.message});
  @override
  List<Object> get props => [message];
}

final class LoginSuccessState extends LoginState {}

final class LoginErrorState extends LoginState {
  final String message;
  const LoginErrorState({required this.message});
  @override
  List<Object> get props => [message];
}

final class ChangeRememberMeState extends LoginState {
  final bool rememberMe;
  const ChangeRememberMeState({required this.rememberMe});
  @override
  List<Object> get props => [rememberMe];
}

final class BiometricAvailabilityState extends LoginState {
  final bool isBiometricAvailable;
  const BiometricAvailabilityState({required this.isBiometricAvailable});
  @override
  List<Object> get props => [isBiometricAvailable];
}
