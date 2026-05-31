import 'package:chest_disease_app/core/helper/functions/diagnosis_label_formatter.dart';

class ViewReportRequestModel {
  final int reportId;
  final String findings;
  final String reasonings;
  final String detectionClass;

  ViewReportRequestModel({
    required this.reportId,
    required this.findings,
    required this.reasonings,
    required this.detectionClass,
  });

  Map<String, dynamic> toJson() {
    return {
      'findings': findings,
      'reasoning': reasonings,
      'detectionClass': formatDiagnosisLabel(detectionClass),
    };
  }
}

class ViewReportResponseModel {
  final String? message;

  ViewReportResponseModel({this.message});

  factory ViewReportResponseModel.fromJson(Map<String, dynamic> json) {
    return ViewReportResponseModel(message: json['message']);
  }
}
