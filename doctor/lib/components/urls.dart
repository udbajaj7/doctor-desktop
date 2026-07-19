import 'dart:convert';

import 'package:doctor/Models/DoctorModel.dart';
import 'package:doctor/Models/MetaData.dart';
import 'package:doctor/Models/PrescPrintRatioModel.dart';
import 'package:doctor/Models/currentPatientModel.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Base URL of the Incue REST API.
///
/// Configurable at build/run time via `--dart-define=INCUE_API_BASE_URL=...`.
/// Falls back to the production endpoint so existing behaviour is preserved
/// when no override is supplied. See `.env.example`.
const String siteUrl = String.fromEnvironment(
  'INCUE_API_BASE_URL',
  defaultValue: "https://incue-oep43kcksq-el.a.run.app/",
);

/// Default timeout applied to outbound HTTP requests to avoid indefinite hangs.
const Duration kRequestTimeout = Duration(seconds: 30);

String getCitiesUrl = siteUrl + "cities/";
String phoneRegUrl = siteUrl + "send_otp/";
String signInUrl = siteUrl + "login/";
String changePassUrl = siteUrl + "change_pwd/";
String forgetPassOtpUrl = siteUrl + "forget_pwd_send_otp/";
String resendOtpUrl = siteUrl + "resend_otp/";
String otpVerificationUrl = siteUrl + "verify_otp/";
String cancelBooking = docUrl + "cancelBooking/";
String docUrl = siteUrl + "doctor/";
String getAllPatientsUrl = docUrl + "getAllPatients/";
String addDoctorUrl = docUrl + "addDoctor/";
String addBooking = docUrl + "addBooking/";
String getEstimatedTimeUrl = siteUrl + "patient/getEstTime/";
String addBookingExtra = docUrl + "addBookingExtra/";
String addBookingMultipleUrl = docUrl + "addBookingMultiple/";
String getEarlyUrl = docUrl + "getEarliestSlot/";
String getReviewsUrl = docUrl + "getReviews/";
String waitingQueueUrl = docUrl + "getWaitingQueue/";
String reachedQueueUrl = docUrl + "getReachedQueue/";
String endAppointmentUrl = docUrl + "endBooking/";
String sendInButtonUrl = docUrl + "sendInBtn/";
String getCurrentPatientUrl = docUrl + "getCurrentPatient/";
String updateBalanceUrl = docUrl + "updateBalance/";
String getBalanceUrl = docUrl + "getBalance/";
String getAllPatientBookings = docUrl + "getAllBookings/";
String reachedButtonUrl = docUrl + "reachedBtn/";
String rescheduleUrl = docUrl + "addReschedule/";
String addDelayUrl = docUrl + "addDelay/";
String getAvailSlotsUrl = docUrl + "getSlots/";
String getAvailDates = docUrl + "getAvalDates/";
String addLeaveUrl = docUrl + "addLeave/";
String getLeavesUrl = docUrl + "getLeaves/";
String deleteLeaveUrl = docUrl + "deleteLeave/";
String getReschUrl = docUrl + "getRescheduledTimings/";
String addReschUrl = docUrl + "addRescheduleTimings/";
String delReschUrl = docUrl + "deleteRescheduleTimings/";
String getBookingsUrl = docUrl + "getBookings/";
String editDetailUrl = docUrl + "editProfile/";
String getDocInfoUrl = docUrl + "getDocInfo/";
String writeFeedbackUrl = docUrl + "writeFeedback/";
String docNotesUrl = docUrl + "addTreatmentNotes/";
String getAvailableTreatmentsUrl = docUrl + "getTreatments/";
String sendFileUrl = docUrl + "addTreatmentFiles/";
String getTreatmentFileUrl = docUrl + "getTreatmentFiles/";
String deleteFileUrl = docUrl + "deleteTreatmentFiles/";
String editPatientUrl = docUrl + "editPatientInfo/";
String editTreatmentUrl = docUrl + "editTreatment/";
String getVitalsUrl = docUrl + "getVitals/";
String saveVitalsUrl = docUrl + "saveVitals/";
String getMedicineData = docUrl + "getMedicineData/";
String savePrescrption = docUrl + "savePrescription/";
String getCurrentPrescription = docUrl + "getCurrentPresciption/";
String sendNextUrl = docUrl + "sendNext/";
String saveMedicineDataUrl = docUrl + "saveMedicineData/";
String patSearchUrl = docUrl + "searchPatient/?phone_number=";
String getPrescriptionUrl = docUrl + "getPrescription/";
String savePrescTemplateUrl = docUrl + "savePrescTemplate/";
String getPrescTemplateUrl = docUrl + "getPrescTemplate/";
String getNextPatUrl = docUrl + "getNextPat/";
String getPrescPrintRatios = docUrl + "getPrescPrintRatios/";

late SharedPreferences prefs;
MetaDataa metaData = MetaDataa();
CurrentPatientModel currentPatientModel = CurrentPatientModel();

String dateToString(DateTime dateTime) {
  return dateTime.day.toString().padLeft(2, "0") +
      "-" +
      dateTime.month.toString().padLeft(2, "0") +
      "-" +
      dateTime.year.toString();
}

String timeToString(TimeOfDay timeOfDay) {
  return timeOfDay.hour.toString().padLeft(2, "0") +
      timeOfDay.minute.toString().padLeft(2, "0");
}

late Map<String, String> header;

void initializeHeader() {
  String? password = prefs.getString("password");
  String? phNo = prefs.getString("phoneNumber");
  String basicAuth = 'Basic ' + base64.encode(utf8.encode('$phNo:$password'));

  header = <String, String>{
    'authorization': basicAuth,
    'Accept': 'application/json',
    'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
    'Content-Type': 'application/json; charset=UTF-8',
  };
}

List<String> docTreatmentsAvailable = List.empty(growable: true);

DoctorModel myProfile = DoctorModel(
    id: -1,
    firstName: "",
    lastName: "",
    gender: "",
    age: -1,
    phoneNumber: "",
    email: "",
    registrationNumber: "",
    specialization: "",
    degrees: "",
    appointmentFees: -1,
    clinicName: "",
    clinicAddress: "",
    city: "",
    avgTime: -1,
    patPerSlot: -1,
    timing: [],
    category: "",
    contactNumber: "");

PrescPrintRatioModel myPrescriptionRatios =
    PrescPrintRatioModel(vertical: [0.2, 0.7, 0.1]);
