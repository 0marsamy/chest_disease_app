class DoctorReportsResponseModel {
  int? pageIndex;
  int? pageSize;
  int? count;
  int? totalPages;
  List<Report>? reports;

  DoctorReportsResponseModel(
      {this.pageIndex,
      this.pageSize,
      this.count,
      this.totalPages,
      this.reports});

  DoctorReportsResponseModel.fromJson(Map<String, dynamic> json) {
    pageIndex = json['pageIndex'];
    pageSize = json['pageSize'];
    count = json['count'];
    totalPages = json['totalPages'];
    if (json['data'] != null) {
      reports = <Report>[];
      json['data'].forEach((v) {
        reports!.add(Report.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pageIndex'] = pageIndex;
    data['pageSize'] = pageSize;
    data['count'] = count;
    data['totalPages'] = totalPages;
    if (reports != null) {
      data['data'] = reports!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Report {
  int? id;
  String? imagePath;
  String? detectionClass;
  String? confidence;
  String? aiGeneratedImagePath;
  String? uploadDate;
  int? patientId;
  String? patientName;
  String? patientProfilePicture;
  String? patientDateOfBirth;
  String? patientGender;
  int? age;
  bool? isViewed;

  Report(
      {this.id,
      this.imagePath,
      this.detectionClass,
      this.confidence,
      this.aiGeneratedImagePath,
      this.uploadDate,
      this.patientId,
      this.patientName,
      this.patientProfilePicture,
      this.patientDateOfBirth,
      this.patientGender,
      this.isViewed,
      this.age});

  Report.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    imagePath = json['imagePath'];
    detectionClass = json['detectionClass'];
    confidence = json['confidence'];
    aiGeneratedImagePath = json['aiGeneratedImagePath'];
    uploadDate = json['uploadDate'];
    patientId = json['patientId'];
    patientName = json['patientName'];
    patientProfilePicture = json['patientProfilePicture'];
    patientDateOfBirth = json['patientDateOfBirth'];
    patientGender = json['patientGender'];
    age = json['age'];
    isViewed = json['isViewed'] ?? false; // Default to false if not present
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['imagePath'] = imagePath;
    data['detectionClass'] = detectionClass;
    data['confidence'] = confidence;
    data['aiGeneratedImagePath'] = aiGeneratedImagePath;
    data['uploadDate'] = uploadDate;
    data['patientId'] = patientId;
    data['patientName'] = patientName;
    data['patientProfilePicture'] = patientProfilePicture;
    data['patientDateOfBirth'] = patientDateOfBirth;
    data['patientGender'] = patientGender;
    data['age'] = age;
    return data;
  }
}


class DoctorReportsRequestModel {
  final int pageIndex;
  final int pageSize;


  DoctorReportsRequestModel({
    required this.pageIndex,
    required this.pageSize,

  });

  Map<String, dynamic> toJson() {
    return {
      'pageIndex': pageIndex,
      'pageSize': pageSize,

    };
  }
}
