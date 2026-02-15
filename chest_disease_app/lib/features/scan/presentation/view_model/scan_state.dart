part of 'scan_cubit.dart';

sealed class ScanState extends Equatable {
  const ScanState();

  @override
  List<Object> get props => [];
}

final class ScanInitial extends ScanState {}

final class ScanFilePicked extends ScanState {} // الحالة الناقصة سابقاً

final class UploadScanLoadingState extends ScanState {}

final class UploadScanSuccessState extends ScanState {
  final ChestPredictionEntity predictionEntity;

  const UploadScanSuccessState(this.predictionEntity);

  @override
  List<Object> get props => [predictionEntity];
}

final class UploadScanErrorState extends ScanState {
  final String message;

  const UploadScanErrorState(this.message);

  @override
  List<Object> get props => [message];
}