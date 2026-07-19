import 'package:doctor/Models/MedicineModel.dart';
import 'package:doctor/screens/prescriptionScreen/components/constants.dart';

class MedicineDataModel {
  List<MedicineModel> medicines;
  List<String> diagnosis;
  List<String> symptoms;
  List<String> tests;

  MedicineDataModel({
    required this.medicines,
    required this.diagnosis,
    required this.symptoms,
    required this.tests,
  });

  Object toJson() {
    return {
      'medicines': this.medicines,
      'diagnosis': this.diagnosis,
      'symptoms': this.symptoms,
      'tests': this.tests,
    };
  }
  factory MedicineDataModel.fromJsonWithDefaultDuration(Map<String, dynamic> json) {
    List medicines = json['Medicines'];
    List<MedicineModel> medicinesList = [];
    for (Map<String, dynamic> medicine in medicines) {
      medicinesList.add(MedicineModel.fromJsonWithDefaultDuration(medicine));
    }

    medicinesList.insert(
      0,
      MedicineModel(
        name: ConstantsForPrescriptionScreen.unSelectedTag,
        type: '',
        saltComposition: '',
        when: null,
        duration: null,
        dose: null,
      ),
    );

    List<String> diagnosis = [];
    List<String> symptoms = [];
    List<String> tests = [];

    List diagnosisList = json['diagnosis'];
    for (String diag in diagnosisList) {
      diagnosis.add(diag);
    }

    List symptomsList = json['symptoms'];
    for (String symptom in symptomsList) {
      symptoms.add(symptom);
    }

    List testsList = json['tests'];
    for (String test in testsList) {
      tests.add(test);
    }

    // diagnosis.insert(0, ConstantsForPrescriptionScreen.unSelectedTag);
    // symptoms.insert(0, ConstantsForPrescriptionScreen.unSelectedTag);
    // tests.insert(0, ConstantsForPrescriptionScreen.unSelectedTag);

    return MedicineDataModel(
      medicines: medicinesList,
      diagnosis: diagnosis,
      symptoms: symptoms,
      tests: tests,
    );
  }


  factory MedicineDataModel.fromJson(Map<String, dynamic> json) {
    List medicines = json['Medicines'];
    List<MedicineModel> medicinesList = [];
    for (Map<String, dynamic> medicine in medicines) {
      medicinesList.add(MedicineModel.fromJson(medicine));
    }

    medicinesList.insert(
      0,
      MedicineModel(
        name: ConstantsForPrescriptionScreen.unSelectedTag,
        type: '',
        saltComposition: '',
        when: null,
        duration: null,
        dose: null,
      ),
    );

    List<String> diagnosis = [];
    List<String> symptoms = [];
    List<String> tests = [];

    List diagnosisList = json['diagnosis'];
    for (String diag in diagnosisList) {
      diagnosis.add(diag);
    }

    List symptomsList = json['symptoms'];
    for (String symptom in symptomsList) {
      symptoms.add(symptom);
    }

    List testsList = json['tests'];
    for (String test in testsList) {
      tests.add(test);
    }

    // diagnosis.insert(0, ConstantsForPrescriptionScreen.unSelectedTag);
    // symptoms.insert(0, ConstantsForPrescriptionScreen.unSelectedTag);
    // tests.insert(0, ConstantsForPrescriptionScreen.unSelectedTag);

    return MedicineDataModel(
      medicines: medicinesList,
      diagnosis: diagnosis,
      symptoms: symptoms,
      tests: tests,
    );
  }
}
