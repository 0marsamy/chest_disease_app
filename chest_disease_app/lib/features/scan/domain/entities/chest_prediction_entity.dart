import 'package:equatable/equatable.dart';

class ChestPredictionEntity extends Equatable {
  final String prediction;
  final double confidence;
  final String description;
  final String? segmentedBase64;
  final String? heatmapBase64;
  final String? imagePath;
  final int? id;

  const ChestPredictionEntity({
    required this.prediction,
    required this.confidence,
    required this.description,
    this.segmentedBase64,
    this.heatmapBase64,
    this.imagePath,
    this.id,
  });

  @override
  List<Object?> get props => [
    prediction,
    confidence,
    description,
    segmentedBase64,
    heatmapBase64,
    imagePath,
    id,
  ];
}
