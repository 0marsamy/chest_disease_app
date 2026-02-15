import 'package:equatable/equatable.dart';

class ChestPredictionEntity extends Equatable {
  final String prediction;
  final double confidence;
  final String description;
  final String? heatmapBase64;

  const ChestPredictionEntity({
    required this.prediction,
    required this.confidence,
    required this.description,
    this.heatmapBase64,
  });

  @override
  List<Object?> get props => [
        prediction,
        confidence,
        description,
        heatmapBase64,
      ];
}
