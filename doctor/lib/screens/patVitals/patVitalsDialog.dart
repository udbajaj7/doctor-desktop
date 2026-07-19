import 'dart:ui';

import 'package:doctor/Models/PatientModel.dart';
import 'package:doctor/Models/Vital.dart';
import 'package:doctor/Models/VitalsObject.dart';
import 'package:doctor/components/customButton.dart';
import 'package:doctor/components/size_config.dart';
import 'package:doctor/screens/patVitals/components/requests.dart';
import 'package:doctor/screens/prescriptionScreen/components/providers.dart';
import 'package:doctor/screens/prescriptionScreen/components/tagged_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:textfield_tags/textfield_tags.dart';

class PatientVitalsDialog extends StatefulWidget {
  final PatientModel patientModel;
  final int bookingID;
  final Function goBack;
  final BuildContext context;

  const PatientVitalsDialog(
      {Key? key,
      required this.patientModel,
      required this.bookingID,
      required this.context,
      required this.goBack})
      : super(key: key);

  @override
  State<PatientVitalsDialog> createState() => _PatientVitalsDialogState();
}

class _PatientVitalsDialogState extends State<PatientVitalsDialog> {
  TextfieldTagsController symptompsTagsController = TextfieldTagsController();
  TextfieldTagsController diagnosisTagsController = TextfieldTagsController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();
  final TextStyle heading = GoogleFonts.publicSans(
          fontWeight: FontWeight.w500, color: Color(0xFF909090), fontSize: 14),
      subHeading = GoogleFonts.publicSans(
          fontWeight: FontWeight.w500, color: Colors.black, fontSize: 12),
      unit = GoogleFonts.publicSans(
          fontWeight: FontWeight.w500, color: Color(0xFF737373), fontSize: 11),
      value = GoogleFonts.publicSans(
          fontWeight: FontWeight.w500, color: Color(0xFF515151), fontSize: 13);

  String notes = "", clinicalHistory = "";

  List<VitalForUI> vitals = [
    VitalForUI(vitalHeading: "weight", unit: "kg"),
    VitalForUI(vitalHeading: "Height", unit: "cm"),
    VitalForUI(vitalHeading: "Temp", unit: "F"),
    VitalForUI(vitalHeading: "SpO2", unit: "%"),
    VitalForUI(vitalHeading: "BP", unit: "mmHg"),
    VitalForUI(vitalHeading: "Pulse", unit: "bpm"),
  ];

  List<String> symptoms = [], diagnosis = [];

  bool initialized = false;

  late Future getVitalsFuture;

  @override
  void initState() {
    super.initState();
    getVitalsFuture = getVitals(widget.bookingID);
  }

  Column buildClinicalHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: getProportionateScreenWidth(6)),
          child: Text("Clinical History", style: heading),
        ),
        SizedBox(
          height: getProportionateWebScreenHeight(9),
        ),
        Container(
          padding: EdgeInsets.all(getProportionateScreenWidth(8)),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            shadows: [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 20,
                offset: Offset(0, 2),
                spreadRadius: 0,
              )
            ],
          ),
          child: TextFormField(
            initialValue: clinicalHistory,
            maxLines: 4,
            onChanged: (value) => clinicalHistory = value,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              fillColor: Colors.white,
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(
                  left: getProportionateScreenWidth(8),
                  top: getProportionateScreenWidth(8)),
            ),
          ),
        )
      ],
    );
  }

  Column buildNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: getProportionateScreenWidth(6)),
          child: Text("Notes", style: heading),
        ),
        SizedBox(
          height: getProportionateWebScreenHeight(9),
        ),
        Container(
          padding: EdgeInsets.all(getProportionateScreenWidth(8)),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            shadows: [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 20,
                offset: Offset(0, 2),
                spreadRadius: 0,
              )
            ],
          ),
          child: TextFormField(
            initialValue: notes,
            maxLines: 4,
            onChanged: (value) => notes = value,
            cursorColor: Colors.black,
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(
                    left: getProportionateScreenWidth(8),
                    top: getProportionateScreenWidth(8))),
          ),
        )
      ],
    );
  }

  Padding vitalRow(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(4)),
      child: SizedBox(
        width: (MediaQuery.of(context).size.width) * (0.145) * (0.7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: EdgeInsets.only(left: getProportionateScreenWidth(6)),
              child: Text(
                vitals[index].vitalHeading,
                style: subHeading,
              ),
            ),
            SizedBox(
              width:
                  (MediaQuery.of(context).size.width) * (0.145) * (0.3) * (0.7),
              child: TextFormField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                     inputFormatters: <TextInputFormatter>[
                (index == 4)
                    ? FilteringTextInputFormatter.allow(RegExp('[0-9]+|/'))
                    : FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
              ],
                textAlign: TextAlign.center,
                style: value,
                onChanged: (value) => vitals[index].value = value,
                initialValue: vitals[index].value,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFF838383), width: 1))),
              ),
            ),
            Text(vitals[index].unit, style: unit)
          ],
        ),
      ),
    );
  }

  Column buildVitals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: getProportionateScreenWidth(24)),
          child: Text("Vitals", style: heading),
        ),
        SizedBox(
          height: SizeConfig.screenHeight * 0.12,
          child: ListView.separated(
              itemBuilder: (context, index) {
                return vitalRow(index);
              },
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) => SizedBox(
                    height: SizeConfig.screenHeight * 0.12,
                    child: Center(
                      child: Container(
                          color: Color(0xFFE9E9E9),
                          width: getProportionateScreenWidth(2),
                          height: getProportionateScreenHeight(38)),
                    ),
                  ),
              itemCount: vitals.length),
        )
      ],
    );
  }

  Padding titleRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(6)),
      child: Row(
        children: [
          Spacer(),
          Expanded(
            child: Center(
              child: Text(
                "Patient Health Details",
                style: GoogleFonts.publicSans(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    fontSize: 21.58),
              ),
            ),
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.patientModel.firstName,
                style: GoogleFonts.publicSans(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3F3F3F),
                    fontSize: 17),
              ),
              Text(
                widget.patientModel.age.toString() +
                    "/" +
                    widget.patientModel.gender.toUpperCase(),
                style: GoogleFonts.publicSans(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3F3F3F),
                    fontSize: 17),
              ),
            ],
          ))
        ],
      ),
    );
  }

  List<Widget> actionsList() {
    return [
      CustomButton(
          backgroundColor: Color(0xFFF3F3F3),
          onPressed: () => Navigator.pop(context),
          text: "Cancel"),
      SizedBox(
        width: getProportionateScreenWidth(16),
      ),
      CustomButton(
          backgroundColor: Colors.black,
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              String message = "";
              if (notes.isNotEmpty) {
                String output = await addNotes(widget.bookingID, notes);
                if (output == "Error")
                  message += "Error occurred in Adding Notes!";
                else
                  message += "Notes Added Successfully";
              }

              symptoms = symptompsTagsController.getTags ?? [];
              diagnosis = diagnosisTagsController.getTags ?? [];
              _scaffoldKey.currentContext!.loaderOverlay.show();

              saveVitals(
                      widget.bookingID,
                      VitalsObject(
                          clinicalHistory: clinicalHistory,
                          notes: notes,
                          vitals: Vitals(
                              bloodPressure: (vitals[4].value != null &&
                                      vitals[4].value != "")
                                  ? vitals[4].value!
                                  : null,
                              height: (vitals[1].value != null &&
                                      vitals[1].value != "")
                                  ? double.parse(vitals[1].value!)
                                  : null,
                              pulse: (vitals[5].value != null &&
                                      vitals[5].value != "")
                                  ? double.parse(vitals[5].value!)
                                  : null,
                              spo2: (vitals[3].value != null &&
                                      vitals[3].value != "")
                                  ? double.parse(vitals[3].value!)
                                  : null,
                              temperature: (vitals[2].value != null &&
                                      vitals[2].value != "")
                                  ? double.parse(vitals[2].value!)
                                  : null,
                              weight: (vitals[0].value != null &&
                                      vitals[0].value != "")
                                  ? double.parse(vitals[0].value!)
                                  : null),
                          diagnosis: diagnosis,
                          symptoms: symptoms))
                  .then((_value) {
                _scaffoldKey.currentContext!.loaderOverlay.hide();
                Navigator.pop(context);
                if (_value == "Success") {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Vitals updated successfully " +
                          (message != "" ? "& " : "") +
                          message)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          "Vitals could not be updated due to some error" +
                              (message != "" ? "& " : "") +
                              message)));
                }
              });
            }
          },
          text: "Save")
    ];
  }

  List<String> removeEmptyStringsFromList(List<String> list) {
    for (String s in list) {
      if (s.isEmpty) {
        list.remove(s);
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      body: Container(
        margin: EdgeInsets.symmetric(
            horizontal: SizeConfig.screenWidth * 0.15 * (0.7)),
        child: FutureBuilder(
            future: getVitalsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                if (!initialized) {
                  VitalsObject vitalsObject = snapshot.data as VitalsObject;
                  if (vitalsObject.vitals != null) {
                    vitals[5].value =
                        (vitalsObject.vitals!.pulse ?? "").toString();
                    vitals[4].value =
                        (vitalsObject.vitals!.bloodPressure ?? "").toString();
                    // if (vitals[4].value != "" && vitals[4].value!.length == 5) {
                    //   String s = vitals[4].value!.substring(0, 3),
                    //       a = vitals[4].value!.substring(3, 5);
                    //   vitals[4].value = s + '/' + a;
                    // }
                    vitals[2].value =
                        (vitalsObject.vitals!.temperature ?? "").toString();
                    vitals[3].value =
                        (vitalsObject.vitals!.spo2 ?? "").toString();
                    vitals[1].value =
                        (vitalsObject.vitals!.height ?? "").toString();
                    vitals[0].value =
                        (vitalsObject.vitals!.weight ?? "").toString();
                  }
                  symptoms = vitalsObject.symptoms!;
                  diagnosis = vitalsObject.diagnosis!;
                  notes = vitalsObject.notes ?? "";
                  clinicalHistory = vitalsObject.clinicalHistory ?? "";
                  initialized = true;
                  print('check this out $symptoms');
                  print('$diagnosis');
                }

                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: AlertDialog(
                    title: titleRow(),
                    content: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.01),
                          child: Column(
                            children: [
                              SizedBox(
                                  height: SizeConfig.screenHeight * 0.16,
                                  width: MediaQuery.of(context).size.width *
                                      0.98 *
                                      (0.7),
                                  child: buildVitals()),
                              SizedBox(
                                  height: getProportionateScreenHeight(16)),
                              SymptomsDiagnosisFromSharedPrefWidget(
                                initialDiagnosis:
                                    removeEmptyStringsFromList(diagnosis),
                                initialSymptoms:
                                    removeEmptyStringsFromList(symptoms),
                                diagnosisTagsController:
                                    diagnosisTagsController,
                                symptompsTagsController:
                                    symptompsTagsController,
                              ),
                              SizedBox(
                                  height: getProportionateScreenHeight(16)),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.42 *
                                                (0.7),
                                        child: buildClinicalHistory()),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.42 *
                                                (0.7),
                                        child: buildNotes())
                                  ]),
                            ],
                          ),
                        ),
                      ),
                    ),
                    actions: actionsList(),
                    actionsAlignment: MainAxisAlignment.center,
                  ),
                );
              } else {
                return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Center(
                        child: SpinKitPouringHourGlass(color: Colors.grey)));
              }
            }),
      ),
    );
  }
}

class SymptomsDiagnosisFromSharedPrefWidget extends ConsumerWidget {
  final List<String> initialSymptoms;
  final List<String> initialDiagnosis;
  final TextfieldTagsController symptompsTagsController;
  final TextfieldTagsController diagnosisTagsController;
  const SymptomsDiagnosisFromSharedPrefWidget({
    Key? key,
    required this.diagnosisTagsController,
    required this.symptompsTagsController,
    required this.initialDiagnosis,
    required this.initialSymptoms,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.42 * (0.7),
          child: CustomTaggedTextFieldWidget(
            title: 'Symptoms',
            textfieldTagsController: symptompsTagsController,
            searchTags: globalMedicineDataModel.symptoms,
            initialTags: initialSymptoms,
            hintText: 'Add Symptoms',
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.42 * (0.7),
          child: CustomTaggedTextFieldWidget(
            title: 'Diagnosis',
            textfieldTagsController: diagnosisTagsController,
            searchTags: globalMedicineDataModel.diagnosis,
            initialTags: initialDiagnosis,
            hintText: 'Add Diagnosis',
          ),
        )
      ],
    );
  }
}
