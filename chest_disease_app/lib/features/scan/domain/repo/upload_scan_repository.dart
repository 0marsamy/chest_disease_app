import 'dart:io';

import 'package:chest_disease_app/core/error/failure.dart';
import 'package:chest_disease_app/features/scan/domain/entities/chest_prediction_entity.dart';
import 'package:dartz/dartz.dart';

abstract class UploadScanRepository {
  Future<Either<Failure, ChestPredictionEntity>> uploadScan({
    required double long,
    required double lat,
    required File image,
  });
}

