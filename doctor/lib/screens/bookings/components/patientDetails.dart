import 'dart:convert';
import 'package:doctor/Models/AddPatientModel.dart';
import 'package:doctor/Models/DoctorBookings.dart';
import 'package:doctor/Models/MedicalFiles.dart';
import 'package:doctor/Models/MedicineDetailsModel.dart';
import 'package:doctor/Models/PatientModel.dart';
import 'package:doctor/components/size_config.dart';
import 'package:doctor/screens/allPatientScreen/components/webBody.dart';
import 'package:doctor/screens/bookings/components/patientAllBookingsScreen.dart';
import 'package:doctor/screens/bookings/components/requests.dart';
import 'package:doctor/screens/homeScreen/components/Helper.dart';
import 'package:doctor/screens/homeScreen/components/requests.dart';
import 'package:doctor/screens/prescriptionScreen/components/constants.dart';
import 'package:doctor/screens/prescriptionScreen/components/providers.dart';
import 'package:doctor/screens/prescriptionScreen/components/rx_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuple/tuple.dart';

import 'imageViewer.dart';

class PatientDetailWeb extends StatefulWidget {
  final PatientModel patientModel;
  final Function showAddPatientScreen;
  PatientDetailWeb(this.patientModel, this.showAddPatientScreen);

  @override
  State<PatientDetailWeb> createState() => _PatientDetailWebState();
}

class _PatientDetailWebState extends State<PatientDetailWeb> {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      flex: 1,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
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
            future: getPatientAllBookings(widget.patientModel.id),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.connectionState == ConnectionState.done) {
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
                              Text("Name:",
                                  style: GoogleFonts.publicSans(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14)),
                              Text(
                                  widget.patientModel.firstName +
                                      " " +
                                      widget.patientModel.lastName,
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
                              Text("Age:",
                                  style: GoogleFonts.publicSans(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14)),
                              Text(widget.patientModel.age.toString(),
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
                              Text(widget.patientModel.gender,
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
                              SelectableText(
                                  widget.patientModel.phoneNumber.toString(),
                                  style: GoogleFonts.publicSans(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600))
                            ],
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: TextButton(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty
                                      .all<OutlinedBorder>(RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  getProportionateScreenHeight(
                                                      24))))),
                                  elevation:
                                      MaterialStateProperty.all<double>(10),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.black)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Book Another Appointment",
                                  style: GoogleFonts.publicSans(
                                      fontSize:
                                          getProportionateScreenHeight(20),
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                ),
                              ),
                              onPressed: () {
                                widget.showAddPatientScreen(AddPatientModel(
                                    widget.patientModel.firstName,
                                    widget.patientModel.lastName,
                                    widget.patientModel.age,
                                    widget.patientModel.phoneNumber,
                                    "Checkup",
                                    widget.patientModel.gender,
                                    false,
                                    widget.patientModel.address));
                              },
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          )
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
                                        horizontal:
                                            getProportionateScreenWidth(12),
                                        vertical:
                                            getProportionateScreenHeight(6)),
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
                                        intComputeSlot(int.parse(
                                                bookingList[index].slotTime))
                                            .format(context),
                                    style: GoogleFonts.publicSans(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color:
                                            Color.fromARGB(255, 106, 106, 106)),
                                  ),
                                  title: Text(
                                    bookingList[index].treatment,
                                    style: GoogleFonts.publicSans(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.black),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () => {
                                        showDialog(
                                          context: context,
                                          builder: (_contex) => documentDialog(
                                              bookingList[index].bookingId,
                                              _contex,
                                              bookingList[index].fileAvailable),
                                        )
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.attachment,
                                              color: bookingList[index]
                                                          .fileAvailable !=
                                                      true
                                                  ? Colors.blue
                                                  : Colors.green),
                                          Text(
                                            bookingList[index].fileAvailable ==
                                                    true
                                                ? "Attached Files"
                                                : "Upload Files",
                                            style: GoogleFonts.publicSans(
                                                color: bookingList[index]
                                                            .fileAvailable !=
                                                        true
                                                    ? Colors.blue
                                                    : Colors.green),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: getProportionateWebScreenWidth(15),
                                    ),
                                    Consumer(builder: (context, ref, child) {
                                      return InkWell(
                                        onTap: () {
                                          // showPreviousPrescription(context,
                                          //     bookingList[index].bookingId);
                                          ref
                                              .read(medicineDetailsListProvider
                                                  .notifier)
                                              .update((state) => [
                                                    MedicineDetailsModel(
                                                      type: '',
                                                      name:
                                                          ConstantsForPrescriptionScreen
                                                              .unSelectedTag,
                                                      when:
                                                          ConstantsForPrescriptionScreen
                                                              .whenList.first,
                                                      duration:
                                                          ConstantsForPrescriptionScreen
                                                              .durationList
                                                              .first,
                                                      dose:
                                                          ConstantsForPrescriptionScreen
                                                              .dosageList.first,
                                                      saltComposition:
                                                          ConstantsForPrescriptionScreen
                                                              .saltCompositionValue,
                                                    )
                                                  ]);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => Material(
                                                child: Scaffold(
                                                  body: PrescriptionScreenTwo(
                                                    patient:
                                                        widget.patientModel,
                                                    bookingId:
                                                        bookingList[index]
                                                            .bookingId,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Rx',
                                          style: TextStyle(
                                            shadows: [
                                              Shadow(
                                                  color: Colors.purple,
                                                  offset: Offset(0, -5))
                                            ],
                                            decoration:
                                                TextDecoration.underline,
                                            decorationThickness: 3,
                                            decorationStyle:
                                                TextDecorationStyle.dotted,
                                            color: Colors.transparent,
                                            decorationColor: Colors.purple,
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
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
      ),
    );
  }
}

AlertDialog documentDialog(
    int bookingId, BuildContext context, bool? filesAvailable) {
  return AlertDialog(
    backgroundColor: Colors.white,
    content: SizedBox(
      height: SizeConfig.screenHeight * 0.6,
      width: SizeConfig.screenWidth * 0.6,
      child: FutureBuilder(
          future: getTreatmentFiles(bookingId),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              var p = snapshot.data
                  as Tuple2<List<MedicalFiles>, List<MedicalFiles>>;
              List<MedicalFiles> images = p.item1;
              List<MedicalFiles> documents = p.item2;

              bool bool1 = (images.length != 0),
                  bool2 = (documents.length != 0);
              return Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          filesAvailable == true
                              ? "Attached files"
                              : "Upload Files",
                          style: GoogleFonts.publicSans(
                              fontSize: getProportionateScreenHeight(20),
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.upload),
                          onPressed: () async {
                            String message = "File uploaded succesfully";
                            String response = await uploadFile(bookingId,
                                context, documents.length + images.length);

                            if (response == "Error")
                              message =
                                  "File could not be added due to some error";
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(message)));
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  bool1
                      ? Text(
                          "Image files",
                          style: GoogleFonts.publicSans(
                              fontSize: getProportionateScreenHeight(16),
                              fontWeight: FontWeight.w700),
                        )
                      : SizedBox(height: 0),
                  SizedBox(
                    height: 10,
                  ),
                  // GalleryImageView(
                  //     width: MediaQuery.of(context).size.width,

                  //     listImage: images.map((e) {
                  //       return Image.memory(base64Decode(e.fileData),
                  //               fit: BoxFit.scaleDown)
                  //           .image;
                  //     }).toList(),
                  //     imageDecoration: BoxDecoration(
                  //         border: Border.all(color: Colors.white)),
                  //     galleryType: 1),
                  bool1
                      // ? Expanded(
                      //     child: ListView.builder(
                      //         itemCount: images.length,
                      //         itemBuilder: (_context, index) {
                      //           return InkWell(
                      //             onTap: () => SwipeImageGallery(
                      //               backgroundColor: Colors.white,
                      //               context: context,
                      //               initialIndex: index,
                      //               dismissDragDistance: 1,
                      //               itemBuilder: (context, _index) {
                      //                 return Stack(
                      //                   children: [
                      //                     Center(
                      //                       child: Image.memory(
                      //                           base64Decode(
                      //                               images[_index].fileData),
                      //                           fit: BoxFit.scaleDown),
                      //                     ),
                      //                     Positioned(
                      //                       left: SizeConfig.screenWidth * 0.9,
                      //                       top: SizeConfig.screenHeight * 0.05,
                      //                       child: IconButton(
                      //                           icon: Icon(Icons.close,
                      //                               color: Colors.black),
                      //                           onPressed: () =>
                      //                               Navigator.pop(context)),
                      //                     )
                      //                   ],
                      //                 );
                      //               },
                      //               itemCount: images.length,
                      //             ).show(),
                      //             child: Padding(
                      //               padding: const EdgeInsets.all(8.0),
                      //               child: Container(
                      //                   decoration: BoxDecoration(
                      //                       border: Border.all(
                      //                           color: Colors.grey,
                      //                           width: 0.2)),
                      //                   height:
                      //                       getProportionateScreenHeight(100),
                      //                   width: getProportionateScreenWidth(150),
                      //                   child: Image.memory(
                      //                     base64Decode(images[index].fileData),
                      //                   )),
                      //             ),
                      //           );
                      //         },
                      //         scrollDirection: Axis.horizontal),
                      //   )
                      ? Padding(
                          padding: EdgeInsets.only(
                              top: getProportionateScreenHeight(8)),
                          child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.3,
                              // child: GalleryImageView(
                              //     width:
                              //         MediaQuery.of(context).size.width,
                              //     listImage: fileList.item1.map((e) {
                              //       return Image.memory(
                              //               base64Decode(e.fileData),
                              //               fit: BoxFit.cover)
                              //           .image;
                              //     }).toList(),
                              //     imageDecoration: BoxDecoration(
                              //         border: Border.all(
                              //             color: Colors.white)),
                              //     galleryType: 1)
                              child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3),
                                itemCount: images.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ImageListView(
                                                      images: images,
                                                      index: index)));
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          getProportionateScreenHeight(12)),
                                      child: Image(
                                          image: Image.memory(
                                        base64Decode(images[index].fileData),
                                        fit: BoxFit.cover,
                                      ).image),
                                    ),
                                  );
                                },
                              )))
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.15,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.12,
                                  child: Center(
                                      child: Image.asset(
                                    'assets/images/no_notifs.png',
                                    width: getProportionateScreenWidth(171),
                                    fit: BoxFit.contain,
                                  ))),
                              Text(
                                "No Attached Images!",
                                style: GoogleFonts.publicSans(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              )
                            ],
                          ),
                        ),
                  SizedBox(
                    height: 20,
                  ),
                  bool2
                      ? Text(
                          "Document Files",
                          style: GoogleFonts.publicSans(
                              fontSize: getProportionateScreenHeight(16),
                              fontWeight: FontWeight.w700),
                        )
                      : SizedBox(height: 0),
                  SizedBox(
                    height: 4,
                  ),
                  documents.length != 0
                      ? Expanded(
                          child: ListView.builder(
                              itemCount: documents.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Icon(
                                    Icons.file_open,
                                    color: Colors.green,
                                  ),
                                  title: Text(documents[index].fileName),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                          onPressed: () async {
                                            var response = await deleteFileApi(
                                                bookingId,
                                                documents[index].fileName);
                                            String message =
                                                "File deleted successfully";
                                            if (response == "Error")
                                              message =
                                                  "Could not delete file due to some error";
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(message)));
                                            Navigator.of(context).pop();
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          )),
                                      IconButton(
                                        icon: Icon(
                                          Icons.download,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          downloadFile(documents[index]);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }))
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.15,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.12,
                                  child: Center(
                                      child: Image.asset(
                                    'assets/images/no_notifs.png',
                                    width: getProportionateScreenWidth(171),
                                    fit: BoxFit.contain,
                                  ))),
                              Text(
                                "No Attached Documents!",
                                style: GoogleFonts.publicSans(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              )
                            ],
                          ),
                        )
                ],
              );
            }
            return SpinKitPouringHourGlass(color: Colors.grey);
          }),
    ),
  );
}
