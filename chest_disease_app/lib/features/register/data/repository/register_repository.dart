import 'package:chest_disease_app/features/register/data/models/register_model.dart';
import 'package:chest_disease_app/features/register/data/remote/register_remote_data_source.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/data/network_services/api_error_handler.dart';

@singleton
class RegisterRepository {
  final RegisterRemoteDataSource dataSource;
  RegisterRepository({required this.dataSource});

  Future<Either<ApiErrorModel, RegisterResponseModel>> patientRegister(
    PatientRegisterRequestModel parameters,
  ) async {
    try {
      final response = await dataSource.patientRegister(parameters);
      return Right(response);
    } on Exception catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<Either<ApiErrorModel, RegisterResponseModel>> doctorRegister(
    DoctorRegisterRequestModel parameters,
  ) async {
    try {
      final response = await dataSource.doctorRegister(parameters);
      return Right(response);
    } on Exception catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
