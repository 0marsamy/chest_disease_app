import 'dart:io';

import 'package:chest_disease_app/features/scan/data/models/upload_scan_model.dart';
import 'package:chest_disease_app/foundations/app_urls.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Calls the Gradio proxy server (Python) which forwards to Hugging Face Space Ibrahim2002/xray_ai.
@singleton
class HuggingFaceScanRemoteDataSource {
  HuggingFaceScanRemoteDataSource();

  static String get _predictUrl =>
      '${AppUrls.gradioProxyBaseUrl}${AppUrls.gradioProxyPredict}';

  Future<ChestPredictionModel> predict(File image) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        image.path,
        filename: image.path.split(Platform.pathSeparator).last,
      ),
    });

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
      ),
    );

    final response = await dio.post(
      _predictUrl,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        receiveDataWhenStatusError: true,
      ),
    );

    if (response.data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Invalid response format',
      );
    }

    return ChestPredictionModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
