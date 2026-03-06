import 'package:chest_disease_app/features/register/data/models/register_model.dart';
import 'package:chest_disease_app/foundations/app_urls.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class RegisterRemoteDataSource {
  Dio _getDio() {
    return Dio(
      BaseOptions(
        baseUrl: AppUrls.baseUrl,
        connectTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
        sendTimeout: const Duration(minutes: 2),
      ),
    );
  }

  Future<RegisterResponseModel> patientRegister(
      PatientRegisterRequestModel parameters) async {
    final formData = await parameters.toFormData();
    final response = await _getDio().post(
      "${AppUrls.baseUrl}/api/Auth/register/patient",
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
      "${AppUrls.baseUrl}/api/Auth/register/doctor",
      data: formData,
    );
    print("Registration response received: ${response.statusCode}");
    return RegisterResponseModel.fromJson(response.data);
  }
}
