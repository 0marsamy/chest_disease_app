import 'package:chest_disease_app/core/data/network_services/api_service.dart';
import 'package:chest_disease_app/features/edit_profile/data/models/edit_profile_model.dart';
import 'package:chest_disease_app/foundations/app_urls.dart';
import 'package:injectable/injectable.dart';

@singleton
class EditProfileRemoteDataSource {
  Future<EditProfileResponseModel> editProfile(
      EditProfileRequestModel body) async {
    final response = await AppDio()
        .post(path: AppUrls.editProfile, data: await body.toFormData());

    return EditProfileResponseModel.fromJson(response.data);
  }
}

