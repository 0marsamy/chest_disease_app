import 'package:chest_disease_app/foundations/app_urls.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/data/network_services/api_error_handler.dart';
import '../models/login_model.dart';
import '../remote/login_remote_data_source.dart';

@singleton
class LoginRepository {
  final LoginRemoteDataSource dataSource;

  LoginRepository({required this.dataSource});

  // ✅ دالة تسجيل الدخول المعدلة
  Future<Either<ApiErrorModel, LoginResponseModel>> login(
      LoginRequestModel parameters) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: AppUrls.baseUrl,
          connectTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      final response = await dio.post(
        "${AppUrls.baseUrl}/api/Auth/login",
        data: {
          "email": parameters.email, 
          "password": parameters.password, 
        },
        options: Options(
          headers: {
            "Content-Type": "application/x-www-form-urlencoded", // Form Data عشان FastAPI يفهمه
          },
          receiveTimeout: const Duration(minutes: 1),
          sendTimeout: const Duration(minutes: 1),
        ),
      );

      // 4. التحقق من النجاح
      if (response.statusCode == 200) {
        // تحويل الرد لموديل
        return Right(LoginResponseModel.fromJson(response.data));
      } else {
        return Left(ApiErrorModel(message: "Login Failed: ${response.statusCode}"));
      }

    } catch (e) {
      print("🔥 Login Repo Error: $e");
      if (e is DioException) {
        return Left(ApiErrorModel(
            message: e.response?.data['detail'] ?? e.message ?? "Connection Error"));
      }
      return Left(ApiErrorModel(message: e.toString()));
    }
  }

  // دالة نسيان كلمة المرور (سيبناها زي ما هي مؤقتاً)
  Future<Either<ApiErrorModel, String>> forgetPassword(String email) async {
    try {
      final response = await dataSource.forgetPassword(email);
      return Right(response);
    } on Exception catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}