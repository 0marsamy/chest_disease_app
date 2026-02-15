import 'package:chest_disease_app/features/register/data/models/register_model.dart';
import 'package:chest_disease_app/features/register/data/remote/register_remote_data_source.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/data/network_services/api_error_handler.dart';
import 'package:dio/dio.dart';

@singleton
class RegisterRepository {
  final RegisterRemoteDataSource dataSource;
  RegisterRepository({required this.dataSource});

  Future<Either<ApiErrorModel, RegisterResponseModel>> patientRegister(
      PatientRegisterRequestModel parameters) async {
    try {
      final RegisterResponseModel response =
          await dataSource.patientRegister(parameters);
      return Right(response);
    } on Exception catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<Either<ApiErrorModel, RegisterResponseModel>> doctorRegister(
      DoctorRegisterRequestModel parameters) async {
    try {
      print("Calling doctorRegister in repository...");
      final RegisterResponseModel response =
          await dataSource.doctorRegister(parameters);
      print("doctorRegister in repository successful.");
      return Right(response);
    } catch (e) {
       print("🔥 Repository Error: $e");
      if (e is DioException) {
         return Left(ApiErrorModel(message: e.message ?? "Connection Error"));
      }
      return Left(ApiErrorModel(message: e.toString()));
    }
  }
}