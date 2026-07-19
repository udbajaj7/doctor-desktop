import 'dart:convert';
import 'package:doctor/Models/DoctorBookings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

import '../../../Models/MedicalFiles.dart';
import '../../../Models/PatientModel.dart';
import '../../../components/urls.dart';
import '../../../providers/httpClientProvider.dart';

Future getBalance(int bookingId) async {
  var response = await http.post(Uri.parse(getBalanceUrl),
      body: jsonEncode(<String, int>{"booking_id": bookingId}),
      headers: header);
  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body.toString());
    print("balance is .........");
    print(jsonResponse["balance"]);
    return Tuple2(jsonResponse["balance"], jsonResponse["installment"] ?? 0);
  } else
    return null;
}

Future<List<DoctorBookingsModel>> getPatientAllBookings(int patId) async {
  var response = await http.post(Uri.parse(getAllPatientBookings),
      body: jsonEncode(<String, int>{"pat_id": patId, "doc_id": myProfile.id}),
      headers: header);
  print("getting all booking for patient");
  print(getAllPatientBookings);
  print(<String, int>{"pat_id": patId, "doc_id": myProfile.id});
  print(response.statusCode);
  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body.toString());
    print("got response for patient all bookings");
    PatientAllBookingResponse bookingResponse =
        PatientAllBookingResponse.fromJson(jsonResponse);

    return bookingResponse.bookings;
  } else
    return [];
}

Future<String> uploadFileAPi(
    int bookingId, List<MedicalFiles> encodedFile) async {
  // print(encodedFile.toJson());

  final response = await ConnectionService().returnConnection().post(
      Uri.parse(sendFileUrl),
      headers: header,
      body: jsonEncode(
          <String, dynamic>{"booking_id": bookingId, 'files': encodedFile}));
  print(response.statusCode);
  if (response.statusCode == 200) return "Done";
  return "Error";
}

Future<Tuple2<List<MedicalFiles>, List<MedicalFiles>>?> getTreatmentFiles(
    int bookingId) async {
  final response = await ConnectionService()
      .returnConnection()
      .post(Uri.parse(getTreatmentFileUrl),
          headers: header,
          body: jsonEncode(<String, dynamic>{
            "booking_id": bookingId,
          }));
  print(response.statusCode);

  if (response.statusCode == 200) {
    var responseJson = json.decode(response.body.toString());
    List<MedicalFiles> files = List<MedicalFiles>.from(
        responseJson["files"].map((file) => MedicalFiles.fromJson(file)));
    print(files);
    List<MedicalFiles> images = [];
    List<MedicalFiles> documents = [];
    files.forEach((f) {
      String extention = f.fileName.split('.').last;
      if (["jpg", "jpeg", "png"].contains(extention))
        images.add(f);
      else
        documents.add(f);
      print(extention);
    });
    print("images are : ${images}");
    print("Documents are : ${documents}");
    return Tuple2(images, documents);
  }
  return Tuple2([], []);
}

class PatientAllBookingResponse {
  final List<DoctorBookingsModel> bookings;

  PatientAllBookingResponse({required this.bookings});

  factory PatientAllBookingResponse.fromJson(Map<String, dynamic> parsedJson) {
    var list1 = parsedJson["Bookings"] as List;
    List<DoctorBookingsModel> bookingsList =
        list1.map((i) => DoctorBookingsModel.fromJson(i)).toList();
    return PatientAllBookingResponse(bookings: bookingsList);
  }
}

Future<Map<String, List>> getBookings(int docId, String date) async {
  print("fetching all bookings for doctor $docId and date $date");
  var response = await http.post(Uri.parse(getBookingsUrl),
      body: jsonEncode(<String, dynamic>{"doc_id": docId, "date": date}),
      headers: header);

  var jsonResponse = json.decode(response.body.toString());
  if (response.statusCode == 200) {
    BookingResponse jsonResp = BookingResponse.fromJson(jsonResponse);

    var bookList = jsonResp.bookings;
    var patList = jsonResp.patients;
    print(bookList);
    print(patList);
    return {"pats": patList, "books": bookList};
  } else
    return {"pats": [], "books": []};
}

class BookingResponse {
  final List<PatientModel> patients;
  final List<DoctorBookingsModel> bookings;

  BookingResponse({required this.patients, required this.bookings});

  factory BookingResponse.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson["Patients"] as List;
    List<PatientModel> patList =
        list.map((i) => PatientModel.fromJson(i)).toList();
    var list1 = parsedJson["Bookings"] as List;
    List<DoctorBookingsModel> bookingsList =
        list1.map((i) => DoctorBookingsModel.fromJson(i)).toList();
    return BookingResponse(patients: patList, bookings: bookingsList);
  }
}

TimeOfDay computeSlot(String d) {
  d = d.padLeft(4, "0");
  int hours = int.parse(d.substring(0, 2));
  int minutes = int.parse(d.substring(2, 4));
  TimeOfDay slot = TimeOfDay(hour: hours, minute: minutes);
  return slot;
}

class Patient {
  String name;
  TimeOfDay bookingTime;

  Patient({required this.name, required this.bookingTime});
}
