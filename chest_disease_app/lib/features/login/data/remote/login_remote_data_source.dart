import 'package:chest_disease_app/foundations/app_urls.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/data/network_services/api_service.dart';
import '../models/login_model.dart';

@singleton
class LoginRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel parameters) async {
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
  }

  Future<String> forgetPassword(String email) async {
    final response = await AppDio().post(
      path: AppUrls.forgetPassword,
      data: {"email": email},
    );
    return response.data['email'];
  }
}
