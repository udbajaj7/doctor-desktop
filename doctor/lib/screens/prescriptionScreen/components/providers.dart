import 'package:doctor/Models/MedicineDataModel.dart';
import 'package:doctor/Models/MedicineDetailsModel.dart';
import 'package:doctor/Models/MedicineModel.dart';
import 'package:doctor/Models/PatientModel.dart';
import 'package:doctor/Models/PrescriptionModel.dart';
import 'package:doctor/components/urls.dart';
import 'package:doctor/screens/homeScreen/components/requests.dart';
import 'package:doctor/screens/prescriptionScreen/components/constants.dart';
import 'package:doctor/screens/prescriptionScreen/components/requests.dart';
import 'package:doctor/screens/prescriptionScreen/components/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:textfield_tags/textfield_tags.dart';

final TextEditingController clinicalHistoryController = TextEditingController();

final TextEditingController notesController = TextEditingController();

final symptomsTextfieldTagsControler = TextfieldTagsController();
final diagnosisTextfieldTagsControler = TextfieldTagsController();
final testsTextfieldTagsControler = TextfieldTagsController();

// List<String> diagnosisInitialTags = [];
// List<String> symptomsInitialTags = [];
// List<String> testsInitialTags = [];
// final diagnosisInitialTagsProvider = StateProvider<List<String>>((ref) => []);
// final symptomsInitialTagsProvider = StateProvider<List<String>>((ref) => []);
// final testsInitialTagsProvider = StateProvider<List<String>>((ref) => []);

final weightProvider = StateProvider<String>((ref) => "");
final heightProvider = StateProvider<String>((ref) => "");
final temperatureProvider = StateProvider<String>((ref) => "");
final bloodPressureProvider = StateProvider<String>((ref) => "");
final pulseProvider = StateProvider<String>((ref) => "");
final spo2Provider = StateProvider<String>((ref) => "");

//name${ConstantsForPrescriptionScreen.alternateMedicineDelimiter}type${ConstantsForPrescriptionScreen.alternateMedicineDelimiter}instructions;
final customMedicinesProvider = StateProvider<List<String>>((ref) => []);

final isPrescriptionSavedProvider = StateProvider<bool>((ref) => false);

final medicineDetailsListProvider =
    StateProvider<List<MedicineDetailsModel>>((ref) => [
          MedicineDetailsModel(
            name: ConstantsForPrescriptionScreen.unSelectedTag,
            type: '',
            when: ConstantsForPrescriptionScreen.whenList.first,
            duration: ConstantsForPrescriptionScreen.durationList[4],
            dose: ConstantsForPrescriptionScreen.dosageList.first,
            saltComposition:
                ConstantsForPrescriptionScreen.saltCompositionValue,
          )
        ]);

final bookingIdProvider = StateProvider<int>((ref) => 0);

final nextVisitProvider = StateProvider<String>((ref) {
  // DateTime date = DateTime.now();
  // String day = (date.day ~/ 10 == 0) ? '0${date.day}' : '${date.day}';
  // String month = (date.month ~/ 10 == 0) ? '0${date.month}' : '${date.month}';
  // print('this is month $month');
  return '';
});

final medicineDropdownFocusNode = FocusNode();
final anotherFocusNode = FocusNode();

final getMedicineDataProvider =
    FutureProvider.autoDispose<MedicineDataModel>((ref) async {
  MedicineDataModel data = await getPrescreptionData();

  if (ref.read(medicineDetailsListProvider.notifier).state.isEmpty) {
    ref.read(medicineDetailsListProvider.notifier).update((state) {
      MedicineDetailsModel firstElement = MedicineDetailsModel(
        type: data.medicines.first.type,
        name: data.medicines.first.name,
        when: ConstantsForPrescriptionScreen.whenList.first,
        duration: ConstantsForPrescriptionScreen.durationList[4],
        dose: ConstantsForPrescriptionScreen.dosageList.first,
        saltComposition: ConstantsForPrescriptionScreen.saltCompositionValue,
      );
      return [firstElement];
    });
  }

  return data;
});

final getCurrentPatientProvider = FutureProvider.autoDispose<List>((ref) async {
  print('Started');
  Map<String, dynamic> data = await getCurrentPatients(myProfile.id);
  PrescriptionModel previousPrescriptionData = await getCurrentPrescreption();
  print(
      'previousPrescriptionData ${previousPrescriptionData.toJson().toString()}');

  // diagnosisInitialTags = previousPrescriptionData.diagnosis;
  // symptomsInitialTags = previousPrescriptionData.symptoms;
  // testsInitialTags = previousPrescriptionData.tests;

  // ref
  //     .read(diagnosisInitialTagsProvider.notifier)
  //     .update((state) => previousPrescriptionData.diagnosis);
  // ref
  //     .read(symptomsInitialTagsProvider.notifier)
  //     .update((state) => previousPrescriptionData.symptoms);
  // ref
  //     .read(testsInitialTagsProvider.notifier)
  //     .update((state) => previousPrescriptionData.tests);

  ref.read(bookingIdProvider.notifier).state =
      previousPrescriptionData.bookingId ?? -3;
  ref.read(nextVisitProvider.notifier).state =
      previousPrescriptionData.nextVisit ?? '';

  ref
      .read(weightProvider.notifier)
      .update((state) => previousPrescriptionData.vitals.weight);
  ref
      .read(heightProvider.notifier)
      .update((state) => previousPrescriptionData.vitals.height);
  ref
      .read(temperatureProvider.notifier)
      .update((state) => previousPrescriptionData.vitals.temperature);
  ref
      .read(bloodPressureProvider.notifier)
      .update((state) => previousPrescriptionData.vitals.bp);
  ref
      .read(pulseProvider.notifier)
      .update((state) => previousPrescriptionData.vitals.pulse);
  ref
      .read(spo2Provider.notifier)
      .update((state) => previousPrescriptionData.vitals.spo2);

  notesController.text = previousPrescriptionData.notes;
  clinicalHistoryController.text = previousPrescriptionData.clinicalHistory;

  List<MedicineDetailsModel> medicines = previousPrescriptionData.medicines;
  if (!medicines.isEmpty &&
      medicines[0].name != ConstantsForPrescriptionScreen.unSelectedTag) {
    ref.read(medicineDetailsListProvider.notifier).update((state) => []);
    medicines.forEach((element) {
      ref.read(medicineDetailsListProvider.notifier).update((state) {
        MedicineDetailsModel medicineDetailsModel = MedicineDetailsModel(
          type: element.type,
          name: element.name,
          when: element.when,
          duration: element.duration,
          dose: element.dose,
          saltComposition: element.saltComposition,
        );
        return [...state, medicineDetailsModel];
      });
    });
  } else {
    ref.read(medicineDetailsListProvider.notifier).update((state) => [
          MedicineDetailsModel(
            type: '',
            name: ConstantsForPrescriptionScreen.unSelectedTag,
            when: ConstantsForPrescriptionScreen.whenList.first,
            duration: ConstantsForPrescriptionScreen.durationList[4],
            dose: ConstantsForPrescriptionScreen.dosageList.first,
            saltComposition:
                ConstantsForPrescriptionScreen.saltCompositionValue,
          )
        ]);
  }

  debugPrint(data.toString());
  print('ended');

  return [
    data,
    previousPrescriptionData,
    // previousPrescriptionData.diagnosis,
    // previousPrescriptionData.symptoms,
    // previousPrescriptionData.tests,
    // previousPrescriptionData.vitals,
  ];
});

final getCurrentPrecriptionProvider = FutureProvider.autoDispose
    .family<PrescriptionModel, int>((ref, int bookingId) async {
  PrescriptionModel data = await getPrescription(bookingId);

  ref.read(bookingIdProvider.notifier).state = data.bookingId ?? -3;

  ref.read(weightProvider.notifier).update((state) => data.vitals.weight);
  ref.read(heightProvider.notifier).update((state) => data.vitals.height);
  ref
      .read(temperatureProvider.notifier)
      .update((state) => data.vitals.temperature);
  ref.read(bloodPressureProvider.notifier).update((state) => data.vitals.bp);
  ref.read(pulseProvider.notifier).update((state) => data.vitals.pulse);
  ref.read(spo2Provider.notifier).update((state) => data.vitals.spo2);

  notesController.text = data.notes;
  clinicalHistoryController.text = data.clinicalHistory;

  List<MedicineDetailsModel> medicines = data.medicines;
  if (medicines.isNotEmpty) {
    ref.read(medicineDetailsListProvider.notifier).update((state) => []);
  }
  medicines.forEach((element) {
    ref.read(medicineDetailsListProvider.notifier).update((state) {
      MedicineDetailsModel medicineDetailsModel = MedicineDetailsModel(
        type: element.type,
        name: element.name,
        when: element.when,
        duration: element.duration,
        dose: element.dose,
        saltComposition: element.saltComposition,
      );
      return [...state, medicineDetailsModel];
    });
  });

  debugPrint(data.toString());
  print('ended');

  return data;
});

final getMedicinesFromSharedPrefsProvider =
    FutureProvider.autoDispose<MedicineDataModel>((ref) async {
  List<MedicineModel> medicines = await SharedPrefs().getMedicine();
  List<String> diagnosis = await SharedPrefs().getDiagnosis();
  List<String> symptoms = await SharedPrefs().getSymptoms();
  List<String> tests = await SharedPrefs().getTests();

  if (ref.read(medicineDetailsListProvider.notifier).state.isEmpty) {
    ref.read(medicineDetailsListProvider.notifier).update((state) {
      MedicineDetailsModel firstElement = MedicineDetailsModel(
        type: medicines.first.type,
        name: medicines.first.name,
        when: ConstantsForPrescriptionScreen.whenList.first,
        duration: ConstantsForPrescriptionScreen.durationList[4],
        dose: ConstantsForPrescriptionScreen.dosageList.first,
        saltComposition: ConstantsForPrescriptionScreen.saltCompositionValue,
      );
      return [firstElement];
    });
  }

  return MedicineDataModel(
    medicines: medicines,
    diagnosis: diagnosis,
    symptoms: symptoms,
    tests: tests,
  );
});

MedicineDataModel globalMedicineDataModel = MedicineDataModel(
  medicines: [],
  diagnosis: [],
  symptoms: [],
  tests: [],
);

Future<void> saveMedicineDataFromBackend() async {
  try {
    print('saveMedicineDataFromBackend started');
    MedicineDataModel data = await getPrescreptionData();
    print('saveMedicineDataFromBackend ended');
    print(data.medicines.length);
    print(data.diagnosis.length);
    print(data.symptoms.length);
    print(data.tests.length);

    print(data.medicines.first.name);
    print(data.medicines.first.type);
    print(data.medicines.first.saltComposition);
    List<MedicineModel> medicines = [];
    data.medicines.forEach((element) {
      medicines.add(MedicineModel(
        type: element.type,
        name: element.name,
        when: element.when,
        duration: ConstantsForPrescriptionScreen.durationList[4],
        dose: element.dose,
        saltComposition: element.saltComposition,
      ));
    });

    // await SharedPrefs().saveMedicines(medicines);
    // await SharedPrefs().saveDiagnosis(data.diagnosis);
    // await SharedPrefs().saveSymptoms(data.symptoms);

    globalMedicineDataModel = data;
  } catch (e, s) {
    print('error in saveMedicineDataFromBackend ${e.toString()}');
    print('StackTrace' + s.toString());
  }
}

final getSymptomsAndDiagnosisProvider =
    FutureProvider.autoDispose<MedicineDataModel>((ref) async {
  List<String> diagnosis = await SharedPrefs().getDiagnosis();
  List<String> symptoms = await SharedPrefs().getSymptoms();

  return MedicineDataModel(
    medicines: [],
    diagnosis: diagnosis,
    symptoms: symptoms,
    tests: [],
  );
});

final rebuildMedicineTableProvider = StateProvider<int>((ref) => 0);

final nextPatientInfoProvider =
    FutureProvider.autoDispose<PatientModel>((ref) async {
  PatientModel data = await getNextPatient();
  return data;
});
