import 'dart:convert';

import 'package:doctor/Models/MedicineDataModel.dart';
import 'package:doctor/Models/MedicineDetailsModel.dart';
import 'package:doctor/Models/PrescPrintRatioModel.dart';
import 'package:doctor/Models/PrescriptionModel.dart';
import 'package:doctor/Models/VitalModel.dart';
import 'package:doctor/Models/PatientModel.dart';
import 'package:doctor/components/urls.dart';
import 'package:doctor/screens/prescriptionScreen/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<MedicineDataModel> getPrescreptionData() async {
  http.Response response =
      await http.get(Uri.parse(getMedicineData), headers: header);

  return MedicineDataModel.fromJsonWithDefaultDuration(
      //because the duration data should be hardcoded to 1 week
      jsonDecode(response.body) as Map<String, dynamic>);
}

Future<int> savePrescreption({
  required int bookingId,
  required String clinicalHistory,
  required String notes,
  required Map<String, dynamic> vitals,
  required List<String> symptoms,
  required List<String> diagnosis,
  required List<String> tests,
  required String nextVisit,
  required List<MedicineDetailsModel> medicines,
}) async {
  try {
    for (MedicineDetailsModel med in medicines) {
      if (med.name == ConstantsForPrescriptionScreen.unSelectedTag) {
        med.name = ConstantsForPrescriptionScreen.emptyInputTag;
        medicines.remove(med);
        break;
      }
      if (med.name
          .split(ConstantsForPrescriptionScreen.alternateMedicineDelimiter)
          .last
          .isEmpty) {
        print(' this is med.name ${med.name}');
        if (med.name.length >= 2) {
          med.name = med.name.substring(0, med.name.length - 1);
        }
      }
    }
  } catch (e, s) {
    print('error inside save prescription');
    print(e.toString());
    print(s.toString());
  }

  print('this is the nextVisit $nextVisit');

  String body = jsonEncode({
    "booking_id": bookingId,
    "vitals": vitals,
    "clinical_history": clinicalHistory,
    "notes": notes,
    "symptoms": symptoms,
    "diagnosis": diagnosis,
    "medicines": medicines.map((e) => e.toJson()).toList(),
    "tests": tests,
    "next_visit": nextVisit,
  });

  print('this is the body in savePrescription $body');

  http.Response response = await http
      .post(Uri.parse(savePrescrption), headers: header, body: body)
      .timeout(Duration(seconds: 5));
  debugPrint('here is the response for save prescription');
  debugPrint(response.statusCode.toString());
  debugPrint('this is the bookingId $bookingId');

  return response.statusCode;
}

Future<PrescriptionModel> getCurrentPrescreption() async {
  String body = jsonEncode({
    "booking_id": null,
    "Patient": {},
    "prescription": {},
  });

  final request = http.Request(
    'GET',
    Uri.parse(getCurrentPrescription + '?doc_id=${myProfile.id}'),
  );
  request.headers.addAll(header);
  request.body = body;
  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);
  debugPrint('getPreviousPrescreption');
  PrescriptionModel prescriptionModel = PrescriptionModel(
    // clinicalHistory: "",
    // notes: "",
    bookingId: -2,
    symptoms: [],
    diagnosis: [],
    tests: [],
    notes: "",
    clinicalHistory: "",
    vitals: VitalsModel(
      pulse: "",
      bp: "",
      weight: "",
      height: "",
      temperature: "",
      spo2: "",
    ),
    medicines: [
      MedicineDetailsModel(
        type: '',
        name: ConstantsForPrescriptionScreen.unSelectedTag,
        when: ConstantsForPrescriptionScreen.whenList.first,
        duration: ConstantsForPrescriptionScreen.durationList[4],
        dose: ConstantsForPrescriptionScreen.dosageList.first,
        saltComposition: ConstantsForPrescriptionScreen.saltCompositionValue,
      )
    ],
  );
  int id = jsonDecode(response.body)['booking_id'] ?? -1;
  debugPrint('this is the id $id');
  prescriptionModel.bookingId = id;
  try {
    prescriptionModel = PrescriptionModel.fromJson(
        jsonDecode(response.body)['prescription'] as Map<String, dynamic>);
    prescriptionModel.bookingId = id;
  } catch (e) {
    print('caught error in get currentPrescription $e');
    prescriptionModel = PrescriptionModel(
      // clinicalHistory: "",
      // notes: "",
      bookingId: id,
      symptoms: [],
      diagnosis: [],
      tests: [],
      notes: "",
      clinicalHistory: "",
      vitals: VitalsModel(
        pulse: "",
        bp: "",
        weight: "",
        height: "",
        temperature: "",
        spo2: "",
      ),
      medicines: [
        MedicineDetailsModel(
          type: '',
          name: ConstantsForPrescriptionScreen.unSelectedTag,
          when: ConstantsForPrescriptionScreen.whenList.first,
          duration: ConstantsForPrescriptionScreen.durationList[4],
          dose: ConstantsForPrescriptionScreen.dosageList.first,
          saltComposition: ConstantsForPrescriptionScreen.saltCompositionValue,
        ),
      ],
    );
  }

  return prescriptionModel;
}

Future<PrescriptionModel> getPrescription(int bookingId) async {
  final queryParameters = {
    'booking_id': bookingId.toString(),
  };
  final uri =
      Uri.parse(getPrescriptionUrl).replace(queryParameters: queryParameters);
  final http.Response response = await http.get(
    uri,
    headers: header,
  );

  debugPrint('getPrescreption $bookingId');
  PrescriptionModel prescriptionModel = PrescriptionModel(
    // clinicalHistory: "",
    // notes: "",
    bookingId: -2,
    symptoms: [],
    diagnosis: [],
    tests: [],
    vitals: VitalsModel(
      pulse: "",
      bp: "",
      weight: "",
      height: "",
      temperature: "",
      spo2: "",
    ),
    notes: "",
    clinicalHistory: "",
    medicines: [],
  );
  int id = int.parse(jsonDecode(response.body)['booking_id'] ?? '-1');
  debugPrint('this is the id $id');
  prescriptionModel.bookingId = id;
  try {
    prescriptionModel = PrescriptionModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
    prescriptionModel.bookingId = id;
  } catch (e) {
    print('caught error in getPrescription $e');
    return prescriptionModel = PrescriptionModel(
      // clinicalHistory: "",
      // notes: "",
      bookingId: id,
      symptoms: [],
      diagnosis: [],
      tests: [],
      vitals: VitalsModel(
        pulse: "",
        bp: "",
        weight: "",
        height: "",
        temperature: "",
        spo2: "",
      ),
      medicines: [],
      notes: "",
      clinicalHistory: "",
    );
  }

  return prescriptionModel;
}

Future<int> sendNextPatient(
  int? currentId,
) async {
  final String body =
      jsonEncode({"doc_id": myProfile.id, "current": currentId});

  final http.Response response = await http.post(
    Uri.parse(sendNextUrl),
    headers: header,
    body: body,
  );

  debugPrint('sendNextPatient');
  debugPrint(response.statusCode.toString());

  return response.statusCode;
}

Future<int> saveCustomMedicine({
  required String name,
  required String type,
  required String instructions,
}) async {
  final String body = jsonEncode({
    "name": name,
    "type": type,
    "instructions": instructions,
  });

  final http.Response response = await http.post(Uri.parse(saveMedicineDataUrl),
      headers: header, body: body);

  debugPrint('saveCustomMedicine');
  debugPrint(response.statusCode.toString());

  return response.statusCode;
}

Future<int> savePrescTemplate({
  required int age,
  required String gender,
  required List<String> symptoms,
  required List<String> diagnosis,
  required List<String> tests,
  required String nextVisit,
  required List<MedicineDetailsModel> medicines,
}) async {
  for (MedicineDetailsModel med in medicines) {
    if (med.name == ConstantsForPrescriptionScreen.unSelectedTag) {
      med.name = ConstantsForPrescriptionScreen.emptyInputTag;
      medicines.remove(med);
    }
    if (med.name
        .split(ConstantsForPrescriptionScreen.alternateMedicineDelimiter)
        .last
        .isEmpty) {
      try {
        print(' this is med.name ${med.name}');
        med.name = med.name.substring(0, med.name.length - 1);
      } catch (e) {
        print('error inside savePrecTemplate');
        print(e.toString());
      }
    }
  }

  String body = jsonEncode({
    "doc_id": myProfile.id,
    "pat_age": age,
    "pat_gender": gender,
    "symptoms": symptoms,
    "diagnosis": diagnosis,
    "medicines": medicines.map((e) => e.toJson()).toList(),
    "tests": tests,
    "next_visit": nextVisit,
  });

  print('this is the body in savePrecTemplate $body');

  http.Response response = await http
      .post(Uri.parse(savePrescTemplateUrl), headers: header, body: body)
      .timeout(Duration(seconds: 5));
  debugPrint('here is the response for savePrecTemplate');
  debugPrint(response.statusCode.toString());

  return response.statusCode;
}

Future<PrescriptionModel> getSavedPrecTemplateByDiagnosis(
    {required List<String> diagnosis}) async {
  final String body = jsonEncode({
    "doc_id": myProfile.id,
    "diagnosis": diagnosis,
  });

  final http.Response response = await http.post(
    Uri.parse(getPrescTemplateUrl),
    headers: header,
    body: body,
  );

  debugPrint('getSavedPrecTemplateByDiagnosis');
  debugPrint(response.statusCode.toString());

  Map<String, dynamic> data = jsonDecode(response.body);

  if (data.isEmpty) {
    return PrescriptionModel(
      bookingId: -1,
      symptoms: [],
      diagnosis: [],
      tests: [],
      vitals: VitalsModel(
        pulse: "",
        bp: "",
        weight: "",
        height: "",
        temperature: "",
        spo2: "",
      ),
      notes: "",
      clinicalHistory: "",
      medicines: [],
    );
  }

  List<MedicineDetailsModel> medicines = [];

  for (var element in data['medicines']) {
    print(element.runtimeType);
    MedicineDetailsModel medicineDetailsModel =
        MedicineDetailsModel.fromJson(element);
    medicines.add(medicineDetailsModel);
  }

  List<String> symptoms = [];
  List<String> tests = [];

  for (var element in data['symptoms'] ?? []) {
    symptoms.add(element);
  }

  for (var element in data['tests'] ?? []) {
    tests.add(element);
  }

  PrescriptionModel prescriptionModel = PrescriptionModel(
    // clinicalHistory: "",
    // notes: "",
    bookingId: -2,
    symptoms: symptoms,
    diagnosis: diagnosis,
    tests: tests,
    vitals: VitalsModel(
      pulse: "",
      bp: "",
      weight: "",
      height: "",
      temperature: "",
      spo2: "",
    ),
    notes: "",
    clinicalHistory: "",
    medicines: medicines,
    nextVisit: data["next_visit"] ?? "",
  );

  return prescriptionModel;
}

Future<PatientModel> getNextPatient() async {
  final http.Response response = await http.get(
    Uri.parse(getNextPatUrl + '?doc_id=' + myProfile.id.toString()),
    headers: header,
  );

  debugPrint('getNextPatient');
  debugPrint(response.statusCode.toString());

  try {
    Map<String, dynamic> data = jsonDecode(response.body);
    if (data.isEmpty) {
      return PatientModel(
        id: -1,
        firstName: "",
        lastName: "",
        phoneNumber: "",
        email: "",
        age: -1,
        gender: "",
        city: "",
        address: "",
      );
    } else {
      return PatientModel(
        id: data['id'] ?? -1,
        email: data['email'] ?? 'null',
        gender: data['gender'] ?? 'null',
        firstName: data['first_name'] ?? '',
        lastName: data['last_name'] ?? '',
        city: data['city'].toString(),
        age: data['age'] ?? -1,
        phoneNumber: data['phone_number'] ?? 'null',
        address: data['address'] ?? 'null',
      );
    }
  } catch (e, s) {
    print('error in getNextPatientInfo');
    print(e);
    print(s);
    throw Exception();
  }
}

Future getPrintRatios() async {
  final http.Response response = await http.get(
    Uri.parse(getPrescPrintRatios + '?doc_id=' + myProfile.id.toString()),
    headers: header,
  );
  var jsonResponse = json.decode(response.body.toString());
  if (response.statusCode == 200) {
    var prescRatios = PrescPrintRatioModel.fromJson(jsonResponse);
    myPrescriptionRatios = prescRatios;
    print("mypresc ratio");
    print(myPrescriptionRatios);
    return prescRatios;
  }
  return PrescPrintRatioModel(vertical: [0.2, 0.7, 0.1]);
}
