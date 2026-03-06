import 'package:chest_disease_app/foundations/app_urls.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/verification_code_model.dart';

@singleton
class VerifyCodeRemoteDataSource {
  Dio _getDio() {
    return Dio(
      BaseOptions(
        baseUrl: AppUrls.baseUrl,
        connectTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
      ),
    );
  }

  Future<String> verifyCode(VerificationCodeRequestModel body) async {
    final dio = _getDio();
    try {
      final response = await dio.post(
        "${AppUrls.baseUrl}/api/Auth/verify",
        data: body.toJson(),
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return "Success";
      } else {
        throw Exception(
            'Failed to verify code. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to verify code: $e');
    }
  }

  Future<String> verifyForgetCode(VerificationCodeRequestModel body) async {
    final dio = _getDio();
    try {
      final response = await dio.post(
        '${AppUrls.baseUrl}/api/Account/VerifyForgetCode',
        data: body.toJson(),
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return "Success";
      } else {
        throw Exception(
            'Failed to verify forget code. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to verify forget code: $e');
    }
  }
}

