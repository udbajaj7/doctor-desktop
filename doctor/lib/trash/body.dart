// import 'dart:io';
// import 'package:doctor/Models/DoctorModel.dart';
// import 'package:doctor/Models/PatientModel.dart';
// import 'package:doctor/Models/reachedListModel.dart';
// import 'package:doctor/components/size_config.dart';
// import 'package:doctor/screens/homeScreen/components/CurrentPatient.dart';
// import 'package:doctor/components/CustomAppBar.dart';
// import 'package:doctor/screens/homeScreen/components/bookingListCard.dart';
// import 'package:doctor/screens/homeScreen/components/currPatientForTwo.dart';
// import 'package:doctor/screens/loginScreen/components/requests.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:loader_overlay/loader_overlay.dart';
// import '../../../Models/DoctorBookings.dart';
// import '../../../components/urls.dart';
// import '../../addPatientScreen/AddPatientScreen.dart';
// import 'ReachedListCard.dart';
// import 'accountsScreen.dart';
// import 'reachedListCardForTwo.dart';
// import 'requests.dart';

// class HomeScreenBody extends StatefulWidget {
//   HomeScreenBody({Key? key}) : super(key: key);

//   @override
//   State<HomeScreenBody> createState() => _HomeScreenBodyState();
// }

// class _HomeScreenBodyState extends State<HomeScreenBody> {
//   late Future<Map<String, List>> getReachedQueueFutureResponse;
//   late Future<Map<String, List>> getBookingQueueFutureResponse;
//   late Future<DoctorModel> getDocInfoFutureResponse;
//   int pageIndex = 0;
//   late TimeOfDay timePicked;
//   GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
//       new GlobalKey<RefreshIndicatorState>();
//   late List<PatientModel> patListReached;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   Future<bool> _onWillPop() async {
//     return false;
//   }

//   @override
//   void initState() {
//     super.initState();

//     initializeHeader();
//     getDocInfoFutureResponse = getDocInfo(myProfile.id);
//     getReachedQueueFutureResponse = getReachedQueue(myProfile.id);
//     getBookingQueueFutureResponse = getBookingQueue(myProfile.id);
//   }

//   void onRefresh() async {
//     setState(() {
//       getReachedQueueFutureResponse = getReachedQueue(myProfile.id);
//       getBookingQueueFutureResponse = getBookingQueue(myProfile.id);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);

//     int id = prefs.getInt("currentDocId") ?? -1;
//     myProfile.id = id;
//     // print("Patients per slot are :");
//     // print(myProfile.patPerSlot);
//     ReachedListModel r1 = ReachedListModel(
//         notes: "",
//         age: -1,
//         fName: "",
//         lastName: "",
//         phoneNumber: "",
//         gender: "",
//         slotNumber: "",
//         prevPatientBookingID: -1,
//         treatment: "",
//         balance: -1,
//         consentOrNot: false,
//         installment: 0);
//     ReachedListModel r2 = ReachedListModel(
//         notes: "",
//         age: -1,
//         fName: "",
//         lastName: "",
//         phoneNumber: "",
//         gender: "",
//         slotNumber: "",
//         prevPatientBookingID: -1,
//         treatment: "",
//         balance: -1,
//         consentOrNot: false,
//         installment: 0);
//     int patPerSlot = prefs.getInt("pat_per_slot") ?? 0;
//     // if (patPerSlot > 1) initializeTwoPatients();

//     return LoaderOverlay(
//       overlayWidget: Center(
//           child: SpinKitPouringHourGlass(
//         color: Colors.grey,
//       )),
//       child: Scaffold(
//           key: _scaffoldKey,
//           appBar: AppBar(
//             systemOverlayStyle: SystemUiOverlayStyle(
//               statusBarColor: Colors.white,
//               statusBarIconBrightness: Brightness.dark,
//               statusBarBrightness: Brightness.light,
//             ),
//             title: Text(
//               "INCUE",
//               style: GoogleFonts.josefinSans(
//                   fontWeight: FontWeight.w700,
//                   color: Colors.black,
//                   fontSize: 20),
//             ),
//             elevation: 0,
//             centerTitle: true,
//             backgroundColor: Colors.white,
//             leading: InkWell(
//               onTap: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => AccountsScreen(
//                               refreshIndicatorKey: refreshIndicatorKey,
//                             )));
//               },
//               child: Transform.translate(
//                   offset: Offset(14, 0),
//                   child: Container(
//                     margin: EdgeInsets.all(14),
//                     height: 32,
//                     width: 32,
//                     child: CircleAvatar(
//                       backgroundColor: Colors.black,
//                       child: Icon(
//                         Icons.person_2_outlined,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                     ),
//                   )),
//             ),
//             actions: [
//               InkWell(
//                 onTap: () async {
//                   TimeOfDay? picked = (kIsWeb || Platform.isAndroid)
//                       ? await showTimePicker(
//                           context: context,
//                           initialTime: TimeOfDay(hour: 0, minute: 15),
//                           initialEntryMode: TimePickerEntryMode.input,
//                           builder: (context, childWidget) {
//                             return MediaQuery(
//                                 data: MediaQuery.of(context).copyWith(
//                                     // Using 24-Hour format
//                                     alwaysUse24HourFormat: true),
//                                 // If you want 12-Hour format, just change alwaysUse24HourFormat to false o
//                                 //remove all the builder argument
//                                 child: childWidget!);
//                           },
//                         )
//                       : await showCupertinoModalPopup(
//                           context: context,
//                           builder: (_) => Container(
//                                 height: 500,
//                                 color: const Color.fromARGB(255, 255, 255, 255),
//                                 child: Column(
//                                   children: [
//                                     SizedBox(
//                                       height: 400,
//                                       child: CupertinoDatePicker(
//                                           mode: CupertinoDatePickerMode.time,
//                                           use24hFormat: true,
//                                           initialDateTime: DateTime.now(),
//                                           onDateTimeChanged: (val) {}),
//                                     ),
//                                     // Close the modal
//                                     CupertinoButton(
//                                       child: const Text('OK'),
//                                       onPressed: () =>
//                                           Navigator.of(context).pop(),
//                                     )
//                                   ],
//                                 ),
//                               ));

//                   print("time picked for delay ");
//                   print(picked);
//                   if (picked == null) {
//                   } else {
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                           builder: (context) => WillPopScope(
//                                 onWillPop: _onWillPop,
//                                 child: SpinKitPouringHourGlass(
//                                   color: Colors.grey,
//                                 ),
//                               )),
//                     );
//                   }
//                   var result = await addDelay(myProfile.id, picked!);
//                   print("after future");
//                   print(result);
//                   Navigator.pop(context);
//                   if (result != "Success")
//                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                       padding:
//                           EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//                       content: Text(
//                           "There was some error and delay could not be added"),
//                     ));
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(width: 1, color: Colors.black)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(6.0),
//                     child: Center(
//                       child: Icon(
//                         Icons.more_time_sharp,
//                         color: Colors.black,
//                         size: 20,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 width: 8,
//               ),
//               InkWell(
//                 onTap: () async {
//                   Navigator.of(context).push(MaterialPageRoute(
//                     builder: (context) => AddPatientScreen(  // add refresh function callback here todo
//                       age: null,
//                       firstName: "",
//                       gender: "",
//                       lastName: "",
//                       phoneNumber: "",
//                       treatment: "",
//                       getEarly: true,
//                       refreshIndicatorKey: refreshIndicatorKey,
//                     ),
//                   ));
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(width: 1, color: Colors.black)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(6.0),
//                     child: Center(
//                       child: Icon(
//                         Icons.person_add_alt,
//                         color: Colors.black,
//                         size: 20,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 width: 22,
//               ),
//             ],
//           ),
//           backgroundColor: Colors.white,
//           body: Container(
//             margin: EdgeInsets.symmetric(
//                 horizontal: SizeConfig.screenWidth * 0.04, vertical: 16),
//             child: RefreshIndicator(
//               color: Colors.white,
//               backgroundColor: Colors.black,
//               strokeWidth: 3.0,
//               key: refreshIndicatorKey,
//               // This check is used to customize listening to scroll notifications
//               // from the widget's children.
//               notificationPredicate: (ScrollNotification notification) {
//                 return notification.depth == 1 || notification.depth == 0;
//               },
//               onRefresh: () async {
//                 setState(() {
//                   getBookingQueueFutureResponse = getBookingQueue(myProfile.id);
//                   getReachedQueueFutureResponse = getReachedQueue(myProfile.id);
//                 });
//               },
//               child: FutureBuilder(
//                   future: getDocInfoFutureResponse,
//                   builder: (context, snapshot) {
//                     if (snapshot.hasData &&
//                         snapshot.connectionState == ConnectionState.done) {
//                       if (snapshot.data == null)
//                         return SpinKitPouringHourGlass(color: Colors.grey);

//                       myProfile = snapshot.data as DoctorModel;
//                       patPerSlot = myProfile.patPerSlot;
//                       return Column(mainAxisSize: MainAxisSize.min, children: [
//                         myNavBar(context),
//                         SizedBox(
//                           height: 16,
//                         ),
//                         pageIndex == 0
//                             ? Expanded(
//                                 child: FutureBuilder(
//                                   future: getReachedQueueFutureResponse,
//                                   builder: (context, snapshot) {
//                                     if (snapshot.hasData &&
//                                         snapshot.connectionState ==
//                                             ConnectionState.done) {
//                                       // print("snapshot has ");
//                                       // print(snapshot.data);
//                                       bool hasData = false;
//                                       Map<String, List> map =
//                                           snapshot.data as Map<String, List>;
//                                       patListReached = List<PatientModel>.from(
//                                           map["pats"] as Iterable);
//                                       List<DoctorBookingsModel>
//                                           bookListReached =
//                                           List<DoctorBookingsModel>.from(
//                                               map["books"] as Iterable);

//                                       List<PatientModel> currentPatients =
//                                           List<PatientModel>.from(
//                                               map["currentPatients"]
//                                                   as Iterable);
//                                       List<DoctorBookingsModel>
//                                           currentPatientBookings =
//                                           List<DoctorBookingsModel>.from(
//                                               map["currentPatientBookings"]
//                                                   as Iterable);
//                                       int hasCurrentPatient =
//                                           currentPatients.length;

//                                       print(
//                                           "patients reached : $patListReached");
//                                       print(
//                                           ("reached booking list : $bookListReached"));

//                                       // print(
//                                       //     "patient list in reached queue is of length ${patListBooking.length} booking list ${bookList.length} ");
//                                       // print(patListBooking);
//                                       List<int> timeLeft = [0];
//                                       if (map["time_left"] != null)
//                                         timeLeft = List.from(
//                                             map["time_left"] as Iterable);
//                                       if (patListReached.length > 0) {
//                                         hasData = true;
//                                       }
//                                       if (hasCurrentPatient >= 1) {
//                                         r1.notes =
//                                             currentPatientBookings[0].notes;
//                                         r1.lastName =
//                                             currentPatients[0].lastName;
//                                         r1.phoneNumber =
//                                             currentPatients[0].phoneNumber;

//                                         r1.age = currentPatients[0].age;
//                                         r1.fName = currentPatients[0].firstName;
//                                         r1.gender = currentPatients[0].gender;
//                                         r1.slotNumber =
//                                             currentPatientBookings[0]
//                                                 .slotNumber
//                                                 .toString();
//                                         r1.prevPatientBookingID =
//                                             currentPatientBookings[0].bookingId;
//                                         r1.treatment =
//                                             currentPatientBookings[0].treatment;
//                                         r1.balance =
//                                             currentPatientBookings[0].balance;
//                                         r1.consentOrNot =
//                                             currentPatientBookings[0]
//                                                 .consentForm;
//                                         r1.installment =
//                                             currentPatientBookings[0]
//                                                 .installment;

//                                         if (hasCurrentPatient == 2) {
//                                           r2.notes =
//                                               currentPatientBookings[0].notes;
//                                           r2.age = currentPatients[1].age;
//                                           r2.lastName =
//                                               currentPatients[1].lastName;
//                                           r2.phoneNumber =
//                                               currentPatients[1].phoneNumber;
//                                           r2.fName =
//                                               currentPatients[1].firstName;
//                                           r2.gender = currentPatients[1].gender;
//                                           r2.slotNumber =
//                                               currentPatientBookings[1]
//                                                   .slotNumber
//                                                   .toString();
//                                           r2.prevPatientBookingID =
//                                               currentPatientBookings[1]
//                                                   .bookingId;
//                                           r2.treatment =
//                                               currentPatientBookings[1]
//                                                   .treatment;
//                                           r2.balance =
//                                               currentPatientBookings[1].balance;
//                                           r2.consentOrNot =
//                                               currentPatientBookings[1]
//                                                   .consentForm;

//                                           r2.installment =
//                                               currentPatientBookings[1]
//                                                   .installment;
//                                         }
//                                       }

//                                       return SingleChildScrollView(
//                                           physics:
//                                               AlwaysScrollableScrollPhysics(),
//                                           child: patPerSlot == 1
//                                               ? Column(
//                                                   children: [
//                                                     hasCurrentPatient == 1
//                                                         ? currentPatient(
//                                                             r1,
//                                                             context,
//                                                             refreshIndicatorKey,
//                                                             _scaffoldKey,onRefresh)
//                                                         : SizedBox(
//                                                             height: 0,
//                                                           ),
//                                                     (hasData == true ||
//                                                             hasCurrentPatient ==
//                                                                 1)
//                                                         ? ListView.builder(
//                                                             shrinkWrap: true,
//                                                             physics:
//                                                                 AlwaysScrollableScrollPhysics(),
//                                                             itemCount:
//                                                                 patListReached
//                                                                     .length,
//                                                             itemBuilder:
//                                                                 (context,
//                                                                     index) {
//                                                               return ReachedListCard(
//                                                                   patListReached[
//                                                                       index], //this part can be optimized.
//                                                                   bookListReached[
//                                                                       index],
//                                                                   refreshIndicatorKey,
//                                                                   onRefresh,
//                                                                   timeLeft[
//                                                                       index],
//                                                                   r1,
//                                                                   _scaffoldKey);
//                                                             })
//                                                         : (Center(
//                                                             child: Column(
//                                                               children: [
//                                                                 SizedBox(
//                                                                   height: 60,
//                                                                 ),
//                                                                 Image.asset(
//                                                                   "assets/images/nopat.png",
//                                                                   width: 150,
//                                                                   height: 150,
//                                                                 ),
//                                                                 Text(
//                                                                   "No patients Reached!",
//                                                                   style: GoogleFonts.publicSans(
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .w500,
//                                                                       color: Colors
//                                                                           .black,
//                                                                       fontSize:
//                                                                           18),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ))
//                                                   ],
//                                                 )
//                                               : Column(
//                                                   children: [
//                                                     r1.fName != ""
//                                                         ? IntrinsicHeight(
//                                                             child: Row(
//                                                                 mainAxisSize:
//                                                                     MainAxisSize
//                                                                         .max,
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .stretch,
//                                                                 children: [
//                                                                   CurrentPatientForTwo(
//                                                                       r1,
//                                                                       bookListReached,
//                                                                       patListReached,
//                                                                       refreshIndicatorKey,
//                                                                       onRefresh,
//                                                                       1,
//                                                                       _scaffoldKey),
//                                                                 ]),
//                                                           )
//                                                         : SizedBox(
//                                                             height: 0,
//                                                           ),
//                                                     r2.fName != ""
//                                                         ? IntrinsicHeight(
//                                                             child: Row(
//                                                               mainAxisSize:
//                                                                   MainAxisSize
//                                                                       .max,
//                                                               crossAxisAlignment:
//                                                                   CrossAxisAlignment
//                                                                       .stretch,
//                                                               children: [
//                                                                 CurrentPatientForTwo(
//                                                                     r2,
//                                                                     bookListReached,
//                                                                     patListReached,
//                                                                     refreshIndicatorKey,
//                                                                     onRefresh,
//                                                                     2,
//                                                                     _scaffoldKey),
//                                                               ],
//                                                             ),
//                                                           )
//                                                         : SizedBox(
//                                                             height: 0,
//                                                           ),
//                                                     hasData == true
//                                                         ? ListView.builder(
//                                                             shrinkWrap: true,
//                                                             physics:
//                                                                 AlwaysScrollableScrollPhysics(),
//                                                             itemCount:
//                                                                 patListReached
//                                                                     .length,
//                                                             itemBuilder:
//                                                                 (context,
//                                                                     index) {
//                                                               return ReachedListCardForTwo(
//                                                                   r2.fName ==
//                                                                       "", //check here a issue can be there

//                                                                   patListReached[
//                                                                       index], //this part can be optimized.
//                                                                   bookListReached[
//                                                                       index],
//                                                                   refreshIndicatorKey,
//                                                                   onRefresh,
//                                                                   timeLeft[
//                                                                       index],
//                                                                   r1,
//                                                                   r2,
//                                                                   _scaffoldKey);
//                                                             })
//                                                         : (r1.fName == "" &&
//                                                                 r2.fName == "")
//                                                             ? (Center(
//                                                                 child: Column(
//                                                                   children: [
//                                                                     SizedBox(
//                                                                       height:
//                                                                           60,
//                                                                     ),
//                                                                     Image.asset(
//                                                                       "assets/images/nopat.png",
//                                                                       width:
//                                                                           150,
//                                                                       height:
//                                                                           150,
//                                                                     ),
//                                                                     Text(
//                                                                       "No patients Reached!",
//                                                                       style: GoogleFonts.publicSans(
//                                                                           fontWeight: FontWeight
//                                                                               .w500,
//                                                                           color: Colors
//                                                                               .black,
//                                                                           fontSize:
//                                                                               18),
//                                                                     ),
//                                                                   ],
//                                                                 ),
//                                                               ))
//                                                             : SizedBox(
//                                                                 height: 0)
//                                                   ],
//                                                 ));
//                                     } else {
//                                       return SpinKitPouringHourGlass(
//                                         color: Colors.grey,
//                                       );
//                                     }
//                                   },
//                                 ),
//                               )
//                             : Expanded(
//                                 child: FutureBuilder(
//                                   future: getBookingQueueFutureResponse,
//                                   builder: (context, snapshot) {
//                                     if (snapshot.hasData &&
//                                         snapshot.connectionState ==
//                                             ConnectionState.done) {
//                                       bool hasData = false;
//                                       Map<String, List> map =
//                                           snapshot.data as Map<String, List>;
//                                       List<PatientModel> patList =
//                                           List<PatientModel>.from(
//                                               map["pats"] as Iterable);
//                                       List<DoctorBookingsModel> bookList =
//                                           List<DoctorBookingsModel>.from(
//                                               map["books"] as Iterable);
//                                       if (patList.length > 0) {
//                                         hasData = true;
//                                       }
//                                       debugPrint(patList.length.toString());
//                                       return SingleChildScrollView(
//                                           physics:
//                                               AlwaysScrollableScrollPhysics(),
//                                           child: hasData == true
//                                               ? ListView.builder(
//                                                   shrinkWrap: true,
//                                                   physics:
//                                                       AlwaysScrollableScrollPhysics(),
//                                                   itemCount: patList.length,
//                                                   itemBuilder:
//                                                       (context, index) {
//                                                     return BookingListCard(
//                                                         patList[index],
//                                                         bookList[index],
//                                                         context,
//                                                         refreshIndicatorKey,
//                                                         _scaffoldKey,()=>  null);
//                                                   })
//                                               : Center(
//                                                   child: Column(
//                                                     children: [
//                                                       SizedBox(
//                                                         height: 60,
//                                                       ),
//                                                       Image.asset(
//                                                         "assets/images/nobook.png",
//                                                         width: 113,
//                                                         height: 113,
//                                                       ),
//                                                       SizedBox(
//                                                         height: 20,
//                                                       ),
//                                                       Text(
//                                                         "No bookings yet for today!",
//                                                         style: GoogleFonts
//                                                             .publicSans(
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .w500,
//                                                                 color: Colors
//                                                                     .black,
//                                                                 fontSize: 18),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ));
//                                     } else {
//                                       return SpinKitPouringHourGlass(
//                                         color: Colors.grey,
//                                       );
//                                     }
//                                   },
//                                 ),
//                               ),
//                       ]);
//                     } else
//                       return SpinKitPouringHourGlass(color: Colors.grey);
//                   }),
//             ),
//           )),
//     );
//   }

//   Container myNavBar(BuildContext context) {
//     return Container(
//         decoration: BoxDecoration(
//             border: Border.all(
//               color: Color.fromARGB(255, 246, 246, 246),
//             ),
//             color: Color.fromARGB(255, 246, 246, 246),
//             borderRadius: BorderRadius.all(Radius.circular(8))),
//         child: IntrinsicHeight(
//           child: Row(
//             children: [
//               Padding(
//                 padding: EdgeInsets.only(
//                     left: SizeConfig.screenWidth * 0.015, top: 3, bottom: 3),
//                 child: Container(
//                   width: SizeConfig.screenWidth * 0.43,
//                   decoration: BoxDecoration(
//                     color: pageIndex == 0
//                         ? Colors.black
//                         : Color.fromARGB(255, 246, 246, 246),
//                     borderRadius: const BorderRadius.all(Radius.circular(8)),
//                   ),
//                   child: TextButton(
//                     onPressed: () => {
//                       setState(() {
//                         pageIndex = 0;
//                       })
//                     },
//                     child: Text(
//                       "Reached",
//                       style: GoogleFonts.inter(
//                           fontSize: 14,
//                           color: pageIndex == 0
//                               ? Colors.white
//                               : Color.fromARGB(255, 154, 154, 154),
//                           fontWeight: FontWeight.w500),
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 child: VerticalDivider(
//                   thickness: 2,
//                   width: SizeConfig.screenWidth * 0.02,
//                   color: Color.fromARGB(255, 234, 234, 234),
//                 ),
//               ),
//               Padding(
//                 padding: EdgeInsets.only(
//                     right: SizeConfig.screenWidth * 0.015, top: 3, bottom: 3),
//                 child: Container(
//                   width: SizeConfig.screenWidth * 0.43,
//                   decoration: BoxDecoration(
//                     color: pageIndex == 1
//                         ? Colors.black
//                         : Color.fromARGB(255, 246, 246, 246),
//                     borderRadius: const BorderRadius.all(Radius.circular(8)),
//                   ),
//                   child: TextButton(
//                     onPressed: () => {
//                       setState(() {
//                         pageIndex = 1;
//                       })
//                     },
//                     child: Text(
//                       "Bookings",
//                       style: GoogleFonts.inter(
//                           fontSize: 14,
//                           color: pageIndex == 1
//                               ? Colors.white
//                               : Color.fromARGB(255, 154, 154, 154),
//                           fontWeight: FontWeight.w500),
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ));
//   }
// }

// // Future<Map<String, List>> getBookingQueue(int docId) async {
// //   print(docId);
// //   print("calling booking queue");
// //   var response = await http.post(Uri.parse(waitingQueueUrl),
// //       body: jsonEncode(<String, int>{
// //         "doc_id": docId,
// //       }),
// //       headers: header);

// //   print(response.statusCode);
// //   print(response.body.toString());

// //   if (response.statusCode == 200) {
// //     var jsonResponse = json.decode(response.body.toString());
// //     debugPrint(response.body);
// //     BookedResponse jsonResp = BookedResponse.fromJson(jsonResponse);
// //     List<DoctorBookingsModel> bookList = jsonResp.bookings;
// //     List<PatientModel> patList = jsonResp.patients;
// //     return {"pats": patList, "books": bookList};
// //   } else
// //     return {"pats": [], "books": []};
// // }

// // Future<Map<String, List>> getReachedQueue(int docId) async {
// //   print("calling reached queue with doc id $docId");
// //   var response = await http.post(Uri.parse(reachedQueueUrl),
// //       body: jsonEncode(<String, int>{
// //         "doc_id": docId,
// //       }),
// //       headers: header);
// //   if (response.statusCode == 200) {
// //     var jsonResponse = json.decode(response.body.toString());
// //     debugPrint("Reached queue ${response.body}");
// //     ReachedResponse jsonResp = ReachedResponse.fromJson(jsonResponse);
// //     List<DoctorBookingsModel> bookList = jsonResp.bookings;
// //     List<PatientModel> patList = jsonResp.patients;
// //     List<int> timeLeft = jsonResp.timeLeft;
// //     print("Reached patient list is of size ${patList.length}");
// //     print(patList.toList());
// //     return {"pats": patList, "books": bookList, "time_left": timeLeft};
// //   } else
// //     return {"pats": [], "books": [], "time_left": []};
// // }

// // class ReachedResponse {
// //   final List<PatientModel> patients;
// //   final List<DoctorBookingsModel> bookings;
// //   final List<int> timeLeft;

// //   ReachedResponse({this.patients, this.bookings, this.timeLeft});

// //   factory ReachedResponse.fromJson(Map<String, dynamic> parsedJson) {
// //     var list = parsedJson["Patients"] as List;
// //     List<PatientModel> patList =
// //         list.map((i) => PatientModel.fromJson(i)).toList();
// //     var list1 = parsedJson["Bookings"] as List;
// //     List<DoctorBookingsModel> bookingsList =
// //         list1.map((i) => DoctorBookingsModel.fromJson(i)).toList();
// //     var list2 = parsedJson["time_left"] as List;
// //     List<int> _timeLeft = list2.map((i) => i as int).toList();
// //     return ReachedResponse(
// //         patients: patList, bookings: bookingsList, timeLeft: _timeLeft);
// //   }
// // }

// // class BookedResponse {
// //   final List<PatientModel> patients;
// //   final List<DoctorBookingsModel> bookings;

// //   BookedResponse({this.patients, this.bookings});

// //   factory BookedResponse.fromJson(Map<String, dynamic> parsedJson) {
// //     var list = parsedJson["Patients"] as List;
// //     List<PatientModel> patList =
// //         list.map((i) => PatientModel.fromJson(i)).toList();
// //     var list1 = parsedJson["Bookings"] as List;
// //     List<DoctorBookingsModel> bookingsList =
// //         list1.map((i) => DoctorBookingsModel.fromJson(i)).toList();
// //     return BookedResponse(patients: patList, bookings: bookingsList);
// //   }
// // }
