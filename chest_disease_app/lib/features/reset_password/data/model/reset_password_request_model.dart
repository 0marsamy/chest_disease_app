class ResetPasswordRequestModel {
  final String email;
  final String code;
  final String newPassword;

  ResetPasswordRequestModel({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {'email': email, 'code': code, 'newPassword': newPassword};
  }

  // Create from JSON
  // factory ResetPasswordRequestModel.fromJson(Map<String, dynamic> json) {
  //   return ResetPasswordRequestModel(
  //     email: json['email'],
  //     code: json['code'],
  //     newPassword: json['newPassword'],
  //   );
  // }
}
