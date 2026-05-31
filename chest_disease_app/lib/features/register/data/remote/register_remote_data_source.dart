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
    PatientRegisterRequestModel parameters,
  ) async {
    try {
      final formData = await parameters.toFormData();
      final response = await _getDio().post(
        '/${AppUrls.registerPatient}',
        data: formData,
      );
      return RegisterResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      // Extract error message from FastAPI HTTPException
      if (e.response?.data is Map<String, dynamic>) {
        final errorData = e.response!.data as Map<String, dynamic>;
        final detail =
            errorData['detail'] as String? ?? errorData['message'] as String?;
        if (detail != null) {
          throw detail;
        }
      }
      throw e.message ?? 'Unknown error occurred';
    }
  }

  Future<RegisterResponseModel> doctorRegister(
    DoctorRegisterRequestModel parameters,
  ) async {
    try {
      final dio = _getDio();
      final formData = await parameters.toFormData();
      final response = await dio.post(
        '/${AppUrls.registerDoctor}',
        data: formData,
      );
      return RegisterResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      // Extract error message from FastAPI HTTPException
      if (e.response?.data is Map<String, dynamic>) {
        final errorData = e.response!.data as Map<String, dynamic>;
        final detail =
            errorData['detail'] as String? ?? errorData['message'] as String?;
        if (detail != null) {
          throw detail;
        }
      }
      throw e.message ?? 'Unknown error occurred';
    }
  }
}
