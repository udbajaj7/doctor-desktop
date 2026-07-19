import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../Models/PatientModel.dart';
import '../../../components/urls.dart';

Future<List<PatientModel>> getAllPatientsFuture(int docId) async {
  print("calling all patient api");
  final response = await http.post(
    Uri.parse(getAllPatientsUrl),
    headers: header,
    body: jsonEncode(<String, dynamic>{"doc_id": docId}),
  );
  print(response.statusCode);
  if (response.statusCode == 200) {
    print("All patients are here");
    var responseJson = json.decode(response.body.toString());
    var list = responseJson["Patients"] as List;
    List<PatientModel> patList =
        list.map((i) => PatientModel.fromJson(i)).toList();
    return patList;
  } else {
    return [];
  }
}

Future<String> editPatientDetail(PatientModel patient) async {
  var response = await http.post(Uri.parse(editPatientUrl),
      headers: header, body: patient.toJson2());

  if (response.statusCode == 200) {
    return response.body;
  } else {
    return "";
  }
}
