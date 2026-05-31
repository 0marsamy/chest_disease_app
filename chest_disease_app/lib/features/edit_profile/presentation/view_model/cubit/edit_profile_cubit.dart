import 'package:bloc/bloc.dart';
import 'package:chest_disease_app/features/edit_profile/data/models/edit_profile_request_model.dart';
import 'package:chest_disease_app/features/edit_profile/data/repo/edit_profile_repository.dart';
import 'package:chest_disease_app/foundations/app_constants.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

part "edit_profile_state.dart";

@injectable
class EditProfileCubit extends Cubit<EditProfileState> {
  final EditProfileRepo repository;
  EditProfileCubit({required this.repository})
    : super(const EditProfileInitial());

  final formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController(
    text: AppConstants.user?.fullName ?? '',
  );
  TextEditingController emailController = TextEditingController(
    text: AppConstants.user?.email ?? '',
  );

  TextEditingController userNameController = TextEditingController(
    text: AppConstants.user?.userName ?? '',
  );

  void toggleEditMode() {
    emit(state.copyWith(isEditing: !state.isEditing));
  }

  Future<void> editProfile() async {
    emit(EditProfileLoading(isEditing: true));
    final result = await repository.editProfile(
      EditProfileRequestModel(
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        userName: userNameController.text.trim(),
      ),
    );
    result.fold(
      (error) {
        emit(EditProfileError(isEditing: true));
      },
      (updatedUser) async {
        nameController.text = updatedUser.fullName ?? '';
        emailController.text = updatedUser.email ?? '';
        userNameController.text = updatedUser.userName ?? '';
        emit(const EditProfileSuccess(isEditing: false));
      },
    );
  }
}
