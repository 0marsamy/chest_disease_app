import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/verification_code_model.dart';

@singleton
class VerifyCodeRemoteDataSource {
  Dio _getDio() {
    final dio = Dio();
    // This is insecure; only use for local development.
    (dio.httpClientAdapter as dynamic).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    return dio;
  }

  Future<String> verifyCode(VerificationCodeRequestModel body) async {
    final dio = _getDio();
    try {
      final response = await dio.post(
        "http://10.0.2.2:8000/api/Auth/verify",
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
        'http://10.0.2.2:8000/api/Account/VerifyForgetCode',
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

