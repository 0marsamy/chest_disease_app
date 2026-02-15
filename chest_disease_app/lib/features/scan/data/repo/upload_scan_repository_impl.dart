import 'dart:io';

import 'package:chest_disease_app/core/error/failure.dart';
import 'package:chest_disease_app/features/scan/domain/entities/chest_prediction_entity.dart';
import 'package:chest_disease_app/features/scan/domain/repo/upload_scan_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: UploadScanRepository)
class UploadScanRepositoryImpl implements UploadScanRepository {
  UploadScanRepositoryImpl();

  @override
  Future<Either<Failure, ChestPredictionEntity>> uploadScan({
    required double long,
    required double lat,
    required File image,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return const Right(
      ChestPredictionEntity(
        prediction: 'Pneumonia',
        confidence: 96.5,
        description: 'Simulated result for demonstration purposes.',
      ),
    );
  }
}