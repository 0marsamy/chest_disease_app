import 'package:chest_disease_app/features/scan/data/models/upload_scan_model.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/data/network_services/api_service.dart';

@singleton
class UploadScanRemoteDataSource {
  final AppDio _dio;

  UploadScanRemoteDataSource(this._dio);

  Future<ChestPredictionModel> uploadScan(
      UploadScanRequestModel requestModel) async {
    // The 'toFormData' method in UploadScanRequestModel already sets the 'image' key
    final formData = await requestModel.toFormData();

    final response = await _dio.post(
      path: '/api/ChestScan/upload',
      data: formData,
    );

    // Parse the response using the new model's fromJson factory
    return ChestPredictionModel.fromJson(response.data);
  }
}
