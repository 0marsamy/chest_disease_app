import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:chest_disease_app/core/utils/strings/app_string.dart';
import 'package:chest_disease_app/features/register/data/models/register_model.dart';
import 'package:chest_disease_app/features/register/data/repository/register_repository.dart';
import 'package:chest_disease_app/features/register/presentation/view_model/rigester_screen_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
  final clinicPhoneNumberController = TextEditingController();
  final birthDateController = TextEditingController();
  final clinicAddressController = TextEditingController();

  final FocusNode emailFocus = FocusNode();
  final FocusNode fullNameFocus = FocusNode();
  final FocusNode clinicPhoneNumberFocus = FocusNode();
  final FocusNode userNameFocus = FocusNode();
  final FocusNode birthDateFocus = FocusNode();
  final FocusNode genderFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  final selectedGender = TextEditingController();

  bool isSelectMaleGenders = false;
  bool isSelectFemaleGenders = false;

  File? clinicLicenseFile;

  void setClinicLicense(File license) {
    clinicLicenseController.text = license.path.split('/').last;
    clinicLicenseFile = license;
    emit(SetClinicLiscenseState());
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    emit(RigesterScreenLoadingState());

    try {
      final submittedEmail = emailController.text.trim();
      final model = DoctorRegisterRequestModel(
        clinicAddress: clinicAddressController.text,
        cliniclicense: clinicLicenseFile,
        dateOfBirth: pickedDate != null
            ? DateFormat(
                'yyyy-MM-dd',
                Intl.defaultLocale ?? 'en',
              ).format(pickedDate!)
            : "",
        latitude: 30.0,
        longitude: 31.0,
        phone: clinicPhoneNumberController.text,
        fullName: fullNameController.text.trim(),
        userName: userNameController.text,
        email: submittedEmail,
        password: passwordController.text,
        gender: selectedGender.text,
        // تم إزالة ملفات الشهادات والصورة الشخصية من هنا
      );

      final result = await registerRepository.doctorRegister(model);

      result.fold(
        (failure) {
          emit(
            RegisterErrorState(message: failure.message ?? "حدث خطأ غير معروف"),
          );
        },
        (r) {
          final verificationEmail =
              (r.email != null && r.email!.trim().isNotEmpty)
              ? r.email!.trim()
              : submittedEmail;
          clear();
          emit(RegisterSuccessState(email: verificationEmail));
        },
      );
    } catch (e) {
      emit(
        RegisterErrorState(message: e.toString().replaceAll("Exception: ", "")),
      );
    }
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
        return File(result.files.single.path!);
      }
    } catch (e) {
      debugPrint("File picking error: $e");
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

  void clear() {
    fullNameController.clear();
    userNameController.clear();
    emailController.clear();
    passwordController.clear();
    clinicPhoneNumberController.clear();
    birthDateController.clear();
    clinicAddressController.clear();
    clinicLicenseFile = null;
    selectedGender.clear();
    pickedDate = null;
    emit(ClearAuthFieldsState());
  }
}
