import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:chest_disease_app/features/edit_profile/data/models/edit_profile_request_model.dart';
import 'package:chest_disease_app/features/edit_profile/data/repo/edit_profile_repository.dart';
import 'package:chest_disease_app/features/login/data/models/login_model.dart';
import 'package:chest_disease_app/foundations/app_constants.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

part "edit_profile_state.dart";

@injectable
class EditProfileCubit extends Cubit<EditProfileState> {
  final EditProfileRepo repository;
  EditProfileCubit({required this.repository}) : super(const EditProfileInitial());

  TextEditingController nameController = TextEditingController(
    text: AppConstants.user!.fullName,
  );
  TextEditingController emailController = TextEditingController(
    text: AppConstants.user!.email,
  );

  TextEditingController userNameController = TextEditingController(
    text: AppConstants.user!.userName,
  );

  File? profileImage;

  void toggleEditMode() {
    emit(state.copyWith(isEditing: !state.isEditing));
  }

  pickProfileImage() async {
    final result = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (result != null) {
      profileImage = File(result.path);
      emit(state.copyWith(profileImage: profileImage, isEditing: true));
    }
  }

  Future<void> editProfile() async {
    emit(state.copyWith(isEditing: true)); // Keep editing mode while loading
    final result = await repository.editProfile(
      EditProfileRequestModel(
        fullName: nameController.text,
        image: profileImage,
      ),
    );
    result.fold(
      (error) {
        emit(const EditProfileError(isEditing: true)); // Stay in edit mode on error
      },
      (response) async {
        final updatedUser = User(
          id: AppConstants.user!.id,
          fullName: nameController.text,
          userName: userNameController.text,
          email: emailController.text,
          profilePicture:
              profileImage?.path ?? AppConstants.user!.profilePicture,
          dateOfBirth: AppConstants.user!.dateOfBirth,
          role: AppConstants.user!.role,
          gender: AppConstants.user!.gender,
          latitude: AppConstants.user!.latitude,
          longitude: AppConstants.user!.longitude,
          age: AppConstants.user!.age,
        );

        await AppConstants.setUser(updatedUser);

        emit(const EditProfileSuccess(isEditing: false)); // Exit edit mode on success
      },
    );
  }
}

