import 'dart:io';

import 'package:dio/dio.dart';

class EditProfileRequestModel {
  final String? fullName;
  final String? email;
  final String? userName;
  final File? image;

  EditProfileRequestModel({this.fullName, this.email, this.userName, this.image});

  Future<Map<String, dynamic>> toMap() async {
    final map = <String, dynamic>{};
    if (fullName != null) {
      map['fullName'] = fullName;
    }
    if (email != null) {
      map['email'] = email;
    }
    if (userName != null) {
      map['userName'] = userName;
    }
    if (image != null) {
      map['image'] = await MultipartFile.fromFile(image!.path);
    }
    return map;
  }
}