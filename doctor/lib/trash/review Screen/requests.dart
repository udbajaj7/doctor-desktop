import 'package:doctor/Models/DoctorModel.dart';
import 'package:doctor/Models/DoctorReview.dart';
import 'package:doctor/Models/PatientModel.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../../../components/urls.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Tuple4> getReviewsFuture(int docId) async {
  var response = await http.post(Uri.parse(getReviewsUrl),
      body: jsonEncode(<String, int>{"doc_id": docId}), headers: header);

  if (response.statusCode == 200) {
    var responseJson = json.decode(response.body.toString());
   
    List<DoctorReview> reviewList =
        (responseJson["Reviews"] as List).map((e) => DoctorReview.fromJson(e)).toList();
    List<PatientModel> patientList = (responseJson["Patients"] as List)
        .map(
          (e) => PatientModel.fromJson(e),
        )
        .toList();
    String rating = responseJson["Rating"];
    var ratingSplit = responseJson["Rating Split"];
    List<String> ratingPercentage = [
      ratingSplit["1"],
      ratingSplit["2"],
      ratingSplit["3"],
      ratingSplit["4"],
      ratingSplit["5"]
    ];
    return Tuple4(rating, ratingPercentage, patientList, reviewList);
  } else {
    return Tuple4(0, [], [], []);
  }
}
