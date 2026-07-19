import 'package:doctor/Models/AddPatientModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../components/size_config.dart';
import '../../../components/urls.dart';
import '../../homeScreen/components/bookingQueue.dart';
import '../../homeScreen/components/reachedQueue.dart';
import '../../homeScreen/components/requests.dart';

class Queues extends StatefulWidget {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final Function onRefresh;
  final Function(AddPatientModel) showAddPatientScreen;
  final Function showVitalsDialog;
  Queues(this.refreshIndicatorKey, this._scaffoldKey, this.onRefresh,
      this.showAddPatientScreen, this.showVitalsDialog);

  @override
  State<Queues> createState() => _QueuesState();
}

class _QueuesState extends State<Queues> {
  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    List month = [
      "Jan",
      "Feb",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "Sept",
      "Oct",
      "Nov",
      "Dec"
    ];
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(right: BorderSide(color: Colors.grey, width: 1))),
      height: SizeConfig.screenHeight,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              margin: const EdgeInsets.only(left: 14.0, right: 14, top: 14),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Appointments",
                        style: GoogleFonts.publicSans(
                            fontSize: getProportionateWebScreenHeight(32),
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: getProportionateWebScreenHeight(10),
                      ),
                      Text(
                        "${DateTime.now().day} ${month[DateTime.now().month - 1]},${DateTime.now().year}",
                        style: GoogleFonts.publicSans(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF6B6B6B),
                            fontSize: getProportionateWebScreenHeight(20)),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Color(0xFF3E3E3E))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                "assets/images/addDelay.png",
                                height: getProportionateWebScreenHeight(15),
                                width: getProportionateWebScreenHeight(15),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                "Add Delay",
                                style: GoogleFonts.publicSans(
                                    fontSize:
                                        getProportionateWebScreenHeight(15),
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        onPressed: () async {
                          TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(hour: 0, minute: 15),
                            initialEntryMode: TimePickerEntryMode.input,
                            builder: (context, childWidget) {
                              return MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                      // Using 24-Hour format
                                      alwaysUse24HourFormat: true),
                                  // If you want 12-Hour format, just change alwaysUse24HourFormat to false o
                                  //remove all the builder argument
                                  child: childWidget!);
                            },
                          );

                          print("time picked for delay ");
                          print(picked);
                          if (picked == null) {
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => WillPopScope(
                                        onWillPop: _onWillPop,
                                        child: SpinKitPouringHourGlass(
                                          color: Colors.grey,
                                        ),
                                      )),
                            );
                          }
                          var result = await addDelay(myProfile.id, picked!);
                          print("after future");
                          print(result);
                          Navigator.pop(context);
                          if (result != "Success")
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              padding: EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 8),
                              content: Text(
                                  "There was some error and delay could not be added"),
                            ));
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: getProportionateWebScreenWidth(10),
                  ),
                  TextButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Color(0xFF3E3E3E))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/addPatient.png",
                            height: getProportionateWebScreenHeight(15),
                            width: getProportionateWebScreenHeight(15),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            "Add Patient",
                            style: GoogleFonts.publicSans(
                                fontSize: getProportionateWebScreenHeight(15),
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      widget.showAddPatientScreen(AddPatientModel(
                          "", "", null, "", "Checkup", "Male", true, ""));
                    },
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.grey,
              height: 20,
              thickness: 1,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    height: SizeConfig.screenHeight * 0.85,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Reached Patients",
                            style: GoogleFonts.inter(
                                fontSize: getProportionateWebScreenHeight(22),
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: getProportionateScreenHeight(20),
                          ),
                          Container(
                            color: Colors.white,
                            margin: EdgeInsets.only(left: 4, right: 4, top: 4),
                            child: ReachedQueue(
                              widget.refreshIndicatorKey,
                              widget._scaffoldKey,
                              widget.showAddPatientScreen,
                              widget.onRefresh,
                              widget.showVitalsDialog,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: SizeConfig.screenHeight * 0.85,
                  color: Colors.grey,
                ),
                Expanded(
                  child: SizedBox(
                    height: SizeConfig.screenHeight * 0.85,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            "Yet to reach",
                            style: GoogleFonts.inter(
                                fontSize: getProportionateWebScreenHeight(22),
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: getProportionateScreenHeight(20),
                          ),
                          Container(
                            color: Colors.white,
                            margin: EdgeInsets.only(left: 4, right: 4, top: 4),
                            child: BookingQueue(widget.refreshIndicatorKey,
                                widget._scaffoldKey, widget.onRefresh),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
