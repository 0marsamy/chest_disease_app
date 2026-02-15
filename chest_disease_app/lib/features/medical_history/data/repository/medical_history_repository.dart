import 'package:chest_disease_app/core/data/models/doctor_clinic_model.dart';
import 'package:chest_disease_app/core/data/network_services/api_error_handler.dart';
import 'package:chest_disease_app/features/medical_history/data/model/detection_response.dart';
import 'package:chest_disease_app/features/medical_history/data/remote/medical_history_data_source.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class MedicalHistoryRepository {
  MedicalHistoryDataSource remoteDataSource;

  MedicalHistoryRepository({required this.remoteDataSource});

  Future<Either<ApiErrorModel, DetectionResponse>> getPatientScans(
      DetectionRequest query) async {
    try {
      final response = await remoteDataSource.getPatientScans(query);
      return Right(response);
    } on Exception catch (error) {
      return Left(ErrorHandler.handle(error));
    }
  }

  Future<Either<ApiErrorModel, DoctorClinicModel>> getDoctorById(
      String doctorId) async {
    try {
      final response = await remoteDataSource.getDoctorById(doctorId);
      return Right(response);
    } on Exception catch (error) {
      return Left(ErrorHandler.handle(error));
    }
  }
}

