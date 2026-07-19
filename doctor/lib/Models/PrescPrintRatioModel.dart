import 'dart:convert';

import 'package:flutter/cupertino.dart';

class PrescPrintRatioModel {
  List<double> vertical;
  List<double>? horizontal;

  PrescPrintRatioModel({required this.vertical, this.horizontal});

  factory PrescPrintRatioModel.fromJson(Map<String, dynamic> parsedJson) {
    debugPrint(parsedJson.toString());
    var list = parsedJson["vertical"];
    List<double> doubleList = [];
    list.forEach((value) => doubleList.add(value));
    print(doubleList);
    return PrescPrintRatioModel(
      vertical: doubleList,
      horizontal: null,
    );
  }
}
