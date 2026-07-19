import 'dart:convert';

import 'package:flutter/cupertino.dart';

class VitalsObject {
  Vitals? vitals;
  List<String>? symptoms;
  List<String>? diagnosis;
  String? notes, clinicalHistory;

  VitalsObject(
      {this.vitals,
      this.symptoms,
      this.diagnosis,
      this.notes,
      this.clinicalHistory});

  factory VitalsObject.fromJson(Map<String, dynamic> json) {
    return VitalsObject(
        vitals:
            json['vitals'] != null ? Vitals.fromJson(json["vitals"]) : Vitals(),
        symptoms: List<String>.from(json["symptoms"].map((x) => x)),
        diagnosis: List<String>.from(json["diagnosis"].map((x) => x)),
        notes: json["notes"] ?? "",
        clinicalHistory: json["clinical_history"] ?? "");
  }

  Map<String, dynamic> toJson(int bookingID) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['booking_id'] = bookingID;
    if (this.vitals != null) {
      data['vitals'] = this.vitals!.toJson();
    }
    data['symptoms'] = this.symptoms;
    data['diagnosis'] = this.diagnosis;
    data['clinical_history'] = this.clinicalHistory;
    data['notes'] = this.notes;
    return data;
  }

  Map<String, dynamic> toJsonForEncoding() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.vitals != null) {
      data['vitals'] = this.vitals!.toJson();
    }
    data['symptoms'] = this.symptoms;
    data['diagnosis'] = this.diagnosis;
    data['notes'] = this.notes;
    data['clinical_history'] = this.clinicalHistory;
    return data;
  }

  static String encode(VitalsObject vitalsObject) => json.encode(
        vitalsObject.toJsonForEncoding(),
      );

  static VitalsObject decode(String vitalString) {
    if (vitalString == "") return VitalsObject();
    debugPrint(vitalString);
    return VitalsObject.fromJson(jsonDecode(vitalString));
  }
}

class Vitals {
  double? weight;
  double? height;
  double? temperature;
  String? bloodPressure;
  double? pulse;
  double? spo2;

  Vitals(
      {this.weight,
      this.height,
      this.temperature,
      this.bloodPressure,
      this.pulse,
      this.spo2});

  factory Vitals.fromJson(Map<String, dynamic> json) {
    return Vitals(
      weight: double.tryParse(json['weight'].toString()),
      height: double.tryParse(json['height'].toString()),
      temperature: double.tryParse(json['temperature'].toString()),
      bloodPressure: json['bloodPressure'],
      pulse: double.tryParse(json['pulse'].toString()),
      spo2: double.tryParse(json['spo2'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.weight != null) data['weight'] = this.weight;
    if (this.height != null) data['height'] = this.height;
    if (this.temperature != null) data['temperature'] = this.temperature;
    if (this.bloodPressure != null) data['bloodPressure'] = this.bloodPressure;
    if (this.pulse != null) data['pulse'] = this.pulse;
    if (this.spo2 != null) data['spo2'] = this.spo2;
    return data;
  }
}
