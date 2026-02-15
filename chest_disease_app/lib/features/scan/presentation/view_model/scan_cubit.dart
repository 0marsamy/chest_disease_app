import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:chest_disease_app/features/scan/domain/entities/chest_prediction_entity.dart';
import 'package:chest_disease_app/features/scan/domain/repo/upload_scan_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:injectable/injectable.dart';

part 'scan_state.dart';

@injectable
class ScanCubit extends Cubit<ScanState> {
  final UploadScanRepository _repository;

  ScanCubit(this._repository) : super(ScanInitial());

  File? file;
  String fileName = "";

  // دالة اختيار الملف باستخدام FilePicker
  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result == null) {
      // لم يتم اختيار ملف
      return;
    }

    file = File(result.files.single.path!);
    fileName = result.files.single.name;
    emit(ScanFilePicked()); // تحديث الواجهة
  }

  // دالة الرفع (بدون لوكيشن - ثابت)
  Future<void> uploadScan() async {
    if (file == null) {
      emit(const UploadScanErrorState("No file selected."));
      return;
    }

    emit(UploadScanLoadingState());

    final result = await _repository.uploadScan(
      image: file!,
      lat: 30.0, // إحداثيات ثابتة لتخطي الـ GPS
      long: 31.0,
    );

    result.fold(
      (failure) {
        emit(UploadScanErrorState(failure.message));
      },
      (entity) {
        emit(UploadScanSuccessState(entity));
      },
    );
  }

  // دالة الإلغاء
  void cancelUpload() {
    file = null;
    fileName = "";
    emit(ScanInitial());
  }
}