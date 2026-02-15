import 'dart:io';

import 'package:dio/dio.dart';

class RegisterResponseModel {
  String? email;

  RegisterResponseModel({this.email});

  RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
  }
}

class PatientRegisterRequestModel {
  final File? profileProfile;
  final String fullName;
  final String userName;
  final String email;
  final String dateOfBirth;
  final String password;
  final double latitude;
  final double longitude;
  final String gender;

  PatientRegisterRequestModel(
    this.profileProfile,
    this.fullName,
    this.userName,
    this.email,
    this.dateOfBirth,
    this.password,
    this.latitude,
    this.longitude,
    this.gender,
  );
  Future<FormData> toFormData() async {
    FormData formData = FormData.fromMap({
      "fullName": fullName,
      "userName": userName,
      "email": email,
      "dateOfBirth": dateOfBirth,
      "password": password,
      "latitude": latitude,
      "longitude": longitude,
      "gender": gender,
    });
    if (profileProfile != null) {
      formData.files.add(
        MapEntry(
          "profilePicture",
          await MultipartFile.fromFile(
            profileProfile!.path,
            filename: profileProfile!.path.split('/').last,
          ),
        ),
      );
    }
    return formData;
  }
}

class DoctorRegisterRequestModel {
  final File profileProfile;
  final String fullName;
  final String userName;
  final String email;
  final String password;
  final double latitude;
  final double longitude;
  final String phone;
  final File? licenseFront;
  final File? licenseBack;
  final File? cliniclicense;
  final String clinicAddress;
  final String gender;
  final String dateOfBirth;

  DoctorRegisterRequestModel({
    required this.profileProfile,
    required this.fullName,
    required this.userName,
    required this.email,
    required this.password,
    required this.latitude,
    required this.longitude,
    required this.phone,
    this.licenseFront,
    this.licenseBack,
    this.cliniclicense,
    required this.clinicAddress,
    required this.dateOfBirth,
    required this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "userName": userName,
      "email": email,
      "password": password,
      "phone": phone,
      "gender": gender,
      "dateOfBirth": dateOfBirth,
      "clinicAddress": clinicAddress,
      "latitude": latitude,
      "longitude": longitude,
      "profileProfile": profileProfile.path,
      "licenseFront": licenseFront?.path,
      "licenseBack": licenseBack?.path,
      "cliniclicense": cliniclicense?.path,
    };
  }

  Future<FormData> toFormData() async {
    // 1. نجهز البيانات الأساسية الأول
    Map<String, dynamic> data = {
      "fullName": fullName,
      "userName": userName,
      "email": email,
      "password": password,
      "phone": phone,
      "gender": gender,
      "dateOfBirth": dateOfBirth,
      "clinicAddress": clinicAddress,
      "latitude": latitude,
      "longitude": longitude,
    };

    // 2. نضيف صورة البروفايل (إجباري)
    data['profileProfile'] = await MultipartFile.fromFile(
      profileProfile.path,
      filename: profileProfile.path.split('/').last,
    );

    // 3. ✅ التعديل هنا: نضيف الرخص فقط لو المستخدم اختارها (لو مش null)
    if (licenseFront != null) {
      data['licenseFront'] = await MultipartFile.fromFile(
        licenseFront!.path,
        filename: licenseFront!.path.split('/').last,
      );
    }

    if (licenseBack != null) {
      data['licenseBack'] = await MultipartFile.fromFile(
        licenseBack!.path,
        filename: licenseBack!.path.split('/').last,
      );
    }

    if (cliniclicense != null) {
      data['cliniclicense'] = await MultipartFile.fromFile(
        cliniclicense!.path,
        filename: cliniclicense!.path.split('/').last,
      );
    }

    return FormData.fromMap(data);
  }
}
