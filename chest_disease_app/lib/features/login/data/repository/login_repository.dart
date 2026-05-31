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

  Future<Either<ApiErrorModel, LoginResponseModel>> login(
    LoginRequestModel parameters,
  ) async {
    try {
      final response = await dataSource.login(parameters);
      return Right(response);
    } catch (e) {
      return Left(_handleCustomError(e));
    }
  }

  Future<Either<ApiErrorModel, String>> forgetPassword(String email) async {
    try {
      final response = await dataSource.forgetPassword(email);
      return Right(response);
    } catch (e) {
      return Left(_handleCustomError(e));
    }
  }

  // الدالة المعدلة بذكاء لالتقاط أي رسالة خطأ
  ApiErrorModel _handleCustomError(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;

      if (data != null) {
        // 1. لو الخطأ راجع كـ Map (وهو الشائع في الـ APIs)
        if (data is Map) {
          // نحاول نجيب الرسالة من أي Key محتمل
          final String errorMessage =
              data['detail']?.toString() ??
              data['message']?.toString() ??
              data['error']?.toString() ??
              data.values.firstOrNull?.toString() ??
              'Unknown error occurred';
          return ApiErrorModel(message: errorMessage);
        }

        // 2. لو السيرفر باعت الخطأ كنص مباشر (String)
        return ApiErrorModel(message: data.toString());
      }
    }

    // الملاذ الأخير: إذا لم تكن DioException أو لا توجد داتا، نستخدم الـ ErrorHandler الأصلي
    return ErrorHandler.handle(e);
  }
}
