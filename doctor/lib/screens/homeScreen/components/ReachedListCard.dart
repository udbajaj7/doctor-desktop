import 'package:doctor/components/urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../Models/DoctorBookings.dart';
import '../../../Models/PatientModel.dart';
import '../../../components/size_config.dart';
import '../../addPatientScreen/AddPatientScreen.dart';
import 'requests.dart';

class ReachedListCard extends StatelessWidget {
  final int bookingID;
  final PatientModel patientModel;
  final DoctorBookingsModel doctorBookingsModel;
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function notifyParent;
  final int minutes;
  final Function showVitalsDialog;
  final String docCategory;

  ReachedListCard(
      this.patientModel,
      this.doctorBookingsModel,
      this.refreshIndicatorKey,
      this.minutes,
      this.bookingID,
      this.scaffoldKey,
      this.notifyParent,
      this.showVitalsDialog,
      this.docCategory);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    int _minutes = minutes;
    TimeOfDay time = computeSlot(int.parse(doctorBookingsModel.slotTime));
    debugPrint("Time for reched list card" + time.toString());
    int hours = 0;
    if (_minutes > 59) {
      hours = (_minutes / 60).floor();
      _minutes -= (hours * 60);
    }
    String _gender = "O";

    if (patientModel.gender == "Male") _gender = "M";
    if (patientModel.gender == "Female") _gender = "F";
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 0,
          blurRadius: 5,
          offset: Offset(0, 0),
        ),
      ]),
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(
            vertical: getProportionateScreenHeight(6),
            horizontal: getProportionateScreenWidth(16)),
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: getProportionateScreenHeight(6),
              horizontal: getProportionateScreenWidth(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                child: Text(
                  doctorBookingsModel.slotNumber.toString(),
                  style: GoogleFonts.publicSans(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                radius: getProportionateScreenWidth(23.5),
                backgroundColor: Colors.black.withOpacity(0.04),
              ),
              SizedBox(width: getProportionateWebScreenWidth(8)),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        patientModel.firstName + " " + patientModel.lastName,
                        maxLines: 4,
                        style: GoogleFonts.publicSans(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.8),
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: getProportionateScreenWidth(4),
                      ),
                      Text(
                        "($_gender, ${patientModel.age})",
                        style: GoogleFonts.publicSans(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        width: getProportionateScreenWidth(6),
                      ),
                      docCategory.toLowerCase() == "dentist"
                          ? doctorBookingsModel.consentForm == false
                              ? SizedBox(
                                  child: Image.asset("assets/images/danger.png",
                                      color: Color(0xFF4D4D4D)),
                                  height: getProportionateScreenWidth(14),
                                  width: getProportionateScreenWidth(14),
                                )
                              : SizedBox(
                                  child: Image.asset("assets/images/tick.png",
                                      color: Color(0xFF4D4D4D)),
                                  height: getProportionateScreenWidth(14),
                                  width: getProportionateScreenWidth(14),
                                )
                          : SizedBox(height: 0),
                    ],
                  ),
                  SizedBox(
                    height: getProportionateScreenHeight(6),
                  ),
                  Text(
                    "${doctorBookingsModel.treatment}",
                    style: GoogleFonts.publicSans(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      SizedBox(height: getProportionateScreenHeight(12) + 11),
                      Skeleton.shade(
                        child: Row(
                          children: [
                            InkWell(
                                onTap: () => showVitalsDialog(patientModel,
                                    doctorBookingsModel.bookingId, context),
                                child: Container(
                                  padding: EdgeInsets.all(
                                      getProportionateScreenWidth(6)),
                                  decoration: BoxDecoration(
                                      color:
                                          Color(0xFF000000).withOpacity(0.05),
                                      border: Border.all(
                                          color: Colors.black, width: 1)),
                                  child: SvgPicture.asset(
                                      "assets/images/iconoir_journal-page.svg",
                                      color: Color(0xFF424242)),
                                )),
                            SizedBox(width: getProportionateScreenWidth(12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(height: getProportionateScreenHeight(6)),
                      Text(
                        "Time Left: $minutes" + " mins",
                        style: GoogleFonts.publicSans(
                            fontSize: 11,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(height: getProportionateScreenHeight(6)),
                      Skeleton.shade(
                        child: TextButton(
                            onPressed: () {
                              showDialog<void>(
                                  context: context,
                                  barrierDismissible:
                                      false, // user must tap button!
                                  builder: (BuildContext _context) {
                                    return AlertDialog(
                                      title: const Text(
                                          'Are you sure you want to Send In?'),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          onPressed: () async {
                                            Navigator.of(_context).pop();
                                          },
                                          child: Text(
                                            "Cancel",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.black)),
                                        ),
                                        TextButton(
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.black)),
                                          child: const Text(
                                            'Confirm',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          onPressed: () async {
                                            Navigator.of(_context).pop();
                                            scaffoldKey
                                                .currentContext!.loaderOverlay
                                                .show();
                                            sendInButtonPressed(
                                                    myProfile.id,
                                                    doctorBookingsModel
                                                        .bookingId,
                                                    bookingID)
                                                .then((value) {
                                              scaffoldKey
                                                  .currentContext!.loaderOverlay
                                                  .hide();
                                              String message;
                                              if (value.contains("Done")) {
                                                debugPrint(
                                                    "sendInButtonCLicked");

                                                message =
                                                    "Patient has been marked as Sent In!";

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content:
                                                            Text(message)));
                                                notifyParent();
                                              } else if (value
                                                  .contains("Error")) {
                                                message =
                                                    "Error while marking patient as Sent In!";
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content:
                                                            Text(message)));
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            },
                            child: Container(
                              width: getProportionateScreenWidth(70),
                              height: getProportionateScreenHeight(24),
                              child: Center(
                                child: Text("Send In",
                                    style: GoogleFonts.publicSans(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.black,
                              minimumSize: Size(0, 0),
                              side: BorderSide(width: 0.3, color: Colors.black),
                            )),
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
