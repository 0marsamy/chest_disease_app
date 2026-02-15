import 'dart:io';

import 'package:chest_disease_app/features/register/data/models/register_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class RegisterRemoteDataSource {
  Dio _getDio() {
    final dio = Dio();
    // This is insecure; only use for local development.
    (dio.httpClientAdapter as dynamic).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    return dio;
  }

  Future<RegisterResponseModel> patientRegister(
      PatientRegisterRequestModel parameters) async {
    // This is not used in the user's scenario, but I'll leave it as is.
    final formData = await parameters.toFormData();
    final response = await _getDio().post(
      "http://10.0.2.2:8000/api/Auth/register/patient",
      data: formData,
    );
    return RegisterResponseModel.fromJson(response.data);
  }

  Future<RegisterResponseModel> doctorRegister(
      DoctorRegisterRequestModel parameters) async {
    final dio = _getDio();
    final formData = await parameters.toFormData();
    print("Sending registration request to backend...");
    final response = await dio.post(
      "http://10.0.2.2:8000/api/Auth/register/doctor",
      data: formData,
      options: Options(
        receiveTimeout: const Duration(minutes: 1),
        sendTimeout: const Duration(minutes: 1),
      ),
    );
    print("Registration response received: ${response.statusCode}");
    return RegisterResponseModel.fromJson(response.data);
  }
}
