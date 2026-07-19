import 'dart:convert';
import 'package:doctor/Models/DoctorLeave.dart';
import 'package:doctor/components/size_config.dart';
import 'package:doctor/screens/leaves/components/AddLeavesScreen.dart';
import 'package:doctor/components/urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LeaveScreen extends StatefulWidget {
  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final TextStyle headingStyle =
      GoogleFonts.publicSans(fontSize: 18, fontWeight: FontWeight.bold);

  void onRefresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.screenWidth * 0.56,
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          height: 61,
          width: 61,
          decoration: BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: 8,
                offset: Offset(0, 0),
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          child: IconButton(
            icon: Icon(Icons.add, size: 36, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddLeavesScreen(onRefresh)));
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Leaves",
                  style: GoogleFonts.publicSans(
                      fontSize: getProportionateScreenWidth(36),
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                FutureBuilder(
                    future: getLeaves(myProfile.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.connectionState == ConnectionState.done) {
                        Map<String, List> map =
                            snapshot.data as Map<String, List>;
                        List<DoctorLeaveModel> upList =
                            map["up"] as List<DoctorLeaveModel>;
                        List<DoctorLeaveModel> pastList =
                            map["past"] as List<DoctorLeaveModel>;
                        if (upList.length == 0 && pastList.length == 0) {
                          return Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.2),
                              Center(
                                  child:
                                      Image.asset("assets/images/noresch.png")),
                              SizedBox(
                                height: 6,
                              ),
                              Text("No Leaves \n    Added!",
                                  style: GoogleFonts.publicSans(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18))
                            ],
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                upList.length != 0
                                    ? Text(
                                        "Upcoming Leaves",
                                        style: headingStyle,
                                      )
                                    : SizedBox(height: 0),
                                upList.length != 0
                                    ? SizedBox(
                                        height: 22,
                                      )
                                    : SizedBox(height: 0),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemBuilder: (context, index) =>
                                      leaveCard(upList[index]),
                                  itemCount: upList.length,
                                ),
                                SizedBox(
                                  height: 42,
                                ),
                                pastList.isEmpty
                                    ? SizedBox(height: 0)
                                    : Text(
                                        "Past Leaves",
                                        style: headingStyle,
                                      ),
                                SizedBox(
                                  height: 22,
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemBuilder: (context, index) =>
                                      leaveCard(pastList[index]),
                                  itemCount: pastList.length,
                                )
                              ],
                            ),
                          );
                        }
                      } else {
                        return SpinKitPouringHourGlass(
                          color: Colors.grey,
                        );
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget leaveCard(DoctorLeaveModel leave) {
    DateTime startDay =
        computeDate(leave.startTime.split("-").reversed.join("-"));
    DateTime endDay = computeDate(leave.endTime.split("-").reversed.join("-"));
    final diff = startDay.difference(endDay);
    int noOfDays = -diff.inDays;
    return Container(
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
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(16),
              vertical: getProportionateScreenHeight(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(noOfDays > 1 ? "$noOfDays Days Leave" : "1 Day Leave",
                      style: GoogleFonts.publicSans(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF6B6B6B))),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    changeDateTime(startDay) + "  -  " + changeDateTime(endDay),
                    style: headingStyle,
                  )
                ],
              ),
              ClipOval(
                child: Material(
                  color: Color.fromARGB(255, 255, 74, 74),
                  child: InkWell(
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              "Are you sure you want to Delete this leave:",
                              style: headingStyle,
                            ),
                            content: Text(
                              changeDateTime(startDay) +
                                  "  -  " +
                                  changeDateTime(endDay),
                              style: headingStyle,
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () async {
                                    String deleteResp = await deleteLeave(
                                        myProfile.id,
                                        leave.startTime
                                            .split("-")
                                            .reversed
                                            .join("-"),
                                        leave.endTime
                                            .split("-")
                                            .reversed
                                            .join("-"));
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(deleteResp)));
                                    Future.delayed(const Duration(seconds: 2))
                                        .then(
                                      (value) => setState(() {}),
                                    );
                                  },
                                  child: Text(
                                    "Yes",
                                    style: headingStyle,
                                  )),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "No",
                                    style: headingStyle,
                                  )),
                            ],
                          );
                        },
                      );
                    },
                    child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 14,
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String> deleteLeave(int docId, String startTime, String endTime) async {
  var response = await http.post(Uri.parse(deleteLeaveUrl),
      body: jsonEncode(<String, dynamic>{
        "doc_id": docId,
        "start_day": startTime,
        "end_day": endTime
      }),
      headers: header);
  if (response.statusCode == 200) {
    return "Leave Successfully Deleted!";
  } else {
    return "Some error occurred in Deleting Leave!";
  }
}

Future<Map<String, List>> getLeaves(int docId) async {
  var response = await http.post(Uri.parse(getLeavesUrl),
      body: jsonEncode(<String, dynamic>{"doc_id": docId}), headers: header);
  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body.toString());
    LeaveResponse jsonResp = LeaveResponse.fromJson(jsonResponse);
    List<DoctorLeaveModel> upList = jsonResp.upcomingLeaves;
    List<DoctorLeaveModel> pastList = jsonResp.pastLeaves;
    return {"up": upList, "past": pastList};
  } else {
    return {"up": [], "past": []};
  }
}

class LeaveResponse {
  final List<DoctorLeaveModel> upcomingLeaves;
  final List<DoctorLeaveModel> pastLeaves;

  LeaveResponse({required this.upcomingLeaves, required this.pastLeaves});

  factory LeaveResponse.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson["Upcoming"] as List;
    List<DoctorLeaveModel> upLeaveList =
        list.map((i) => DoctorLeaveModel.fromJson(i)).toList();
    var list1 = parsedJson["Past"] as List;
    List<DoctorLeaveModel> pastLeaveList =
        list1.map((i) => DoctorLeaveModel.fromJson(i)).toList();
    return LeaveResponse(
        upcomingLeaves: upLeaveList, pastLeaves: pastLeaveList);
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

String changeDateTime(DateTime dateTime) {
  String day = DateFormat("EEEE").format(dateTime);
  String numberDay = dateTime.day.toString();
  String month = DateFormat.MMMM().format(dateTime);
  return day.substring(0, 3) + " " + numberDay + ", " + month.substring(0, 3);
}
