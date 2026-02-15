import 'package:chest_disease_app/core/helper/functions/convert_time_slot_function.dart';

class AvailableSlotsModel {
  int? id;
  int? dayOfWeek;
  String? startTime;
  bool? isAvailable;

  AvailableSlotsModel(
      {this.id, this.dayOfWeek, this.startTime, this.isAvailable});

  AvailableSlotsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dayOfWeek = json['dayOfWeek'];
    startTime = formatTimeTo24Hour(json['startTime']);
    isAvailable = json['isAvailable'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['dayOfWeek'] = dayOfWeek;
    data['startTime'] = startTime;
    data['isAvailable'] = isAvailable;
    return data;
  }
}

class AvailableSlotsRequestModel {
  final int clinicId;
  final int day;

  AvailableSlotsRequestModel({required this.clinicId, required this.day});
}

