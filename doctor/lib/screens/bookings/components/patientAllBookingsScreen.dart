import 'package:doctor/Models/DoctorBookings.dart';
import 'package:doctor/Models/PatientModel.dart';
import 'package:doctor/components/size_config.dart';
import 'package:doctor/screens/bookings/components/requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../addPatientScreen/AddPatientScreen.dart';

class PatientAllBookingsScreen extends StatelessWidget {
  final PatientModel patientModel;
  PatientAllBookingsScreen(this.patientModel);
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light),
        title: Text(patientModel.firstName + " " + patientModel.lastName,
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontSize: 20)),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: Transform.translate(
          offset: Offset(14, 0),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(width: 1, color: Colors.black)),
              child: Icon(Icons.chevron_left_outlined, color: Colors.black),
            ),
          ),
        ),
        actions: [
          Transform.translate(
            offset: Offset(-14, 0),
            child: InkWell(
              onTap: () {
                makePhoneCall(patientModel.phoneNumber);
              },
              child: Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(width: 0, color: Colors.black)),
                child: Icon(
                  Icons.call,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.12,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: 8,
                offset: Offset(0, 0),
              ),
            ],
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddPatientScreen( //// add refresh function callback here todo
                        goBack: () => Navigator.pop(context),
                            firstName: patientModel.firstName,
                            lastName: patientModel.lastName,
                            phoneNumber: patientModel.phoneNumber,
                            age: patientModel.age,
                            gender: patientModel.gender,
                            treatment: "",
                            getEarly: true,
                            refreshIndicatorKey: null,
                            reschedule: true,
                            address: patientModel.address)));
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.84,
                height: MediaQuery.of(context).size.height * 0.06,
                color: Colors.black,
                child: Center(
                    child: Text(
                  "Book Another Appointment",
                  style: GoogleFonts.publicSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.white),
                )),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder(
          future: getPatientAllBookings(patientModel.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<DoctorBookingsModel> bookingList =
                  snapshot.data as List<DoctorBookingsModel>;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: getProportionateScreenHeight(12)),
                  Text("Patients Details",
                      style: GoogleFonts.publicSans(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontSize: 18)),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.014,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Age:",
                                style: GoogleFonts.publicSans(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14)),
                            Text(patientModel.age.toString(),
                                style: GoogleFonts.publicSans(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600))
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Gender:",
                                style: GoogleFonts.publicSans(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14)),
                            Text(patientModel.gender,
                                style: GoogleFonts.publicSans(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600))
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Mobile:",
                                style: GoogleFonts.publicSans(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14)),
                            SelectableText(patientModel.phoneNumber.toString(),
                                style: GoogleFonts.publicSans(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600))
                          ],
                        ),
                        SizedBox(height: 20)
                      ],
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(12)),
                  Text("Booking Details",
                      style: GoogleFonts.publicSans(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontSize: 18)),
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: bookingList.length,
                        itemBuilder: (context, index) {
                          DateTime dateOfBooking = convertStringToDateTime(
                              bookingList[index].date,
                              int.parse(bookingList[index].slotTime));
                          Color color = Color.fromARGB(255, 226, 169, 23);
                          String status = "Upcoming";
                          if (DateTime.now().isAfter(dateOfBooking)) {
                            status = "Completed";
                            color = Colors.green;
                          }
                          return Column(
                            children: [
                              ListTile(
                                trailing: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: getProportionateScreenWidth(12),
                                      vertical: getProportionateScreenHeight(6)),
                                  decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(3)),
                                  child: Text(status,
                                      style: GoogleFonts.publicSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                ),
                                contentPadding: EdgeInsets.zero,
                                subtitle: Text(
                                  bookingList[index].date +
                                      " | " +
                                      computeSlot(int.parse(
                                              bookingList[index].slotTime))
                                          .format(context),
                                  style: GoogleFonts.publicSans(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: Color.fromARGB(255, 106, 106, 106)),
                                ),
                                title: Text(
                                  bookingList[index].treatment,
                                  style: GoogleFonts.publicSans(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.black),
                                ),
                              ),
                              Divider(
                                  color: Color.fromARGB(255, 230, 230, 230),
                                  thickness: 0.6),
                            ],
                          );
                        }),
                  ),
                ],
              );
            } else
              return SpinKitPouringHourGlass(color: Colors.grey);
          },
        ),
      ),
    );
  }
}

TimeOfDay computeSlot(int d) {
  int minutes = d % 100;
  int hours = (d / 100).floor();
  // print("for $d the hour is $hours $minutes");
  TimeOfDay slot = TimeOfDay(hour: hours, minute: minutes);
  return slot;
}

DateTime convertStringToDateTime(String date, int time) {
  List<String> list = date.split("-");
  int minutes = time % 100;
  int hours = (time / 100).floor();
  DateTime dateTime = DateTime(int.parse(list[2]), int.parse(list[1]),
      int.parse(list[0]), hours, minutes);
  return dateTime;
}

Future<void> makePhoneCall(String phoneNumber) async {
  await FlutterPhoneDirectCaller.callNumber(phoneNumber);
}
