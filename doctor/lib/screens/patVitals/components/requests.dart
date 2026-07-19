import 'package:doctor/Models/VitalsObject.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import '../../../components/urls.dart';
import '../../../providers/httpClientProvider.dart';

Future<String> addNotes(int bookingId, String notes) async {
  final response = await ConnectionService().returnConnection().post(
      Uri.parse(docNotesUrl),
      headers: header,
      body: jsonEncode(
          <String, dynamic>{"booking_id": bookingId, "notes": notes}));

  if (response.statusCode == 200) {
    return "Success";
  } else
    return "Error";
}

Future<VitalsObject> getVitals(int bookingID) async {
  // SharedPrefVitals sharedPrefVitals = SharedPrefVitals();
  // VitalsObject vitalsObject = await sharedPrefVitals.read(bookingID.toString());
  // if (vitalsObject.vitals != null) return vitalsObject;

  final response = await ConnectionService().returnConnection().get(
      Uri.parse(getVitalsUrl + "?booking_id=" + bookingID.toString()),
      headers: header);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body.toString());

    debugPrint(jsonResponse.toString());
    // debugPrint((jsonResponse["diagnosis"] as List<String>).toString());
    VitalsObject vitalsObject = VitalsObject.fromJson(jsonResponse);
    return vitalsObject;

    // sharedPrefVitals.save(bookingID.toString(), vitalsObject);
  } else
    return VitalsObject();
}

Future<String> saveVitals(int bookingId, VitalsObject vitalsObject) async {
  // SharedPrefVitals sharedPrefVitals = SharedPrefVitals();
  final response = await ConnectionService().returnConnection().post(
      Uri.parse(saveVitalsUrl),
      headers: header,
      body: jsonEncode(vitalsObject.toJson(bookingId)));

  if (response.statusCode == 200) {
    // sharedPrefVitals.save(bookingId.toString(), vitalsObject);
    return "Success";
  } else
    return "Error";
}
