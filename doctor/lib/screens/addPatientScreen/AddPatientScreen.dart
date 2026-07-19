import 'dart:convert';
import 'dart:ui';
import 'package:doctor/components/size_config.dart';
import 'package:doctor/components/urls.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

import '../../components/customButton.dart';

class AddPatientScreen extends StatefulWidget {
  String firstName = "",
      lastName = "",
      phoneNumber = "",
      gender = "Male",
      address = "";
  int? age;
  String treatment;
  bool getEarly = true;
  GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;
  Function? refreshParent;
  bool reschedule;
  final Function goBack;

  AddPatientScreen(
      {required this.firstName,
      required this.lastName,
      required this.phoneNumber,
      required this.age,
      required this.gender,
      required this.treatment,
      required this.getEarly,
      required this.refreshIndicatorKey,
      required this.reschedule,
      required this.goBack,
      required this.address,
      this.refreshParent});
  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  bool search = true;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController c = TextEditingController();
  late bool useTreatmentOrNot;
  String treatment = "Checkup", walkIn = "Walk In";
  List<String> walkInAvailable = ["Walk In", "Appointment"];
  final itemkey = GlobalKey();
  final itemController = ItemScrollController();
  List<String> genderList = ["Male", "Female", "Others"];
  String select = "Male";
  late bool pop;
  DateTime lastRefreshTime = DateTime.now();
  TimeOfDay _selectedSlot = TimeOfDay(hour: 0, minute: 0);
  bool _avail = true;
  int checkedIndex = -1, checkedBatch = -1;
  String selectedSalutation = "Mr";
  List<String> salutationsList = ['Mr', 'Miss', 'Mrs', 'Mstr', 'Dr'];

  List<TextEditingController> list = List.filled(4, TextEditingController());

  InputDecoration inputDecoration = InputDecoration(
      enabledBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Colors.black, style: BorderStyle.solid)),
      focusedBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Colors.black, style: BorderStyle.solid)),
      border: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Colors.black, style: BorderStyle.solid)));

  TextStyle headingStyle = GoogleFonts.publicSans(
      fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey);
  TextStyle inputStyle = GoogleFonts.publicSans(
      fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black);
  late TimeOfDay selectedSlot;

  late int marked;
  int numSlots = 1;

  List<DateTime> datesAvailable = [];
  late Future<List<DateTime>> getAvailableDates;
  DateTime selectedDate = DateTime(-1);
  late Tuple2<int, TimeOfDay> selectedSlotForBooking; //<batch,slot time>
  TextEditingController _controller = TextEditingController();
  static final _formKey = GlobalKey<FormState>();
  late Future getEaliestSlotFutureResponse;
  late Future? getAvailSlotsFutureResponse;

  @override
  void initState() {
    super.initState();

    List<String> fNames = widget.firstName.split(" ");
    for (int i = 0; i < salutationsList.length; i++) {
      if (fNames[0] == salutationsList[i]) {
        selectedSalutation = fNames[0];
        widget.firstName = widget.firstName.replaceFirst(fNames[0] + " ", "");
        break;
      }
    }

    list[0] = TextEditingController.fromValue(
        TextEditingValue(text: widget.firstName));
    list[1] = TextEditingController.fromValue(
        TextEditingValue(text: widget.lastName));
    if (widget.age != null)
      list[2] = TextEditingController.fromValue(
          TextEditingValue(text: widget.age.toString()));

    list[3] =
        TextEditingController.fromValue(TextEditingValue(text: widget.address));

    if (widget.firstName != "") search = false;

    marked = 0;
    pop = widget.firstName == "" ? false : true;
    numSlots = 1;
    _controller.text = "1";
    getAvailableDates = _getAvailDates(myProfile.id);
    getEaliestSlotFutureResponse = getEarliestSlot(myProfile.id);
    c.text = widget.phoneNumber;
    print(widget.treatment);
    print(widget.treatment.length);
    treatment = widget.treatment.length == 0 ? treatment : widget.treatment;
  }

  @override
  Widget build(BuildContext context) {
    if (myProfile.category == 'Dentist') {
      useTreatmentOrNot = true;
    } else {
      useTreatmentOrNot = false;
    }
    select = widget.gender.length == 0 ? "Male" : widget.gender;
    widget.gender = select;
    int day = DateTime.now().day;
    DateTime x1 =
        DateTime(DateTime.now().year, DateTime.now().month, 0).toUtc();
    int daysInMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0)
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

    SizeConfig().init(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
            actions: actionsList(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7.19),
            ),
            backgroundColor: Colors.white,
            title: buildTitle(),
            content: content()),
      ),
    );
  }

  Widget content() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (_) {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SizedBox(
        width: SizeConfig.screenWidth,
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: getProportionateScreenHeight(24),
              horizontal: getProportionateScreenWidth(16)),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildPatDetails(),
                    SizedBox(width: getProportionateScreenWidth(8)),
                    Container(
                        color: Colors.grey,
                        width: 1,
                        height: SizeConfig.screenHeight * 0.65),
                    SizedBox(width: getProportionateScreenWidth(8)),
                    slotHalf()
                  ],
                ),
                SizedBox(
                  height: getProportionateScreenHeight(16),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget slotHalf() {
    return SizedBox(
      height: SizeConfig.screenHeight * 0.65,
      width: SizeConfig.screenWidth * 0.314,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                "Book earliest slot",
                style: GoogleFonts.publicSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.black),
              ),
              Checkbox(
                  activeColor: Colors.black,
                  tristate: false,
                  value: widget.getEarly,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  onChanged: (value) {
                    setState(() {
                      if (!value!)
                        _selectedSlot = TimeOfDay(hour: 0, minute: 0);
                      print(
                          "setting state for get early and calling set state");
                      widget.getEarly = value!;
                    });
                  }),
            ],
          ),
          widget.getEarly == true ? buildEarly() : buildSlots(),
          SizedBox(
            height: getProportionateScreenHeight(24),
          ),
          Divider(
            thickness: 0.6,
            color: Color.fromARGB(255, 234, 234, 234),
          ),
          widget.getEarly == false
              ? Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Estimated Time of \nAppointment:",
                        style: GoogleFonts.publicSans(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.black),
                      ),
                      (_selectedSlot != TimeOfDay(hour: 0, minute: 0) &&
                              _selectedSlot != TimeOfDay(hour: -1, minute: 99))
                          ? FutureBuilder(
                              future: fetchEstimatedTime(
                                  myProfile.id,
                                  convertDateToString(selectedDate),
                                  _selectedSlot.hour.toString() +
                                      _selectedSlot.minute
                                          .toString()
                                          .padLeft(2, "0")),
                              builder: (context, snapshot) {
                                String amOrPm = "";
                                if (snapshot.hasData) {
                                  String estimatedTime =
                                      snapshot.data as String;
                                  int value =
                                      int.parse(estimatedTime.substring(0, 2));
                                  if (value >= 12) {
                                    if (value != 12) {
                                      estimatedTime = (value - 12).toString() +
                                          estimatedTime.substring(2);
                                    }
                                    amOrPm = " PM";
                                  } else
                                    amOrPm = "AM";
                                  return TextButton(
                                      onPressed: null,
                                      child: Text(estimatedTime + amOrPm,
                                          style: GoogleFonts.publicSans(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600)),
                                      style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  getProportionateScreenWidth(
                                                      26),
                                              vertical:
                                                  getProportionateScreenHeight(
                                                      16)),
                                          backgroundColor: Colors.grey[200]));
                                } else
                                  return Center(
                                      child: SpinKitCircle(color: Colors.grey));
                              },
                            )
                          : TextButton(
                              onPressed: null,
                              child: Text("--:--",
                                  style: GoogleFonts.publicSans(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600)),
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          getProportionateScreenWidth(26),
                                      vertical:
                                          getProportionateScreenHeight(16)),
                                  backgroundColor: Colors.grey[200])),
                    ],
                  ),
                )
              : SizedBox(height: 0),
        ],
      ),
    );
  }

  Widget buildSlots() {
    return Column(
      children: [
        (!myProfile.category.toLowerCase().contains("dentist") ||
                (myProfile.category.toLowerCase().contains("dentist") &&
                    treatment == 'Other'))
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "Number of Slots",
                    style: GoogleFonts.publicSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.black),
                  ),
                  SizedBox(
                    width: getProportionateScreenWidth(20),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.04,
                          height: MediaQuery.of(context).size.height * 0.038,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            controller: _controller,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: false,
                              signed: true,
                            ),
                          ),
                        ),
                        Container(
                          height: getProportionateScreenHeight(38),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: InkWell(
                                  child: Icon(
                                    Icons.arrow_drop_up,
                                    size: 18.0,
                                  ),
                                  onTap: () {
                                    int currentValue =
                                        int.parse(_controller.text);
                                    setState(() {
                                      currentValue++;
                                      numSlots = currentValue;
                                      _controller.text = (currentValue)
                                          .toString(); // incrementing value
                                    });
                                  },
                                ),
                              ),
                              InkWell(
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  size: 18.0,
                                ),
                                onTap: () {
                                  int currentValue =
                                      int.parse(_controller.text);
                                  setState(() {
                                    //print("Setting state");
                                    currentValue--;
                                    numSlots =
                                        currentValue > 1 ? currentValue : 1;
                                    _controller.text =
                                        (currentValue > 1 ? currentValue : 1)
                                            .toString(); // decrementing value
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Container(),
        FutureBuilder(
            future: getAvailableDates,
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
                print("got the future data of available dates ${myProfile.id}");
                // print(snapshot.data);
                datesAvailable = snapshot.data as List<DateTime>;

                if (datesAvailable.length == 0) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Center(
                      child: Text(
                        "No Dates Available!",
                        style: GoogleFonts.publicSans(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                      ),
                    ),
                  );
                } else {
                  if (selectedDate.year == -1) {
                    selectedDate = datesAvailable[0];
                    getAvailSlotsFutureResponse = _getAvailSlots(
                        convertDateToString(selectedDate), myProfile.id);
                  }
                  return Column(
                    children: [
                      dateBuilder(datesAvailable),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () async {
                            final DateTime? date = await showDatePicker(
                                selectableDayPredicate: (day) {
                                  if (day.compareTo(datesAvailable[
                                          datesAvailable.length - 1]) <
                                      0)
                                    return false;
                                  else
                                    return true;
                                },
                                context: context,
                                initialDate:
                                    datesAvailable[datesAvailable.length - 1],
                                firstDate: DateTime(2015, 8),
                                lastDate: DateTime(2101));

                            if (date != null &&
                                !datesAvailable.contains(date)) {
                              setState(() {
                                datesAvailable.add(date);
                                datesAvailable.sort();
                                selectedDate = date;
                                marked = datesAvailable.indexOf(date);
                                scrollToItem(marked);
                              });
                            }
                          },
                          child: Container(
                            height: getProportionateScreenHeight(40),
                            width: getProportionateScreenWidth(40),
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
                      ),
                      FutureBuilder(
                          future: getAvailSlotsFutureResponse,
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.connectionState ==
                                    ConnectionState.done) {
                              List<List<Tuple2<TimeOfDay, bool>>>
                                  batchWiseSlots = snapshot.data
                                      as List<List<Tuple2<TimeOfDay, bool>>>;

                              if (batchWiseSlots.length == 0)
                                return Center(
                                    child: Text(
                                  "No slots available for today!",
                                  style: GoogleFonts.publicSans(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ));

                              return SizedBox(
                                height: SizeConfig.screenHeight * 0.3,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      for (int i = 0;
                                          i < batchWiseSlots.length;
                                          i++)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            i == 0
                                                ? Text(
                                                    "Morning Slots",
                                                    style:
                                                        GoogleFonts.publicSans(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 14),
                                                  )
                                                : i == 1
                                                    ? Text(
                                                        "Afternoon Slots",
                                                        style: GoogleFonts
                                                            .publicSans(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 14),
                                                      )
                                                    : Text(
                                                        "Evening Slots",
                                                        style: GoogleFonts
                                                            .publicSans(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 14),
                                                      ),
                                            GridView.builder(
                                              itemBuilder: (context, index) {
                                                return slot(
                                                    batchWiseSlots[i]
                                                        .elementAt(index)
                                                        .item1,
                                                    batchWiseSlots[i]
                                                        .elementAt(index)
                                                        .item2,
                                                    index,
                                                    i,
                                                    convertDateToString(
                                                        selectedDate));
                                              },
                                              itemCount:
                                                  batchWiseSlots[i].length,
                                              shrinkWrap: true,
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 4,
                                                      mainAxisExtent: 65),
                                              scrollDirection: Axis.vertical,
                                              physics:
                                                  AlwaysScrollableScrollPhysics(),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            } else if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                width: double.infinity,
                                child: Center(
                                    child: SpinKitChasingDots(
                                  color: Colors.grey,
                                )),
                              );
                            } else
                              return Container(
                                width: double.infinity,
                                child: Center(
                                    child: SpinKitChasingDots(
                                  color: Colors.grey,
                                )),
                              );
                          })
                    ],
                  );
                }
              } else
                return Container(
                  child: Center(
                      child: SpinKitChasingDots(
                    color: Colors.grey,
                  )),
                );
            }),
      ],
    );
  }

  Widget buildEarly() {
    return FutureBuilder(
        future: getEaliestSlotFutureResponse,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            EarlyResponse earlyResponse = snapshot.data as EarlyResponse;

            _selectedSlot = (earlyResponse.slotTime != null)
                ? computeSlot(earlyResponse.slotTime!)
                : TimeOfDay(hour: -1, minute: -1);

            var estimatedTime = "No Slots Left!";
            if (earlyResponse.slotTime != -1)
              estimatedTime = earlyResponse.estTime.toString();
            String amOrpm = "";
            if (estimatedTime != "No Slots Left!") {
              print("Estimated time is $estimatedTime");
              var timings = estimatedTime.split(":");
              var intTimings = [int.parse(timings[0]), int.parse(timings[1])];

              if (intTimings[0] >= 12) {
                amOrpm = " PM";
              } else
                amOrpm = " AM";

              if (intTimings[0] == 0)
                intTimings[0] = intTimings[0] + 12;
              else if (intTimings[0] > 12) intTimings[0] = intTimings[0] - 12;

              estimatedTime = intTimings[0].toString() + ":" + timings[1];
            }

            return Padding(
              padding: EdgeInsets.only(left: getProportionateScreenWidth(12)),
              child: Column(
                children: [
                  SizedBox(
                    height: getProportionateScreenHeight(16),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        estimatedTime != "No Slots Left!"
                            ? "Estimated Time of \nAppointment:"
                            : estimatedTime,
                        style: GoogleFonts.publicSans(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.black),
                      ),
                      estimatedTime != "No Slots Left!"
                          ? TextButton(
                              onPressed: null,
                              child: Text(estimatedTime + amOrpm,
                                  style: GoogleFonts.publicSans(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600)),
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          getProportionateScreenWidth(26),
                                      vertical:
                                          getProportionateScreenHeight(16)),
                                  backgroundColor: Colors.grey[200]))
                          : SizedBox(height: 0),
                    ],
                  )
                ],
              ),
            );
          } else
            return SpinKitPouringHourGlass(color: Colors.grey);
        });
  }

  Future scrollToItem(index) async {
    itemController.scrollTo(index: index, duration: Duration(seconds: 1));
  }

  Widget dateBuilder(List<DateTime> days) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: getProportionateScreenHeight(0.1 * 812),
        child: ScrollablePositionedList.builder(
            itemScrollController: itemController,
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            itemBuilder: ((context, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 5),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _selectedSlot = TimeOfDay(hour: 0, minute: 0);
                      marked = index;
                      selectedDate = days[index];
                      getAvailSlotsFutureResponse = _getAvailSlots(
                          convertDateToString(selectedDate), myProfile.id);
                    });
                  },
                  child: SizedBox(
                    width: getProportionateScreenWidth(0.12 * 375),
                    height: getProportionateScreenHeight(0.1 * 812),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            width: getProportionateScreenWidth(0.12 * 375),
                            height: getProportionateScreenHeight(0.015 * 812),
                            decoration: BoxDecoration(
                              color:
                                  marked == index ? Colors.black : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                            )),
                        Container(
                          height: getProportionateScreenHeight(0.07 * 812),
                          width: getProportionateScreenWidth(0.12 * 375),
                          color: marked == index ? Colors.black : Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height:
                                    getProportionateScreenHeight(0.01 * 812),
                                child: FittedBox(
                                  child: Text(
                                      DateFormat("EEEE")
                                          .format(days[index])
                                          .substring(0, 3),
                                      style: GoogleFonts.publicSans(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                          color: marked == index
                                              ? Colors.white
                                              : Colors.black)),
                                ),
                              ),
                              SizedBox(
                                height:
                                    getProportionateScreenHeight(0.01 * 812),
                              ),
                              SizedBox(
                                height:
                                    getProportionateScreenHeight(0.025 * 812),
                                child: FittedBox(
                                  child: Text(days[index].day.toString(),
                                      style: GoogleFonts.publicSans(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                          color: marked == index
                                              ? Colors.white
                                              : Colors.black)),
                                ),
                              ),
                              SizedBox(
                                height:
                                    getProportionateScreenHeight(0.015 * 812),
                                child: FittedBox(
                                  child: Text(
                                      DateFormat("MMM").format(days[index]),
                                      style: GoogleFonts.publicSans(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                          color: marked == index
                                              ? Colors.white
                                              : Colors.black)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            width: getProportionateScreenWidth(0.12 * 375),
                            height: getProportionateScreenHeight(0.015 * 812),
                            decoration: BoxDecoration(
                              color:
                                  marked == index ? Colors.black : Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              );
            })),
      ),
    );
  }

  Widget slot(TimeOfDay selectedSlot, bool avail, int index, int batchNo,
      String selectedDay) {
    bool checked = false;
    if ((index == checkedIndex && batchNo == checkedBatch) ||
        _selectedSlot == selectedSlot) {
      checked = true;
    }

    if (_selectedSlot == TimeOfDay(hour: -1, minute: -1) ||
        _selectedSlot == TimeOfDay(hour: 0, minute: 0)) {
      checked = false;
    }

    return InkWell(
      onTap: () {
        if (avail) {
          setState(() {
            checkedIndex = index;
            checkedBatch = batchNo;
            _selectedSlot = selectedSlot;
            _avail = avail;
          });
        } else
          return;
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.05,
        width: MediaQuery.of(context).size.height * 0.1,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(getProportionateScreenWidth(2)),
            border: checked == false
                ? (Border.all(color: avail ? Colors.black : Colors.white))
                : Border.all(color: Colors.white),
            color: checked == false
                ? (avail ? Colors.white : Color(0xFFF3F3F3))
                : Colors.black),
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Center(
          child: Text(
            selectedSlot.format(context),
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: checked == false
                    ? (avail ? Colors.black : Color(0xFF7A7A7A))
                    : Colors.white),
          ),
        ),
      ),
    );
  }

  Widget buildPatDetails() {
    return SizedBox(
      height: SizeConfig.screenHeight * 0.65,
      width: SizeConfig.screenWidth * 0.315,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Patient Details",
              style: GoogleFonts.publicSans(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: getProportionateScreenHeight(24),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMobileNo(),
                SizedBox(
                  width: getProportionateScreenWidth(16),
                ),
                _buildAge(),
              ],
            ),
            SizedBox(
              height: getProportionateScreenHeight(16),
            ),
            SizedBox(
              width: SizeConfig.screenWidth * 0.315,
              child: Row(
                children: [
                  _buildFirstName(),
                  SizedBox(
                    width: SizeConfig.screenWidth * 0.015,
                  ),
                  _buildLastName(),
                ],
              ),
            ),
            SizedBox(
              height: getProportionateScreenHeight(24),
            ),
            _buildAddress(),
            SizedBox(
              height: getProportionateScreenHeight(24),
            ),
            _buildGender(),
            SizedBox(
              height: getProportionateScreenHeight(16),
            ),
            docTreatmentsAvailable.length != 0
                ? SizedBox(
                    width: SizeConfig.screenWidth * 0.315,
                    child: Row(
                      children: [
                        _buildTreatment(),
                        SizedBox(
                          width: SizeConfig.screenWidth * 0.015,
                        ),
                        _buildCategory(),
                      ],
                    ),
                  )
                : SizedBox(height: 0)
          ],
        ),
      ),
    );
  }

  Widget _buildCategory() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        "Category",
        style: GoogleFonts.publicSans(
            fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
      ),
      SizedBox(height: getProportionateScreenHeight(16)),
      Container(
        color: Color(0xFFF3F3F3),
        width: SizeConfig.screenWidth * 0.15,
        padding:
            EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(16)),
        child: DropdownButton<String>(
            underline: SizedBox(),
            value: walkIn,
            borderRadius: BorderRadius.circular(2),
            iconEnabledColor: Color(0xFF8E8E8E),
            items: walkInAvailable.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value,
                    style: GoogleFonts.publicSans(
                        color: Colors.black, fontWeight: FontWeight.w600)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                walkIn = value!;
                debugPrint("category selected is $walkIn");
              });
            }),
      )
    ]);
  }

  Widget buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Add Patient",
          style: GoogleFonts.publicSans(
              fontWeight: FontWeight.w700, color: Colors.black, fontSize: 20),
        ),
      ],
    );
  }

  List<Widget> actionsList() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Spacer(),
          CustomButton(
              backgroundColor: Color(0xFFF3F3F3),
              onPressed: () => widget.goBack(context),
              text: "Cancel"),
          SizedBox(
            width: getProportionateScreenWidth(16),
          ),
          CustomButton(
              backgroundColor: Colors.black,
              onPressed: () async {
                print("add patient is tapped");
                print(_formKey.currentState!.validate());
                if (_selectedSlot == TimeOfDay(hour: 0, minute: 0))
                  _avail = false;
                if (_formKey.currentState!.validate() && _avail) {
                  return showDialog<void>(
                    context: _scaffoldKey.currentContext!,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: Text(
                          "Do you want to confirm this booking?",
                          style: GoogleFonts.publicSans(),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.of(dialogContext).pop();
                            },
                            child: Text("Cancel",
                                style: TextStyle(color: Colors.white)),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.black)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);

                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                              if (!_formKey.currentState!.validate())
                                return null;

                              print("add patient button is clicked" +
                                  _selectedSlot.format(context));
                              print(
                                  "treatment inside bottom modal sheet is $treatment");
                              if (_avail == false) return null;
                              Navigator.of(dialogContext).pop();
                              _scaffoldKey.currentContext!.loaderOverlay.show();
                              (_selectedSlot != TimeOfDay(hour: 0, minute: 0) &&
                                      _selectedSlot !=
                                          TimeOfDay(hour: -1, minute: 99))
                                  ? addPatientMultiple(
                                          _selectedSlot,
                                          selectedDate,
                                          myProfile.id,
                                          selectedSalutation +
                                              " " +
                                              widget.firstName,
                                          widget.lastName,
                                          widget.age!,
                                          widget.gender,
                                          widget.phoneNumber,
                                          numSlots,
                                          treatment,
                                          useTreatmentOrNot,
                                          walkIn,
                                          widget.address)
                                      .then((value) {
                                      _scaffoldKey.currentContext!.loaderOverlay
                                          .hide();
                                      if (value != -1) {
                                        print("showing refresh indicator 2");
                                        // if (widget.refreshParent != null)
                                        //   widget.refreshParent!();
                                        ScaffoldMessenger.of(
                                                _scaffoldKey.currentContext!)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    "Patient added sucessfully"),
                                                duration:
                                                    Duration(seconds: 2)));

                                        widget.goBack(context);

                                        if (widget.reschedule)
                                          Navigator.pop(
                                              _scaffoldKey.currentContext!);
                                      } else {
                                        print(
                                            "printing scaffold patient could not be added due to some error");
                                        ScaffoldMessenger.of(
                                                _scaffoldKey.currentContext!)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              "Patient could not be added due to some error"),
                                          duration: Duration(seconds: 2),
                                        ));
                                      }
                                    })
                                  : showDialog<void>(
                                      context: context,
                                      barrierDismissible:
                                          false, // user must tap button!
                                      builder: (BuildContext dialogContext) {
                                        _scaffoldKey
                                            .currentContext!.loaderOverlay
                                            .hide();
                                        return AlertDialog(
                                          title: Text(
                                            "All the available slots are filled. Do you wish you add extra slots?",
                                            style: GoogleFonts.publicSans(),
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                Navigator.of(dialogContext)
                                                    .pop();
                                              },
                                              child: Text("Cancel",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(Colors.black)),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(dialogContext)
                                                    .pop();
                                                _scaffoldKey.currentContext!
                                                    .loaderOverlay
                                                    .show();
                                                addPatientExtra(
                                                        DateTime.now(),
                                                        myProfile.id,
                                                        selectedSalutation +
                                                            " " +
                                                            widget.firstName,
                                                        widget.lastName,
                                                        widget.age!,
                                                        widget.gender,
                                                        widget.phoneNumber,
                                                        1,
                                                        treatment,
                                                        walkIn,
                                                        widget.address)
                                                    .then((value) {
                                                  _scaffoldKey.currentContext!
                                                      .loaderOverlay
                                                      .hide();
                                                  if (value != -1) {
                                                    print(
                                                        "showing refresh indicator 3");
                                                    // widget
                                                    //     .refreshParent!(); // }
                                                    widget.goBack(context);
                                                    ScaffoldMessenger.of(
                                                            _scaffoldKey
                                                                .currentContext!)
                                                        .showSnackBar(SnackBar(
                                                      content: Text(
                                                          "Patient added sucessfully"),
                                                      duration:
                                                          Duration(seconds: 2),
                                                    ));

                                                    //Navigator.of(context).pop();
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            _scaffoldKey
                                                                .currentContext!)
                                                        .showSnackBar(SnackBar(
                                                      content: Text(
                                                          "Patient could not be added due to some error"),
                                                      duration:
                                                          Duration(seconds: 2),
                                                    ));
                                                  }
                                                });
                                              },
                                              child: Text(
                                                "Confirm",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                          Color>(Colors.black)),
                                            )
                                          ],
                                        );
                                      },
                                    );
                            },
                            child: Text("Confirm",
                                style: TextStyle(color: Colors.white)),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.black)),
                          )
                        ],
                      );
                    },
                  );
                } else {
                  print("popping context");
                  FocusScopeNode currentFocus = FocusScope.of(context);

                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                }
              },
              text: "Save"),
          Spacer()
        ],
      )
    ];
  }

  Widget _buildFirstName() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "First Name",
          style: headingStyle,
        ),
        SizedBox(
          width: SizeConfig.screenWidth * 0.15,
          child: Row(
            children: [
              SizedBox(
                width: SizeConfig.screenWidth * 0.15 * (40 / 130),
                child: DropdownButtonFormField<String>(
                  padding: EdgeInsets.zero,
                  isDense: true,
                  decoration: inputDecoration,
                  value: selectedSalutation,
                  hint: SizedBox(
                    width: SizeConfig.screenWidth * 0.15 * (24 / 130),
                    child: Text(
                      salutationsList[0],
                      style: inputStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  iconSize: SizeConfig.screenWidth * 0.15 * (10 / 130),
                  onChanged: (salutation) =>
                      setState(() => selectedSalutation = salutation!),
                  validator: (value) => value == null ? 'Field Required' : null,
                  items: salutationsList
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: SizedBox(
                        width: SizeConfig.screenWidth * 0.15 * (24 / 130),
                        child: Text(
                          value,
                          style: inputStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(width: SizeConfig.screenWidth * 0.15 * (4 / 150)),
              SizedBox(
                width: SizeConfig.screenWidth * 0.15 * (96 / 150),
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Please enter the first Name";
                    else
                      return null;
                  },
                  style: inputStyle,
                  controller: list[0],
                  decoration: inputDecoration,
                  onChanged: (value) {
                    setState(() {
                      widget.firstName = value;
                    });
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildLastName() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Last Name",
          style: headingStyle,
        ),
        SizedBox(
          width: SizeConfig.screenWidth * 0.15,
          child: TextFormField(
            style: inputStyle,
            controller: list[1],
            decoration: inputDecoration,
            onChanged: (value) {
              setState(() {
                widget.lastName = value;
              });
            },
          ),
        )
      ],
    );
  }

  Widget _buildAddress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Address (Optional)",
          style: headingStyle,
        ),
        TextFormField(
          controller: list[3],
          style: inputStyle,
          decoration: inputDecoration,
          onChanged: (value) {
            setState(() {
              widget.address = value;
            });
          },
        )
      ],
    );
  }

  Widget _buildMobileNo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mobile No.",
          style: headingStyle,
        ),
        SizedBox(
          width: SizeConfig.screenWidth * 0.15,
          child: TextFormField(
            controller: c,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value == null || value.isEmpty || value.length != 10)
                return "Please enter correct phone number";
              else
                return null;
            },
            style: inputStyle,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
                counter: Padding(
                  padding: const EdgeInsets.only(right: 4, bottom: 4),
                  child: Text(
                    c.value.text.length.toString() + "/10",
                    style: GoogleFonts.publicSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: c.text.length != 10
                            ? Color.fromARGB(255, 158, 158, 158)
                            : Colors.green),
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black, style: BorderStyle.solid)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black, style: BorderStyle.solid)),
                border: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black, style: BorderStyle.solid))),
            onChanged: (value) async {
              setState(() {
                if (value.length == 10) {
                  FocusManager.instance.primaryFocus!.unfocus();
                }

                widget.phoneNumber = value ?? "";
              });

              if (value.length == 10 && search) {
                _scaffoldKey.currentContext!.loaderOverlay.show();
                List<SearchModel> patList =
                    await getPatList(widget.phoneNumber);
                if (patList.length == 1) {
                  List<String> firstName = patList[0].firstName.split(" ");
                  String finalName = "";
                  for (int i = 1; i < firstName.length; i++)
                    finalName += firstName[i];

                  selectedSalutation = firstName[0].replaceAll(".", "");

                  selectedSalutation = firstName[0];

                  setState(() {
                    widget.firstName = finalName;
                    list[0].text = finalName;
                    widget.lastName = patList[0].lastName;
                    list[1].text = patList[0].lastName;
                    widget.age = patList[0].age;
                    list[2].text = patList[0].age.toString();
                    widget.gender = patList[0].gender;
                    select = patList[0].gender;
                  });
                } else if (patList.length > 1) {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                          title: Row(
                            children: [
                              Spacer(),
                              Text("Choose Patient"),
                              Spacer()
                            ],
                          ),
                          content: SizedBox(
                            height: SizeConfig.screenHeight * 0.4,
                            width: SizeConfig.screenWidth * 0.8,
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ListTile(
                                      onTap: () {
                                        List<String> firstName =
                                            patList[index].firstName.split(" ");
                                        String finalName = "";
                                        for (int i = 1;
                                            i < firstName.length;
                                            i++) finalName += firstName[i];

                                        setState(() {
                                          widget.firstName = finalName;
                                          list[0].text = finalName;
                                          widget.lastName =
                                              patList[index].lastName;
                                          list[1].text =
                                              patList[index].lastName;
                                          widget.age = patList[index].age;
                                          list[2].text =
                                              patList[index].age.toString();
                                          widget.gender = patList[index].gender;
                                          select = patList[index].gender;
                                        });

                                        selectedSalutation = firstName[0];

                                        Navigator.pop(context);
                                      },
                                      title: Text(
                                          patList[index].firstName +
                                              " " +
                                              patList[index].lastName,
                                          style: inputStyle),
                                      subtitle: Text(
                                          patList[index].gender +
                                              ", " +
                                              patList[index].age.toString(),
                                          style: headingStyle));
                                },
                                itemCount: patList.length * 100),
                          )));
                }
                _scaffoldKey.currentContext!.loaderOverlay.hide();
              }
            },
          ),
        )
      ],
    );
  }

  Widget _buildAge() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Age",
          style: headingStyle,
        ),
        SizedBox(
          width: SizeConfig.screenWidth * 0.15,
          child: TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty)
                return "Please enter the age";
              else
                return null;
            },
            keyboardType: TextInputType.number,
            style: inputStyle,
            controller: list[2],
            decoration: inputDecoration,
            onChanged: (value) {
              setState(() {
                widget.age = int.parse(value);
              });
            },
          ),
        )
      ],
    );
  }

  Widget _buildGender() {
    Row addRadioButton(int btnValue, String title) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            style: GoogleFonts.publicSans(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
          ),
          Radio(
            activeColor: Colors.black,
            value: genderList[btnValue],
            groupValue: select,
            onChanged: (value) {
              setState(() {
                //print(value);
                select = value.toString();
                widget.gender = value.toString();
              });
            },
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gender",
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
          ),
          SizedBox(
            height: getProportionateScreenHeight(6),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(4)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                addRadioButton(0, 'Male'),
                addRadioButton(1, 'Female'),
                addRadioButton(2, 'Others'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatment() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        "Treatment",
        style: GoogleFonts.publicSans(
            fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
      ),
      SizedBox(height: getProportionateScreenHeight(16)),
      Container(
        color: Color(0xFFF3F3F3),
        width: SizeConfig.screenWidth * 0.15,
        padding:
            EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(16)),
        child: DropdownButton<String>(
            underline: SizedBox(),
            value: treatment,
            borderRadius: BorderRadius.circular(2),
            iconEnabledColor: Color(0xFF8E8E8E),
            items: docTreatmentsAvailable.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value,
                    style: GoogleFonts.publicSans(
                        color: Colors.black, fontWeight: FontWeight.w600)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                treatment = value!;
                debugPrint("Treatment selected is $treatment");
              });
            }),
      )
    ]);
  }

  Future<String> fetchEstimatedTime(
      int docId, String date, String slotTime) async {
    if (computeDate(date) == DateTime(-1)) {
      List<DateTime> list = await _getAvailDates(docId);
      date = convertDateToString(list[0]);
    }

    final request = http.Request("POST", Uri.parse(getEstimatedTimeUrl));
    final body = {
      "doc_id": docId,
      "date": date,
      "slot_time": int.parse(slotTime)
    };
    request.headers.addAll(header);
    request.body = json.encode(body);
    final response = await request.send();
    final resBody = await response.stream.bytesToString();
    final jResponse = json.decode(resBody);
    return jResponse["est_time"];
  }

  Future<int> addPatientExtra(
      DateTime dateToBeUsed,
      int docId,
      String firstName,
      String lastName,
      int age,
      String gender,
      String phoneNumber,
      int batchNumber,
      String treatment,
      String walkIn,
      String address) async {
    print("Extra patient api is called");
    String formattedDate = "";
    if (dateToBeUsed != DateTime(-1)) {
      formattedDate = dateToBeUsed.day.toString().padLeft(2, "0") +
          "-" +
          dateToBeUsed.month.toString().padLeft(2, "0") +
          "-" +
          dateToBeUsed.year.toString();
    } else {
      formattedDate = DateTime.now().day.toString().padLeft(2, "0") +
          "-" +
          DateTime.now().month.toString().padLeft(2, "0") +
          "-" +
          DateTime.now().year.toString();
    }

    debugPrint("Date:" + formattedDate);

    final response = await http.post(
      Uri.parse(addBookingExtra),
      headers: header,
      body: jsonEncode(<String, dynamic>{
        "Patients": {
          "first_name": firstName,
          "last_name": lastName,
          "age": age,
          "gender": gender,
          "phone_number": phoneNumber ?? "",
          "category": walkIn,
          "address": address
        },
        "doc_id": docId,
        "date": formattedDate,
        "treatment": treatment
      }),
    );
    print(jsonEncode(<String, dynamic>{
      "Patients": {
        "first_name": firstName,
        "last_name": lastName,
        "age": age,
        "gender": gender,
        "phone_number": phoneNumber,
        "category": walkIn,
        "address": address
      },
      "doc_id": docId,
      "date": formattedDate,
      "treatment": treatment
    }));
    print(response.statusCode);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      BookingResponse bookingResponse = BookingResponse.fromJson(jsonResponse);
      debugPrint(bookingResponse.bookingId.toString());

      return bookingResponse.bookingId;
    } else {
      return -1;
    }
  }

  Future<int> addPatientMultiple(
      TimeOfDay time,
      DateTime dateToBeUsed,
      int docId,
      String firstName,
      String lastName,
      int age,
      String gender,
      String phoneNumber,
      int numSlots,
      String treatment,
      bool useSpecOrNot,
      String walkIn,
      String address) async {
    String formattedDate = "";
    if (dateToBeUsed != DateTime(-1)) {
      formattedDate = dateToBeUsed.day.toString().padLeft(2, "0") +
          "-" +
          dateToBeUsed.month.toString().padLeft(2, "0") +
          "-" +
          dateToBeUsed.year.toString();
    } else {
      formattedDate = DateTime.now().day.toString().padLeft(2, "0") +
          "-" +
          DateTime.now().month.toString().padLeft(2, "0") +
          "-" +
          DateTime.now().year.toString();
    }

    debugPrint("Date:" + formattedDate);
    String hour = time.hour.toString().padLeft(2, "0"),
        minute = time.minute.toString().padLeft(2, "0");
    String finalTime = hour + minute;
    int startTime = int.parse(finalTime);
    debugPrint("Time:" + finalTime);

    print("add patient function is called");
    var body = jsonEncode(<String, dynamic>{
      "Patients": {
        "first_name": firstName,
        "last_name": lastName,
        "age": age,
        "gender": gender,
        "phone_number": phoneNumber ?? "",
        "category": walkIn,
        "address": address
      },
      "doc_id": docId,
      "slot_time": startTime,
      "num_slots": numSlots == 1 ? null : numSlots,
      "date": formattedDate,
      "treatment": treatment
    });
    print(body);
    final response =
        await http.post(Uri.parse(addBooking), headers: header, body: body);
    debugPrint(body);
    print("....................");
    print(response.statusCode);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      BookingResponse bookingResponse = BookingResponse.fromJson(jsonResponse);
      debugPrint(bookingResponse.bookingId.toString());
      return bookingResponse.bookingId;
    } else {
      return -1;
    }
  }
}

//this future is called too many times. this should be optimzed
Future<List<DateTime>> _getAvailDates(int docId) async {
  var response = await http.post(Uri.parse(getAvailDates),
      body: jsonEncode(<String, int>{
        "doc_id": docId,
      }),
      headers: header);
  //print("Response Recieved for Dates");
  if (response.statusCode == 200) {
    List<DateTime> datesList = [];
    var jsonResponse = jsonDecode(response.body);
    print("Dates recieved for id $docId");
    print(jsonResponse);
    (jsonResponse["dates"] as List).forEach((d) {
      DateTime date = computeDate(d);
      datesList.add(date);
    });
    return datesList;
  } else
    return [];
}

Future<EarlyResponse> getEarliestSlot(int docId) async {
  print("Fetching earliest slot");
  final response = await http.post(
    Uri.parse(getEarlyUrl),
    headers: header,
    body: jsonEncode(<String, int>{"doc_id": docId}),
  );
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    EarlyResponse earlyResponse = EarlyResponse.fromJson(jsonResponse);
    debugPrint(earlyResponse.slotTime.toString() + "slotTime");
    return earlyResponse;
  } else {
    return EarlyResponse(estTime: "", slotTime: -1);
  }
}

class EarlyResponse {
  EarlyResponse({
    required this.slotTime,
    required this.estTime,
  });

  int? slotTime;
  String? estTime;

  factory EarlyResponse.fromJson(Map<String, dynamic> parsedJson) {
    return EarlyResponse(
        slotTime: parsedJson['slot_time'] ?? -1,
        estTime: parsedJson["est_time"] ?? "");
  }
}

class BookingResponse {
  int bookingId;
  BookingResponse({required this.bookingId});

  factory BookingResponse.fromJson(Map<String, dynamic> parsedJson) {
    return BookingResponse(bookingId: parsedJson['booking_id']);
  }
}

Future<List<List<Tuple2<TimeOfDay, bool>>>> _getAvailSlots(
    String date, int docId) async {
  print("Getting available slots ....");
  var response = await http.post(Uri.parse(getAvailSlotsUrl),
      body: jsonEncode(<String, dynamic>{"doc_id": docId, "date": date}),
      headers: header);
  //print("Response Recieved for Slots with status code ${response.statusCode}");

  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(response.body);
    print("slots response is $jsonResponse");
    SlotResponse slotResponse = new SlotResponse.fromJson(jsonResponse);
    // print(slotResponse.batches[0].slotTime.toList());
    List<Batches> batchList = slotResponse.batches;
    List<List<Tuple2<TimeOfDay, bool>>> batchWiseSlots =
        List.generate(batchList.length, (index) => []);

    for (int i = 0; i < batchList.length; i++) {
      int numberOfSlots = batchList[i].slotTime.length;
      for (int j = 0; j < numberOfSlots; j++) {
        batchWiseSlots[i].add(Tuple2<TimeOfDay, bool>(
            computeSlot(int.parse(batchList[i].slotTime[j])),
            batchList[i].availability[j]));
      }
      // batchList[i].slotTime.forEach((element) {
      //   batchWiseSlots[i].add(
      //       Tuple2<TimeOfDay, bool>(computeSlot(int.parse(element)), true));
      // });
    }

    return batchWiseSlots;
  } else
    return [];
}

class SlotResponse {
  late List<Batches> batches;

  SlotResponse({required this.batches});

  SlotResponse.fromJson(Map<String, dynamic> json) {
    if (json['batches'] != null) {
      batches = <Batches>[];
      json['batches'].forEach((v) {
        batches.add(new Batches.fromJson(v));
      });
    }
  }
}

class Batches {
  late List<String> slotTime;
  late List<bool> availability;

  Batches({required this.slotTime, required this.availability});

  Batches.fromJson(Map<String, dynamic> json) {
    if (json['slot_time'] != null) {
      slotTime = <String>[];
      json['slot_time'].forEach((v) {
        slotTime.add(v.toString());
      });
    }
    if (json['availability'] != null) {
      availability = <bool>[];
      json['availability'].forEach((v) {
        int b = v;
        bool t;
        b == 0 ? t = false : t = true;
        availability.add(t);
      });
    }
  }
}

DateTime computeDate(String d) {
  List<String> strings = d.toString().split("-");
  int year = int.parse(strings[2]);
  int month = int.parse(strings[1]);
  int day = int.parse(strings[0]);
  DateTime date = DateTime(year, month, day);
  return date;
}

TimeOfDay computeSlot(int d) {
  int minutes = d % 100;
  int hours = (d / 100).floor();
  // print("for $d the hour is $hours $minutes");
  TimeOfDay slot = TimeOfDay(hour: hours, minute: minutes);
  return slot;
}

String convertDateToString(DateTime date) {
  //print("date recieved for converting $date");
  return date.day.toString().padLeft(2, "0") +
      "-" +
      date.month.toString().padLeft(2, "0") +
      "-" +
      date.year.toString();
}

Future<bool> getSpecialization() async {
  //print("Get specialization called for doctor id  ${myProfile.id}");
  prefs = await SharedPreferences.getInstance();
  String spec = prefs.getString("specialization") ?? myProfile.specialization;
  //print("specialization is $spec");
  if (spec.contains("Dentist") || spec.contains("dentist"))
    return true;
  else
    return false;
}

Future<List<SearchModel>> getPatList(String phoneNumber) async {
  try {
    var response =
        await http.get(Uri.parse(patSearchUrl + phoneNumber), headers: header);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      SearchResponse searchResponse = SearchResponse.fromJson(jsonResponse);
      return searchResponse.pats;
    } else
      return [];
  } catch (error) {
    return [];
  }
}

class SearchResponse {
  final List<SearchModel> pats;

  SearchResponse({required this.pats});

  factory SearchResponse.fromJson(List<dynamic> parsedJson) {
    var list = parsedJson;
    List<SearchModel> patList =
        list.map((i) => SearchModel.fromJson(i)).toList();

    return SearchResponse(pats: patList);
  }
}

class SearchModel {
  String email, gender, firstName, lastName;
  int id, age;

  SearchModel(
      {required this.id,
      required this.email,
      required this.gender,
      required this.firstName,
      required this.lastName,
      required this.age});

  factory SearchModel.fromJson(Map<String, dynamic> parsedJson) {
    debugPrint(parsedJson.toString());
    return SearchModel(
        id: parsedJson["id"],
        firstName: parsedJson["first_name"],
        lastName:
            parsedJson["last_name"] == null ? "" : parsedJson["last_name"],
        email: parsedJson["email"],
        age: parsedJson["age"],
        gender: parsedJson["gender"]);
  }
}
