class DetectionResponse {
  final int pageIndex;
  final int pageSize;
  final int count;
  final int totalPages;
  final List<DetectionItem> data;

  DetectionResponse({
    required this.pageIndex,
    required this.pageSize,
    required this.count,
    required this.totalPages,
    required this.data,
  });

  factory DetectionResponse.fromJson(Map<String, dynamic> json) {
    return DetectionResponse(
      pageIndex: json['pageIndex'],
      pageSize: json['pageSize'],
      count: json['count'],
      totalPages: json['totalPages'],
      data: List<DetectionItem>.from(
        json['data'].map((item) => DetectionItem.fromJson(item)),
      ),
    );
  }
}

class DetectionItem {
  final String imagePath;
  final String detectionClass;
  final bool isReviewed;
  final DateTime uploadDate;
  final DoctorReview? doctorReview;
  final double? confidence;
  final String? description;

  DetectionItem({
    required this.imagePath,
    required this.detectionClass,
    required this.isReviewed,
    required this.uploadDate,
    this.doctorReview,
    this.confidence,
    this.description,
  });

  factory DetectionItem.fromJson(Map<String, dynamic> json) {
    return DetectionItem(
      imagePath: json['imagePath'] as String? ?? '',
      detectionClass: json['detectionClass'] as String? ?? '',
      isReviewed: json['isReviewed'] == true,
      uploadDate: DateTime.tryParse(json['uploadDate']?.toString() ?? '') ?? DateTime.now(),
      doctorReview: json['doctorReview'] != null
          ? DoctorReview.fromJson(json['doctorReview'] as Map<String, dynamic>)
          : null,
      confidence: json['confidence'] != null ? (json['confidence'] as num).toDouble() : null,
      description: json['description'] as String?,
    );
  }
}

class DoctorReview {
  final String findings;
  final String reasoning;
  final String doctorId;
  final String doctorName;
  final String doctorProfilePicture;

  DoctorReview({
    required this.findings,
    required this.reasoning,
    required this.doctorId,
    required this.doctorName,
    required this.doctorProfilePicture,
  });

  factory DoctorReview.fromJson(Map<String, dynamic> json) {
    return DoctorReview(
      findings: json['findings'],
      reasoning: json['reasoning'],
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      doctorProfilePicture: json['doctorProfilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'findings': findings,
      'reasoning': reasoning,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorProfilePicture': doctorProfilePicture,
    };
  }
}

class DetectionRequest {
  final int pageIndex;
  final int pageSize;

  DetectionRequest({required this.pageIndex, required this.pageSize});

  Map<String, dynamic> toJson() {
    return {
      'pageIndex': pageIndex,
      'pageSize': pageSize,
    };
  }
}
