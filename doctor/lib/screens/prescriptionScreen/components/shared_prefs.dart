import 'dart:convert';

import 'package:doctor/Models/MedicineModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  Future<void> saveMedicines(List<MedicineModel> medicines) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> jsonList = [];
    medicines.forEach((medicine) {
      jsonList.add(medicine.toJson().toString());
    });
    print('here is the length of medicines revieved: ${jsonList.length}');
    try {
      prefs.setStringList('medicines', jsonList);
    } catch (e) {
      print('error in saving medicines${e.toString()}');
    }
  }

  Future<List<MedicineModel>> getMedicine() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> jsonList = prefs.getStringList('medicines') ?? [];
    List<MedicineModel> medicines = [];
    jsonList.forEach((json) {
      medicines.add(
          MedicineModel.fromJson(jsonDecode(json) as Map<String, dynamic>));
    });
    return medicines;
  }

  Future<void> saveDiagnosis(List<String> diagnosis) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setStringList('diagnosis', diagnosis);
  }

  Future<List<String>> getDiagnosis() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> diagnosis = prefs.getStringList('diagnosis') ?? [];
    return diagnosis;
  }

  Future<void> saveSymptoms(List<String> symptoms) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setStringList('symptoms', symptoms);
  }

  Future<List<String>> getSymptoms() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> symptoms = prefs.getStringList('symptoms') ?? [];
    return symptoms;
  }

  Future<void> saveTests(List<String> tests) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setStringList('tests', tests);
  }

  Future<List<String>> getTests() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> tests = prefs.getStringList('tests') ?? [];
    return tests;
  }
}
