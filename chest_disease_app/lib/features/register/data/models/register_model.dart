import 'dart:io';
import 'package:dio/dio.dart';

// --- هذا الكلاس كما هو لم يتغير ---
class RegisterResponseModel {
  String? email;

  RegisterResponseModel({this.email});

  RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final user = payload['user'];
    email =
        payload['email']?.toString() ??
        (user is Map<String, dynamic> ? user['email']?.toString() : null);
  }
}

// --- هذا الكلاس كما هو لم يتغير ---
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

// --- تم تعديل هذا الكلاس (شيلنا منه الصور والشهادات المطلوبة) ---
class DoctorRegisterRequestModel {
  final String fullName;
  final String userName;
  final String email;
  final String password;
  final double latitude;
  final double longitude;
  final String phone;
  final File? cliniclicense;
  final String clinicAddress;
  final String gender;
  final String dateOfBirth;

  DoctorRegisterRequestModel({
    required this.fullName,
    required this.userName,
    required this.email,
    required this.password,
    required this.latitude,
    required this.longitude,
    required this.phone,
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
      "cliniclicense": cliniclicense?.path,
    };
  }

  Future<FormData> toFormData() async {
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

    // نبعت رخصة العيادة فقط إذا وجدت
    if (cliniclicense != null) {
      data['cliniclicense'] = await MultipartFile.fromFile(
        cliniclicense!.path,
        filename: cliniclicense!.path.split('/').last,
      );
    }

    return FormData.fromMap(data);
  }
}
