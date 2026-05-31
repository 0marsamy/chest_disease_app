import 'package:dio/dio.dart';
import 'package:chest_disease_app/core/data/network_services/api_service.dart';
import 'package:chest_disease_app/foundations/app_urls.dart';
import 'package:injectable/injectable.dart';

import '../models/verification_code_model.dart';

@singleton
class VerifyCodeRemoteDataSource {
  Future<String> verifyCode(VerificationCodeRequestModel body) async {
    try {
      final response = await AppDio().post(
        path: AppUrls.verifyCode,
        data: body.toJson(),
      );

      return response.data is Map<String, dynamic>
          ? (response.data['message']?.toString() ?? 'Success')
          : 'Success';
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

  Future<String> verifyForgetCode(VerificationCodeRequestModel body) async {
    try {
      final response = await AppDio().post(
        path: AppUrls.verifyForgetPassword,
        data: body.toJson(),
      );

      return response.data is Map<String, dynamic>
          ? (response.data['message']?.toString() ?? 'Success')
          : 'Success';
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

  Future<String> verifyResetCode(VerificationCodeRequestModel body) async {
    try {
      final response = await AppDio().post(
        path: AppUrls.verifyResetCode,
        data: body.toJson(),
      );

      return response.data is Map<String, dynamic>
          ? (response.data['message']?.toString() ?? 'Success')
          : 'Success';
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
