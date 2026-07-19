import 'package:doctor/Models/AddPatientModel.dart';
import 'package:doctor/screens/allPatientScreen/components/webBody.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../Models/PatientModel.dart';
import '../../components/urls.dart';
import 'components/requests.dart';

class AllPatientScreen extends StatefulWidget {
  Function(AddPatientModel) showAddPatientScreen;
  AllPatientScreen(this.showAddPatientScreen);
  @override
  State<AllPatientScreen> createState() => _AllPatientScreenState();
}

class _AllPatientScreenState extends State<AllPatientScreen> {
  List<PatientModel> patListToDisplay = [];
  late Future<List<PatientModel>> patListFuture;
  bool added = false;

  @override
  void initState() {
    super.initState();
    patListFuture = getAllPatientsFuture(myProfile.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(right: BorderSide(color: Colors.grey, width: 1))),
      child: FutureBuilder(
          future: getAllPatientsFuture(myProfile.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<PatientModel> patList = snapshot.data as List<PatientModel>;
              return AllPatientsBodyWeb(
                patList: patList,
                showAddPatientScreen: widget.showAddPatientScreen
              );
            } else
              return SpinKitPouringHourGlass(color: Colors.grey);
          }),
    );
  }
}
