import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:chest_disease_app/core/utils/strings/app_string.dart';
import 'package:chest_disease_app/features/register/data/models/register_model.dart';
import 'package:chest_disease_app/features/register/data/repository/register_repository.dart';
import 'package:chest_disease_app/features/register/presentation/view_model/rigester_screen_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

@injectable
class RigesterScreenCubit extends Cubit<RigesterScreenState> {
  final RegisterRepository registerRepository;

  RigesterScreenCubit({required this.registerRepository})
      : super(RigesterScreenInitial());

  final formKey = GlobalKey<FormState>();

  DateTime? pickedDate;
  final fullNameController = TextEditingController();
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final clinicLicenseController = TextEditingController();
  final licenseFrontController = TextEditingController();
  final licenseBackController = TextEditingController();
  final clinicPhoneNumberController = TextEditingController();
  final birthDateController = TextEditingController();
  final clinicAddressController = TextEditingController();

  // Focus Nodes
  final FocusNode emailFocus = FocusNode();
  final FocusNode fullNameFocus = FocusNode();
  final FocusNode clinicPhoneNumberFocus = FocusNode();
  final FocusNode userNameFocus = FocusNode();
  final FocusNode birthDateFocus = FocusNode();
  final FocusNode genderFocus = FocusNode();
  final FocusNode imageFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  final ImagePicker picker = ImagePicker();
  final selectedGender = TextEditingController();

  bool isSelectMaleGenders = false;
  bool isSelectFemaleGenders = false;

  File? doctorLicenseFront;
  File? doctorLicenseBack;
  File? clinicLicenseFile;
  File? profileImage;

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      saveImage(File(pickedFile.path));
    }
  }

  void setDoctorLicenseFrontFile(File file) {
    doctorLicenseFront = file;
    licenseFrontController.text = file.path.split('/').last;
    emit(SetDoctorLicenseState(fileName: file.path.split('/').last));
  }

  void setDoctorLicenseBackFile(File file) {
    doctorLicenseBack = file;
    licenseBackController.text = file.path.split('/').last;
    emit(SetDoctorLicenseState(fileName: file.path.split('/').last));
  }

  void setClinicLicense(File license) {
    clinicLicenseController.text = license.path.split('/').last;
    clinicLicenseFile = license;
    emit(SetClinicLiscenseState());
  }

  Future<void> register() async {
    if (profileImage == null) {
      emit(RegisterDataMissingState(message: "Please select a profile image"));
      return;
    }

    if (!formKey.currentState!.validate()) {
      return;
    }

    emit(RigesterScreenLoadingState());

    final model = DoctorRegisterRequestModel(
      clinicAddress: clinicAddressController.text,
      cliniclicense: clinicLicenseFile,
      dateOfBirth: pickedDate != null ? DateFormat('yyyy-MM-dd').format(pickedDate!) : "",
      licenseBack: doctorLicenseBack,
      licenseFront: doctorLicenseFront,
      latitude: 30.0,
      longitude: 31.0,
      phone: clinicPhoneNumberController.text,
      profileProfile: profileImage!,
      fullName: fullNameController.text.trim(),
      userName: userNameController.text,
      email: emailController.text,
      password: passwordController.text,
      gender: selectedGender.text,
    );

    print("Registering with data: ${model.toJson()}");


    final result = await registerRepository.doctorRegister(model);

    result.fold((l) {
      print("Registration failed: ${l.message}");
      emit(RegisterErrorState(message: l.message ?? "Unknown Error"));
    }, (r) async {
      print("Registration successful for email: ${r.email}");
      clear();
      emit(RegisterSuccessState(email: r.email));
    });
  }

  void setSelectedDate(DateTime date) {
    pickedDate = date;
    birthDateController.text = DateFormat('yyyy-MM-dd').format(date);
    emit(RigesterScreenUpdateScreen());
  }

  Future<File?> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        return file;
      }
    } catch (e) {
      // TODO: Handle error, e.g., show a toast to the user
    }
    return null;
  }

  void selectMaleGenders() {
    isSelectMaleGenders = true;
    isSelectFemaleGenders = false;
    selectedGender.text = AppStrings.male;
    emit(SelectGenderState(gender: AppStrings.male));
  }

  void selectFemaleGenders() {
    isSelectMaleGenders = false;
    isSelectFemaleGenders = true;
    selectedGender.text = AppStrings.female;
    emit(SelectGenderState(gender: AppStrings.female));
  }

  void saveImage(File image) {
    profileImage = image;
    emit(UploadImageState(image: image));
  }

  void clear() {
    profileImage = null;
    fullNameController.clear();
    userNameController.clear();
    emailController.clear();
    passwordController.clear();
    licenseFrontController.clear();
    licenseBackController.clear();
    clinicPhoneNumberController.clear();
    birthDateController.clear();
    clinicAddressController.clear();
    doctorLicenseFront = null;
    doctorLicenseBack = null;
    clinicLicenseFile = null;

    selectedGender.clear();
    pickedDate = null;
    emit(ClearAuthFieldsState());
  }
}