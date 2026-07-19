import 'package:doctor/Models/MedicineDetailsModel.dart';
import 'package:doctor/Models/PatientModel.dart';
import 'package:doctor/Models/PrescPrintRatioModel.dart';
import 'package:doctor/Models/PrescriptionModel.dart';
import 'package:doctor/Models/VitalModel.dart';
import 'package:doctor/components/size_config.dart';
import 'package:doctor/components/urls.dart';
import 'package:doctor/screens/allPatientScreen/components/editPat.dart';
import 'package:doctor/screens/prescriptionScreen/components/constants.dart';
import 'package:doctor/screens/prescriptionScreen/components/printing.dart';
import 'package:doctor/screens/prescriptionScreen/components/providers.dart';
import 'package:doctor/screens/prescriptionScreen/components/requests.dart';
import 'package:doctor/screens/prescriptionScreen/components/tagged_textfield.dart';
import 'package:doctor/screens/prescriptionScreen/components/medice_table_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class PrescriptionScreen extends ConsumerStatefulWidget {
  final disableNextButton;
  const PrescriptionScreen({Key? key, this.disableNextButton = false})
      : super(key: key);

  @override
  ConsumerState<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends ConsumerState<PrescriptionScreen> {
  late Future getPrintRatiosFuture;
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
    return ref.watch(getCurrentPatientProvider).when(
      data: (data) {
        print('this is the data for getCurrentPatient $data');
        // print(data['pats'][0].toJson());
        // print(data['books'][0].toJson());

        if (data.first['pats'].isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No Patient Currently',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: getProportionateWebScreenHeight(25),
                ),
                SendNextPatientButton(),
              ],
            ),
          );
        }

        return PrescriptionScreenBody(
          key: ValueKey(data.first['pats'][0].id),
          patient: data.first['pats'][0] as PatientModel,
          prescriptionModel: data[1],
          disableNextButton: widget.disableNextButton,
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
        return Container(
          padding: EdgeInsets.only(
            top: getProportionateWebScreenHeight(50),
            left: getProportionateWebScreenWidth(30),
          ),
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

class PrescriptionScreenBody extends ConsumerStatefulWidget {
  final PatientModel patient;

  final bool disableNextButton;
  final PrescriptionModel prescriptionModel;
  const PrescriptionScreenBody({
    Key? key,
    required this.patient,
    required this.disableNextButton,
    required this.prescriptionModel,
  }) : super(key: key);

  @override
  ConsumerState<PrescriptionScreenBody> createState() =>
      _PrescriptionScreenBodyState();
}

class _PrescriptionScreenBodyState
    extends ConsumerState<PrescriptionScreenBody> {

  void onPatientDetailsEditComplete() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
            return CallbackShortcuts(
              bindings: <ShortcutActivator, VoidCallback>{
                LogicalKeySet(
                    LogicalKeyboardKey.control, LogicalKeyboardKey.keyM): () {
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
                          PrescreptionScreenAppBar(
                            patient: widget.patient,
                            onRefresh: onPatientDetailsEditComplete,
                          ),
                          SizedBox(
                            height: getProportionateWebScreenHeight(24),
                          ),
                          Text(
                            'Vitals',
                            style: GoogleFonts.publicSans(
                              color: Color(0xFF909090),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: getProportionateWebScreenHeight(14),
                          ),
                          FocusTraversalGroup(
                            policy: OrderedTraversalPolicy(),
                            child: VitalsWidget(
                              vitals: widget.prescriptionModel.vitals,
                            ),
                          ),
                          SizedBox(
                            height: getProportionateWebScreenHeight(40),
                          ),
                          FocusTraversalGroup(
                            policy: OrderedTraversalPolicy(),
                            child: CustomTagsWidget(
                              initialDiagnosticTags:
                                  widget.prescriptionModel.diagnosis,
                              initialSymptomsTags:
                                  widget.prescriptionModel.symptoms,
                              symptomsTags: globalMedicineDataModel.symptoms,
                              diagnosisTags: globalMedicineDataModel.diagnosis,
                            ),
                          ),
                          SizedBox(
                            height: getProportionateWebScreenHeight(30),
                          ),
                          Row(
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
                                width: getProportionateWebScreenWidth(700),
                              ),
                              AddCustomMedicineWidget(),
                            ],
                          ),
                          SizedBox(
                            height: getProportionateWebScreenHeight(10),
                          ),
                          Center(
                            child: MedicineTableWidget2(
                              key: ValueKey(
                                  ref.watch(rebuildMedicineTableProvider)),
                              medicines: globalMedicineDataModel.medicines,
                            ),
                          ),
                          SizedBox(
                            height: getProportionateWebScreenHeight(40),
                          ),
                          FocusTraversalGroup(
                              policy: OrderedTraversalPolicy(),
                              child: TestsAndNextVisitRow(
                                testsTags: globalMedicineDataModel.tests,
                                initialTestTags: widget.prescriptionModel.tests,
                              )),
                          SizedBox(
                            height: getProportionateWebScreenHeight(40),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SaveTemplateButton(
                                age: widget.patient.age,
                                gender: widget.patient.gender,
                              ),
                              PrintButton(
                                id: widget.patient.id.toString(),
                                name: widget.patient.firstName +
                                    ' ' +
                                    widget.patient.lastName,
                                age: widget.patient.age.toString(),
                                gender: widget.patient.gender,
                                phone: widget.patient.phoneNumber,
                              ),
                              SaveButton(
                                previousPrescription: widget.prescriptionModel,
                              ),
                              (widget.disableNextButton)
                                  ? const CancelButton()
                                  : NextButton(
                                      previousPrescription:
                                          widget.prescriptionModel,
                                    ),
                              const NextPatientInfoWidget(),
                            ],
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

class PrescreptionScreenAppBar extends ConsumerWidget {
  final PatientModel patient;
  final Function onRefresh;
  final bool showBackButton;
  const PrescreptionScreenAppBar({
    Key? key,
    required this.patient,
    required this.onRefresh,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.account_circle,
                color: Color(0xFF5B5B5B),
              ),
              SizedBox(
                width: getProportionateWebScreenWidth(6),
              ),
              Text(
                '${patient.firstName + ' ' + patient.lastName + ' (${patient.id})'}\n${patient.age}/${patient.gender.toUpperCase()}',
                textAlign: TextAlign.left,
                style: GoogleFonts.publicSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5B5B5B),
                ),
              ),
              SizedBox(
                width: getProportionateWebScreenWidth(6),
              ),
              InkWell(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => EditPatAlertDialog(
                    showAddPatientScreen: (AddPatientModel) {},
                    patientModel: patient,
                    refresh: onRefresh,
                  ),
                ),
                child: const Icon(
                  Icons.edit,
                  size: 18,
                  color: Colors.black,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class VitalsWidget extends StatelessWidget {
  final VitalsModel vitals;
  const VitalsWidget({Key? key, required this.vitals}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomInputWidget(
          text: 'Weight',
          unit: 'Kg',
          provider: weightProvider,
          autoFocus: true,
          initialValue: vitals.weight,
        ),
        SizedBox(
          width: getProportionateWebScreenWidth(18),
        ),
        CustomInputWidget(
          text: 'Height',
          unit: 'cm',
          provider: heightProvider,
          initialValue: vitals.height,
        ),
        SizedBox(
          width: getProportionateWebScreenWidth(18),
        ),
        CustomInputWidget(
          text: 'Temperature',
          unit: 'F',
          provider: temperatureProvider,
          initialValue: vitals.temperature,
        ),
        SizedBox(
          width: getProportionateWebScreenWidth(18),
        ),
        CustomInputWidget(
          text: 'SpO2',
          unit: '%',
          provider: spo2Provider,
          initialValue: vitals.spo2,
        ),
        SizedBox(
          width: getProportionateWebScreenWidth(18),
        ),
        CustomInputWidget(
          text: 'Blood Pressure',
          unit: 'mm/Hg',
          provider: bloodPressureProvider,
          isBloodPressure: true,
          initialValue: vitals.bp,
        ),
        SizedBox(
          width: getProportionateWebScreenWidth(18),
        ),
        CustomInputWidget(
          text: 'Pulse',
          unit: 'bpm',
          provider: pulseProvider,
          initialValue: vitals.pulse,
        ),
      ],
    );
  }
}

class CustomInputWidget extends ConsumerWidget {
  final String text, unit;
  final bool? autoFocus;
  final String initialValue;
  final StateProvider<String> provider;
  final bool isBloodPressure;
  const CustomInputWidget(
      {Key? key,
      required this.text,
      required this.unit,
      required this.provider,
      required this.initialValue,
      this.isBloodPressure = false,
      this.autoFocus})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: GoogleFonts.publicSans(
              color: Color(0xFF212121),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          height: getProportionateWebScreenHeight(30),
          width: isBloodPressure
              ? getProportionateWebScreenWidth(90)
              : getProportionateWebScreenWidth(60),
          padding: EdgeInsets.only(bottom: getProportionateWebScreenHeight(8)),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Colors.black,
                width: 1,
              ),
            ),
          ),
          child: Center(
            child: TextFormField(
              initialValue: initialValue,
              autofocus: autoFocus ?? false,
              cursorColor: Colors.black,
              textAlign: TextAlign.center,
              inputFormatters: <TextInputFormatter>[
                (isBloodPressure)
                    ? FilteringTextInputFormatter.allow(RegExp('[0-9]+|/'))
                    : FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
              ],
              decoration: InputDecoration(border: InputBorder.none),
              onChanged: (String value) {
                ref.read(provider.notifier).state = value;
              },
            ),
          ),
        ),
        SizedBox(
          width: getProportionateWebScreenWidth(8),
        ),
        Text(
          unit,
          style: GoogleFonts.publicSans(
            color: Color(0xFF737373),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class SaveButton extends ConsumerStatefulWidget {
  final int bookingId;
  final PrescriptionModel previousPrescription;
  const SaveButton(
      {Key? key, this.bookingId = 0, required this.previousPrescription})
      : super(key: key);

  @override
  ConsumerState<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends ConsumerState<SaveButton> {
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
    if (medicines.last.name == ConstantsForPrescriptionScreen.unSelectedTag) {
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

  void updateGlobalMedicneVariable(List<MedicineDetailsModel> meds) {
    meds.forEach((ele) {
      int index = globalMedicineDataModel.medicines
          .indexWhere((element) => element.name == ele.name);

      globalMedicineDataModel.medicines[index].dose = ele.dose;
      globalMedicineDataModel.medicines[index].duration = ele.duration;
      globalMedicineDataModel.medicines[index].when = ele.when;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
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

        try {
          int statusCode = await savePrescreption(
            bookingId: (widget.bookingId == 0)
                ? ref.read(bookingIdProvider) ?? 100
                : widget.bookingId,
            vitals: vitals,
            clinicalHistory: clinicalHistoryController.text,
            notes: notesController.text,
            symptoms: symptomsTextfieldTagsControler.getTags ?? [],
            diagnosis: diagnosisTextfieldTagsControler.getTags ?? [],
            tests: testsTextfieldTagsControler.getTags ?? [],
            nextVisit: ref.read(nextVisitProvider),
            medicines: copyOfCurrentMeds,
          );

          if (statusCode == 200) {
            updateGlobalMedicneVariable(copyOfCurrentMeds);
            SnackBar snackBar = SnackBar(
              content: Text('Prescription Saved Successfully'),
              backgroundColor: Colors.green,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            ref
                .read(isPrescriptionSavedProvider.notifier)
                .update((state) => true);
          } else {
            SnackBar snackBar = SnackBar(
              content: Text('Prescription Not Saved'),
              backgroundColor: Colors.red,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        } catch (e, s) {
          print('error in saving prescription $e');
          print('stackTrace $s');
        }
        setState(() {
          showLoader = false;
        });
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

class CancelButton extends ConsumerWidget {
  const CancelButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
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
      },
      child: Center(
        child: Container(
          height: getProportionateWebScreenHeight(47),
          width: getProportionateWebScreenWidth(160),
          color: Color(0xffE96363),
          child: Center(
            child: Text(
              'Cancel',
              style: GoogleFonts.publicSans(
                color: Color.fromARGB(255, 255, 255, 255),
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

class PrintButton extends ConsumerWidget {
  final String id, name, age, gender, phone;
  const PrintButton(
      {Key? key,
      required this.id,
      required this.name,
      required this.age,
      required this.gender,
      required this.phone})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        List x = ref.read(medicineDetailsListProvider);
        for (int i = 0; i < x.length; i++) {
          print(x[i].toJson());
          print(x.first.name);
          print(x.first.name.length);
        }
        Map<String, String> vitals = {
          'weight': ref.read(weightProvider.notifier).state,
          'height': ref.read(heightProvider.notifier).state,
          'temperature': ref.read(temperatureProvider.notifier).state,
          'bloodPressure': ref.read(bloodPressureProvider.notifier).state,
          'pulse': ref.read(pulseProvider.notifier).state,
          'spo2': ref.read(spo2Provider.notifier).state,
        };
        printPdf(
            id: id,
            name: name,
            age: age,
            gender: gender,
            phone: phone,
            clinicalHistory: clinicalHistoryController.text,
            notes: notesController.text,
            nextVisit: ref.read(nextVisitProvider),
            symptoms: symptomsTextfieldTagsControler.getTags ?? [],
            diagnosis: diagnosisTextfieldTagsControler.getTags ?? [],
            tests: testsTextfieldTagsControler.getTags ?? [],
            vitals: vitals,
            medications: ref.read(medicineDetailsListProvider),
            prescPrintRatios: myPrescriptionRatios);
            
      },
      child: Container(
        width: getProportionateWebScreenWidth(158.25),
        height: getProportionateWebScreenHeight(47.95),
        decoration: ShapeDecoration(
          color: Color(0xFFF3F3F3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1.20),
          ),
        ),
        child: Center(
          child: Text(
            'Print',
            style: GoogleFonts.publicSans(
              color: Color(0xFF5B5B5B),
              fontSize: 15.58,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showPreviousPrescription(
    BuildContext context, int boookingId) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        surfaceTintColor: Colors.transparent,
        title: const Text('Prescribed Medications'),
        content: SingleChildScrollView(
          child: CurrentPrescriptionWidget(
            bookingId: boookingId,
          ),
        ),
      );
    },
  );
}

class CurrentPrescriptionWidget extends ConsumerWidget {
  final int bookingId;
  const CurrentPrescriptionWidget({
    Key? key,
    required this.bookingId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(getCurrentPrecriptionProvider(bookingId)).when(
        data: (data) {
      print('this is the data for getCurrentPrecription ${data.toJson()}');
      if (data.medicines.isEmpty) {
        return SizedBox(
          height: getProportionateWebScreenHeight(100),
          width: getProportionateWebScreenWidth(100),
          child: Center(
            child: Text('No Previous Prescription'),
          ),
        );
      }

      return Container(
        color: Color.fromRGBO(255, 255, 255, 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            MedicineTableWidgetStateless(
              medicines: data.medicines,
            ),
            SizedBox(
              height: getProportionateWebScreenHeight(40),
            ),
            (data.symptoms.isEmpty)
                ? SizedBox.shrink()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Symptoms: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        width: getProportionateWebScreenWidth(700),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: getProportionateWebScreenHeight(100),
                            minHeight: getProportionateWebScreenHeight(0),
                            maxWidth: getProportionateWebScreenWidth(700),
                            minWidth: getProportionateWebScreenWidth(700),
                          ),
                          child: Text(
                            data.symptoms.join(', '),
                            // 'aj;kasdjfjas;ldfjkqwajs;dklfjaskldfjowiureiweuprioweurdjafs;lkjfwpouerqiowperupoijflkas;djfl;kasdjfjas;ldfjkqw',
                            maxLines: 6,
                            overflow: TextOverflow.visible,
                            style: DefaultTextStyle.of(context).style.copyWith(
                                  color: const Color.fromARGB(255, 73, 72, 72),
                                  fontSize: 16,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
            SizedBox(
              height: getProportionateWebScreenHeight(12),
            ),
            (data.tests.isEmpty)
                ? SizedBox.shrink()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tests: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        width: getProportionateWebScreenWidth(700),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: getProportionateWebScreenHeight(100),
                            minHeight: getProportionateWebScreenHeight(0),
                            maxWidth: getProportionateWebScreenWidth(700),
                            minWidth: getProportionateWebScreenWidth(700),
                          ),
                          child: Text(
                            data.tests.join(', '),
                            maxLines: 6,
                            overflow: TextOverflow.visible,
                            style: DefaultTextStyle.of(context).style.copyWith(
                                  color: const Color.fromARGB(255, 73, 72, 72),
                                  fontSize: 16,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
            SizedBox(
              height: getProportionateWebScreenHeight(12),
            ),
            (data.diagnosis.isEmpty)
                ? SizedBox.shrink()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Diagnosis: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        width: getProportionateWebScreenWidth(700),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: getProportionateWebScreenHeight(100),
                            minHeight: getProportionateWebScreenHeight(0),
                            maxWidth: getProportionateWebScreenWidth(700),
                            minWidth: getProportionateWebScreenWidth(700),
                          ),
                          child: Text(
                            data.diagnosis.join(', '),
                            maxLines: 6,
                            overflow: TextOverflow.visible,
                            style: DefaultTextStyle.of(context).style.copyWith(
                                  color: const Color.fromARGB(255, 73, 72, 72),
                                  fontSize: 16,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
            SizedBox(
              height: getProportionateWebScreenHeight(12),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Visit: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  width: getProportionateWebScreenWidth(700),
                  child: Text(
                    data.nextVisit ?? 'Not given',
                    maxLines: 6,
                    overflow: TextOverflow.visible,
                    style: DefaultTextStyle.of(context).style.copyWith(
                          color: const Color.fromARGB(255, 73, 72, 72),
                          fontSize: 16,
                        ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: getProportionateWebScreenHeight(20),
            ),
          ],
        ),
      );
    }, error: (e, s) {
      return SizedBox(
        height: getProportionateWebScreenHeight(100),
        width: getProportionateWebScreenWidth(100),
        child: Center(
          child: Text('No Previous Prescription'),
        ),
      );
    }, loading: () {
      return Center(
        child: SpinKitPouringHourGlass(color: Colors.grey),
      );
    });
  }
}

class NextButton extends ConsumerStatefulWidget {
  final PrescriptionModel previousPrescription;
  const NextButton({Key? key, required this.previousPrescription})
      : super(key: key);

  @override
  ConsumerState<NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends ConsumerState<NextButton> {
  bool showLoader = false;
  bool disableButton = false;

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
    if (medicines.last.name == ConstantsForPrescriptionScreen.unSelectedTag) {
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

  void updateGlobalMedicneVariable(List<MedicineDetailsModel> meds) {
    meds.forEach((ele) {
      int index = globalMedicineDataModel.medicines
          .indexWhere((element) => element.name == ele.name);

      globalMedicineDataModel.medicines[index].dose = ele.dose;
      globalMedicineDataModel.medicines[index].duration = ele.duration;
      globalMedicineDataModel.medicines[index].when = ele.when;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (disableButton)
          ? () {
              print('Button is disabled');
              return;
            }
          : () async {
              bool saveApi = false;
              bool sendNextApi = false;
              setState(() {
                showLoader = true;
                disableButton = true;
              });

              try {
                List currentMeds = ref.read(medicineDetailsListProvider);
                List<MedicineDetailsModel> copyOfCurrentMeds = [];
                currentMeds.forEach((element) {
                  copyOfCurrentMeds.add(element);
                });

                Map<String, dynamic> vitals = {
                  'weight': (ref.read(weightProvider)),
                  'height': (ref.read(heightProvider)),
                  'temperature': (ref.read(temperatureProvider)),
                  'bloodPressure': (ref.read(bloodPressureProvider)),
                  'pulse': (ref.read(pulseProvider)),
                  'spo2': (ref.read(spo2Provider)),
                };

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
                    disableButton = false;
                  });
                  return;
                }

                int statusCode = await savePrescreption(
                  bookingId: ref.read(bookingIdProvider) ?? 100,
                  vitals: vitals,
                  clinicalHistory: clinicalHistoryController.text,
                  notes: notesController.text,
                  symptoms: symptomsTextfieldTagsControler.getTags ?? [],
                  diagnosis: diagnosisTextfieldTagsControler.getTags ?? [],
                  tests: testsTextfieldTagsControler.getTags ?? [],
                  nextVisit: ref.read(nextVisitProvider),
                  medicines: copyOfCurrentMeds,
                );

                if (statusCode == 200) {
                  saveApi = true;
                  ref
                      .read(isPrescriptionSavedProvider.notifier)
                      .update((state) => true);
                } else {
                  SnackBar snackBar = SnackBar(
                    content: Text('Prescription Not Saved'),
                    backgroundColor: Colors.red,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  return;
                }
              } catch (e, s) {
                print('error in saving prescription $e');
                print('stackTrace $s');
                return;
              }
              bool prescriptionSaved = ref.read(isPrescriptionSavedProvider);

              if (prescriptionSaved) {
                int statusCode =
                    await sendNextPatient(ref.read(bookingIdProvider));
                ref.invalidate(getCurrentPatientProvider);

                if (statusCode == 200) {
                  sendNextApi = true;
                  clinicalHistoryController.clear();
                  notesController.clear();
                  diagnosisTextfieldTagsControler.clearTags();
                  symptomsTextfieldTagsControler.clearTags();
                  testsTextfieldTagsControler.clearTags();

                  ref.read(nextVisitProvider.notifier).update((state) => '');

                  ref.refresh(nextPatientInfoProvider);

                  ref
                      .read(medicineDetailsListProvider.notifier)
                      .update((state) {
                    updateGlobalMedicneVariable(state);
                    MedicineDetailsModel firstElement = MedicineDetailsModel(
                      type: '',
                      name: ConstantsForPrescriptionScreen.unSelectedTag,
                      when: ConstantsForPrescriptionScreen.whenList.first,
                      duration:
                          ConstantsForPrescriptionScreen.durationList.first,
                      dose: ConstantsForPrescriptionScreen.dosageList.first,
                      saltComposition:
                          ConstantsForPrescriptionScreen.saltCompositionValue,
                    );
                    return [firstElement];
                  });
                  ref
                      .read(isPrescriptionSavedProvider.notifier)
                      .update((state) => false);
                } else {
                  SnackBar snackBar = SnackBar(
                    content: Text('Failed'),
                    backgroundColor: Colors.red,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
                showSnackbar(saveApi, sendNextApi);
              } else {
                SnackBar snackBar = SnackBar(
                  content: Text('Please save the prescription first',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.black,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
              setState(() {
                showLoader = false;
                disableButton = false;
              });
            },
      child: Container(
        width: getProportionateWebScreenWidth(158.25),
        height: getProportionateWebScreenHeight(47.95),
        decoration: ShapeDecoration(
          color: Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1.20),
          ),
        ),
        child: Center(
          child: (showLoader)
              ? SpinKitPouringHourGlass(
                  color: Colors.grey,
                )
              : Text(
                  'Save & Next',
                  style: GoogleFonts.publicSans(
                    color: Colors.white,
                    fontSize: 15.58,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  void showSnackbar(bool saveApi, bool sendNextApi) {
    if (saveApi && sendNextApi) {
      SnackBar snackBar = SnackBar(
        content: Text('Prescription Saved and Patient Sent'),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (saveApi && !sendNextApi) {
      SnackBar snackBar = SnackBar(
        content: Text('Prescription Saved but Patient Not Sent'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (!saveApi && sendNextApi) {
      SnackBar snackBar = SnackBar(
        content: Text('Prescription Not Saved but Patient Sent'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      SnackBar snackBar = SnackBar(
        content: Text('Prescription Not Saved and Patient Not Sent'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}

class SendNextPatientButton extends ConsumerStatefulWidget {
  const SendNextPatientButton({Key? key}) : super(key: key);

  @override
  ConsumerState<SendNextPatientButton> createState() =>
      _SendNextPatientButtonState();
}

class _SendNextPatientButtonState extends ConsumerState<SendNextPatientButton> {
  bool showLoader = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        setState(() {
          showLoader = true;
        });
        int statusCode = await sendNextPatient(null);
        ref.invalidate(getCurrentPatientProvider);

        if (statusCode == 200) {
          try {
            clinicalHistoryController.clear();
            notesController.clear();
            diagnosisTextfieldTagsControler.clearTags();
            symptomsTextfieldTagsControler.clearTags();
            testsTextfieldTagsControler.clearTags();
          } catch (e) {
            print('caught error in sendNextPatientButton $e');
          }

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
          ref
              .read(isPrescriptionSavedProvider.notifier)
              .update((state) => false);
          SnackBar snackBar = SnackBar(
            content: Text('Done'),
            backgroundColor: Colors.green,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          SnackBar snackBar = SnackBar(
            content: Text('Failed'),
            backgroundColor: Colors.red,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }

        setState(() {
          showLoader = false;
        });
      },
      child: Container(
        width: getProportionateWebScreenWidth(132.25),
        height: getProportionateWebScreenHeight(30.95),
        decoration: ShapeDecoration(
          color: Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1.20),
          ),
        ),
        child: Center(
          child: (showLoader)
              ? FittedBox(
                  fit: BoxFit.contain,
                  child: SpinKitPouringHourGlass(
                    color: Colors.grey,
                  ),
                )
              : Text(
                  'Next',
                  style: GoogleFonts.publicSans(
                    color: Colors.white,
                    fontSize: 15.58,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class SaveTemplateButton extends ConsumerStatefulWidget {
  final int age;
  final String gender;
  const SaveTemplateButton({
    Key? key,
    required this.age,
    required this.gender,
  }) : super(key: key);

  @override
  ConsumerState<SaveTemplateButton> createState() => _SaveTemplateButtonState();
}

class _SaveTemplateButtonState extends ConsumerState<SaveTemplateButton> {
  bool showLoader = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        setState(() {
          showLoader = true;
        });
        int statusCode = await savePrescTemplate(
          age: widget.age,
          gender: widget.gender,
          symptoms: symptomsTextfieldTagsControler.getTags ?? [],
          diagnosis: diagnosisTextfieldTagsControler.getTags ?? [],
          tests: testsTextfieldTagsControler.getTags ?? [],
          nextVisit: ref.read(nextVisitProvider),
          medicines: ref.read(medicineDetailsListProvider) ?? [],
        );

        if (statusCode == 200) {
          SnackBar snackBar = SnackBar(
            content: Text('Template Saved Successfully'),
            backgroundColor: Colors.green,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          SnackBar snackBar = SnackBar(
            content: Text('Template Not Saved, Check Next Visit Field'),
            backgroundColor: Colors.red,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        setState(() {
          showLoader = false;
        });
      },
      child: Container(
        width: getProportionateWebScreenWidth(158.25),
        height: getProportionateWebScreenHeight(47.95),
        decoration: ShapeDecoration(
          color: Color(0xFFF3F3F3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1.20),
          ),
        ),
        child: Center(
          child: (showLoader)
              ? SpinKitPouringHourGlass(
                  color: Colors.grey,
                )
              : Text(
                  'Save as Template',
                  style: GoogleFonts.publicSans(
                    color: Color(0xFF5B5B5B),
                    fontSize: 15.58,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class NextPatientInfoWidget extends ConsumerWidget {
  const NextPatientInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(nextPatientInfoProvider).when(data: (patDetails) {
      return Container(
        height: getProportionateWebScreenHeight(47.95),
        padding: EdgeInsets.only(
          left: getProportionateWebScreenWidth(10),
          right: getProportionateWebScreenWidth(20),
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xFF2A2A2A),
          ),
          borderRadius: BorderRadius.circular(4),
          color: Color(0xFFF3F3F3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Next Patient -',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              patDetails.id == -1
                  ? 'None'
                  : '${patDetails.firstName} ${patDetails.lastName}',
              maxLines: 3,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }, error: (e, s) {
      return Container(
        width: getProportionateWebScreenWidth(158.25),
        height: getProportionateWebScreenHeight(47.95),
        child: Center(
          child: Text(
            ' $e $s',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }, loading: () {
      return Container(
        width: getProportionateWebScreenWidth(158.25),
        height: getProportionateWebScreenHeight(47.95),
        child: Center(
          child: SpinKitPouringHourGlass(
            color: Colors.grey,
          ),
        ),
      );
    });
  }
}
