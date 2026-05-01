import 'package:chest_disease_app/core/data/network_services/api_service.dart';
import 'package:chest_disease_app/foundations/app_urls.dart';
import 'package:injectable/injectable.dart';

import '../models/verification_code_model.dart';

@singleton
class VerifyCodeRemoteDataSource {
  Future<String> verifyCode(VerificationCodeRequestModel body) async {
    final response = await AppDio().post(
      path: AppUrls.verifyCode,
      data: body.toJson(),
    );

    return response.data is Map<String, dynamic>
        ? (response.data['message']?.toString() ?? 'Success')
        : 'Success';
  }

  Future<String> verifyForgetCode(VerificationCodeRequestModel body) async {
    final response = await AppDio().post(
      path: AppUrls.verifyForgetPassword,
      data: body.toJson(),
    );

    return response.data is Map<String, dynamic>
        ? (response.data['message']?.toString() ?? 'Success')
        : 'Success';
  }
}
