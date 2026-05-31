import 'package:chest_disease_app/core/data/network_services/api_error_handler.dart';
import 'package:chest_disease_app/features/edit_profile/data/models/edit_profile_request_model.dart';
import 'package:chest_disease_app/features/login/data/models/login_model.dart';
import 'package:chest_disease_app/foundations/app_constants.dart';
import 'package:chest_disease_app/foundations/app_urls.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class EditProfileRepo {
  EditProfileRepo();

  Future<Either<ApiErrorModel, User>> editProfile(
    EditProfileRequestModel editProfileModel,
  ) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: AppUrls.baseUrl,
          connectTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      final formData = FormData.fromMap(await editProfileModel.toMap());
      final headers = <String, dynamic>{"Content-Type": "multipart/form-data"};
      final token = await AppConstants.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await dio.post(
        "${AppUrls.baseUrl}/api/Account/UpdateProfile",
        data: formData,
        options: Options(
          headers: headers,
          receiveTimeout: const Duration(minutes: 1),
          sendTimeout: const Duration(minutes: 1),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final updatedUser = _buildUpdatedUser(response.data, editProfileModel);
        await AppConstants.setUser(updatedUser);
        AppConstants.user = updatedUser;
        return Right(updatedUser);
      }

      return Left(ApiErrorModel(message: "Failed to update profile"));
    } catch (e) {
      if (e is DioException) {
        return Left(ApiErrorModel(message: _dioErrorMessage(e)));
      }
      return Left(ApiErrorModel(message: e.toString()));
    }
  }

  User _buildUpdatedUser(
    dynamic responseData,
    EditProfileRequestModel request,
  ) {
    final currentUser = AppConstants.user;
    User? serverUser;

    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      final userJson = data is Map<String, dynamic> ? data['user'] : null;

      if (userJson is Map<String, dynamic>) {
        serverUser = User.fromJson(userJson);
      } else if (responseData['user'] is Map<String, dynamic>) {
        serverUser = User.fromJson(
          responseData['user'] as Map<String, dynamic>,
        );
      } else if (responseData.containsKey('fullName') ||
          responseData.containsKey('email') ||
          responseData.containsKey('userName')) {
        serverUser = User.fromJson(responseData);
      }
    }

    final baseUser = serverUser ?? currentUser ?? User();
    return baseUser.copyWith(
      fullName:
          _valueOrNull(request.fullName) ??
          _valueOrNull(baseUser.fullName) ??
          currentUser?.fullName,
      userName:
          _valueOrNull(request.userName) ??
          _valueOrNull(baseUser.userName) ??
          currentUser?.userName,
      email:
          _valueOrNull(request.email) ??
          _valueOrNull(baseUser.email) ??
          currentUser?.email,
      role: _valueOrNull(baseUser.role) ?? currentUser?.role,
      token: _valueOrNull(baseUser.token) ?? currentUser?.token,
      profilePicture:
          _valueOrNull(baseUser.profilePicture) ?? currentUser?.profilePicture,
      phone: _valueOrNull(baseUser.phone) ?? currentUser?.phone,
      dateOfBirth:
          _valueOrNull(baseUser.dateOfBirth) ?? currentUser?.dateOfBirth,
      gender: _valueOrNull(baseUser.gender) ?? currentUser?.gender,
      latitude: baseUser.latitude ?? currentUser?.latitude,
      longitude: baseUser.longitude ?? currentUser?.longitude,
      age: baseUser.age ?? currentUser?.age,
    );
  }

  String _dioErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['detail']?.toString() ??
          data['message']?.toString() ??
          e.message ??
          "Connection Error";
    }
    return e.message ?? "Connection Error";
  }

  String? _valueOrNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty || trimmed == 'null') {
      return null;
    }
    return trimmed;
  }
}
