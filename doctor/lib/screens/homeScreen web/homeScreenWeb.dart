import 'dart:ui';
import 'package:doctor/Models/AddPatientModel.dart';
import 'package:doctor/Models/DoctorModel.dart';
import 'package:doctor/Models/PatientModel.dart';
import 'package:doctor/components/size_config.dart';
import 'package:doctor/screens/allPatientScreen/allPatientScreen.dart';
import 'package:doctor/screens/loginScreen/loginScreen.dart';
import 'package:doctor/screens/patVitals/patVitalsDialog.dart';
import 'package:doctor/screens/prescriptionScreen/components/providers.dart';
import 'package:doctor/screens/prescriptionScreen/prescreptionScreen.dart';
import 'package:doctor/trash/editProfile/components/editProfileWeb.dart';
import 'package:doctor/screens/homeScreen%20web/components/queues.dart';
import 'package:doctor/screens/leaves/body.dart';
import 'package:doctor/screens/loginScreen/components/requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import '../../../components/urls.dart';
import '../../main.dart';
import '../addPatientScreen/AddPatientScreen.dart';
import '../bookings/components/webBookingScreen.dart';
import '../../trash/accountsScreen.dart';
import '../homeScreen/components/requests.dart';
import '../loginScreen/SignUpScreen.dart';
import '../reschedule.dart/reshedule.dart';

class WebHomeScreenBody extends StatefulWidget {
  WebHomeScreenBody({Key? key}) : super(key: key);

  @override
  State<WebHomeScreenBody> createState() => _WebHomeScreenBodyState();
}

class _WebHomeScreenBodyState extends State<WebHomeScreenBody> {
  late Future<String> getReachedQueueFutureResponse,
      getBookingQueueFutureResponse;
  late Future<DoctorModel> getDocInfoFutureResponse;
  int pageIndex = 0;
  late TimeOfDay timePicked;
  GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int screenNo = 0;
  final dummyPat =
          List.generate(8, (index) => dummyPatForSkeleton, growable: true),
      dummyBooking =
          List.generate(8, (index) => dummyBookingForSkeleton, growable: true);

  Future<bool> _onWillPop() async {
    return false;
  }

  late List<Widget> pages =
      List<Widget>.filled(12, Container(), growable: true);

  late Widget? currentPage = null;
  bool pauseOnTap = false;

  @override
  void initState() {
    super.initState();
    if (!(screenNo == 0 ||
        screenNo == 1 ||
        screenNo == 2 ||
        screenNo == 4 ||
        screenNo == 5 ||
        screenNo == 11)) pauseOnTap = true;

    initializeHeader();
    getDocInfoFutureResponse = getDocInfo(prefs.getInt("currentDocId")!);
    getReachedQueueFutureResponse = getReachedQueue(myProfile.id, context);
    getBookingQueueFutureResponse = getBookingQueue(myProfile.id, context);
  }

  void onRefresh() {
    print("Inside parent refresh function is called");
    setState(() {
      print("Inside setState");
      screenNo = 0;
      currentPage = pages[screenNo];
    });
  }

  void setAddPatientScreen(AddPatientModel patient) {
    setState(() {
      screenNo = 9;
      currentPage = AddPatientScreen(
        goBack: setHomeScreen,
        reschedule: false,
        firstName: patient.firstName,
        lastName: patient.lastName,
        phoneNumber: patient.phoneNo,
        age: patient.age,
        gender: patient.gender,
        treatment: patient.treatment,
        getEarly: patient.getEarly,
        refreshIndicatorKey: refreshIndicatorKey,
        refreshParent: onRefresh,
        address: patient.address,
      );
    });
  }

  void setPatVitalsDialog(
      PatientModel patientModel, int bookingId, BuildContext _context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_context) => PatientVitalsDialog(
            bookingID: bookingId,
            context: _context,
            goBack: setHomeScreen,
            patientModel: patientModel));
  }

  void setHomeScreen(BuildContext context) {
    setState(() {
      screenNo = 0;
      pauseOnTap = false;
      currentPage = Queues(refreshIndicatorKey, _scaffoldKey, onRefresh,
          setAddPatientScreen, setPatVitalsDialog);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!(screenNo == 0 ||
        screenNo == 1 ||
        screenNo == 2 ||
        screenNo == 4 ||
        screenNo == 5 ||
        screenNo == 11 ||
        screenNo == 10)) pauseOnTap = true;

    print("Printing ......................");
    print(myProfile.timing);
    print(myProfile.firstName);
    SizeConfig().init(context);
    pages[0] = Queues(refreshIndicatorKey, _scaffoldKey, onRefresh,
        setAddPatientScreen, setPatVitalsDialog);
    pages[1] = BookingsBodyWeb(
        refreshIndicatorKey: refreshIndicatorKey,
        showAddPatientScreen: setAddPatientScreen);
    pages[9] = AddPatientScreen(
      goBack: setHomeScreen,
      reschedule: false,
      firstName: "",
      lastName: "",
      phoneNumber: "",
      age: null,
      gender: "Male",
      treatment: "",
      getEarly: true,
      refreshIndicatorKey: refreshIndicatorKey,
      refreshParent: onRefresh,
      address: "",
    );
    pages[2] = AllPatientScreen(setAddPatientScreen);
    pages[3] = EditProfileWeb();
    pages[4] = LeaveScreen();
    pages[5] = Reschedule();
    pages[10] = PrescriptionScreen();

    int id = prefs.getInt("currentDocId") ?? -1;
    myProfile.id = id;

    debugPrint("curr doc id: " + id.toString());

    String idsString = prefs.getString("DocIds") ?? "";
    var ids = idsString.split(',');
    if (ids[ids.length - 1].isEmpty)
      ids.removeAt(ids.length - 1); // removing the last empty value

    String namesString = prefs.getString("DocNames") ?? "";
    var names = namesString.split(',');
    if (names[names.length - 1].isEmpty) names.removeAt(names.length - 1);

    names.add("Add Account");
    Map<String, String> profileMap = {};

    for (int i = 0; i < names.length; i++) {
      if (i != names.length - 1) profileMap[names[i]] = ids[i];
    }

    profileMap["Add Account"] = "-1";

    String selectedDoc = profileMap.keys.firstWhere((element) {
      if (profileMap[element] == id.toString())
        return true;
      else
        return false;
    });

    debugPrint(namesString + " watch");
    debugPrint(selectedDoc);
    debugPrint(profileMap[selectedDoc]);

    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Colors.black,
      strokeWidth: 3.0,
      key: refreshIndicatorKey,
      notificationPredicate: (ScrollNotification notification) {
        return notification.depth == 1 || notification.depth == 0;
      },
      onRefresh: () async {
        setState(() {
          getBookingQueueFutureResponse =
              getBookingQueue(myProfile.id, context);
          getReachedQueueFutureResponse =
              getReachedQueue(myProfile.id, context);
        });
      },
      child: LoaderOverlay(
          overlayWidget: Center(
              child: SpinKitPouringHourGlass(
            color: Colors.grey,
          )),
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            body: FutureBuilder(
                future: getDocInfoFutureResponse,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    myProfile = snapshot.data as DoctorModel;

                    print("inside future and currentPage is $currentPage");
                    if (currentPage == null) currentPage = pages[screenNo];

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                    right: BorderSide(
                                        color: Colors.grey, width: 1))),
                            width: getProportionateWebScreenWidth(
                                SizeConfig.screenWidth * 0.20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, top: 23, bottom: 17),
                                  child: Text(
                                    "INCUE PLUS",
                                    style: GoogleFonts.publicSans(
                                        fontSize:
                                            getProportionateWebScreenWidth(38),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Divider(
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  height: getProportionateWebScreenHeight(6),
                                ),
                                Center(
                                    child: Column(
                                  children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius:
                                            getProportionateWebScreenWidth(30),
                                        child: Image.asset(
                                            "assets/images/doctor_image.jpg",
                                            fit: BoxFit.fill),
                                      ),
                                      title: DropdownButton<String>(
                                          underline: SizedBox(),
                                          value: selectedDoc,
                                          iconSize: 32,
                                          items: profileMap.keys
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value != "Add Account"
                                                    ? "Dr. " + value
                                                    : value,
                                                style: GoogleFonts.publicSans(
                                                    fontSize:
                                                        getProportionateWebScreenWidth(
                                                            24),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: pauseOnTap == false
                                              ? (value) {
                                                  setState(() {
                                                    if (value !=
                                                        "Add Account") {
                                                      prefs.setInt(
                                                          "currentDocId",
                                                          int.parse(profileMap[
                                                              value]!));
                                                      Navigator.of(context)
                                                          .pushAndRemoveUntil(
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        MyApp(),
                                                              ),
                                                              (route) => false);
                                                    } else {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  LoginScreen()));
                                                    }
                                                    selectedDoc = value!;
                                                  });
                                                }
                                              : null),
                                    ),
                                    Divider(
                                      thickness: 1,
                                      color: Colors.grey,
                                    )
                                  ],
                                )),
                                ListTile(
                                  leading: Image.asset(
                                    "assets/images/home.png",
                                    color: screenNo == 0
                                        ? Colors.black
                                        : Color.fromARGB(255, 106, 106, 106),
                                  ),
                                  title: Text(
                                    "Home",
                                    style: GoogleFonts.publicSans(
                                        fontWeight: screenNo == 0
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize:
                                            getProportionateWebScreenWidth(
                                                18.4)),
                                  ),
                                  onTap: pauseOnTap == false
                                      ? () {
                                          setState(() {
                                            print("Booking clicked");
                                            screenNo = 0;
                                            currentPage = pages[screenNo];
                                          });
                                        }
                                      : null,
                                ),
                                ListTile(
                                  leading: Image.asset(
                                    "assets/images/bookings.png",
                                    color: screenNo == 1
                                        ? Colors.black
                                        : Color.fromARGB(255, 106, 106, 106),
                                  ),
                                  title: Text(
                                    "Bookings",
                                    style: GoogleFonts.publicSans(
                                        fontWeight: screenNo == 1
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize:
                                            getProportionateWebScreenWidth(
                                                18.4)),
                                  ),
                                  onTap: pauseOnTap == false
                                      ? () {
                                          setState(() {
                                            print("Booking clicked");
                                            screenNo = 1;
                                            currentPage = pages[screenNo];
                                          });
                                        }
                                      : null,
                                ),
                                ListTile(
                                  leading: Image.asset(
                                    "assets/images/allPatients.png",
                                    color: screenNo == 2
                                        ? Colors.black
                                        : Color.fromARGB(255, 106, 106, 106),
                                  ),
                                  title: Text(
                                    "All Patients",
                                    style: GoogleFonts.publicSans(
                                        fontWeight: screenNo == 2
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize:
                                            getProportionateWebScreenWidth(
                                                18.4)),
                                  ),
                                  onTap: pauseOnTap == false
                                      ? () {
                                          setState(() {
                                            print("All patients clicked");
                                            screenNo = 2;
                                            currentPage = pages[screenNo];
                                          });
                                        }
                                      : null,
                                ),
                                SizedBox(
                                  height: getProportionateWebScreenHeight(
                                      getProportionateWebScreenHeight(4)),
                                ),
                                Consumer(builder: (context, ref, ch) {
                                  return ListTile(
                                    leading: Image.asset(
                                      "assets/images/createPrescription.png",
                                      color: screenNo == 10
                                          ? Colors.black
                                          : Color.fromARGB(255, 106, 106, 106),
                                    ),
                                    title: Text(
                                      "Create Prescription",
                                      style: GoogleFonts.publicSans(
                                        fontSize:
                                            getProportionateWebScreenWidth(
                                          18.4,
                                        ),
                                        fontWeight: screenNo == 10
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    onTap: pauseOnTap == false
                                        ? () {
                                            setState(() {
                                              print(
                                                  "Create Prescription clicked");
                                              screenNo = 10;
                                              currentPage = pages[screenNo];

                                              ref.refresh(
                                                  getCurrentPatientProvider);
                                            });
                                          }
                                        : null,
                                  );
                                }),
                                SizedBox(
                                  height: getProportionateWebScreenHeight(
                                      getProportionateWebScreenHeight(4)),
                                ),
                                // ListTile(
                                //   leading: Icon(Icons.home),
                                //   title: Text(
                                //     "Edit Profile",
                                //     style: GoogleFonts.publicSans(
                                //         fontSize: getProportionateWebScreenHeight(
                                //             18.4)),
                                //   ),
                                //   onTap: () {
                                //     setState(() {
                                //       print("Edit Profile clicked");
                                //       screenNo = 3;
                                //       currentPage = pages[screenNo];
                                //     });
                                //   },
                                // ),
                                // SizedBox(
                                //   height: getProportionateWebScreenHeight(
                                //       getProportionateWebScreenHeight(20)),
                                // ),
                                // ListTile(
                                //   leading: Icon(Icons.home),
                                //   title: Text(
                                //     "Patient Reviews",
                                //     style: GoogleFonts.publicSans(
                                //         fontSize: getProportionateWebScreenHeight(
                                //             18.4)),
                                //   ),
                                //   onTap: null,
                                // ),
                                // SizedBox(
                                //   height: getProportionateWebScreenHeight(20),
                                // ),
                                Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                ),
                                ListTile(
                                  leading: Image.asset(
                                    "assets/images/leaves.png",
                                    height: getProportionateWebScreenWidth(22),
                                    width: getProportionateWebScreenWidth(22),
                                    color: screenNo == 4
                                        ? Colors.black
                                        : Color.fromARGB(255, 106, 106, 106),
                                  ),
                                  title: Text(
                                    "Leaves",
                                    style: GoogleFonts.publicSans(
                                        fontWeight: screenNo == 4
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize:
                                            getProportionateWebScreenWidth(
                                                18.4)),
                                  ),
                                  onTap: pauseOnTap == false
                                      ? () {
                                          setState(() {
                                            screenNo = 4;
                                            currentPage = pages[screenNo];
                                          });
                                        }
                                      : null,
                                ),
                                ListTile(
                                  leading: Image.asset(
                                    "assets/images/rescheduleClinicTimings.png",
                                    height: getProportionateWebScreenWidth(22),
                                    width: getProportionateWebScreenWidth(22),
                                    color: screenNo == 5
                                        ? Colors.black
                                        : Color.fromARGB(255, 106, 106, 106),
                                  ),
                                  title: Text(
                                    "Reschedule Clinic Timings",
                                    style: GoogleFonts.publicSans(
                                        fontWeight: screenNo == 5
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize:
                                            getProportionateWebScreenWidth(
                                                18.4)),
                                  ),
                                  onTap: pauseOnTap == false
                                      ? () {
                                          setState(() {
                                            screenNo = 5;
                                            currentPage = pages[screenNo];
                                          });
                                        }
                                      : null,
                                ),
                                Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                ),
                                SizedBox(
                                  height: getProportionateWebScreenHeight(6),
                                ),
                                Expanded(child: Container()),
                                Center(
                                  child: SizedBox(
                                      height: getProportionateScreenWidth(35),
                                      width: getProportionateScreenWidth(200),
                                      child: ElevatedButton.icon(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Color(0xffE96363))),
                                        icon: Icon(
                                          Icons.logout,
                                          color: Colors.white,
                                        ),
                                        onPressed: pauseOnTap == false
                                            ? () {
                                                showDialog<void>(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder:
                                                      (BuildContext context) {
                                                    return BackdropFilter(
                                                      filter: ImageFilter.blur(
                                                          sigmaX: 10,
                                                          sigmaY: 10),
                                                      child: AlertDialog(
                                                        title: RichText(
                                                          text: TextSpan(
                                                            text: 'Log out of ',
                                                            style: GoogleFonts
                                                                .publicSans(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        18),
                                                            children: <TextSpan>[
                                                              TextSpan(
                                                                  text:
                                                                      'INCUE?',
                                                                  style: GoogleFonts.josefinSans(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          18))
                                                            ],
                                                          ),
                                                        ),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .black),
                                                            child: Text(
                                                                'Log Out',
                                                                style: GoogleFonts.publicSans(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .white)),
                                                            onPressed:
                                                                () async {
                                                              clearData();
                                                              Navigator.pushAndRemoveUntil(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              SignUpScreen()),
                                                                  (route) =>
                                                                      false);
                                                            },
                                                          ),
                                                          TextButton(
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .grey),
                                                            child: Text(
                                                                'Cancel',
                                                                style: GoogleFonts.publicSans(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .black)),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              }
                                            : null,
                                        label: Text(
                                          "Logout",
                                          style: GoogleFonts.publicSans(
                                              color: Colors.white,
                                              fontSize:
                                                  getProportionateScreenHeight(
                                                      18),
                                              fontWeight: FontWeight.w500),
                                        ),
                                      )),
                                ),
                                SizedBox(
                                  height: getProportionateWebScreenHeight(20),
                                ),
                                Center(
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: getProportionateWebScreenWidth(22),
                                    child: Image.asset(
                                      "assets/images/logo_without_title.png",
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: getProportionateWebScreenHeight(20),
                                ),
                                Center(
                                  child: Text(
                                    "BLINCUE TECHNOLOGIES PRIVATE LIMITED",
                                    style: GoogleFonts.publicSans(
                                        fontSize:
                                            getProportionateScreenHeight(8)),
                                  ),
                                ),
                                Center(
                                  child: Text("© All rights reserved.",
                                      style: GoogleFonts.publicSans(
                                          fontSize:
                                              getProportionateScreenWidth(8))),
                                )
                              ],
                            ),
                          ),
                        ),
                        //Center part of screen starting from here
                        Expanded(child: currentPage!),
                      ],
                    );
                  } else
                    return SpinKitPouringHourGlass(color: Colors.grey);
                }),
          )),
    );
  }

  Container myNavBar(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: Color.fromARGB(255, 246, 246, 246),
            ),
            color: Color.fromARGB(255, 246, 246, 246),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: SizeConfig.screenWidth * 0.015, top: 3, bottom: 3),
                child: Container(
                  color: Colors.white,
                  width: SizeConfig.screenWidth * 0.43,
                  decoration: BoxDecoration(
                    color: pageIndex == 0
                        ? Colors.black
                        : Color.fromARGB(255, 246, 246, 246),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextButton(
                    onPressed: () => {
                      setState(() {
                        pageIndex = 0;
                      })
                    },
                    child: Text(
                      "Reached",
                      style: GoogleFonts.publicSans(
                          fontSize: 14,
                          color: pageIndex == 0
                              ? Colors.white
                              : Color.fromARGB(255, 154, 154, 154),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: VerticalDivider(
                  thickness: 2,
                  width: SizeConfig.screenWidth * 0.02,
                  color: Color.fromARGB(255, 234, 234, 234),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    right: SizeConfig.screenWidth * 0.015, top: 3, bottom: 3),
                child: Container(
                  width: SizeConfig.screenWidth * 0.43,
                  decoration: BoxDecoration(
                    color: pageIndex == 1
                        ? Colors.black
                        : Color.fromARGB(255, 246, 246, 246),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextButton(
                    onPressed: () => {
                      setState(() {
                        print("Booking button clicked");
                        screenNo = 1;
                        currentPage = pages[screenNo];
                      })
                    },
                    child: Text(
                      "Bookings",
                      style: GoogleFonts.publicSans(
                          fontSize: 14,
                          color: pageIndex == 1
                              ? Colors.white
                              : Color.fromARGB(255, 154, 154, 154),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

// Future profileAlertDialog(BuildContext context) {
//   return showDialog<void>(
//     context: context,
//     barrierDismissible: true,
//     builder: (context) {
//       return BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: AlertDialog(
//           contentPadding: EdgeInsets.all(getProportionateScreenWidth(30)),
//           title: Center(
//               child: Text("Switch Account",
//                   style: GoogleFonts.publicSans(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                       fontSize: 21))),
//           content: Container(
//             alignment: Alignment.topCenter,
//             height: getProportionateScreenHeight(100),
//             width: SizeConfig.screenWidth * 0.3,
//             child: GridView.builder(
//               physics: AlwaysScrollableScrollPhysics(),
//               itemCount: names.length,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 4,
//               ),
//               shrinkWrap: true,
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                     onTap: () {},
//                     child: Container(
//                       height: getProportionateScreenHeight(150),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Container(
//                             width: getProportionateScreenWidth(48),
//                             height: getProportionateScreenHeight(48),
//                             decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(
//                                       getProportionateScreenWidth(30)),
//                                 ),
//                                 border: Border.all(
//                                     color: index != length
//                                         ? (ids[index] == currentId
//                                             ? Colors.black
//                                             : Colors.white)
//                                         : Colors.white,
//                                     width: 2)),
//                             child: Container(
//                               decoration: BoxDecoration(
//                                   color: index != length
//                                       ? Colors.blueGrey
//                                       : Colors.grey,
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                       color: Colors.white, width: 1.5)),
//                               child: FractionallySizedBox(
//                                 heightFactor: 0.90,
//                                 widthFactor: 0.90,
//                                 child: Center(
//                                   child: index != length
//                                       ? Text(
//                                           names[index][0].toUpperCase(),
//                                           style: GoogleFonts.publicSans(
//                                               color: Colors.white,
//                                               fontSize:
//                                                   getProportionateScreenHeight(
//                                                       24),
//                                               fontWeight: FontWeight.bold),
//                                         )
//                                       : Icon(
//                                           Icons.add,
//                                           color: Colors.black,
//                                         ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                               width: getProportionateScreenWidth(36),
//                               child: Center(
//                                 child: Text(
//                                   names[index],
//                                   overflow: TextOverflow.ellipsis,
//                                   style: GoogleFonts.publicSans(
//                                       color: Colors.black,
//                                       fontSize: 14,
//                                       fontWeight: index != length
//                                           ? (ids[index] == currentId
//                                               ? FontWeight.bold
//                                               : FontWeight.normal)
//                                           : FontWeight.normal),
//                                 ),
//                               ))
//                         ],
//                       ),
//                     ));
//               },
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }
