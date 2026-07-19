import 'package:doctor/screens/homeScreen/components/requests.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../Models/Appointment.dart';
import '../../../Models/DoctorBookings.dart';
import '../../../Models/PatientModel.dart';
import '../../../components/size_config.dart';
import '../../../components/urls.dart';
import '../../../providers/appointmentProvider.dart';
import 'bookingListCard.dart';

class BookingQueue extends StatefulWidget {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final Function refreshParent;
  BookingQueue(this.refreshIndicatorKey, this._scaffoldKey, this.refreshParent);

  @override
  State<BookingQueue> createState() => _BookingQueueState();
}

class _BookingQueueState extends State<BookingQueue> {
  late Future<String> getReachedQueueFutureResponse,
      getBookingQueueFutureResponse;
  late List<PatientModel> patListReached;
  final dummyPat =
          List.generate(8, (index) => dummyPatForSkeleton, growable: true),
      dummyBooking =
          List.generate(8, (index) => dummyBookingForSkeleton, growable: true);

  @override
  void initState() {
    super.initState();
    getBookingQueueFutureResponse = getBookingQueue(myProfile.id, context);
    getReachedQueueFutureResponse = getReachedQueue(myProfile.id, context);
  }

  void onRefresh() async {
    print("get reached queue ka on refresh is called");
    setState(() {
      getBookingQueueFutureResponse = getBookingQueue(myProfile.id, context);
    });
  }

  void refreshReached() async {
    setState(() {
      getReachedQueueFutureResponse = getReachedQueue(myProfile.id, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    int id = prefs.getInt("currentDocId") ?? -1;
    myProfile.id = id;
    return Consumer<AppointmentProvider>(
        builder: (context, appointmentProvider, _) {
      return FutureBuilder(
        future: getBookingQueueFutureResponse,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            bool hasData = false;
            List<Appointment> bookings = appointmentProvider.getBookAppoin;
            List<PatientModel> bookingPatList = [];
            List<DoctorBookingsModel> bookingBookList = [];

            bookings.forEach((element) {
              bookingPatList.add(element.patientModel);
              bookingBookList.add(element.doctorBookingsModel);
            });

            if (bookingPatList.length > 0) {
              hasData = true;
            }
            debugPrint(bookingPatList.length.toString());
            return SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: hasData == true
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: bookingPatList.length,
                        itemBuilder: (context, index) {
                          return BookingListCard(
                              bookingPatList[index],
                              bookingBookList[index],
                              context,
                              widget.refreshIndicatorKey,
                              widget._scaffoldKey,
                              refreshReached);
                        })
                    : (Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: getProportionateScreenHeight(60),
                            ),
                            Image.asset(
                              "assets/images/nopat.png",
                              width: getProportionateScreenWidth(150),
                              height: getProportionateScreenHeight(150),
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
                      )));
          } else {
            return Skeletonizer(
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: dummyBooking.length,
                  itemBuilder: (context, index) {
                    return BookingListCard(
                        dummyPat[index],
                        dummyBooking[index],
                        context,
                        widget.refreshIndicatorKey,
                        widget._scaffoldKey,
                        refreshReached);
                  }),
            );
          }
        },
      );
    });
  }
}
