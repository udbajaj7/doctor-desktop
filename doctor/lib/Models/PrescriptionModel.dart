import 'package:doctor/Models/MedicineDetailsModel.dart';
import 'package:doctor/Models/VitalModel.dart';

class PrescriptionModel {
  String clinicalHistory;
  String notes;
  List<String> symptoms;
  List<String> diagnosis;
  List<String> tests;
  VitalsModel vitals;
  List<MedicineDetailsModel> medicines;
  String? nextVisit;
  int? bookingId;

  PrescriptionModel({
    required this.clinicalHistory,
    required this.notes,
    required this.symptoms,
    required this.diagnosis,
    required this.tests,
    required this.vitals,
    required this.medicines,
    this.bookingId,
    this.nextVisit,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    List<MedicineDetailsModel> x = [];
    try {
      x = List<MedicineDetailsModel>.from(
          json["medicines"].map((x) => MedicineDetailsModel.fromJson(x)));
    } catch (e) {
      x = [];
      print('caught error in prescription model from json' + e.toString());
    }
    ;
    return PrescriptionModel(
      // clinicalHistory: json["clinical_history"],
      // notes: json["notes"],
      symptoms: List<String>.from(json["symptoms"].map((x) => x)),
      diagnosis: List<String>.from(json["diagnosis"].map((x) => x)),
      tests: List<String>.from(json["tests"].map((x) => x)),
      vitals: VitalsModel.fromJson(json["vitals"]),
      medicines: x,
      nextVisit: json["next_visit"] ?? '',
      notes: json["notes"] ?? '',
      clinicalHistory: json["clinical_history"] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        // "clinical_history": clinicalHistory,
        // "notes": notes,
        "symptoms": List<dynamic>.from(symptoms.map((x) => x)),
        "diagnosis": List<dynamic>.from(diagnosis.map((x) => x)),
        "tests": List<dynamic>.from(tests.map((x) => x)),
        "vitals": vitals.toJson(),
        "medicines": List<dynamic>.from(medicines.map((x) => x.toJson())),
        "next_visit": nextVisit ?? '',
        "booking_id": bookingId,
        "notes": notes,
        "clinical_history": clinicalHistory,
      };
}
