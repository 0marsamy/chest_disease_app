part of 'reset_password_cubit.dart';

sealed class ResetPasswordState {}

final class ResetPasswordInitial extends ResetPasswordState {}

final class ResetPasswordLoadingState extends ResetPasswordState {}

final class ResetPasswordSuccess extends ResetPasswordState {}

class ResetPasswordError extends ResetPasswordState {
  final String message;
  ResetPasswordError({required this.message});
}

final class ResetPasswordChangeVisibilty extends ResetPasswordState {
  bool isObscure;

  ResetPasswordChangeVisibilty(this.isObscure);
}
