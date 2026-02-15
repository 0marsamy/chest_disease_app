import 'dart:io';

import 'package:dio/dio.dart';

class EditProfileRequestModel {
  final String? name;
  final String? userName;
  final String? email;
  final File? profileImage;

  EditProfileRequestModel({
    this.name,
    this.userName,
    this.profileImage,
    this.email,
  });

  Future<FormData> toFormData() async {
    final formData = FormData.fromMap({
      'fullName': name ?? '',
      'userName': userName ?? '',
      'email': email ?? '',
    });

    if (profileImage != null) {
      formData.files.add(
        MapEntry(
          'profileImage',
          await MultipartFile.fromFile(profileImage!.path,
              filename: profileImage!.path.split('/').last),
        ),
      );
    }
    return formData;
  }
}

class EditProfileResponseModel {
  final String? name;
  final String? userName;
  final String? email;
  final String? profileImageUrl;

  EditProfileResponseModel({
    this.name,
    this.userName,
    this.email,
    this.profileImageUrl,
  });

  factory EditProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return EditProfileResponseModel(
      name: json['fullName'],
      userName: json['userName'],
      email: json['email'],
      profileImageUrl: json['profileImageUrl'],
    );
  }
}
