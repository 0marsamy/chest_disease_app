import 'package:chest_disease_app/foundations/app_urls.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/data/network_services/api_service.dart';
import '../models/login_model.dart';

@singleton
class LoginRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel parameters) async {
    try {
      final response =
          await Dio(
            BaseOptions(
              baseUrl: AppUrls.baseUrl,
              connectTimeout: const Duration(minutes: 2),
              receiveTimeout: const Duration(minutes: 2),
            ),
          ).post(
            '/${AppUrls.login}',
            data: parameters.toJson(),
            options: Options(
              contentType: Headers.formUrlEncodedContentType,
              receiveTimeout: const Duration(minutes: 1),
              sendTimeout: const Duration(minutes: 1),
            ),
          );
      return LoginResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> forgetPassword(String email) async {
    try {
      final response = await AppDio().post(
        path: AppUrls.forgetPassword,
        data: {"email": email},
      );
      // Handle simple JSON response: {"message": "..."}
      // Return the email that was sent for navigation
      return email;
    } catch (e) {
      rethrow;
    }
  }
}
