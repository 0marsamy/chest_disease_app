import 'package:chest_disease_app/core/data/network_services/api_service.dart';
import 'package:chest_disease_app/features/clincs_management/data/models/add_clinic_model.dart';
import 'package:chest_disease_app/foundations/app_urls.dart';
import 'package:injectable/injectable.dart';

@singleton
class ClinicManagementRemoteDataSource {
  Future<AddClinicResponseModel> addClinic(
      AddClinicRequestModel requestModel) async {
    final response = await AppDio()
        .post(path: AppUrls.addClinic, data: requestModel.toFormData());

        return AddClinicResponseModel.fromJson(response.data);
  }
}

