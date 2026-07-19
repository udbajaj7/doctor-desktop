import 'dart:ui';

import 'package:doctor/Models/AddPatientModel.dart';
import 'package:doctor/components/size_config.dart';
import 'package:doctor/screens/bookings/components/patientDetails.dart';
import 'package:doctor/screens/bookings/components/requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../Models/DoctorBookings.dart';
import '../../../Models/PatientModel.dart';
import '../../../components/urls.dart';
import '../../homeScreen/components/duesScreen.dart';

class BookingsBodyWeb extends StatefulWidget {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;
  final Function(AddPatientModel) showAddPatientScreen;
  BookingsBodyWeb(
      {required this.refreshIndicatorKey, required this.showAddPatientScreen});

  @override
  State<BookingsBodyWeb> createState() => _BookingsBodyWebState();
}

class _BookingsBodyWebState extends State<BookingsBodyWeb> {
  bool initPat = false;
  int lastChosenIndex = 0;
  int marked = 0;
  DateTime chosenDate = DateTime.now();
  DateTime dateTime = DateTime.now();
  late Future getBookingFutureResponse;
  var mapper;
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBookingFutureResponse =
        getBookings(myProfile.id, dateToString(chosenDate));
    mapper = new List.generate(3, (index) => index);
  }

  setChosenDateAndRefresh(date) {
    chosenDate = date;
    getBookingFutureResponse =
        getBookings(myProfile.id, dateToString(chosenDate));
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    int day = dateTime.day;
    DateTime x1 = DateTime(dateTime.year, dateTime.month, 0).toUtc();
    int daysInMonth = DateTime(dateTime.year, dateTime.month + 1, 0)
        .toUtc()
        .difference(x1)
        .inDays;
    List<int> days = [day];
    if (daysInMonth < (day + 6)) {
      int diff = (day + 6) - daysInMonth;
      for (int i = 1; i < (7 - diff); i++) {
        days.add(day + i);
      }
      for (int i = 1; i <= diff; i++) {
        days.add(i);
      }
    } else {
      for (int i = 1; i < 7; i++) {
        days.add(day + i);
      }
    }

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(right: BorderSide(color: Colors.grey, width: 1))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: getProportionateScreenHeight(18),
          ),
          Padding(
            padding: EdgeInsets.only(left: getProportionateScreenWidth(10)),
            child: Text(
              "Bookings",
              style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.w700, fontSize: 32),
            ),
          ),
          SizedBox(
            height: getProportionateScreenHeight(8),
          ),
          Padding(
            padding: EdgeInsets.only(left: getProportionateScreenWidth(10)),
            child: Text(
              "Patients sorted according to their date of booking",
              style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  color: Colors.grey),
            ),
          ),
          SizedBox(
            height: getProportionateScreenHeight(8),
          ),
          Divider(color: Colors.grey, thickness: 1),
          SizedBox(
            height: getProportionateScreenHeight(8),
          ),
          Expanded(
            child: Row(
              children: [
                Flexible(
                    fit: FlexFit.loose,
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: getProportionateScreenWidth(10)),
                          child: Text(
                            "Date of Booking",
                            style: GoogleFonts.publicSans(
                                fontWeight: FontWeight.w700, fontSize: 22),
                          ),
                        ),
                        SizedBox(
                          height: getProportionateScreenHeight(20),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: getProportionateScreenWidth(4)),
                          child: SizedBox(
                            height: getProportionateScreenHeight(90),
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: days.length,
                                itemBuilder: ((context, index) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: getProportionateScreenWidth(8)),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          marked = index;
                                          setChosenDateAndRefresh(dateTime
                                              .add(Duration(days: index)));
                                          debugPrint(chosenDate.toString());
                                          patientModel = PatientModel(
                                              id: -1,
                                              email: "",
                                              gender: "",
                                              firstName: "",
                                              lastName: "",
                                              city: "",
                                              age: -1,
                                              phoneNumber: "",
                                              address: "");
                                        });
                                      },
                                      child: SizedBox(
                                        width: getProportionateScreenWidth(45),
                                        height:
                                            getProportionateScreenHeight(20),
                                        child: Column(
                                          children: [
                                            Container(
                                                width:
                                                    getProportionateScreenWidth(
                                                        45),
                                                height:
                                                    getProportionateScreenHeight(
                                                        20),
                                                decoration: BoxDecoration(
                                                  color: marked == index
                                                      ? Colors.black
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(40),
                                                    topRight:
                                                        Radius.circular(40),
                                                  ),
                                                )),
                                            Container(
                                              width:
                                                  getProportionateScreenWidth(
                                                      45),
                                              color: marked == index
                                                  ? Colors.black
                                                  : Colors.white,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    height:
                                                        getProportionateScreenHeight(
                                                            15),
                                                    child: FittedBox(
                                                      child: Text(
                                                          DateFormat("EEEE")
                                                              .format(dateTime
                                                                  .add(Duration(
                                                                      days:
                                                                          index)))
                                                              .substring(0, 3),
                                                          style: GoogleFonts
                                                              .publicSans(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 10,
                                                                  color: marked ==
                                                                          index
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black)),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        getProportionateScreenHeight(
                                                            5),
                                                  ),
                                                  Text(days[index].toString(),
                                                      style: GoogleFonts
                                                          .publicSans(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 20,
                                                              color: marked ==
                                                                      index
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black))
                                                ],
                                              ),
                                            ),
                                            Container(
                                                width:
                                                    getProportionateScreenWidth(
                                                        45),
                                                height:
                                                    getProportionateScreenHeight(
                                                        20),
                                                decoration: BoxDecoration(
                                                  color: marked == index
                                                      ? Colors.black
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(40),
                                                    bottomRight:
                                                        Radius.circular(40),
                                                  ),
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                })),
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("                 "),
                            Text(
                              DateFormat("EEEE").format(chosenDate) +
                                  " " +
                                  DateFormat.MMMM().format(chosenDate) +
                                  " " +
                                  chosenDate.day.toString() +
                                  ", " +
                                  chosenDate.year.toString(),
                              style: GoogleFonts.publicSans(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black),
                            ),
                            InkWell(
                              onTap: () async {
                                final DateTime? date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2015, 8),
                                    lastDate: DateTime(2101));
                                if (date != null && date != dateTime) {
                                  setState(() {
                                    dateTime = date;
                                    setChosenDateAndRefresh(date);
                                    marked = 0;
                                  });
                                }
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Color(0xFF000000).withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Icon(
                                  Icons.calendar_month_sharp,
                                  color: Colors.black,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 30),
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: SingleChildScrollView(
                              physics: AlwaysScrollableScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    "Patients Visited",
                                    style: GoogleFonts.publicSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 22,
                                        color: Colors.black),
                                  ),
                                  SizedBox(
                                    height: 14,
                                  ),
                                  FutureBuilder(
                                    future: getBookingFutureResponse,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.connectionState ==
                                              ConnectionState.done) {
                                        Map<String, List> map =
                                            snapshot.data as Map<String, List>;
                                        List<PatientModel> patList =
                                            map["pats"] as List<PatientModel>;
                                        print(
                                            "length of patList is ${patList.length}");
                                        bool hasData =
                                            patList.length == 0 ? false : true;
                                        if (hasData) {
                                          patientModel = patList[0];
                                        }
                                        List<DoctorBookingsModel> bookList =
                                            map["books"]
                                                as List<DoctorBookingsModel>;

                                        return hasData == true
                                            ? bookingListWidget(
                                                patList, bookList)
                                            : (Center(
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      height: 60,
                                                    ),
                                                    Image.asset(
                                                      "assets/images/nopat.png",
                                                      width: 150,
                                                      height: 150,
                                                    ),
                                                    Text(
                                                      "No Bookings on this Day!",
                                                      style: GoogleFonts
                                                          .publicSans(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 18),
                                                    ),
                                                  ],
                                                ),
                                              ));
                                      } else {
                                        return Column(
                                          children: [
                                            SpinKitPouringHourGlass(
                                              color: Colors.grey,
                                            ),
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.4)
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                SizedBox(width: getProportionateScreenWidth(16)),
                patientModel.id != -1
                    ? PatientDetailWeb(
                        patientModel, widget.showAddPatientScreen)
                    : Expanded(child: Container())
              ],
            ),
          ),
        ],
      ),
    );
  }

  initializeMapper(List<List<PatientModel>> patList,
      List<List<DoctorBookingsModel>> bookList) {
    //Maps the index of slots to actual index of tabs in case of empty time slots
    if (patList[0].length == 0 && patList[1].length != 0) {
      mapper[0] = 0;
      mapper[1] = 0;
      mapper[2] = 1;
    } else if (patList[0].length == 0 && patList[1].length == 0) {
      mapper[0] = 0;
      mapper[1] = 0;
      mapper[2] = 0;
    } else {
      mapper[0] = 0;
      mapper[1] = 1;
      mapper[2] = 2;
    }
  }

  Widget bookingListWidget(
      List<PatientModel> patList, List<DoctorBookingsModel> bookList) {
    List<List<PatientModel>> _patList = List.generate(3, (index) => []);
    List<List<DoctorBookingsModel>> _bookList = List.generate(3, (index) => []);

    for (int i = 0; i < bookList.length; i++) {
      if (bookList[i].batchNumber == 0) {
        _bookList[0].add(bookList[i]);
        _patList[0].add(patList[i]);
      } else if (bookList[i].batchNumber == 1) {
        _bookList[1].add(bookList[i]);
        _patList[1].add(patList[i]);
      } else if (bookList[i].batchNumber == 2) {
        _bookList[2].add(bookList[i]);
        _patList[2].add(patList[i]);
      }
    }
    initializeMapper(_patList, _bookList);

    final List<String> tabTitle = [
      "Morning Slots",
      "Afternoon Slots",
      "Evening Slots"
    ];

    List<Tab> _customTabs = List.generate(
            3,
            (index) => Tab(
                child: Text(tabTitle[index],
                    style: GoogleFonts.publicSans(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)))),
        _finalTabs = [];

    List<Widget> _customWidgets = List.generate(
            3,
            (index) =>
                individualList(_patList[index], _bookList[index], index)),
        _finalWidgets = [];
    List<int> removalIndex = [];

    int length = 0;

    for (int i = 0; i < 3; i++) {
      if (_bookList[i].isNotEmpty) {
        if (!initPat) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              patientModel = _patList[i][0];
            });
          });
          initPat = true;
        }
        length++;
      } else {
        removalIndex.add(i);
      }
    }

    bool b = true;

    for (int i = 0; i < 3; i++) {
      if (i == lastChosenIndex) b = !b;

      if (!removalIndex.contains(i)) {
        _finalTabs.add(_customTabs[i]);
        _finalWidgets.add(_customWidgets[i]);
      } else if (b) lastChosenIndex--;
    }

    return DefaultTabController(
        length: length,
        initialIndex: lastChosenIndex,
        child: Column(
          children: [
            TabBar(
              tabs: _finalTabs,
            ),
            SizedBox(
              height: SizeConfig.screenHeight * 0.4,
              child: TabBarView(children: _finalWidgets),
            ),
          ],
        ));
  }

  Widget individualList(List<PatientModel> patList,
      List<DoctorBookingsModel> bookList, int slotIndex) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(16)),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: patList.length,
        itemBuilder: (context, index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            patientModel = patList[index];
                            lastChosenIndex = mapper[slotIndex];
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          patList[index].firstName +
                              " " +
                              patList[index].lastName,
                          style: GoogleFonts.publicSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black),
                        ),
                        subtitle: Text(
                          computeSlot(bookList[index].slotTime).format(context),
                          style: GoogleFonts.publicSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.black),
                        ),
                        trailing: Container(
                          height: 47,
                          width: 47,
                          decoration: BoxDecoration(
                            color: Color(0xFF000000).withOpacity(0.04),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Text(
                              (index + 1).toString(),
                              style: GoogleFonts.publicSans(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () {
                        getBalance(bookList[index].bookingId).then((value) {
                          if (value == null)
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    "Could not open the finances due to some error")));
                          else
                            showDialog(
                              context: context,
                              builder: (context) {
                                return BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: DuesScreen(
                                    showAddPatientScreen:
                                        widget.showAddPatientScreen,
                                    refreshIndicatorKey:
                                        widget.refreshIndicatorKey,
                                    notes: bookList[index].notes,
                                    bookingId: bookList[index].bookingId,
                                    balance: value.item1,
                                    fName: patList[index].firstName,
                                    lName: patList[index].lastName,
                                    age: patList[index].age,
                                    phoneNumber: patList[index].phoneNumber,
                                    gender: patList[index].gender,
                                    treatment: '',
                                    installment: value.item2,
                                    fileAvailable:
                                        bookList[index].fileAvailable,
                                    address: patList[index].address,
                                  ),
                                );
                              },
                            );
                        });
                      },
                    ),
                  ],
                ),
              ),
              Divider(
                  color: Color.fromARGB(255, 234, 234, 234), thickness: 0.6),
            ],
          );
        },
        physics: AlwaysScrollableScrollPhysics(),
      ),
    );
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
