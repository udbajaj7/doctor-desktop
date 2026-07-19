import 'package:doctor/Models/MedicineDetailsModel.dart';
import 'package:doctor/Models/PatientModel.dart';
import 'package:doctor/Models/PrescriptionModel.dart';
import 'package:doctor/Models/VitalModel.dart';
import 'package:doctor/components/size_config.dart';
import 'package:doctor/screens/prescriptionScreen/components/constants.dart';
import 'package:doctor/screens/prescriptionScreen/components/medice_table_widgets.dart';
import 'package:doctor/screens/prescriptionScreen/components/providers.dart';
import 'package:doctor/screens/prescriptionScreen/components/requests.dart';
import 'package:doctor/screens/prescriptionScreen/components/tagged_textfield.dart';
import 'package:doctor/screens/prescriptionScreen/prescreptionScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class PrescriptionScreenTwo extends ConsumerStatefulWidget {
  final PatientModel patient;
  final int bookingId;
  const PrescriptionScreenTwo(
      {Key? key, required this.patient, required this.bookingId})
      : super(key: key);

  @override
  ConsumerState<PrescriptionScreenTwo> createState() =>
      _PrescriptionScreenTwoState();
}

class _PrescriptionScreenTwoState extends ConsumerState<PrescriptionScreenTwo> {
  void rebuildPrescriptionScreen() {
    setState(() {});
  }

  List<String> removeEmptyStringFromList(List<String> list) {
    List<String> newList = [];
    for (String item in list) {
      if (item != '') {
        newList.add(item);
      }
    }
    return newList;
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(getCurrentPrecriptionProvider(widget.bookingId)).when(
      data: (data) {
        print('this is the data for getCurrentPatient $data');

        return Center(
          child: PrescriptionScreenBodyTwo(
            patient: widget.patient,
            prescription: data,
            disableNextButton: true,
            bookingId: widget.bookingId,
          ),
        );
      },
      error: (e, s) {
        return Center(
          child: Text(
            e.toString() + '\n' + s.toString(),
          ),
        );
      },
      loading: () {
        return SizedBox(
          child: Center(
            child: SpinKitPouringHourGlass(
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }
}

final double innerPadding = getProportionateWebScreenWidth(150);

class PrescriptionScreenBodyTwo extends ConsumerWidget {
  final int bookingId;
  final PatientModel patient;
  final PrescriptionModel prescription;
  final bool disableNextButton;
  const PrescriptionScreenBodyTwo(
      {Key? key,
      required this.patient,
      required this.prescription,
      required this.bookingId,
      required this.disableNextButton})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    print(' PrescriptionScreenBody Widget Rebuild happend');
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyM): () {
          print('shortcut detected');
          addCustomMedicine(
            context,
            ref,
          );
        }
      },
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            top: getProportionateWebScreenHeight(39),
            left: getProportionateWebScreenWidth(49),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: getProportionateWebScreenHeight(40),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PrescriptionScreenAppBarTwo(
                    name: patient.firstName +
                        ' ' +
                        patient.lastName +
                        ' (${patient.id})',
                  ),
                  SizedBox(
                    height: getProportionateWebScreenHeight(24),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: innerPadding,
                    ),
                    child: Text(
                      'Vitals',
                      style: GoogleFonts.publicSans(
                        color: Color(0xFF909090),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: getProportionateWebScreenHeight(14),
                  ),
                  FocusTraversalGroup(
                    policy: OrderedTraversalPolicy(),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: innerPadding,
                      ),
                      child: VitalsWidget(
                        vitals: prescription.vitals,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: getProportionateWebScreenHeight(40),
                  ),
                  FocusTraversalGroup(
                    policy: OrderedTraversalPolicy(),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: innerPadding,
                      ),
                      child: CustomTagsWidget(
                        initialDiagnosticTags: prescription.diagnosis,
                        initialSymptomsTags: prescription.symptoms,
                        symptomsTags: globalMedicineDataModel.symptoms,
                        diagnosisTags: globalMedicineDataModel.diagnosis,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: getProportionateWebScreenHeight(30),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: innerPadding,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Medicine',
                          style: GoogleFonts.publicSans(
                            color: Color(0xFF909090),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          width: getProportionateWebScreenWidth(720),
                        ),
                        AddCustomMedicineWidget(),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: getProportionateWebScreenHeight(10),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: innerPadding,
                      ),
                      child: MedicineTableWidget2(
                        key: ValueKey(ref.watch(rebuildMedicineTableProvider)),
                        medicines: globalMedicineDataModel.medicines,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: getProportionateWebScreenHeight(40),
                  ),
                  FocusTraversalGroup(
                      policy: OrderedTraversalPolicy(),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: innerPadding,
                        ),
                        child: TestsAndNextVisitRow(
                          testsTags: globalMedicineDataModel.tests,
                          initialTestTags: prescription.tests,
                        ),
                      )),
                  SizedBox(
                    height: getProportionateWebScreenHeight(40),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: getProportionateWebScreenWidth(85),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SaveTemplateButton(
                          age: patient.age,
                          gender: patient.gender,
                        ),
                        PrintButton(
                          id: patient.id.toString(),
                          name: patient.firstName + ' ' + patient.lastName,
                          age: patient.age.toString(),
                          gender: patient.gender,
                          phone: patient.phoneNumber,
                        ),
                        SaveButtonTwo(
                          bookingId: bookingId,
                          previousPrescription: prescription,
                        ),
                        const CancelButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SaveButtonTwo extends ConsumerStatefulWidget {
  final int bookingId;
  final PrescriptionModel previousPrescription;
  const SaveButtonTwo(
      {Key? key, required this.bookingId, required this.previousPrescription})
      : super(key: key);

  @override
  ConsumerState<SaveButtonTwo> createState() => _SaveButtonTwoState();
}

class _SaveButtonTwoState extends ConsumerState<SaveButtonTwo> {
  bool showLoader = false;

  bool areVitalsSame(Map<String, dynamic> vitals) {
    if (vitals['weight'] != widget.previousPrescription.vitals.weight) {
      return false;
    }
    if (vitals['height'] != widget.previousPrescription.vitals.height) {
      return false;
    }
    if (vitals['temperature'] !=
        widget.previousPrescription.vitals.temperature) {
      return false;
    }
    if (vitals['bloodPressure'] != widget.previousPrescription.vitals.bp) {
      return false;
    }
    if (vitals['pulse'] != widget.previousPrescription.vitals.pulse) {
      return false;
    }
    if (vitals['spo2'] != widget.previousPrescription.vitals.spo2) {
      return false;
    }
    return true;
  }

  bool areMedicinesSames(List<MedicineDetailsModel> medicines) {
    if (medicines.length > 0 &&
        medicines.last.name == ConstantsForPrescriptionScreen.unSelectedTag) {
      medicines.removeLast();
    }

    if (medicines.length != widget.previousPrescription.medicines.length) {
      print('okay');
      return false;
    }

    for (int i = 0; i < medicines.length; i++) {
      print('this');

      if (medicines[i].name != widget.previousPrescription.medicines[i].name) {
        return false;
      }
      if (medicines[i].type != widget.previousPrescription.medicines[i].type) {
        return false;
      }
      if (medicines[i].when != widget.previousPrescription.medicines[i].when) {
        return false;
      }
      if (medicines[i].duration !=
          widget.previousPrescription.medicines[i].duration) {
        return false;
      }
      if (medicines[i].dose != widget.previousPrescription.medicines[i].dose) {
        return false;
      }
      if (medicines[i].saltComposition !=
          widget.previousPrescription.medicines[i].saltComposition) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (!showLoader) {
          setState(() {
            showLoader = true;
          });
          Map<String, dynamic> vitals = {
            'weight': (ref.read(weightProvider)),
            'height': (ref.read(heightProvider)),
            'temperature': (ref.read(temperatureProvider)),
            'bloodPressure': (ref.read(bloodPressureProvider)),
            'pulse': (ref.read(pulseProvider)),
            'spo2': (ref.read(spo2Provider)),
          };

          List currentMeds = ref.read(medicineDetailsListProvider);
          List<MedicineDetailsModel> copyOfCurrentMeds = [];
          currentMeds.forEach((element) {
            copyOfCurrentMeds.add(element);
          });

          //compate new prescription with previous one
          bool areVitalsSamee = areVitalsSame(vitals);
          bool areSymptomsSame =
              (symptomsTextfieldTagsControler.getTags ?? []).join(',') ==
                  widget.previousPrescription.symptoms.join(',');
          bool areDiagnosisSame =
              (diagnosisTextfieldTagsControler.getTags ?? []).join(',') ==
                  widget.previousPrescription.diagnosis.join(',');
          bool areTestsSame =
              (testsTextfieldTagsControler.getTags ?? []).join(',') ==
                  widget.previousPrescription.tests.join(',');
          bool areClinicalHistorySame = clinicalHistoryController.text ==
              widget.previousPrescription.clinicalHistory;
          bool areNotesSame =
              notesController.text == widget.previousPrescription.notes;
          bool areMedicinesSame = areMedicinesSames(copyOfCurrentMeds);

          print('checking for changes');
          print('areVitalsSamee $areVitalsSamee');
          print('areSymptomsSame $areSymptomsSame');
          print('areDiagnosisSame $areDiagnosisSame');
          print('areTestsSame $areTestsSame');
          print('areClinicalHistorySame $areClinicalHistorySame');
          print('areNotesSame $areNotesSame');
          print('areMedicinesSame $areMedicinesSame');
          print(
              'symptomsTextfieldTagsControler.getTags ${symptomsTextfieldTagsControler.getTags}');
          print(
              'diagnosisTextfieldTagsControler.getTags ${diagnosisTextfieldTagsControler.getTags}');
          print(
              'testsTextfieldTagsControler.getTags ${testsTextfieldTagsControler.getTags}');

          List x = copyOfCurrentMeds;
          for (int i = 0; i < x.length; i++) {
            print(x[i].toJson());
            print(x.first.name);
            print(x.first.name.length);
          }

          if (areVitalsSamee &&
              areSymptomsSame &&
              areDiagnosisSame &&
              areTestsSame &&
              areClinicalHistorySame &&
              areNotesSame &&
              areMedicinesSame) {
            SnackBar snackBar = SnackBar(
              content: Text('No changes made'),
              backgroundColor: Colors.red,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            setState(() {
              showLoader = false;
            });
            return;
          }
          int statusCode = await savePrescreption(
            bookingId: widget.bookingId,
            vitals: vitals,
            clinicalHistory: clinicalHistoryController.text,
            notes: notesController.text,
            symptoms: symptomsTextfieldTagsControler.getTags ?? [],
            diagnosis: diagnosisTextfieldTagsControler.getTags ?? [],
            tests: testsTextfieldTagsControler.getTags ?? [],
            nextVisit: ref.read(nextVisitProvider),
            medicines: copyOfCurrentMeds,
          );
          setState(() {
            showLoader = false;
          });
          if (statusCode == 200) {
            SnackBar snackBar = SnackBar(
              content: Text('Prescription Saved Successfully'),
              backgroundColor: Colors.green,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);

            notesController.clear();
            diagnosisTextfieldTagsControler.clearTags();
            symptomsTextfieldTagsControler.clearTags();
            testsTextfieldTagsControler.clearTags();

            ref.read(nextVisitProvider.notifier).update((state) => '');

            ref.read(medicineDetailsListProvider.notifier).update((state) {
              MedicineDetailsModel firstElement = MedicineDetailsModel(
                type: '',
                name: ConstantsForPrescriptionScreen.unSelectedTag,
                when: ConstantsForPrescriptionScreen.whenList.first,
                duration: ConstantsForPrescriptionScreen.durationList.first,
                dose: ConstantsForPrescriptionScreen.dosageList.first,
                saltComposition:
                    ConstantsForPrescriptionScreen.saltCompositionValue,
              );
              return [firstElement];
            });

            Navigator.of(context).pop();
          } else {
            SnackBar snackBar = SnackBar(
              content: Text('Prescription Not Saved'),
              backgroundColor: Colors.red,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        }
      },
      child: Center(
        child: Container(
          height: getProportionateWebScreenHeight(47),
          width: getProportionateWebScreenWidth(160),
          color: Color(0xFFF3F3F3),
          child: Center(
            child: (showLoader)
                ? SpinKitPouringHourGlass(
                    color: Colors.grey,
                  )
                : Text(
                    'Save',
                    style: GoogleFonts.publicSans(
                      color: Color(0xFF5B5B5B),
                      fontSize: 15.58,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class PrescriptionScreenAppBarTwo extends ConsumerWidget {
  final String name;
  const PrescriptionScreenAppBarTwo({Key? key, required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back,
            color: Color(0xFF5B5B5B),
          ),
        ),
        Text(
          'Prescription',
          style: GoogleFonts.publicSans(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.black.withOpacity(0.8),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: getProportionateWebScreenWidth(150)),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Icon(
              Icons.account_circle,
              color: Color(0xFF5B5B5B),
            ),
            SizedBox(
              width: getProportionateWebScreenWidth(6),
            ),
            Text(
              name,
              textAlign: TextAlign.left,
              style: GoogleFonts.publicSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5B5B5B),
              ),
            ),
          ]),
        )
      ],
    );
  }
}
