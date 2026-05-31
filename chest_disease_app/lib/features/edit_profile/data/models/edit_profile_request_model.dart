class EditProfileRequestModel {
  final String? fullName;
  final String? email;
  final String? userName;

  EditProfileRequestModel({this.fullName, this.email, this.userName});

  Future<Map<String, dynamic>> toMap() async {
    final map = <String, dynamic>{};
    final trimmedFullName = fullName?.trim();
    final trimmedEmail = email?.trim();
    final trimmedUserName = userName?.trim();

    if (trimmedFullName != null && trimmedFullName.isNotEmpty) {
      map['fullName'] = trimmedFullName;
    }
    if (trimmedEmail != null && trimmedEmail.isNotEmpty) {
      map['email'] = trimmedEmail;
    }
    if (trimmedUserName != null && trimmedUserName.isNotEmpty) {
      map['userName'] = trimmedUserName;
    }
    return map;
  }
}
