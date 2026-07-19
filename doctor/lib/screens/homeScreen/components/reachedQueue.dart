import 'package:doctor/providers/appointmentProvider.dart';
import 'package:doctor/screens/homeScreen/components/reachedListCardForTwo.dart';
import 'package:doctor/screens/homeScreen/components/requests.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../Models/AddPatientModel.dart';
import '../../../Models/Appointment.dart';
import '../../../Models/DoctorBookings.dart';
import '../../../Models/DoctorModel.dart';
import '../../../Models/PatientModel.dart';
import '../../../components/size_config.dart';
import '../../../components/urls.dart';
import 'CurrentPatient.dart';
import 'ReachedListCard.dart';
import 'currPatientForTwo.dart';

class ReachedQueue extends StatefulWidget {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final Function(AddPatientModel) showAddPatientScreen;
  final Function showVitalsDialog;
  final Function refreshParent;
  ReachedQueue(this.refreshIndicatorKey, this._scaffoldKey,
      this.showAddPatientScreen, this.refreshParent, this.showVitalsDialog);

  @override
  State<ReachedQueue> createState() => _ReachedQueueState();
}

class _ReachedQueueState extends State<ReachedQueue> {
  late Future<String> getReachedQueueFutureResponse;
  late Future<DoctorModel> getDocInfoFutureResponse;
  int pageIndex = 0;
  late TimeOfDay timePicked;
  late List<PatientModel> patListReached;
  final dummyPat =
      List.generate(8, (index) => dummyPatForSkeleton, growable: true);

  @override
  void initState() {
    super.initState();
    getReachedQueueFutureResponse = getReachedQueue(myProfile.id, context);
  }

  refreshReachedQueueAndParent() {
    setState(() {
      getReachedQueueFutureResponse = getReachedQueue(myProfile.id, context);
    });
    widget.refreshParent();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    int id = prefs.getInt("currentDocId") ?? -1;
    myProfile.id = id;
    int patPerSlot = prefs.getInt("pat_per_slot") ?? 0;

    return Consumer<AppointmentProvider>(
        builder: (context, appointmentProvider, _) {
      return FutureBuilder(
        future: getReachedQueueFutureResponse,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            bool hasData = false;
            List<Appointment> reached = appointmentProvider.getReachedAppoin,
                curr = appointmentProvider.getCurrAppoin;

            List<PatientModel> patListReached = [];
            List<DoctorBookingsModel> bookListReached = [];
            List<PatientModel> currentPatients = [];
            List<DoctorBookingsModel> currentPatientBookings = [];
            List<int> timeLeft = [];

            reached.forEach((element) {
              patListReached.add(element.patientModel);
              bookListReached.add(element.doctorBookingsModel);
              timeLeft.add(element.timeLeft ?? 0);
            });

            curr.forEach((element) {
              currentPatients.add(element.patientModel);
              currentPatientBookings.add(element.doctorBookingsModel);
            });

            int numCurrentPatient = currentPatients.length;

            if (patListReached.length > 0) {
              hasData = true;
            }

            return SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: patPerSlot == 1
                    ? Column(
                        children: [
                          numCurrentPatient == 1
                              ? currentPatient(
                                  widget.showAddPatientScreen,
                                  myProfile.category,
                                  widget.showVitalsDialog,
                                  currentPatientBookings[0],
                                  currentPatients[0],
                                  context,
                                  widget.refreshIndicatorKey,
                                  widget._scaffoldKey,
                                  widget.refreshParent)
                              : SizedBox(
                                  height: 0,
                                ),
                          (hasData == true || numCurrentPatient == 1)
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemCount: patListReached.length,
                                  itemBuilder: (context, index) {
                                    return ReachedListCard(
                                        patListReached[index],
                                        bookListReached[index],
                                        widget.refreshIndicatorKey,
                                        timeLeft[index],
                                        currentPatientBookings.length > 0
                                            ? currentPatientBookings[0]
                                                .bookingId
                                            : 0,
                                        widget._scaffoldKey,
                                        refreshReachedQueueAndParent,
                                        widget.showVitalsDialog,
                                        myProfile.category);
                                  })
                              : (Center(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height:
                                            getProportionateScreenHeight(60),
                                      ),
                                      Image.asset(
                                        "assets/images/nopat.png",
                                        width: getProportionateScreenWidth(150),
                                        height:
                                            getProportionateScreenHeight(150),
                                      ),
                                      Text(
                                        "No patients Reached!",
                                        style: GoogleFonts.publicSans(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                            fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ))
                        ],
                      )
                    : Column(
                        children: [
                          numCurrentPatient >= 1
                              ? IntrinsicHeight(
                                  child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        CurrentPatientForTwo(
                                            currentPatientBookings[0],
                                            currentPatients[0],
                                            bookListReached,
                                            patListReached,
                                            widget.refreshIndicatorKey,
                                            1,
                                            widget._scaffoldKey,
                                            widget.refreshParent,
                                            widget.showAddPatientScreen,
                                            widget.showVitalsDialog,
                                            myProfile.category),
                                      ]),
                                )
                              : SizedBox(
                                  height: 0,
                                ),
                          numCurrentPatient == 2
                              ? IntrinsicHeight(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      CurrentPatientForTwo(
                                          currentPatientBookings[1],
                                          currentPatients[1],
                                          bookListReached,
                                          patListReached,
                                          widget.refreshIndicatorKey,
                                          2,
                                          widget._scaffoldKey,
                                          widget.refreshParent,
                                          widget.showAddPatientScreen,
                                          widget.showVitalsDialog,
                                          myProfile.category),
                                    ],
                                  ),
                                )
                              : SizedBox(
                                  height: 0,
                                ),
                          hasData == true
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemCount: patListReached.length,
                                  itemBuilder: (context, index) {
                                    return ReachedListCardForTwo(
                                        patListReached[
                                            index], //this part can be optimized.
                                        bookListReached[index],
                                        widget.refreshIndicatorKey,
                                        timeLeft[index],
                                        numCurrentPatient == 1
                                            ? Appointment(
                                                doctorBookingsModel:
                                                    currentPatientBookings[0],
                                                patientModel:
                                                    currentPatients[0])
                                            : Appointment(
                                                doctorBookingsModel:
                                                    DoctorBookingsModel(
                                                        date: "",
                                                        startTime: '',
                                                        slotTime: "",
                                                        endTime: "",
                                                        docId: -1,
                                                        patId: -1,
                                                        batchNumber: -1,
                                                        slotNumber: -1,
                                                        bookingId: -1,
                                                        treatment: "",
                                                        consentForm: false,
                                                        balance: 0,
                                                        notes: "",
                                                        installment: 0),
                                                patientModel: PatientModel(
                                                    id: -1,
                                                    email: "",
                                                    gender: "",
                                                    firstName: "",
                                                    lastName: "",
                                                    city: "",
                                                    age: -1,
                                                    phoneNumber: "",
                                                    address: "")),
                                        numCurrentPatient == 2
                                            ? Appointment(
                                                doctorBookingsModel:
                                                    currentPatientBookings[1],
                                                patientModel:
                                                    currentPatients[1])
                                            : Appointment(
                                                doctorBookingsModel:
                                                    DoctorBookingsModel(
                                                        date: "",
                                                        startTime: '',
                                                        slotTime: "",
                                                        endTime: "",
                                                        docId: -1,
                                                        patId: -1,
                                                        batchNumber: -1,
                                                        slotNumber: -1,
                                                        bookingId: -1,
                                                        treatment: "",
                                                        consentForm: false,
                                                        balance: 0,
                                                        notes: "",
                                                        installment: 0),
                                                patientModel: PatientModel(
                                                    id: -1,
                                                    email: "",
                                                    gender: "",
                                                    firstName: "",
                                                    lastName: "",
                                                    city: "",
                                                    age: -1,
                                                    phoneNumber: "",
                                                    address: "")),
                                        widget._scaffoldKey,
                                        widget.refreshParent,
                                        widget.showVitalsDialog,
                                        myProfile.category);
                                  })
                              : (numCurrentPatient == 0)
                                  ? (Center(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height:
                                                getProportionateScreenHeight(
                                                    60),
                                          ),
                                          Image.asset(
                                            "assets/images/nopat.png",
                                            width: getProportionateScreenWidth(
                                                150),
                                            height:
                                                getProportionateScreenHeight(
                                                    150),
                                          ),
                                          Text(
                                            "No bookings yet for today!",
                                            style: GoogleFonts.publicSans(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ))
                                  : SizedBox(height: 0)
                        ],
                      ));
          } else {
            return Skeletonizer(
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: dummyPat.length,
                  itemBuilder: (context, index) {
                    return ReachedListCardForTwo(
                        dummyPat[index], //this part can be optimized.
                        dummyBookingForSkeleton,
                        widget.refreshIndicatorKey,
                        0,
                        Appointment(
                            doctorBookingsModel: dummyBookingForSkeleton,
                            patientModel: dummyPatForSkeleton),
                        Appointment(
                            doctorBookingsModel: dummyBookingForSkeleton,
                            patientModel: dummyPatForSkeleton),
                        widget._scaffoldKey,
                        widget.refreshParent,
                        widget.showVitalsDialog,
                        myProfile.category);
                  }),
            );
          }
        },
      );
    });
  }
}
