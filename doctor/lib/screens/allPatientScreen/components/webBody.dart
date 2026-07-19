import 'package:doctor/components/size_config.dart';
import 'package:doctor/screens/allPatientScreen/components/editPat.dart';
import 'package:doctor/screens/bookings/components/patientDetails.dart';
import 'package:doctor/screens/bookings/components/requests.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../Models/AddPatientModel.dart';
import '../../../Models/DoctorBookings.dart';
import '../../../Models/PatientModel.dart';

class AllPatientsBodyWeb extends StatefulWidget {
  final List<PatientModel> patList;
  final Function(AddPatientModel) showAddPatientScreen;
    AllPatientsBodyWeb(
      {required this.patList, required this.showAddPatientScreen});

  @override
  State<AllPatientsBodyWeb> createState() => _AllPatientsBodyWebState();
}

class _AllPatientsBodyWebState extends State<AllPatientsBodyWeb> {
  List<PatientModel> patientsToDisplay = [];
  PatientModel patientModel = PatientModel(
      id: -1,
      email: "",
      gender: "",
      firstName: "",
      lastName: "",
      city: "",
      age: -1,
      phoneNumber: "",
      address: "");
  RefreshController _refreshReschedule =
      RefreshController(initialRefresh: true);

  @override
  void initState() {
    super.initState();
    patientsToDisplay = widget.patList;
  }

  void f() {
    setState(() {
      _refreshReschedule.refreshCompleted();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text("pull up load");
          } else if (mode == LoadStatus.loading) {
            body = CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text("Load Failed!Click retry!");
          } else if (mode == LoadStatus.canLoading) {
            body = Text("release to load more");
          } else {
            body = Text("No more Data");
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      controller: _refreshReschedule,
      onRefresh: () {
        f();
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: getProportionateScreenHeight(30),
            ),
            Padding(
              padding: EdgeInsets.only(left: getProportionateScreenWidth(10)),
              child: Text(
                "All Patients",
                style: GoogleFonts.publicSans(
                    fontWeight: FontWeight.w700,
                    fontSize: getProportionateScreenHeight(30)),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: getProportionateScreenWidth(10)),
              child: Text(
                "List of all the Patients visited",
                style: GoogleFonts.publicSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    color: Colors.grey),
              ),
            ),
            Divider(color: Colors.grey, thickness: 1),
            SizedBox(
              height: getProportionateScreenHeight(15),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: getProportionateScreenWidth(8)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text("Patients List",
                                style: GoogleFonts.publicSans(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    fontSize: 24)),
                          ),
                          SizedBox(height: getProportionateScreenHeight(20)),
                          Container(
                            width: SizeConfig.screenWidth * 0.35,
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 5,
                                offset: Offset(0, 0),
                              ),
                            ]),
                            child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                                child: TextField(
                                  textAlign: TextAlign.start,
                                  keyboardType: TextInputType.name,
                                  cursorColor: Colors.black,
                                  textCapitalization: TextCapitalization.words,
                                  onChanged: searchPat,
                                  style: GoogleFonts.publicSans(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                      hintText: "Search for Patients:",
                                      hintStyle: GoogleFonts.publicSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                      prefixIcon: Icon(Icons.search,
                                          color: Colors.black),
                                      border: const UnderlineInputBorder(
                                          borderSide: BorderSide.none)),
                                )),
                          ),
                          SizedBox(height: getProportionateScreenHeight(16)),
                          Container(
                            width: SizeConfig.screenWidth * 0.35,
                            child: ListView.separated(
                              separatorBuilder: (context, index) => Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: getProportionateScreenHeight(12)),
                                child: Divider(
                                  thickness: 0.6,
                                  color: Color.fromARGB(255, 234, 234, 234),
                                ),
                              ),
                              physics: AlwaysScrollableScrollPhysics(),
                              itemCount: patientsToDisplay.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return ListTile(
                                    onTap: () {
                                      setState(() {
                                        patientModel = patientsToDisplay[index];
                                        print(
                                            "patient model index is now ${patientModel.id}");
                                      });
                                    },
                                    title: Text(
                                      patientsToDisplay[index].firstName +
                                          " " +
                                          patientsToDisplay[index].lastName,
                                      style: GoogleFonts.publicSans(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      patientsToDisplay[index].gender +
                                          ", " +
                                          patientsToDisplay[index]
                                              .age
                                              .toString(),
                                      style: GoogleFonts.publicSans(
                                          fontSize: 12,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    trailing: CircleAvatar(
                                      child: Text(
                                        patientsToDisplay[index].id.toString(),
                                        style: GoogleFonts.publicSans(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      radius: getProportionateScreenWidth(30),
                                      backgroundColor:
                                          Colors.black.withOpacity(0.04),
                                    ));
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: getProportionateScreenWidth(16)),
                patientModel.id != -1
                    ? Flexible(
                        fit: FlexFit.loose,
                        flex: 1,
                        child: Container(
                          height: SizeConfig.screenHeight,
                          decoration:
                              BoxDecoration(color: Colors.white, boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 5,
                              offset: Offset(0, 0),
                            ),
                          ]),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: FutureBuilder(
                              future: getPatientAllBookings(patientModel.id),
                              builder: (context, snapshot) {
                                if (snapshot.hasData &&
                                    snapshot.connectionState ==
                                        ConnectionState.done) {
                                  List<DoctorBookingsModel> bookingList =
                                      snapshot.data
                                          as List<DoctorBookingsModel>;
                                  return SingleChildScrollView(
                                    child: Container(
                                      height: SizeConfig.screenHeight,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                              height:
                                                  getProportionateScreenHeight(
                                                      12)),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              MaterialButton(
                                                shape: CircleBorder(),
                                                elevation: 0,
                                                color: Colors.black
                                                    .withOpacity(0.04),
                                                onPressed: () => showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        EditPatAlertDialog(
                                                            showAddPatientScreen:
                                                                widget
                                                                    .showAddPatientScreen,
                                                            patientModel:
                                                                patientModel,
                                                            refresh: f)),
                                                child: const Icon(
                                                  Icons.edit,
                                                  size: 18,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          PatientDetailWeb(
                                            patientModel,
                                            widget.showAddPatientScreen,
                                          ),
                                          // SizedBox(
                                          //   height: MediaQuery.of(context)
                                          //           .size
                                          //           .height *
                                          //       0.014,
                                          // ),
                                          // Padding(
                                          //   padding: const EdgeInsets.symmetric(
                                          //       horizontal: 10),
                                          //   child: Column(
                                          //     children: [
                                          //       Row(
                                          //         mainAxisAlignment:
                                          //             MainAxisAlignment
                                          //                 .spaceBetween,
                                          //         children: [
                                          //           Text("Name:",
                                          //               style: GoogleFonts
                                          //                   .publicSans(
                                          //                       color:
                                          //                           Colors.grey,
                                          //                       fontWeight:
                                          //                           FontWeight
                                          //                               .w500,
                                          //                       fontSize: 14)),
                                          //           Text(
                                          //               patientModel.firstName +
                                          //                   " " +
                                          //                   patientModel
                                          //                       .lastName,
                                          //               style: GoogleFonts
                                          //                   .publicSans(
                                          //                       color: Colors
                                          //                           .black,
                                          //                       fontSize: 16,
                                          //                       fontWeight:
                                          //                           FontWeight
                                          //                               .w600))
                                          //         ],
                                          //       ),
                                          //       SizedBox(
                                          //         height: 20,
                                          //       ),
                                          //       Row(
                                          //         mainAxisAlignment:
                                          //             MainAxisAlignment
                                          //                 .spaceBetween,
                                          //         children: [
                                          //           Text("Age:",
                                          //               style: GoogleFonts
                                          //                   .publicSans(
                                          //                       color:
                                          //                           Colors.grey,
                                          //                       fontWeight:
                                          //                           FontWeight
                                          //                               .w500,
                                          //                       fontSize: 14)),
                                          //           Text(
                                          //               patientModel.age
                                          //                   .toString(),
                                          //               style: GoogleFonts
                                          //                   .publicSans(
                                          //                       color: Colors
                                          //                           .black,
                                          //                       fontSize: 16,
                                          //                       fontWeight:
                                          //                           FontWeight
                                          //                               .w600))
                                          //         ],
                                          //       ),
                                          //       SizedBox(
                                          //         height: 20,
                                          //       ),
                                          //       Row(
                                          //         mainAxisAlignment:
                                          //             MainAxisAlignment
                                          //                 .spaceBetween,
                                          //         children: [
                                          //           Text("Gender:",
                                          //               style: GoogleFonts
                                          //                   .publicSans(
                                          //                       color:
                                          //                           Colors.grey,
                                          //                       fontWeight:
                                          //                           FontWeight
                                          //                               .w500,
                                          //                       fontSize: 14)),
                                          //           Text(patientModel.gender,
                                          //               style: GoogleFonts
                                          //                   .publicSans(
                                          //                       color: Colors
                                          //                           .black,
                                          //                       fontSize: 16,
                                          //                       fontWeight:
                                          //                           FontWeight
                                          //                               .w600))
                                          //         ],
                                          //       ),
                                          //       SizedBox(
                                          //         height: 20,
                                          //       ),
                                          //       Row(
                                          //         mainAxisAlignment:
                                          //             MainAxisAlignment
                                          //                 .spaceBetween,
                                          //         children: [
                                          //           Text("Mobile:",
                                          //               style: GoogleFonts
                                          //                   .publicSans(
                                          //                       color:
                                          //                           Colors.grey,
                                          //                       fontWeight:
                                          //                           FontWeight
                                          //                               .w500,
                                          //                       fontSize: 14)),
                                          //           SelectableText(
                                          //               patientModel.phoneNumber
                                          //                   .toString(),
                                          //               style: GoogleFonts
                                          //                   .publicSans(
                                          //                       color: Colors
                                          //                           .black,
                                          //                       fontSize: 16,
                                          //                       fontWeight:
                                          //                           FontWeight
                                          //                               .w600))
                                          //         ],
                                          //       ),
                                          //       SizedBox(height: 20),
                                          //       Center(
                                          //         child: TextButton(
                                          //           style: ButtonStyle(
                                          //               shape: MaterialStateProperty.all<
                                          //                       OutlinedBorder>(
                                          //                   RoundedRectangleBorder(
                                          //                       borderRadius: BorderRadius.all(Radius.circular(
                                          //                           getProportionateScreenHeight(
                                          //                               24))))),
                                          //               elevation: MaterialStateProperty
                                          //                   .all<double>(10),
                                          //               backgroundColor:
                                          //                   MaterialStateProperty.all<Color>(
                                          //                       Colors.black)),
                                          //           child: Padding(
                                          //             padding:
                                          //                 const EdgeInsets.all(
                                          //                     8.0),
                                          //             child: Text(
                                          //               "Book Another Appointment",
                                          //               style: GoogleFonts
                                          //                   .publicSans(
                                          //                       fontSize:
                                          //                           getProportionateScreenHeight(
                                          //                               20),
                                          //                       fontWeight:
                                          //                           FontWeight
                                          //                               .w500,
                                          //                       color: Colors
                                          //                           .white),
                                          //             ),
                                          //           ),
                                          //           onPressed: () {
                                          //             widget.showAddPatientScreen(
                                          //                 AddPatientModel(
                                          //                     patientModel
                                          //                         .firstName,
                                          //                     patientModel
                                          //                         .lastName,
                                          //                     patientModel.age,
                                          //                     patientModel
                                          //                         .phoneNumber,
                                          //                     "Checkup",
                                          //                     patientModel
                                          //                         .gender,
                                          //                     false));
                                          //           },
                                          //         ),
                                          //       ),
                                          //       SizedBox(
                                          //         height: 20,
                                          //       )
                                          //     ],
                                          //   ),
                                          // ),
                                          // SizedBox(
                                          //     height:
                                          //         getProportionateScreenHeight(
                                          //             12)),
                                          // Text("Booking Details",
                                          //     style: GoogleFonts.publicSans(
                                          //         fontWeight: FontWeight.w700,
                                          //         color: Colors.black,
                                          //         fontSize: 18)),
                                          // Expanded(
                                          //   child: ListView.builder(
                                          //       shrinkWrap: true,
                                          //       itemCount: bookingList.length,
                                          //       itemBuilder: (context, index) {
                                          //         DateTime dateOfBooking =
                                          //             convertStringToDateTime(
                                          //                 bookingList[index]
                                          //                     .date,
                                          //                 int.parse(
                                          //                     bookingList[index]
                                          //                         .slotTime));
                                          //         Color color = Color.fromARGB(
                                          //             255, 226, 169, 23);
                                          //         String status = "Upcoming";
                                          //         if (DateTime.now()
                                          //             .isAfter(dateOfBooking)) {
                                          //           status = "Completed";
                                          //           color = Colors.green;
                                          //         }
                                          //         return Column(
                                          //           children: [
                                          //             ListTile(
                                          //               leading: IconButton(
                                          //                   onPressed: (() {
                                          //                     showDialog(
                                          //                       context:
                                          //                           context,
                                          //                       builder:
                                          //                           (_context) {
                                          //                         if (bookingList[
                                          //                                     index]
                                          //                                 .fileAvailable !=
                                          //                             false)
                                          //                           return AlertDialog(
                                          //                               content:
                                          //                                   Container(
                                          //                             color: Colors
                                          //                                 .white,
                                          //                             child:
                                          //                                 Row(
                                          //                               mainAxisSize:
                                          //                                   MainAxisSize.min,
                                          //                               children: [
                                          //                                 IconButton(
                                          //                                     onPressed: () {
                                          //                                       // downloadFile(bookingList[index].bookingId);
                                          //                                       Navigator.of(_context).pop();
                                          //                                     },
                                          //                                     icon: Icon(Icons.download)),
                                          //                                 SizedBox(
                                          //                                   width:
                                          //                                       20,
                                          //                                 ),
                                          //                                 IconButton(
                                          //                                     onPressed: () {
                                          //                                       // deleteFileApi(bookingList[index].bookingId);
                                          //                                       Navigator.of(_context).pop();
                                          //                                     },
                                          //                                     icon: Icon(Icons.delete))
                                          //                               ],
                                          //                             ),
                                          //                           ));

                                          //                         return AlertDialog(
                                          //                           content:
                                          //                               Container(
                                          //                             color: Colors
                                          //                                 .white,
                                          //                             child: IconButton(
                                          //                                 onPressed: () => null,
                                          //                                 icon:
                                          //                                     Icon(Icons.upload)),
                                          //                           ),
                                          //                         );
                                          //                       },
                                          //                     );
                                          //                   }),
                                          //                   icon: Icon(Icons
                                          //                       .file_open)),
                                          //               trailing: Container(
                                          //                 padding: EdgeInsets.symmetric(
                                          //                     horizontal:
                                          //                         getProportionateScreenWidth(
                                          //                             12),
                                          //                     vertical:
                                          //                         getProportionateScreenHeight(
                                          //                             6)),
                                          //                 decoration: BoxDecoration(
                                          //                     color: color,
                                          //                     borderRadius:
                                          //                         BorderRadius
                                          //                             .circular(
                                          //                                 3)),
                                          //                 child: Text(status,
                                          //                     style: GoogleFonts.publicSans(
                                          //                         fontSize: 12,
                                          //                         fontWeight:
                                          //                             FontWeight
                                          //                                 .w600,
                                          //                         color: Colors
                                          //                             .white)),
                                          //               ),
                                          //               contentPadding:
                                          //                   EdgeInsets.zero,
                                          //               subtitle: Text(
                                          //                 bookingList[index]
                                          //                         .date +
                                          //                     " | " +
                                          //                     intComputeSlot(int.parse(
                                          //                             bookingList[
                                          //                                     index]
                                          //                                 .slotTime))
                                          //                         .format(
                                          //                             context),
                                          //                 style: GoogleFonts
                                          //                     .publicSans(
                                          //                         fontWeight:
                                          //                             FontWeight
                                          //                                 .w600,
                                          //                         fontSize: 12,
                                          //                         color: Color
                                          //                             .fromARGB(
                                          //                                 255,
                                          //                                 106,
                                          //                                 106,
                                          //                                 106)),
                                          //               ),
                                          //               title: Text(
                                          //                 bookingList[index]
                                          //                     .treatment,
                                          //                 style: GoogleFonts
                                          //                     .publicSans(
                                          //                         fontWeight:
                                          //                             FontWeight
                                          //                                 .w600,
                                          //                         fontSize: 16,
                                          //                         color: Colors
                                          //                             .black),
                                          //               ),
                                          //             ),
                                          //             Divider(
                                          //                 color: Color.fromARGB(
                                          //                     255,
                                          //                     230,
                                          //                     230,
                                          //                     230),
                                          //                 thickness: 0.6),
                                          //           ],
                                          //         );
                                          //       }),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else
                                  return SpinKitPouringHourGlass(
                                      color: Colors.grey);
                              },
                            ),
                          ),
                        ),
                      )
                    : Expanded(
                        flex: 1,
                        child: Container(
                          color: Colors.amber,
                        ))
              ],
            )
          ],
        ),
      ),
    );
  }

  void searchPat(String query) {
    final suggestions = widget.patList.where((pat) {
      final patName = (pat.firstName + " " + pat.lastName).toLowerCase();
      final input = query.toLowerCase();
      return patName.contains(input);
    }).toList();
    setState(() => patientsToDisplay = suggestions);
  }
}

TimeOfDay intComputeSlot(int d) {
  int minutes = d % 100;
  int hours = (d / 100).floor();
  // print("for $d the hour is $hours $minutes");
  TimeOfDay slot = TimeOfDay(hour: hours, minute: minutes);
  return slot;
}

TimeOfDay computeSlot(String d) {
  d = d.padLeft(4, "0");
  int hours = int.parse(d.substring(0, 2));
  int minutes = int.parse(d.substring(2, 4));
  TimeOfDay slot = TimeOfDay(hour: hours, minute: minutes);
  return slot;
}
