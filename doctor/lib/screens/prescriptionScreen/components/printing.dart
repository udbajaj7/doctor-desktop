import 'package:doctor/Models/MedicineDetailsModel.dart';
import 'package:doctor/Models/PrescPrintRatioModel.dart';
import 'package:doctor/components/size_config.dart';
import 'package:doctor/components/urls.dart';
import 'package:doctor/screens/prescriptionScreen/components/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void printPdf({
  required String id,
  required String name,
  required String age,
  required String phone,
  required String gender,
  required String nextVisit,
  required String clinicalHistory,
  required String notes,
  required List<String> symptoms,
  required List<String> diagnosis,
  required List<String> tests,
  required Map<String, String> vitals,
  required List<MedicineDetailsModel> medications,
  required PrescPrintRatioModel prescPrintRatios,
}) async {
  for (MedicineDetailsModel med in medications) {
    if (med.name == ConstantsForPrescriptionScreen.unSelectedTag) {
      med.name = ConstantsForPrescriptionScreen.emptyInputTag;
      medications.remove(med);
    }
  }
  final doc = pw.Document();
  print(prescPrintRatios.horizontal.toString());
  doc.addPage(
    pw.MultiPage(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      margin: pw.EdgeInsets.only(
          left: 35,
          right: 25,
          top: PdfPageFormat.a4.height * prescPrintRatios.vertical[0],
          bottom: PdfPageFormat.a4.height * prescPrintRatios.vertical[2]),
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          (myProfile.id == 697)
              ? getPrescriptionPdfFor697(
                  id: id,
                  name: name,
                  age: age,
                  gender: gender,
                  phone: phone,
                  nextVisit: nextVisit,
                  clinicalHistory: clinicalHistory,
                  notes: notes,
                  symptoms: symptoms,
                  diagnosis: diagnosis,
                  tests: tests,
                  vitals: vitals,
                  medications: medications,
                )
              : pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.RichText(
                          text: pw.TextSpan(
                            children: [
                              pw.TextSpan(
                                text: 'ID: $id',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  color: PdfColor.fromHex('000000'),
                                ),
                              ),
                              pw.TextSpan(
                                text: '\t\t\t\t\t|\t\t\t\t\t',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  color: PdfColor.fromHex('4a4a4a'),
                                ),
                              ),
                              pw.TextSpan(
                                text: '$name',
                                style: pw.TextStyle(
                                  fontSize: 13,
                                  color: PdfColor.fromHex('000000'),
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.TextSpan(
                                text: '\t\t\t\t\t|\t\t\t\t\t',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  color: PdfColor.fromHex('4a4a4a'),
                                ),
                              ),
                              pw.TextSpan(
                                text: '$age/$gender',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  color: PdfColor.fromHex('000000'),
                                ),
                              ),
                              pw.TextSpan(
                                text: '\t\t\t\t\t|\t\t\t\t\t',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  color: PdfColor.fromHex('4a4a4a'),
                                ),
                              ),
                              pw.TextSpan(
                                text: '$phone',
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  color: PdfColor.fromHex('000000'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.Text(
                          '${getMonthName(DateTime.now().month)} ${DateTime.now().day}, ${DateTime.now().year}',
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: PdfColor.fromHex('000000'),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: (9)),
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: vitals['weight'] != ""
                                ? 'Weight: ${vitals['weight']} Kgs'
                                : "",
                            style: pw.TextStyle(
                              color: PdfColor.fromHex('000000'),
                              fontSize: 11,
                            ),
                          ),
                          pw.TextSpan(
                            text: vitals['height'] != ""
                                ? '\t|\tHeight: ${vitals['height']} cm'
                                : "",
                            style: pw.TextStyle(
                              color: PdfColor.fromHex('000000'),
                              fontSize: 11,
                            ),
                          ),
                          pw.TextSpan(
                            text: vitals['bloodPressure'] != ""
                                ? '\t|\tBP: ${vitals['bloodPressure']} mm/Hg'
                                : "",
                            style: pw.TextStyle(
                              color: PdfColor.fromHex('000000'),
                              fontSize: 11,
                            ),
                          ),
                          pw.TextSpan(
                            text: vitals['temperature'] != ""
                                ? '\t|\tTemp: ${vitals['temperature']} F'
                                : "",
                            style: pw.TextStyle(
                              color: PdfColor.fromHex('000000'),
                              fontSize: 11,
                            ),
                          ),
                          pw.TextSpan(
                            text: vitals['pulse'] != ""
                                ? '\t|\tPulse: ${vitals['pulse']} bpm'
                                : "",
                            style: pw.TextStyle(
                              color: PdfColor.fromHex('000000'),
                              fontSize: 11,
                            ),
                          ),
                          pw.TextSpan(
                            text: vitals['spo2'] != ""
                                ? '\t|\tspo2: ${vitals['spo2']} %'
                                : "",
                            style: pw.TextStyle(
                              color: PdfColor.fromHex('000000'),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: (5)),
                    (notes.isNotEmpty)
                        ? pw.ConstrainedBox(
                            constraints: pw.BoxConstraints(
                              maxWidth: 360,
                              maxHeight: 100,
                              minHeight: 15,
                              minWidth: 360,
                            ),
                            child: pw.Text(
                              notes,
                              style: pw.TextStyle(
                                color: PdfColor.fromHex('000000'),
                                fontSize: 11,
                              ),
                            ),
                          )
                        : pw.SizedBox.shrink(),
                    // pw.SizedBox(height: getProportionateWebScreenHeight(4)),
                    (clinicalHistory.isNotEmpty)
                        ? patientDetailsRow(
                            'Clinical History:', clinicalHistory)
                        : pw.Container(),
                    // pw.SizedBox(height: (4)),
                    (symptoms.isEmpty)
                        ? pw.SizedBox.shrink()
                        : pw.Padding(
                            padding: pw.EdgeInsets.only(right: 15),
                            child: patientDetailsRow(
                              'Symptoms :',
                              symptoms.join(', '),
                            ),
                          ),
                    pw.SizedBox(height: (8)),
                    (diagnosis.isEmpty)
                        ? pw.SizedBox.shrink()
                        : pw.Padding(
                            padding: pw.EdgeInsets.only(right: 15),
                            child: patientDetailsRow(
                              'Diagnosis :',
                              diagnosis.join(', '),
                            ),
                          ),
                    pw.SizedBox(height: getProportionateWebScreenHeight(8)),
                    (medications.isNotEmpty) ? tableHeader() : pw.Container(),
                    for (MedicineDetailsModel meds in medications)
                      tableBody(
                          index: medications.indexOf(meds) + 1, med: meds),
                    pw.SizedBox(height: 16),
                    tests.isEmpty
                        ? pw.Container()
                        : pw.Padding(
                            padding: pw.EdgeInsets.only(right: 15),
                            child: patientDetailsRow(
                              'Tests :',
                              tests.join(', '),
                            ),
                          ),
                    pw.SizedBox(height: (16)),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        (nextVisit.isEmpty)
                            ? pw.SizedBox.shrink()
                            : patientDetailsRow('Next Visit :', nextVisit,
                                disableMinWidth: false),
                        pw.Text('Signature'),
                      ],
                    ),
                  ],
                )
        ];
      },
    ),
  );

  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save());
}

String setVitalsString(Map<String, String> vitals) {
  String vitalsString = '';
  vitals.forEach((key, value) {
    if (value.isNotEmpty) {
      vitalsString += '$key: $value\t|\t ';
    }
  });
  vitalsString = vitalsString.substring(0, vitalsString.length - 3);
  return vitalsString;
}

pw.Column patientDetailsColumn(String title, String desc) {
  return pw.Column(
    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        title,
        style: pw.TextStyle(
          color: PdfColor.fromHex('0f0f0f'),
          fontSize: 12,
        ),
      ),
      pw.Text(
        desc,
        style: pw.TextStyle(
          color: PdfColor.fromHex('555555'),
          fontSize: 12,
        ),
      ),
    ],
  );
}

pw.Row patientDetailsRow(String title, String desc,
    {bool disableMinWidth = true}) {
  print(
      ' this is the title $title, and this is the length of desc ${desc.length}');
  // List<String> newLines = getNewLines(desc);
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.start,
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        title,
        maxLines: 3,
        style: pw.TextStyle(
          color: PdfColor.fromHex('0e0e0e'),
          fontSize: 11,
        ),
      ),
      pw.SizedBox(width: 10),
      pw.ConstrainedBox(
        constraints: pw.BoxConstraints(
          maxWidth: 360,
          maxHeight: 100,
          minHeight: 15,
          minWidth: disableMinWidth ? 360 : 0,
        ),
        child: pw.Text(
          desc,
          style: pw.TextStyle(
            color: PdfColor.fromHex('000000'),
            fontSize: 11,
          ),
        ),
      ),
    ],
  );
}

List<String> getNewLines(String text) {
  if (text.length >= 55 && text.length <= 110) {
    return [text.substring(0, 55), text.substring(55)];
  } else if (text.length > 110 && text.length <= 165) {
    return [
      text.substring(0, 55),
      text.substring(55, 110),
      text.substring(110)
    ];
  } else if (text.length > 165 && text.length <= 220) {
    return [
      text.substring(0, 55),
      text.substring(55, 110),
      text.substring(110, 165),
      text.substring(165)
    ];
  } else if (text.length > 220 && text.length <= 275) {
    return [
      text.substring(0, 55),
      text.substring(55, 110),
      text.substring(110, 165),
      text.substring(165, 220),
      text.substring(220)
    ];
  } else if (text.length > 275 && text.length <= 330) {
    return [
      text.substring(0, 55),
      text.substring(55, 110),
      text.substring(110, 165),
      text.substring(165, 220),
      text.substring(220, 275),
      text.substring(275)
    ];
  } else if (text.length > 330 && text.length <= 385) {
    return [
      text.substring(0, 55),
      text.substring(55, 110),
      text.substring(110, 165),
      text.substring(165, 220),
      text.substring(220, 275),
      text.substring(275, 330),
      text.substring(330)
    ];
  } else if (text.length > 385 && text.length <= 440) {
    return [
      text.substring(0, 55),
      text.substring(55, 110),
      text.substring(110, 165),
      text.substring(165, 220),
      text.substring(220, 275),
      text.substring(275, 330),
      text.substring(330, 385),
      text.substring(385)
    ];
  } else if (text.length > 440 && text.length <= 495) {
    return [
      text.substring(0, 55),
      text.substring(55, 110),
      text.substring(110, 165),
      text.substring(165, 220),
      text.substring(220, 275),
      text.substring(275, 330),
      text.substring(330, 385),
      text.substring(385, 440),
      text.substring(440)
    ];
  } else if (text.length > 495 && text.length <= 550) {
    return [
      text.substring(0, 55),
      text.substring(55, 110),
      text.substring(110, 165),
      text.substring(165, 220),
      text.substring(220, 275),
      text.substring(275, 330),
      text.substring(330, 385),
      text.substring(385, 440),
      text.substring(440, 495),
      text.substring(495)
    ];
  } else if (text.length > 550 && text.length <= 605) {
    return [
      text.substring(0, 55),
      text.substring(55, 110),
      text.substring(110, 165),
      text.substring(165, 220),
      text.substring(220, 275),
      text.substring(275, 330),
      text.substring(330, 385),
      text.substring(385, 440),
      text.substring(440, 495),
      text.substring(495, 550),
      text.substring(550)
    ];
  }
  return [text];
}

pw.Row tableHeader() {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.start,
    children: [
      tableCellDark(
        width: 25,
        text: '#',
        height: 20,
        keepHighFontSize: false,
      ),
      tableCellDark(
        width: 150,
        text: 'Medicine',
        height: 20,
        keepHighFontSize: false,
      ),
      myProfile.id == 718
          ? pw.Container()
          : tableCellDark(
              width: 120,
              text: 'Composition',
              height: 20,
            ),
      tableCellDark(
        width: 70,
        text: 'Dosage',
        height: 20,
        keepHighFontSize: false,
      ),
      tableCellDark(
        width: 100,
        text: 'When',
        height: 20,
        keepHighFontSize: false,
      ),
      tableCellDark(
        width: 70,
        text: 'Duration',
        height: 20,
        keepHighFontSize: false,
      ),
    ],
  );
}

pw.Row tableBody({required int index, required MedicineDetailsModel med}) {
  // myProfile.id = 718;
  if (med.name
              .split(ConstantsForPrescriptionScreen.alternateMedicineDelimiter)
              .length ==
          2 &&
      med.name
          .split(ConstantsForPrescriptionScreen.alternateMedicineDelimiter)
          .last
          .isNotEmpty) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        tableCellDark(
          width: 25,
          text: index.toString(),
          height: 50,
        ),
        medicineTableCell(width: 150, text: med.name, height: 50, fontSize: 10),
        myProfile.id == 718
            ?  pw.Container(): tableCellLight(
                width: 120,
                text: med.saltComposition,
                fontSize: 8,
                height: 50,
                leftAligned: true,
              )
            ,
        tableCellLight(width: 70, text: med.dose, height: 50),
        tableCellLight(
            width: 100, text: med.when, enablePadding: false, height: 50),
        tableCellLight(width: 70, text: med.duration, height: 50),
      ],
    );
  }
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.start,
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      tableCellDark(width: 25, text: index.toString()),
      medicineTableCell(width: 150, text: med.name, fontSize: 10),
      myProfile.id == 718
          ? pw.Container()
          : tableCellLight(
              width: 120,
              fontSize: 8,
              text: med.saltComposition,
              leftAligned: true,
            ),
      tableCellLight(width: 70, text: med.dose),
      tableCellLight(width: 100, text: med.when, enablePadding: false),
      tableCellLight(
          width: 70, text: med.duration),
    ],
  );
}

pw.Container tableCellDark({
  required double width,
  required String text,
  double height = 28,
  keepHighFontSize = false,
}) {
  return pw.Container(
    height: height,
    width: width,
    decoration: pw.BoxDecoration(
      color: PdfColor.fromHex('ffffff'),
      border: pw.Border.all(
        color: PdfColor.fromHex('0e0e0e'),
        width: 0.5,
      ),
    ),
    child: pw.Center(
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: keepHighFontSize ? 14 : 11,
        ),
      ),
    ),
  );
}

pw.Container tableCellLight(
    {required String text,
    required double width,
    bool enablePadding = true,
    bool keepHighFontSize = false,
    bool leftAligned = false,
    double height = 28,
    double? fontSize}) {
  return pw.Container(
      height: height,
      width: width,
      padding: (enablePadding)
          ? pw.EdgeInsets.only(left: 5)
          : pw.EdgeInsets.only(top: 1, bottom: 2),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('ffffff'),
        border: pw.Border.all(
          color: PdfColor.fromHex('0e0e0e'),
          width: 0.5,
        ),
      ),
      child: pw.Align(
        alignment:
            (leftAligned) ? pw.Alignment.centerLeft : pw.Alignment.center,
        child: pw.Text(
          text,
          textAlign: (leftAligned) ? pw.TextAlign.left : pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize:
                (fontSize == null) ? (keepHighFontSize ? 14 : 11) : fontSize,
          ),
        ),
      ));
}

pw.Container medicineTableCell(
    {required String text,
    required double width,
    height = 28,
    double fontSize = 9}) {
  List<String> medNames =
      text.split(ConstantsForPrescriptionScreen.alternateMedicineDelimiter);
  print('this is medNames: $medNames');
  return pw.Container(
      height: height,
      width: width,
      padding: pw.EdgeInsets.only(left: 3, bottom: 2, top: 1),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('ffffff'),
        border: pw.Border.all(
          color: PdfColor.fromHex('0e0e0e'),
          width: 0.5,
        ),
      ),
      child: pw.Align(
        alignment: pw.Alignment.centerLeft,
        child: (medNames.length == 2 && medNames.last.isNotEmpty)
            ? pw.Text(
                medNames.first + '\n' + '(or ${medNames.last})',
                maxLines: 5,
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(
                  fontSize: fontSize,
                ),
              )
            : pw.Text(
                medNames.first,
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(
                  fontSize: fontSize,
                ),
              ),
      ));
}

String getMonthName(int month) {
  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return months[month - 1];
}

pw.Widget getPrescriptionPdfFor697({
  required String id,
  required String name,
  required String age,
  required String gender,
  required String phone,
  required String nextVisit,
  required String clinicalHistory,
  required String notes,
  required List<String> symptoms,
  required List<String> diagnosis,
  required List<String> tests,
  required Map<String, String> vitals,
  required List<MedicineDetailsModel> medications,
}) {
  return pw.Padding(
    padding: pw.EdgeInsets.only(left: 70),
    child: pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: (200)),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: 'ID: $id',
                    style: pw.TextStyle(
                      fontSize: 11,
                      color: PdfColor.fromHex('000000'),
                    ),
                  ),
                  pw.TextSpan(
                    text: '\t\t|\t\t',
                    style: pw.TextStyle(
                      fontSize: 11,
                      color: PdfColor.fromHex('4a4a4a'),
                    ),
                  ),
                  pw.TextSpan(
                    text: '$name',
                    style: pw.TextStyle(
                      fontSize: 13,
                      color: PdfColor.fromHex('000000'),
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.TextSpan(
                    text: '\t\t|\t\t',
                    style: pw.TextStyle(
                      fontSize: 11,
                      color: PdfColor.fromHex('4a4a4a'),
                    ),
                  ),
                  pw.TextSpan(
                    text: '$age/$gender',
                    style: pw.TextStyle(
                      fontSize: 11,
                      color: PdfColor.fromHex('000000'),
                    ),
                  ),
                  pw.TextSpan(
                    text: '\t\t|\t\t',
                    style: pw.TextStyle(
                      fontSize: 11,
                      color: PdfColor.fromHex('4a4a4a'),
                    ),
                  ),
                  pw.TextSpan(
                    text: '$phone',
                    style: pw.TextStyle(
                      fontSize: 11,
                      color: PdfColor.fromHex('000000'),
                    ),
                  ),
                ],
              ),
            ),
            pw.Text(
              '${getMonthName(DateTime.now().month)} ${DateTime.now().day}, ${DateTime.now().year}',
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColor.fromHex('000000'),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: (9)),
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: vitals['weight'] != ""
                    ? 'Weight: ${vitals['weight']} Kgs'
                    : "",
                style: pw.TextStyle(
                  color: PdfColor.fromHex('000000'),
                  fontSize: 11,
                ),
              ),
              pw.TextSpan(
                text: vitals['height'] != ""
                    ? '\t|\tHeight: ${vitals['height']} cm'
                    : "",
                style: pw.TextStyle(
                  color: PdfColor.fromHex('000000'),
                  fontSize: 11,
                ),
              ),
              pw.TextSpan(
                text: vitals['bloodPressure'] != ""
                    ? '\t|\tBP: ${vitals['bloodPressure']} mm/Hg'
                    : "",
                style: pw.TextStyle(
                  color: PdfColor.fromHex('000000'),
                  fontSize: 11,
                ),
              ),
              pw.TextSpan(
                text: vitals['temperature'] != ""
                    ? '\t|\tTemp: ${vitals['temperature']} F'
                    : "",
                style: pw.TextStyle(
                  color: PdfColor.fromHex('000000'),
                  fontSize: 11,
                ),
              ),
              pw.TextSpan(
                text: vitals['pulse'] != ""
                    ? '\t|\tPulse: ${vitals['pulse']} bpm'
                    : "",
                style: pw.TextStyle(
                  color: PdfColor.fromHex('000000'),
                  fontSize: 11,
                ),
              ),
              pw.TextSpan(
                text: vitals['spo2'] != ""
                    ? '\t|\tspo2: ${vitals['spo2']} %'
                    : "",
                style: pw.TextStyle(
                  color: PdfColor.fromHex('000000'),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: (6)),
        (notes.isNotEmpty)
            ? pw.ConstrainedBox(
                constraints: pw.BoxConstraints(
                  maxWidth: 360,
                  maxHeight: 100,
                  minHeight: 15,
                  minWidth: 360,
                ),
                child: pw.Text(
                  notes,
                  style: pw.TextStyle(
                    color: PdfColor.fromHex('000000'),
                    fontSize: 11,
                  ),
                ),
              )
            : pw.SizedBox.shrink(),
        // pw.SizedBox(height: (4)),
        (clinicalHistory.isNotEmpty)
            ? patientDetailsRow('Clinical History:', clinicalHistory)
            : pw.Container(),
        // pw.SizedBox(height: (4)),
        (symptoms.isEmpty)
            ? pw.SizedBox.shrink()
            : pw.Padding(
                padding: pw.EdgeInsets.only(right: 40),
                child: patientDetailsRow(
                  'Symptoms :',
                  symptoms.join(', '),
                ),
              ),
        // pw.SizedBox(height: (4)),
        (diagnosis.isEmpty)
            ? pw.SizedBox.shrink()
            : pw.Padding(
                padding: pw.EdgeInsets.only(right: 40),
                child: patientDetailsRow(
                  'Diagnosis :',
                  diagnosis.join(', '),
                ),
              ),
        pw.SizedBox(height: getProportionateWebScreenHeight(4)),
        (medications.isNotEmpty)
            ? pw.Padding(
                padding: pw.EdgeInsets.only(right: 4),
                child: tableHeaderFor697(),
              )
            : pw.Container(),
        for (MedicineDetailsModel meds in medications)
          pw.Padding(
            padding: pw.EdgeInsets.only(right: 4),
            child: tableBodyFor697(
                index: medications.indexOf(meds) + 1, med: meds),
          ),
        pw.SizedBox(height: 6),
        tests.isEmpty
            ? pw.Container()
            : pw.Padding(
                padding: pw.EdgeInsets.only(right: 40),
                child: patientDetailsRow(
                  'Tests :',
                  tests.join(', '),
                ),
              ),
        // pw.SizedBox(height: (4)),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            (nextVisit.isEmpty)
                ? pw.SizedBox.shrink()
                : patientDetailsRow('Next Visit :', nextVisit,
                    disableMinWidth: false),
            pw.Text('Signature'),
          ],
        ),
      ],
    ),
  );
}

pw.Row tableBodyFor697(
    {required int index, required MedicineDetailsModel med}) {
  if (med.name
              .split(ConstantsForPrescriptionScreen.alternateMedicineDelimiter)
              .length ==
          2 &&
      med.name
          .split(ConstantsForPrescriptionScreen.alternateMedicineDelimiter)
          .last
          .isNotEmpty) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      children: [
        tableCellDark(width: 25, text: index.toString(), height: 50),
        medicineTableCell(width: 100, text: med.name, height: 50),
        tableCellLight(
          width: 90,
          text: med.saltComposition,
          fontSize: 8,
          height: 50,
          leftAligned: true,
        ),
        tableCellLight(width: 70, text: med.dose, height: 50),
        tableCellLight(
            width: 100, text: med.when, enablePadding: false, height: 50),
        tableCellLight(width: 70, text: med.duration, height: 50),
      ],
    );
  }
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.start,
    children: [
      tableCellDark(width: 25, text: index.toString()),
      medicineTableCell(width: 100, text: med.name),
      tableCellLight(
        width: 90,
        fontSize: 8,
        text: med.saltComposition,
        leftAligned: true,
      ),
      tableCellLight(width: 70, text: med.dose),
      tableCellLight(width: 100, text: med.when, enablePadding: false),
      tableCellLight(width: 70, text: med.duration),
    ],
  );
}

pw.Row tableHeaderFor697() {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.start,
    children: [
      tableCellDark(
        width: 25,
        text: '#',
        height: 20,
      ),
      tableCellDark(
        width: 100,
        text: 'Medicine',
        height: 20,
      ),
      tableCellDark(
        width: 90,
        text: 'Composition',
        height: 20,
      ),
      tableCellDark(
        width: 70,
        text: 'Dosage',
        height: 20,
      ),
      tableCellDark(
        width: 100,
        text: 'When',
        height: 20,
      ),
      tableCellDark(
        width: 70,
        text: 'Duration',
        height: 20,
      ),
    ],
  );
}
