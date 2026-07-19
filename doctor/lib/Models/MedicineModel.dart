import 'dart:convert';

import 'package:doctor/screens/prescriptionScreen/components/constants.dart';

class MedicineModel {
  String name;
  String type;
  String saltComposition;
  String? when;
  String? duration;
  String? dose;

  MedicineModel({
    required this.name,
    required this.type,
    required this.saltComposition,
    required this.when,
    required this.duration,
    required this.dose,
  });

  Object toJson() {
    return jsonEncode(<String, dynamic>{
      'name': this.name,
      'type': this.type,
      'composition': this.saltComposition,
      'when': this.when ?? 'Not Defined',
      'duration': this.duration ?? 'Not Defined',
      'dose': this.dose ?? 'Not Defined',
    });
  }

  factory MedicineModel.fromJsonWithDefaultDuration(Map<String, dynamic> json) {
    String composition = json['composition'] ?? 'Not available';
    String name = json['name'];
    String type = json['type'];
    String? when = json['when'];
    String? duration = ConstantsForPrescriptionScreen.durationList[4];
    String? dose = json['dose'];

    return MedicineModel(
      name: name,
      type: type,
      saltComposition: composition,
      when: when,
      duration: duration,
      dose: dose,
    );
  }

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    String composition = json['composition'] ?? 'Not available';
    String name = json['name'];
    String type = json['type'];
    String? when = json['when'];
    String? duration = json['duration'];
    String? dose = json['dose'];

    return MedicineModel(
      name: name,
      type: type,
      saltComposition: composition,
      when: when,
      duration: ConstantsForPrescriptionScreen.durationList[4],
      dose: dose,
    );
  }
}
