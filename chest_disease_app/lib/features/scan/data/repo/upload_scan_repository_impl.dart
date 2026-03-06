import 'dart:io';

import 'package:chest_disease_app/core/error/failure.dart';
import 'package:chest_disease_app/features/scan/data/models/upload_scan_model.dart';
import 'package:chest_disease_app/features/scan/data/remote/upload_scan_remote_data_source.dart';
import 'package:chest_disease_app/features/scan/domain/entities/chest_prediction_entity.dart';
import 'package:chest_disease_app/features/scan/domain/repo/upload_scan_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: UploadScanRepository)
class UploadScanRepositoryImpl implements UploadScanRepository {
  final UploadScanRemoteDataSource _remoteDataSource;

  UploadScanRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, ChestPredictionEntity>> uploadScan({
    required double long,
    required double lat,
    required File image,
  }) async {
    try {
      final request = UploadScanRequestModel(long: long, lat: lat, image: image);
      final model = await _remoteDataSource.uploadScan(request);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioException(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}