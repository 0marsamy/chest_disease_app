import 'dart:io';
import 'package:chest_disease_app/core/data/network_services/api_error_handler.dart';
import 'package:chest_disease_app/features/edit_profile/data/models/edit_profile_request_model.dart';
import 'package:chest_disease_app/features/login/data/models/login_model.dart';
import 'package:chest_disease_app/foundations/app_constants.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:injectable/injectable.dart';

@singleton
class EditProfileRepo {
  EditProfileRepo();

  Future<Either<ApiErrorModel, String>> editProfile(
      EditProfileRequestModel editProfileModel) async {
    try {
      final dio = Dio();
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };

      Map<String, dynamic> dataMap = await editProfileModel.toMap();
      if (AppConstants.user != null) {
        dataMap['email'] = AppConstants.user!.email;
      }

      FormData formData = FormData.fromMap(dataMap);

      final response = await dio.post(
        "http://10.0.2.2:8000/api/Account/UpdateProfile",
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
          },
          receiveTimeout: const Duration(minutes: 1),
          sendTimeout: const Duration(minutes: 1),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = response.data;
          
          if (responseData['data'] != null && responseData['data']['user'] != null) {
            
            // 1. استلام البيانات الجديدة من السيرفر
            User serverUpdatedUser = User.fromJson(responseData['data']['user']);

            // 2. الحفاظ على البيانات القديمة المهمة (Role + Token)
            // إذا السيرفر لم يرسلهم، نستخدم القيم المخزنة حالياً
            String finalRole = (serverUpdatedUser.role != null && serverUpdatedUser.role != "null") 
                ? serverUpdatedUser.role! 
                : (AppConstants.user?.role ?? "Doctor");

            String? finalToken = serverUpdatedUser.token ?? AppConstants.user?.token;

            // 3. دمج البيانات باستخدام copyWith
            User finalUser = serverUpdatedUser.copyWith(
              role: finalRole,
              token: finalToken,
            );

            // 4. حفظ المستخدم النهائي
            await AppConstants.setUser(finalUser);
            
            print("✅ User updated & merged. Role: ${finalUser.role}, Token preserved.");
          }
        } catch (e) {
          print("⚠️ Warning: Failed to update local user data: $e");
        }

        return const Right("Profile Updated Successfully");
      } else {
        return Left(ApiErrorModel(message: "Failed to update profile"));
      }

    } catch (e) {
      print("🔥 Edit Profile Error: $e");
      if (e is DioException) {
        return Left(ApiErrorModel(
            message: e.response?.data['detail'] ?? e.message ?? "Connection Error"));
      }
      return Left(ApiErrorModel(message: e.toString()));
    }
  }
}