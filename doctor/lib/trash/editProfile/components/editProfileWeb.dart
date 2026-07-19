import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:doctor/components/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Models/DoctorModel.dart';
import '../../../components/urls.dart';
import '../../../screens/homeScreen/homeScreen.dart';
import '../../../screens/otp/components/error_dialog.dart';

class EditProfileWeb extends StatefulWidget {
  const EditProfileWeb({Key? key}) : super(key: key);

  @override
  State<EditProfileWeb> createState() => _EditProfileWebState();
}

class _EditProfileWebState extends State<EditProfileWeb> {
  int pageIndex = 0;
  String category = myProfile.category;
  List<String> categoriesAvailable = [
    "Dentist",
    "Physician",
    "Cardiologist",
    "ENT",
    "Gynaecologist",
    "Orthopedic",
    "Paediatrician",
    "Psychiatrist",
    "Radiologist",
    "Neurologist",
    "Other"
  ];
  bool correctTimingOrNot = true;
  late TimeOfDay startingSelectedTime;
  late TimeOfDay endingSelectedTime;
  DoctorModel doctorInfo = DoctorModel(
      id: -1,
      firstName: "",
      lastName: "",
      gender: "",
      age: -1,
      phoneNumber: "",
      email: "",
      registrationNumber: "",
      specialization: "",
      degrees: "",
      appointmentFees: -1,
      clinicName: "",
      clinicAddress: "",
      city: "",
      avgTime: -1,
      patPerSlot: -1,
      timing: [],
      category: "",
      contactNumber: "");
  bool hidePassword = true;
  bool isCitiesLoaded = false;
  List<String> cities = [], timings = [];
  late String gender;
  late Future<List<dynamic>> getCityFuture;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<bool> sitOrNot = List.generate(7, (index) => false);
  List<bool> has2Slots = List.generate(7, (index) => false),
      has3Slots = List.generate(7, (index) => false);

  final List<String> weekdays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  List<List<TimeOfDay>> defaultStartTime = List.generate(
      7, (index) => List.generate(3, (index) => TimeOfDay(hour: 0, minute: 0)));
  List<List<TimeOfDay>> defaultEndTime = List.generate(
      7, (index) => List.generate(3, (index) => TimeOfDay(hour: 0, minute: 0)));
  List<List<bool>> startTimesUpdatedOrNot =
      List.generate(7, (index) => List.generate(3, (index) => false));
  List<List<bool>> endTimesUpdatedOrNot =
      List.generate(7, (index) => List.generate(3, (index) => false));

  @override
  void initState() {
    super.initState();
    doctorInfo = DoctorModel.copyWith(myProfile);
    enterValues();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SizedBox(
      width: MediaQuery.of(context).size.width * (830 / 1460),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(20),
              vertical: getProportionateScreenHeight(30)),
          child: Container(
            width: SizeConfig.screenWidth * 0.56,
            height: SizeConfig.screenHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Edit Profile",
                        style: GoogleFonts.publicSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            color: Colors.black)),
                    navBar(context)
                  ],
                ),
                SizedBox(height: getProportionateScreenHeight(30)),
                pageIndex == 0 ? personal() : clinic(),
                SizedBox(height: getProportionateScreenHeight(30)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.publicSans(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: 16),
                      ),
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: getProportionateScreenWidth(12),
                              vertical: getProportionateScreenHeight(20)),
                          alignment: Alignment.center,
                          backgroundColor: Color.fromARGB(255, 243, 243, 243)),
                    ),
                    SizedBox(width: getProportionateScreenWidth(16)),
                    TextButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        _formKey.currentState!.save();
                        List<String> startTimingToBeFed = [],
                            endTimingToBeFed = [];
                        String finalTime = "";
                        List<String> timingToStore = [];
                        List<int> startTimingsForTesting = [],
                            endTimingsForTesting = [];
                        defaultStartTime.forEach((dayElement) {
                          dayElement.forEach((slotElement) {
                            if (slotElement.hour == 0 &&
                                slotElement.minute == 0) {
                              startTimingToBeFed.add("0,");
                              startTimingsForTesting.add(0);
                            } else {
                              startTimingToBeFed
                                  .add(convertToString(slotElement) + ",");
                              startTimingsForTesting
                                  .add(int.parse(convertToString(slotElement)));
                            }
                          });
                        });
                        defaultEndTime.forEach((dayElement) {
                          dayElement.forEach((slotElement) {
                            if (slotElement.hour == 0 &&
                                slotElement.minute == 0) {
                              endTimingToBeFed.add("0,");
                              endTimingsForTesting.add(0);
                            } else {
                              endTimingToBeFed
                                  .add(convertToString(slotElement) + ",");
                              endTimingsForTesting
                                  .add(int.parse(convertToString(slotElement)));
                            }
                          });
                        });

                        for (int i = 0; i < 7; i++) {
                          for (int j = 0; j < 3; j++) {
                            if (startTimingsForTesting[3 * i + j] >
                                endTimingsForTesting[3 * i + j]) {
                              correctTimingOrNot = false;
                              break;
                            } else {
                              if (j == 1) {
                                if (endTimingsForTesting[3 * i] >
                                        startTimingsForTesting[3 * i + 1] &&
                                    startTimingsForTesting[3 * i + 1] != 0) {
                                  correctTimingOrNot = false;
                                  break;
                                }
                              }
                              if (j == 2) {
                                if (endTimingsForTesting[3 * i + 1] >
                                        startTimingsForTesting[3 * i + 2] &&
                                    startTimingsForTesting[3 * i + 2] != 0) {
                                  correctTimingOrNot = false;
                                  break;
                                }
                              }
                              finalTime += startTimingToBeFed[3 * i + j];
                              finalTime += endTimingToBeFed[3 * i + j];
                            }
                          }
                        }

                        timingToStore += startTimingToBeFed;
                        timingToStore += endTimingToBeFed;

                        finalTime =
                            finalTime.substring(0, finalTime.length - 1);

                        doctorInfo.timeSlots = finalTime;

                        if (correctTimingOrNot) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FutureBuilder(
                                  future: editDetail(doctorInfo),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      saveDataToSharedPreference(
                                          doctorInfo,
                                          timingToStore,
                                          has2Slots,
                                          has3Slots,
                                          sitOrNot);
                                      return HomeScreen();
                                    } else {
                                      return Center(
                                        child: SpinKitCubeGrid(
                                          color: Colors.grey,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ));
                        } else {
                          correctTimingOrNot = true;
                          startTimingToBeFed.clear();
                          endTimingToBeFed.clear();
                          finalTime = '';
                          timingToStore.clear();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ErrorDialog(
                                      context,
                                      "The timings entered are overlapping/incorrect, please check and try again!",
                                      false)));
                        }
                      },
                      child: Text(
                        "Save",
                        style: GoogleFonts.publicSans(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 16),
                      ),
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: getProportionateScreenWidth(12),
                              vertical: getProportionateScreenHeight(20)),
                          alignment: Alignment.center,
                          backgroundColor: Colors.black),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  SizedBox personal() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * (417 / 647),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildFirstName(),
                SizedBox(
                  height: getProportionateScreenHeight(30),
                ),
                _buildLastName(),
                SizedBox(
                  height: getProportionateScreenHeight(30),
                ),
                _buildAge(),
                SizedBox(
                  height: getProportionateScreenHeight(30),
                ),
                _buildReg(),
                SizedBox(
                  height: getProportionateScreenHeight(30),
                ),
                _buildGender()
              ],
            ),
          ),
          VerticalDivider(
              color: Color.fromARGB(255, 221, 221, 221), thickness: 1),
          Expanded(
            child: Column(
              children: [
                _buildEmail(),
                SizedBox(
                  height: getProportionateScreenHeight(30),
                ),
                _buildSpecialization(),
                SizedBox(
                  height: getProportionateScreenHeight(30),
                ),
                _buildDegree(),
                SizedBox(
                  height: getProportionateScreenHeight(30),
                ),
                _buildCity()
              ],
            ),
          )
        ],
      ),
    );
  }

  SizedBox clinic() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * (417 / 647),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildcName(),
                SizedBox(
                  height: getProportionateScreenHeight(30),
                ),
                _buildcAddress(),
                SizedBox(
                  height: getProportionateScreenHeight(30),
                ),
                _buildFees(),
                SizedBox(
                  height: getProportionateScreenHeight(30),
                ),
                _buildClinicNumber(),
                SizedBox(
                  height: getProportionateScreenHeight(30),
                ),
                _buildAvg()
              ],
            ),
          ),
          VerticalDivider(
              color: Color.fromARGB(255, 221, 221, 221), thickness: 1),
          Expanded(
            child: SingleChildScrollView(
              child: _buildHours(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFirstName() {
    return Padding(
      padding: EdgeInsets.only(right: getProportionateScreenWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "First Name",
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
          ),
          TextFormField(
              autofocus: true,
              initialValue: myProfile.firstName,
              onChanged: (value) => doctorInfo.firstName = value,
              validator: (value) => checkFiledEmpty(value!),
              cursorColor: Color.fromARGB(255, 0, 0, 0),
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 16),
              decoration: getDecoration()),
        ],
      ),
    );
  }

  Widget _buildLastName() {
    return Padding(
      padding: EdgeInsets.only(right: getProportionateScreenWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Last Name",
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
          ),
          TextFormField(
              autofocus: true,
              initialValue: myProfile.lastName,
              onChanged: (value) => doctorInfo.lastName = value,
              validator: (value) => checkFiledEmpty(value!),
              cursorColor: Colors.black,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 16),
              decoration: getDecoration()),
        ],
      ),
    );
  }

  Widget _buildAge() {
    return Padding(
      padding: EdgeInsets.only(right: getProportionateScreenWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Age",
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
          ),
          TextFormField(
              keyboardType: TextInputType.number,
              autofocus: true,
              initialValue: myProfile.age.toString(),
              onChanged: (value) => doctorInfo.age = int.parse(value),
              validator: (value) => checkFiledEmpty(value!),
              cursorColor: Colors.black,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 16),
              decoration: getDecoration()),
        ],
      ),
    );
  }

  List<String> genderList = ["Male", "Female", "Others"];
  String select = myProfile.gender;

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
                select = value.toString();
                doctorInfo.gender = value.toString();
              });
            },
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.only(right: getProportionateScreenWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gender",
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
          ),
          SizedBox(
            height: 6,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
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

  Widget _buildReg() {
    return Padding(
      padding: EdgeInsets.only(right: getProportionateScreenWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Registration No.",
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
          ),
          TextFormField(
              autofocus: true,
              initialValue: myProfile.registrationNumber,
              onChanged: (value) => doctorInfo.registrationNumber = value,
              cursorColor: Colors.black,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 16),
              decoration: getDecoration()),
        ],
      ),
    );
  }

  Widget _buildEmail() {
    return Padding(
      padding: EdgeInsets.only(left: getProportionateScreenWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Email",
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
          ),
          TextFormField(
              autofocus: true,
              initialValue: myProfile.email,
              onChanged: (value) => doctorInfo.email = value,
              cursorColor: Colors.black,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 16),
              decoration: getDecoration()),
        ],
      ),
    );
  }

  Widget _buildCategory() {
    return Padding(
      padding: EdgeInsets.only(left: getProportionateScreenWidth(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "Category",
          style: GoogleFonts.publicSans(
              fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
        ),
        DropdownButton<String>(
            value: category,
            items: categoriesAvailable.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                category = value.toString();
                doctorInfo.category = value.toString();
                debugPrint("Treatment selected is $category");
              });
            })
      ]),
    );
  }

  Widget _buildSpecialization() {
    return Padding(
      padding: EdgeInsets.only(left: getProportionateScreenWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Specialization",
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
          ),
          TextFormField(
              autofocus: true,
              initialValue: myProfile.specialization,
              onChanged: (value) => doctorInfo.specialization = value,
              cursorColor: Colors.black,
              validator: (value) => checkFiledEmpty(value!),
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 16),
              decoration: getDecoration()),
        ],
      ),
    );
  }

  Widget _buildDegree() {
    return Padding(
      padding: EdgeInsets.only(left: getProportionateScreenWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Degree",
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
          ),
          TextFormField(
              initialValue: myProfile.degrees,
              autofocus: true,
              onChanged: (value) => doctorInfo.degrees = value,
              cursorColor: Colors.black,
              textCapitalization: TextCapitalization.words,
              validator: (value) => checkFiledEmpty(value!),
              style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 16),
              decoration: getDecoration()),
        ],
      ),
    );
  }

  Widget _buildCity() {
    return Padding(
      padding: EdgeInsets.only(left: getProportionateScreenWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "City",
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
          ),
          TextFormField(
              initialValue: myProfile.city,
              autofocus: true,
              onChanged: (value) => doctorInfo.city = (value),
              cursorColor: Colors.black,
              validator: (value) => checkFiledEmpty(value!),
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 16),
              decoration: getDecoration()),
        ],
      ),
    );
  }

  Widget _buildcName() {
    return Padding(
      padding: EdgeInsets.only(right: getProportionateScreenWidth(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Clinic Name",
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
          ),
          TextFormField(
              autofocus: false,
              initialValue: myProfile.clinicName,
              onChanged: (value) => doctorInfo.clinicName = value,
              validator: (value) => checkFiledEmpty(value!),
              cursorColor: Colors.black,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 16),
              decoration: getDecoration()),
        ],
      ),
    );
  }

  Widget _buildcAddress() {
    return Padding(
      padding: EdgeInsets.only(right: getProportionateScreenWidth(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Clinic Full Address",
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
          ),
          TextFormField(
              autofocus: false,
              initialValue: myProfile.clinicAddress,
              onChanged: (value) => doctorInfo.clinicAddress = value,
              validator: (value) => checkFiledEmpty(value!),
              cursorColor: Colors.black,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 16),
              decoration: getDecoration()),
        ],
      ),
    );
  }

  bool autoValidateOrNot = false;

  Widget _buildClinicNumber() {
    return Padding(
      padding: EdgeInsets.only(right: getProportionateScreenWidth(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Contact Number (Reception)",
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
          ),
          TextFormField(
              autovalidateMode: autoValidateOrNot
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              initialValue: myProfile.contactNumber,
              keyboardType: TextInputType.number,
              autofocus: false,
              onChanged: (value) {
                setState(() {
                  autoValidateOrNot = true;
                });
                doctorInfo.contactNumber = (value);
              },
              validator: (value) {
                if ((value != null &&
                        !(value.length == 10 || value.length == 11)) ||
                    value!.isEmpty)
                  return "Enter a valid Contact Number";
                else
                  return null;
              },
              cursorColor: Colors.black,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 16),
              decoration: getDecoration()),
        ],
      ),
    );
  }

  Widget _buildFees() {
    return Padding(
      padding: EdgeInsets.only(right: getProportionateScreenWidth(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Appointment Fees",
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
          ),
          TextFormField(
              keyboardType: TextInputType.number,
              initialValue: myProfile.appointmentFees.toString(),
              autofocus: false,
              onChanged: (value) =>
                  doctorInfo.appointmentFees = int.parse(value),
              validator: (value) => checkFiledEmpty(value!),
              cursorColor: Colors.black,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 16),
              decoration: getDecoration()),
        ],
      ),
    );
  }

  Widget _buildAvg() {
    return Padding(
      padding: EdgeInsets.only(right: getProportionateScreenWidth(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Average time for appointment (in mins)",
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
          ),
          TextFormField(
              enabled: false,
              initialValue: myProfile.avgTime.toString(),
              keyboardType: TextInputType.number,
              autofocus: false,
              onChanged: (value) => doctorInfo.avgTime = int.parse(value),
              validator: (value) => checkFiledEmpty(value!),
              cursorColor: Colors.black,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 16),
              decoration: getDecoration()),
        ],
      ),
    );
  }

  Widget timeSlot(int index, int slotNo) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          slotNo == 0
              ? SizedBox(
                  width: 25,
                )
              : ClipOval(
                  child: Material(
                    color: Color.fromARGB(255, 255, 74, 74),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (slotNo == 1) {
                            has2Slots[index] = false;
                          }
                          if (slotNo == 2) {
                            has3Slots[index] = false;
                          }
                        });
                      },
                      child: SizedBox(
                          width: 25,
                          height: 25,
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 14,
                          )),
                    ),
                  ),
                ),
          InkWell(
            onTap: () async {
              final TimeOfDay? timeOfDay = await showTimePicker(
                context: context,
                initialTime: index != 0
                    ? TimeOfDay(
                        hour: defaultStartTime[index - 1][slotNo].hour,
                        minute: defaultStartTime[index - 1][slotNo].minute)
                    : TimeOfDay(
                        hour: defaultStartTime[index][slotNo].hour,
                        minute: defaultStartTime[index][slotNo].minute),
                initialEntryMode: TimePickerEntryMode.dial,
                builder: (context, childWidget) {
                  return MediaQuery(
                      data: MediaQuery.of(context).copyWith(),
                      child: childWidget!);
                },
              );
              if (timeOfDay != null) {
                setState(() {
                  debugPrint("Setting the state of Index: " +
                      index.toString() +
                      " and slotNo: " +
                      slotNo.toString());
                  defaultStartTime[index][slotNo] = timeOfDay;
                  doctorInfo.timing[index][slotNo][0] = timeOfDay;
                  startTimesUpdatedOrNot[index][slotNo] = true;
                });
              }
            },
            child: Container(
              color: Color.fromARGB(255, 243, 243, 243),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Center(
                //some changinges were made here need to verify
                child: Text(
                  index == 0
                      ? defaultStartTime[index][slotNo].format(context)
                      : defaultStartTime[index][slotNo].format(context),
                  style: GoogleFonts.publicSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.black),
                ),
              ),
            ),
          ),
          Text("TO",
              style: GoogleFonts.publicSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Color.fromARGB(255, 144, 144, 144))),
          InkWell(
            onTap: () async {
              final TimeOfDay? timeOfDay = await showTimePicker(
                context: context,
                initialTime: index != 0
                    ? TimeOfDay(
                        hour: defaultEndTime[index - 1][slotNo].hour,
                        minute: defaultEndTime[index - 1][slotNo].minute)
                    : TimeOfDay(
                        hour: defaultEndTime[index][slotNo].hour,
                        minute: defaultEndTime[index][slotNo].minute),
                initialEntryMode: TimePickerEntryMode.dial,
                builder: (context, childWidget) {
                  return MediaQuery(
                      data: MediaQuery.of(context).copyWith(),
                      child: childWidget!);
                },
              );
              if (timeOfDay != null) {
                setState(() {
                  defaultEndTime[index][slotNo] = timeOfDay;
                  doctorInfo.timing[index][slotNo][1] = timeOfDay;
                  endTimesUpdatedOrNot[index][slotNo] = true;
                });
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: Color.fromARGB(255, 243, 243, 243),
              child: Center(
                child: Text(
                  index == 0
                      ? defaultEndTime[index][slotNo].format(context)
                      : defaultEndTime[index][slotNo].format(context),
                  style: GoogleFonts.publicSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.black),
                ),
              ),
            ),
          ),
          slotNo != 2
              ? ClipOval(
                  child: Material(
                    color: Colors.black,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (slotNo == 0) {
                            has2Slots[index] = true;
                          } else if (slotNo == 1) {
                            has3Slots[index] = true;
                          }
                        });
                      },
                      child: SizedBox(
                          width: 25,
                          height: 25,
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 14,
                          )),
                    ),
                  ),
                )
              : SizedBox(
                  width: 25,
                )
        ],
      ),
    );
  }

  Widget _buildHours() {
    return Padding(
      padding: EdgeInsets.only(left: getProportionateScreenWidth(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Cinic Working Hours",
            style: GoogleFonts.publicSans(
                fontWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
          ),
          SizedBox(
            height: 16,
          ),
          ListView.builder(
            padding: EdgeInsets.zero,
            physics: AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                          activeColor: Colors.black,
                          tristate: false,
                          value: sitOrNot[index],
                          checkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          onChanged: (value) {
                            value!
                                ? setState(() {
                                    sitOrNot[index] = value;
                                    if (index != 0) {
                                      if (has2Slots[index - 1])
                                        has2Slots[index] = true;
                                      if (has3Slots[index - 1])
                                        has3Slots[index] = true;
                                      for (int i = 0; i < 3; i++) {
                                        if (defaultStartTime[index - 1][i] !=
                                            TimeOfDay(hour: 0, minute: 0)) {
                                          defaultStartTime[index][i] =
                                              defaultStartTime[index - 1][i];
                                        }

                                        if (defaultEndTime[index - 1][i] !=
                                            TimeOfDay(hour: 0, minute: 0)) {
                                          defaultEndTime[index][i] =
                                              defaultEndTime[index - 1][i];
                                        }
                                      }
                                    }
                                  })
                                : setState(() {
                                    sitOrNot[index] = value;
                                    for (int i = 0; i < 3; i++) {
                                      defaultStartTime[index][i] =
                                          TimeOfDay(hour: 0, minute: 0);
                                      defaultEndTime[index][i] =
                                          TimeOfDay(hour: 0, minute: 0);
                                    }
                                  });
                          }),
                      Text(
                        weekdays[index],
                        style: GoogleFonts.publicSans(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.black),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sitOrNot[index]
                          ? timeSlot(index, 0)
                          : SizedBox(
                              height: 0,
                            ),
                      (has2Slots[index] && sitOrNot[index]) == true
                          ? timeSlot(index, 1)
                          : SizedBox(
                              height: 0,
                            ),
                      (has3Slots[index] && sitOrNot[index]) == true
                          ? timeSlot(index, 2)
                          : SizedBox(
                              height: 0,
                            ),
                    ],
                  )
                ],
              );
            },
            itemCount: 7,
          )
        ],
      ),
    );
  }

  Container navBar(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * (342 / 1460),
      height: MediaQuery.of(context).size.height * (61 / 647),
      decoration: BoxDecoration(
          border: Border.all(
            color: Color.fromARGB(255, 246, 246, 246),
          ),
          color: Color.fromARGB(255, 246, 246, 246),
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: getProportionateScreenHeight(3),
                bottom: getProportionateScreenHeight(3),
                left: MediaQuery.of(context).size.width * (7 / 1460),
                right: MediaQuery.of(context).size.width * (3 / 1460)),
            child: Container(
              width: MediaQuery.of(context).size.width * (159 / 1460),
              height: MediaQuery.of(context).size.height * (52 / 647),
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
                  "Personal",
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      color: pageIndex == 0
                          ? Colors.white
                          : Color.fromARGB(255, 154, 154, 154),
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: getProportionateScreenHeight(12)),
            child: VerticalDivider(
              thickness: 2,
              width: MediaQuery.of(context).size.width * (1 / 1460),
              color: Color.fromARGB(255, 234, 234, 234),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: getProportionateScreenHeight(3),
                bottom: getProportionateScreenHeight(3),
                left: MediaQuery.of(context).size.width * (3 / 1460),
                right: MediaQuery.of(context).size.width * (7 / 1460)),
            child: Container(
              width: MediaQuery.of(context).size.width * (159 / 1460),
              height: MediaQuery.of(context).size.height * (52 / 647),
              decoration: BoxDecoration(
                color: pageIndex == 1
                    ? Colors.black
                    : Color.fromARGB(255, 246, 246, 246),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: TextButton(
                onPressed: () => {
                  setState(() {
                    pageIndex = 1;
                  })
                },
                child: Text(
                  "Clinic",
                  style: GoogleFonts.inter(
                      fontSize: 18,
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
    );
  }

  void enterValues() {
    bool sitOrNotBool = false;
    for (int i = 0; i < 7; i++) {
      sitOrNotBool = false;
      for (int j = 0; j < 3; j++) {
        defaultStartTime[i][j] =
            computeSlot(myProfile.timing[i][j][0].toString());
        defaultEndTime[i][j] =
            computeSlot(myProfile.timing[i][j][1].toString());
        print("$i $j ${defaultStartTime[i][j]}");
        if (defaultStartTime[i][j].hour + defaultStartTime[i][j].minute > 0 ||
            defaultEndTime[i][j].hour + defaultEndTime[i][j].minute > 0)
          sitOrNotBool = true;

        if (j == 1) {
          if (defaultStartTime[i][j].hour + defaultStartTime[i][j].minute > 0 ||
              defaultEndTime[i][j].hour + defaultEndTime[i][j].minute > 0)
            has2Slots[i] = true;
        }
        if (j == 2) {
          if (defaultStartTime[i][j].hour + defaultStartTime[i][j].minute > 0 ||
              defaultEndTime[i][j].hour + defaultEndTime[i][j].minute > 0)
            has3Slots[i] = true;
        }
      }
      sitOrNot[i] = sitOrNotBool;
    }
  }
}

InputDecoration getDecoration() {
  return InputDecoration(
    contentPadding: EdgeInsets.symmetric(vertical: 14),
    border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
    enabledBorder:
        UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
    focusedBorder:
        UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
  );
}

TimeOfDay computeSlot(String d) {
  print("computing slot for time $d");
  d = d.replaceAll(",", "");
  d = d.padLeft(4, "0");
  int hours = int.parse(d.substring(0, 2));
  int minutes = int.parse(d.substring(2, 4));
  TimeOfDay slot = TimeOfDay(hour: hours, minute: minutes);
  return slot;
}

String? checkFiledEmpty(String value) {
  if (value.isEmpty)
    return "Enter a valid Input";
  else
    return null;
}

void saveDataToSharedPreference(DoctorModel doctorInfo, List<String> s,
    List<bool> slot2, List<bool> slot3, List<bool> sit) {
  List<String> sitOrNot = List.generate(7, (index) => ""),
      has3Slots = List.generate(7, (index) => ""),
      has2Slots = List.generate(7, (index) => "");
  for (var i = 0; i < sit.length; i++) {
    sitOrNot[i] = sit[i].toString();
    has2Slots[i] = slot2[i].toString();
    has3Slots[i] = slot3[i].toString();
  }
  myProfile = DoctorModel.copyWith(doctorInfo);
}

String convertToString(TimeOfDay timeOfDay) {
  String convertedString = timeOfDay.hour.toString().padLeft(2, "0") +
      timeOfDay.minute.toString().padLeft(2, "0");
  return convertedString;
}

Future<String> editDetail(DoctorModel doc) async {
  var response = await http.post(Uri.parse(editDetailUrl),
      headers: header, body: doc.toJson2());
  if (response.statusCode == HttpStatus.ok) {
    return "Successfully changed the Details!";
  } else {
    return "Error occurred in changing the details!";
  }
}
