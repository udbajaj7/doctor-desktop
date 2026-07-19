import 'dart:math';

import 'package:doctor/Models/MedicineDetailsModel.dart';
import 'package:doctor/Models/MedicineModel.dart';
import 'package:doctor/components/size_config.dart';
import 'package:doctor/screens/prescriptionScreen/components/constants.dart';
import 'package:doctor/screens/prescriptionScreen/components/providers.dart';
import 'package:doctor/screens/prescriptionScreen/components/requests.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicineTableWidget2 extends ConsumerStatefulWidget {
  final List<MedicineModel> medicines;
  const MedicineTableWidget2({Key? key, required this.medicines})
      : super(key: key);

  @override
  ConsumerState<MedicineTableWidget2> createState() =>
      _MedicineTableWidget2State();
}

class _MedicineTableWidget2State extends ConsumerState<MedicineTableWidget2> {
  void parentSetStateFunction() {
    setState(() {});
    print('callback happened');
  }

  void addNewMedicine() {
    List<MedicineDetailsModel> meds =
        ref.read(medicineDetailsListProvider.notifier).state;
    print('this is the meds $meds');

    try {
      if (meds.last.name == ConstantsForPrescriptionScreen.unSelectedTag) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select a medicine first')));
        return;
      }
    } catch (e) {
      print('caught error in addnewmedicine ${e.toString}');
    }
    setState(() {
      MedicineDetailsModel newMed = MedicineDetailsModel(
        type: widget.medicines.first.type,
        name: widget.medicines.first.name,
        when: ConstantsForPrescriptionScreen.whenList.first,
        duration: ref.read(medicineDetailsListProvider).last.duration,
        dose: ConstantsForPrescriptionScreen.dosageList.first,
        saltComposition: ConstantsForPrescriptionScreen.saltCompositionValue,
      );

      ref
          .read(medicineDetailsListProvider.notifier)
          .update((state) => [...state, newMed]);
    });
    ref.read(isPrescriptionSavedProvider.notifier).update((state) => false);
  }

  void onSelectSOS(int index) {
    print('onSelectSOS called');
    setState(() {
      ref.read(medicineDetailsListProvider.notifier).update((state) {
        state[index].duration = 'NA';
        return state;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        HeaderRowWidget(),
        for (MedicineDetailsModel meds
            in ref.watch(medicineDetailsListProvider))
          TableRowWidget(
            key: ValueKey(
                (meds.name) + (meds.dose) + (meds.when) + (meds.duration)),
            medicineDetails: meds,
            index: ref.watch(medicineDetailsListProvider).indexOf(meds),
            medicines: widget.medicines,
            callback: parentSetStateFunction,
            onSelectSOS: onSelectSOS,
          ),
        FooterRowWidget(onTap: addNewMedicine),
      ],
    );
  }
}

class AddCustomMedicineWidget extends ConsumerStatefulWidget {
  const AddCustomMedicineWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<AddCustomMedicineWidget> createState() =>
      _AddCustomMedicineWidgetState();
}

class _AddCustomMedicineWidgetState
    extends ConsumerState<AddCustomMedicineWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        addCustomMedicine(
          context,
          ref,
        );
      },
      child: Center(
        child: Text(
          ' Add Custom Medicine',
          style: TextStyle(
            color: Color.fromRGBO(34, 104, 255, 1),
          ),
        ),
      ),
    );
  }
}

void addCustomMedicine(
  BuildContext context,
  WidgetRef ref,
) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (builder) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
      ),
      shadowColor: Colors.black,
      surfaceTintColor: Colors.transparent,
      child: CustomMedicineInputWidget(),
    ),
  );
}

class CustomMedicineInputWidget extends ConsumerStatefulWidget {
  const CustomMedicineInputWidget({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<CustomMedicineInputWidget> createState() =>
      _CustomMedicineInputWidgetState();
}

class _CustomMedicineInputWidgetState
    extends ConsumerState<CustomMedicineInputWidget> {
  TextEditingController nameController = TextEditingController();
  TextEditingController instructionsController = TextEditingController();
  String dropdownValue = ConstantsForPrescriptionScreen.medicineTypeList.first;

  @override
  void dispose() {
    nameController.dispose();
    instructionsController.dispose();
    dropdownValue = ConstantsForPrescriptionScreen.medicineTypeList.first;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getProportionateScreenHeight(215),
      width: getProportionateScreenWidth(400),
      child: Padding(
        padding: EdgeInsets.only(
          top: getProportionateWebScreenHeight(18),
          left: getProportionateWebScreenWidth(16),
          right: getProportionateWebScreenWidth(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text('Name              '),
                SizedBox(
                  width: getProportionateScreenWidth(20),
                ),
                SizedBox(
                  width: getProportionateScreenWidth(200),
                  child: TextField(
                    cursorColor: Colors.black,
                    controller: nameController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: getProportionateScreenHeight(10),
            ),
            Row(
              children: [
                Text('Type                '),
                SizedBox(
                  width: getProportionateScreenWidth(20),
                ),
                SizedBox(
                  width: getProportionateScreenWidth(200),
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    icon: null,
                    underline: Container(
                      color: Colors.transparent,
                    ),
                    items: [
                      for (String type
                          in ConstantsForPrescriptionScreen.medicineTypeList)
                        DropdownMenuItem(
                          child: SizedBox(
                            width: getProportionateWebScreenWidth(140),
                            child: Text(
                              type,
                              maxLines: 1,
                            ),
                          ),
                          value: type,
                        ),
                    ],
                    onChanged: (String? value) {
                      setState(() {
                        dropdownValue = value ?? '';
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              height: getProportionateScreenHeight(7),
            ),
            Row(
              children: [
                Text('Salt Composition'),
                SizedBox(
                  width: getProportionateScreenWidth(5),
                ),
                SizedBox(
                  width: getProportionateScreenWidth(200),
                  child: TextField(
                    cursorColor: Colors.black,
                    controller: instructionsController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: getProportionateScreenHeight(20),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: getProportionateScreenHeight(20),
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(20),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: getProportionateScreenWidth(20),
                ),
                InkWell(
                  onTap: () async {
                    String name = nameController.text;
                    String type = dropdownValue;
                    String instructions = instructionsController.text;
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter a name'),
                        ),
                      );
                    }
                    if (type.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter a type'),
                        ),
                      );
                    }
                    if (name.isNotEmpty && type.isNotEmpty) {
                      String temp =
                          '$name${ConstantsForPrescriptionScreen.alternateMedicineDelimiter}$type${ConstantsForPrescriptionScreen.alternateMedicineDelimiter}$instructions';
                      int statusCode = await saveCustomMedicine(
                        name: name,
                        type: type,
                        instructions: instructions,
                      );

                      if (statusCode == 200) {
                        ref
                            .read(customMedicinesProvider.notifier)
                            .update((state) => [...state, temp]);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text(
                              'Custom Medicine Added!',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                        nameController.clear();

                        instructionsController.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              'Something went wrong!',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }
                    }
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: getProportionateScreenHeight(20),
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(20),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        'Add',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MedicineTableWidget extends ConsumerStatefulWidget {
  final List<MedicineModel> medicines;
  const MedicineTableWidget({Key? key, required this.medicines})
      : super(key: key);

  @override
  ConsumerState<MedicineTableWidget> createState() =>
      _MedicineTableWidgetState();
}

class _MedicineTableWidgetState extends ConsumerState<MedicineTableWidget> {
  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(
        color: Color.fromRGBO(202, 202, 202, 1),
        width: 1,
      ),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        0: FixedColumnWidth(getProportionateScreenWidth(27)),
        1: FixedColumnWidth(getProportionateScreenWidth(64)),
        2: FixedColumnWidth(getProportionateScreenWidth(178)),
        3: FixedColumnWidth(getProportionateScreenWidth(105)),
        4: FixedColumnWidth(getProportionateScreenWidth(104)),
        5: FixedColumnWidth(getProportionateScreenWidth(98)),
        6: FixedColumnWidth(getProportionateScreenWidth(86)),
        7: FixedColumnWidth(getProportionateScreenWidth(162)),
      },
      children: [
        HeaderRow(),
        for (MedicineDetailsModel meds
            in ref.watch(medicineDetailsListProvider))
          buildTableRow(
              widget.medicines,
              ref.read(medicineDetailsListProvider).indexOf(meds),
              meds,
              ref,
              addNewMedicine),
        FooterRow(addNewMedicine),
      ],
    );
  }

  void addNewMedicine() {
    setState(() {
      MedicineDetailsModel newMed = MedicineDetailsModel(
        type: widget.medicines.first.type,
        name: widget.medicines.first.name,
        when: ConstantsForPrescriptionScreen.whenList.first,
        duration: ConstantsForPrescriptionScreen.durationList.first,
        dose: ConstantsForPrescriptionScreen.dosageList.first,
        saltComposition: ConstantsForPrescriptionScreen.saltCompositionValue,
      );

      ref
          .read(medicineDetailsListProvider.notifier)
          .update((state) => [...state, newMed]);
    });
  }
}

TableRow HeaderRow() {
  return TableRow(
    decoration: BoxDecoration(
      color: const Color(0xFFECECEC),
    ),
    children: [
      SizedBox(
        width: getProportionateWebScreenWidth(27),
        child: Center(
          child: Text('#'),
        ),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(64),
        child: Center(
          child: Text('Type'),
        ),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(178),
        child: Center(
          child: Text('Medicine'),
        ),
      ),
      SizedBox(
        height: getProportionateWebScreenHeight(45),
        width: getProportionateWebScreenWidth(65),
        child: Center(
          child: Text('Dosage'),
        ),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(74),
        child: Center(
          child: Text('When'),
        ),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(98),
        child: Center(
          child: Text('Frequency'),
        ),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(86),
        child: Center(
          child: Text('Duration'),
        ),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(162),
        child: Center(
          child: Text('Instructions'),
        ),
      ),
    ],
  );
}

TableRow FooterRow(Function onTap) {
  return TableRow(
    decoration: BoxDecoration(
      color: Color.fromARGB(255, 255, 255, 255),
    ),
    children: [
      Container(
        color: const Color(0xFFECECEC),
        width: getProportionateWebScreenWidth(27),
        height: getProportionateWebScreenHeight(45),
        child: Center(
          child: Text(' '),
        ),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(64),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(178),
        child: GestureDetector(
          onTap: () {
            onTap();
          },
          child: Center(
            child: Text(
              ' Add New Medicine',
              style: TextStyle(
                color: Colors.blue[400],
              ),
            ),
          ),
        ),
      ),
      SizedBox(
        height: getProportionateWebScreenHeight(45),
        width: getProportionateWebScreenWidth(65),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(74),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(98),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(86),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(162),
      ),
    ],
  );
}

TableRow FooterRow2() {
  return TableRow(
    decoration: BoxDecoration(
      color: Color.fromARGB(255, 255, 255, 255),
    ),
    children: [
      Container(
        color: const Color(0xFFECECEC),
        width: getProportionateWebScreenWidth(27),
        height: getProportionateWebScreenHeight(45),
        child: Center(
          child: Text(' '),
        ),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(64),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(178),
      ),
      SizedBox(
        height: getProportionateWebScreenHeight(45),
        width: getProportionateWebScreenWidth(65),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(74),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(98),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(86),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(162),
      ),
    ],
  );
}

TableRow buildTableRow(List<MedicineModel> medicines, int index,
    MedicineDetailsModel medicineDetails, WidgetRef ref, Function onSelectSOS) {
  return TableRow(
    children: [
      Container(
        color: const Color(0xFFECECEC),
        width: getProportionateWebScreenWidth(27),
        height: getProportionateWebScreenHeight(45),
        child: Center(
          child: Text('${index + 1}'),
        ),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(64),
        child: Center(
          child: Text(ref.watch(medicineDetailsListProvider)[index].type),
        ),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(178),
        child: Center(
            // child: DropDownMedicineWidget(
            //   medicineList: medicines.map((e) => e.name).toList(),
            //   index: index,
            //   medicines: medicines,
            // ),
            ),
      ),
      SizedBox(
        height: getProportionateWebScreenHeight(45),
        width: getProportionateWebScreenWidth(65),
        child: Center(
          child: DropDownDoseageWidget(
            dosageList: ConstantsForPrescriptionScreen.dosageList,
            index: index,
            initialValue: medicineDetails.dose,
            onSelectSOS: (int index) {
              onSelectSOS(index);
            },
          ),
        ),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(74),
        child: Center(
          child: DropDownWhenWidget(
            whenList: ConstantsForPrescriptionScreen.whenList,
            index: index,
            initialValue: medicineDetails.when,
          ),
        ),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(86),
        child: Center(
          child: DropDownDurationWidget(
            durationList: ConstantsForPrescriptionScreen.durationList,
            index: index,
            initialValue: medicineDetails.duration,
          ),
        ),
      ),
    ],
  );
}

class HeaderRowWidget extends StatelessWidget {
  const HeaderRowWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: const Color(0xFFECECEC),
          ),
          height: getProportionateWebScreenHeight(45),
          width: getProportionateWebScreenWidth(27),
          child: Center(
            child: Text('#'),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: const Color(0xFFECECEC),
          ),
          height: getProportionateWebScreenHeight(45),
          width: getProportionateWebScreenWidth(64),
          child: Center(
            child: Text('Type'),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: const Color(0xFFECECEC),
          ),
          height: getProportionateWebScreenHeight(45),
          width: getProportionateWebScreenWidth(350),
          child: Center(
            child: Text('Medicine'),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: const Color(0xFFECECEC),
          ),
          height: getProportionateWebScreenHeight(45),
          width: getProportionateWebScreenWidth(125),
          child: Center(
            child: Text('Dosage'),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: const Color(0xFFECECEC),
          ),
          height: getProportionateWebScreenHeight(45),
          width: getProportionateWebScreenWidth(175),
          child: Center(
            child: Text('When'),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: const Color(0xFFECECEC),
          ),
          height: getProportionateWebScreenHeight(45),
          width: getProportionateWebScreenWidth(140),
          child: Center(
            child: Text('Duration'),
          ),
        ),
      ],
    );
  }
}

class TableRowWidget extends ConsumerWidget {
  final MedicineDetailsModel medicineDetails;
  final List<MedicineModel> medicines;
  final int index;
  final Function callback;
  final Function onSelectSOS;
  const TableRowWidget({
    Key? key,
    required this.medicineDetails,
    required this.index,
    required this.medicines,
    required this.callback,
    required this.onSelectSOS,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: getProportionateWebScreenWidth(27),
          height: getProportionateWebScreenHeight(
              ConstantsForPrescriptionScreen.cellHeight),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: const Color(0xFFECECEC),
          ),
          child: Center(
            child: Text('${index + 1}'),
          ),
        ),
        Container(
          width: getProportionateWebScreenWidth(64),
          height: getProportionateWebScreenHeight(
              ConstantsForPrescriptionScreen.cellHeight),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: Center(
            child: Text(medicineDetails.type),
          ),
        ),
        Container(
          width: getProportionateWebScreenWidth(350),
          height: getProportionateWebScreenHeight(
              ConstantsForPrescriptionScreen.cellHeight),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: AlternateMedicineDropDownWidget(
            medicineList: medicines.map((e) => e.name).toList(),
            index: index,
            medicines: medicines,
            callback: callback,
            initialValue: medicineDetails.name,
          ),
        ),
        Container(
          height: getProportionateWebScreenHeight(
              ConstantsForPrescriptionScreen.cellHeight),
          width: getProportionateWebScreenWidth(125),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: Center(
            child: DropDownDoseageWidget(
              dosageList: ConstantsForPrescriptionScreen.dosageList,
              index: index,
              initialValue: medicineDetails.dose,
              onSelectSOS: onSelectSOS,
            ),
          ),
        ),
        Container(
          width: getProportionateWebScreenWidth(175),
          height: getProportionateWebScreenHeight(
              ConstantsForPrescriptionScreen.cellHeight),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: Center(
            child: DropDownWhenWidget(
              whenList: ConstantsForPrescriptionScreen.whenList,
              index: index,
              initialValue: medicineDetails.when,
            ),
          ),
        ),
        Container(
          width: getProportionateWebScreenWidth(140),
          height: getProportionateWebScreenHeight(
              ConstantsForPrescriptionScreen.cellHeight),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: Center(
            child: DropDownDurationWidget(
              // key: ValueKey(medicineDetails.duration),
              durationList: ConstantsForPrescriptionScreen.durationList,
              index: index,
              initialValue: medicineDetails.duration,
            ),
          ),
        ),
        SizedBox(width: getProportionateWebScreenWidth(10)),
        IconButton(
          onPressed: () {
            ref.read(medicineDetailsListProvider.notifier).update((state) {
              state.removeAt(index);
              ref
                  .read(rebuildMedicineTableProvider.notifier)
                  .update((state) => Random().nextInt(1000));
              return state;
            });
            callback();
          },
          icon: Icon(Icons.delete),
        ),
      ],
    );
  }
}

class FooterRowWidget extends StatelessWidget {
  final Function onTap;
  const FooterRowWidget({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: getProportionateWebScreenWidth(27),
          height: getProportionateWebScreenHeight(45),
          child: Center(
            child: Text(' '),
          ),
        ),
        SizedBox(
          width: getProportionateWebScreenWidth(64),
        ),
        SizedBox(
          width: getProportionateWebScreenWidth(178),
          child: InkWell(
            onTap: () {
              onTap();
            },
            child: Center(
              child: Text(
                '+ Add New Medicine',
                style: TextStyle(
                  color: Color.fromRGBO(34, 104, 255, 1),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: getProportionateWebScreenHeight(200),
        ),
      ],
    );
  }
}

class DropDownMedicineWidget extends ConsumerStatefulWidget {
  final int index;
  final List<String> medicineList;
  final List<MedicineModel> medicines;
  final Function callback;
  final String initialValue;
  const DropDownMedicineWidget({
    Key? key,
    required this.medicineList,
    required this.index,
    required this.medicines,
    required this.callback,
    required this.initialValue,
  }) : super(key: key);

  @override
  ConsumerState<DropDownMedicineWidget> createState() =>
      _DropDownMedicineWidgetState();
}

class _DropDownMedicineWidgetState
    extends ConsumerState<DropDownMedicineWidget> {
  late String dropDownValue;
  @override
  void initState() {
    // dropDownValue = widget.medicineList.first;
    dropDownValue = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      enableFeedback: true,
      focusColor: Theme.of(context).cardColor,
      focusNode: anotherFocusNode,
      value: dropDownValue,
      icon: null,
      underline: Container(
        color: Colors.transparent,
      ),
      items: [
        for (String medicine in widget.medicineList)
          DropdownMenuItem(
            child: SizedBox(
              width: getProportionateWebScreenWidth(140),
              child: Text(
                medicine,
                maxLines: 1,
              ),
            ),
            value: medicine,
          ),
      ],
      onChanged: (String? value) {
        setState(() {
          dropDownValue = value ?? '';
        });
        ref.read(medicineDetailsListProvider.notifier).update((state) {
          state[widget.index].name = value ?? '';

          widget.medicines.forEach((element) {
            if (element.name == value) {
              state[widget.index].type = element.type;
            }
          });
          return state;
        });
        widget.callback();
      },
    );
  }
}

class DropDownDoseageWidget extends ConsumerStatefulWidget {
  final int index;
  final List<String> dosageList;
  final String initialValue;
  final Function onSelectSOS;
  const DropDownDoseageWidget({
    Key? key,
    required this.index,
    required this.dosageList,
    required this.initialValue,
    required this.onSelectSOS,
  }) : super(key: key);

  @override
  ConsumerState<DropDownDoseageWidget> createState() =>
      _DropDownDoseageWidgetState();
}

class _DropDownDoseageWidgetState extends ConsumerState<DropDownDoseageWidget> {
  late String dropDownValue;
  bool showTextfield = false;
  TextEditingController dosageController = TextEditingController();
  @override
  void initState() {
    dropDownValue = widget.initialValue;
    dosageController.text = widget.initialValue;
    super.initState();
  }

  @override
  void dispose() {
    dosageController.dispose();
    super.dispose();
  }

  void prefillFunctionOnSelectMedicine(String? prefillValue) {
    if (prefillValue != null) {
      setState(() {
        if (widget.dosageList.contains(prefillValue)) {
          dropDownValue = prefillValue;
        } else {
          showTextfield = true;
          dosageController.text = prefillValue;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showTextfield ||
        !(ConstantsForPrescriptionScreen.dosageList.contains(dropDownValue))) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateWebScreenWidth(4)),
            child: SizedBox(
              width: getProportionateWebScreenWidth(85),
              child: Center(
                child: TextField(
                  controller: dosageController,
                  autofocus: true,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                  ),
                  onChanged: (s) {
                    ref
                        .read(medicineDetailsListProvider.notifier)
                        .update((state) {
                      state[widget.index].dose = s;
                      return state;
                    });
                  },
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                showTextfield = false;
              });
            },
            child: SizedBox(
              width: getProportionateWebScreenWidth(15),
              child: Icon(
                Icons.undo,
                color: Colors.black,
              ),
            ),
          )
        ],
      );
    }
    return DropdownButton<String>(
      value: dropDownValue,
      icon: null,
      alignment: Alignment.center,
      underline: Container(
        color: Colors.transparent,
      ),
      items: [
        for (String dosage in widget.dosageList)
          DropdownMenuItem(
            child: SizedBox(
              width: getProportionateWebScreenWidth(60),
              child: Text(
                dosage,
                maxLines: 1,
              ),
            ),
            value: dosage,
          ),
      ],
      onChanged: (String? value) {
        if (value == ConstantsForPrescriptionScreen.dosageList.last) {
          setState(() {
            showTextfield = true;
          });
          return;
        }
        setState(() {
          dropDownValue = value ?? '';
        });
        ref.read(medicineDetailsListProvider.notifier).update((state) {
          state[widget.index].dose = value ?? '';
          return state;
        });
        if (value == 'SOS') {
          widget.onSelectSOS(widget.index);
        }
      },
    );
  }
}

class DropDownDurationWidget extends ConsumerStatefulWidget {
  final int index;
  final List<String> durationList;
  final String initialValue;
  DropDownDurationWidget({
    Key? key,
    required this.index,
    required this.durationList,
    required this.initialValue,
  }) : super(key: key);

  final dropDownDurationState = _DropDownDurationWidgetState();

  void prefillFunctionOnSelectMedicine(String? s) {
    dropDownDurationState.prefillFunctionOnSelectMedicine(s);
  }

  @override
  ConsumerState<DropDownDurationWidget> createState() =>
      _DropDownDurationWidgetState();
}

class _DropDownDurationWidgetState
    extends ConsumerState<DropDownDurationWidget> {
  late String dropDownValue;

  void prefillFunctionOnSelectMedicine(String? prefillValue) {
    print('1');
    if (prefillValue != null) {
      print('2');
      setState(() {
        if (widget.durationList.contains(prefillValue)) {
          print('3');
          dropDownValue = prefillValue;
        }
        print('4');
      });
    }
  }

  @override
  void initState() {
    dropDownValue = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropDownValue,
      icon: null,
      alignment: Alignment.center,
      underline: Container(
        color: Colors.transparent,
      ),
      items: [
        for (String duration in widget.durationList)
          DropdownMenuItem(
            child: SizedBox(
              width: getProportionateWebScreenWidth(70),
              child: Text(
                duration,
                maxLines: 1,
              ),
            ),
            value: duration,
          ),
      ],
      onChanged: (String? value) {
        setState(() {
          dropDownValue = value ?? '';
        });
        ref.read(medicineDetailsListProvider.notifier).update((state) {
          state[widget.index].duration = value ?? '';
          return state;
        });
      },
    );
  }
}

class DropDownWhenWidget extends ConsumerStatefulWidget {
  final int index;
  final List<String> whenList;
  final String initialValue;
  const DropDownWhenWidget({
    Key? key,
    required this.index,
    required this.whenList,
    required this.initialValue,
  }) : super(key: key);

  @override
  ConsumerState<DropDownWhenWidget> createState() => _DropDownWhenWidgetState();
}

class _DropDownWhenWidgetState extends ConsumerState<DropDownWhenWidget> {
  late String dropDownValue;
  bool showTextfield = false;
  TextEditingController whenController = TextEditingController();
  @override
  void initState() {
    dropDownValue = widget.initialValue;
    whenController.text = widget.initialValue;
    super.initState();
  }

  @override
  void dispose() {
    whenController.dispose();
    super.dispose();
  }

  void prefillFunctionOnSelectMedicine(String? prefillValue) {
    if (prefillValue != null) {
      setState(() {
        if (widget.whenList.contains(prefillValue)) {
          dropDownValue = prefillValue;
        } else {
          showTextfield = true;
          whenController.text = prefillValue;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showTextfield ||
        !(ConstantsForPrescriptionScreen.whenList.contains(dropDownValue))) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateWebScreenWidth(4)),
            child: SizedBox(
              width: getProportionateWebScreenWidth(110),
              child: Center(
                child: TextField(
                  controller: whenController,
                  autofocus: true,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                  ),
                  onChanged: (s) {
                    ref
                        .read(medicineDetailsListProvider.notifier)
                        .update((state) {
                      state[widget.index].when = s;
                      return state;
                    });
                  },
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                showTextfield = false;
              });
            },
            child: SizedBox(
              width: getProportionateWebScreenWidth(15),
              child: Icon(
                Icons.undo,
                color: Colors.black,
              ),
            ),
          )
        ],
      );
    }
    return DropdownButton<String>(
      value: dropDownValue,
      alignment: Alignment.center,
      icon: null,
      underline: Container(
        color: Colors.transparent,
      ),
      items: [
        for (String when in widget.whenList)
          DropdownMenuItem(
            child: SizedBox(
              width: getProportionateWebScreenWidth(130),
              child: Text(
                when,
                maxLines: 1,
              ),
            ),
            value: when,
          ),
      ],
      onChanged: (String? value) {
        if (value == ConstantsForPrescriptionScreen.whenList.last) {
          setState(() {
            showTextfield = true;
          });
          return;
        }
        setState(() {
          dropDownValue = value ?? '';
        });
        ref.read(medicineDetailsListProvider.notifier).update((state) {
          state[widget.index].when = value ?? '';
          return state;
        });
      },
    );
  }
}

class MedicineTableWidgetStateless extends StatelessWidget {
  final List<MedicineDetailsModel> medicines;
  const MedicineTableWidgetStateless({Key? key, required this.medicines})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(
        color: Color.fromRGBO(202, 202, 202, 1),
        width: 1,
      ),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        0: FixedColumnWidth(getProportionateScreenWidth(27)),
        1: FixedColumnWidth(getProportionateScreenWidth(64)),
        2: FixedColumnWidth(getProportionateScreenWidth(200)),
        3: FixedColumnWidth(getProportionateScreenWidth(105)),
        4: FixedColumnWidth(getProportionateScreenWidth(124)),
        5: FixedColumnWidth(getProportionateScreenWidth(108)),
        6: FixedColumnWidth(getProportionateScreenWidth(96)),
        7: FixedColumnWidth(getProportionateScreenWidth(162)),
      },
      children: [
        HeaderRow(),
        for (MedicineDetailsModel meds in medicines)
          buildTableRow2(medicines.indexOf(meds), meds),
      ],
    );
  }
}

TableRow buildTableRow2(int index, MedicineDetailsModel medicineDetails) {
  return TableRow(
    children: [
      Container(
        color: const Color(0xFFECECEC),
        width: getProportionateWebScreenWidth(27),
        height: getProportionateWebScreenHeight(45),
        child: Center(
          child: Text('${index + 1}'),
        ),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(64),
        child: Center(
          child: Text(medicineDetails.type),
        ),
      ),
      (medicineDetails.name
                      .split(ConstantsForPrescriptionScreen
                          .alternateMedicineDelimiter)
                      .length ==
                  2 &&
              medicineDetails.name
                  .split(
                      ConstantsForPrescriptionScreen.alternateMedicineDelimiter)
                  .last
                  .isNotEmpty)
          ? SizedBox(
              width: getProportionateWebScreenWidth(200),
              child: Column(
                children: [
                  Text(
                    medicineDetails.name
                        .split(ConstantsForPrescriptionScreen
                            .alternateMedicineDelimiter)
                        .first,
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    'or :  ${medicineDetails.name.split(ConstantsForPrescriptionScreen.alternateMedicineDelimiter).last}',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, color: Colors.grey),
                  ),
                ],
              ),
            )
          : SizedBox(
              width: getProportionateWebScreenWidth(200),
              child: Center(
                  child: Text(
                medicineDetails.name,
                style: TextStyle(fontWeight: FontWeight.w900),
              )),
            ),
      SizedBox(
        height: getProportionateWebScreenHeight(45),
        width: getProportionateWebScreenWidth(65),
        child: Center(child: Text(medicineDetails.dose)),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(94),
        child: Center(
          child: Text(medicineDetails.when),
        ),
      ),
      SizedBox(
        width: getProportionateWebScreenWidth(96),
        child: Center(child: Text(medicineDetails.duration)),
      ),
    ],
  );
}

class AlternateMedicineDropDownWidget extends ConsumerStatefulWidget {
  final int index;
  final List<String> medicineList;
  final List<MedicineModel> medicines;
  final Function callback;
  final String initialValue;
  const AlternateMedicineDropDownWidget({
    Key? key,
    required this.medicineList,
    required this.index,
    required this.medicines,
    required this.callback,
    required this.initialValue,
  }) : super(key: key);

  @override
  ConsumerState<AlternateMedicineDropDownWidget> createState() =>
      _AlternateMedicineDropDownWidgetState();
}

class _AlternateMedicineDropDownWidgetState
    extends ConsumerState<AlternateMedicineDropDownWidget> {
  late List<String> previouslySelectedMedicines;

  @override
  initState() {
    super.initState();
    previouslySelectedMedicines = widget.initialValue
        .split(ConstantsForPrescriptionScreen.alternateMedicineDelimiter);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: getProportionateWebScreenWidth(6),
        right: getProportionateWebScreenWidth(6),
        top: (previouslySelectedMedicines.length == 2 &&
                previouslySelectedMedicines.last.isNotEmpty)
            ? 0
            : getProportionateScreenHeight(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: getProportionateWebScreenWidth(290),
                // height: getProportionateWebScreenHeight(40),
                child: SearchableDropDownWidget(
                  medicineList: widget.medicineList,
                  index: widget.index,
                  medicines: widget.medicines,
                  callback: widget.callback,
                  initialValue: previouslySelectedMedicines.first,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  List<MedicineDetailsModel> meds =
                      ref.read(medicineDetailsListProvider.notifier).state;
                  MedicineDetailsModel med = meds[widget.index];
                  if (med.name ==
                      ConstantsForPrescriptionScreen.unSelectedTag) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Please select a medicine first')));
                  } else {
                    List<String> customMedicineDetails =
                        ref.watch(customMedicinesProvider);
                    List<String> customMedicineNames = [];
                    for (String customMedicine in customMedicineDetails) {
                      customMedicineNames.add(customMedicine
                          .split(ConstantsForPrescriptionScreen
                              .alternateMedicineDelimiter)
                          .first);
                    }
                    await showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          surfaceTintColor: Colors.white,
                          title: const Text('Select Alternate Medicine'),
                          content: SearchableDropDownWidget(
                            isAlternate: true,
                            medicineList: [
                              'None',
                              ...widget.medicineList,
                              ...customMedicineNames
                            ],
                            index: widget.index,
                            medicines: widget.medicines,
                            callback: widget.callback,
                            initialValue: previouslySelectedMedicines.last,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Ok'),
                            ),
                          ],
                        );
                      },
                    );
                    setState(() {
                      previouslySelectedMedicines = ref
                          .read(medicineDetailsListProvider)
                          .elementAt(widget.index)
                          .name
                          .split(ConstantsForPrescriptionScreen
                              .alternateMedicineDelimiter);
                    });
                  }
                },
                child: Icon(Icons.add_circle_outline_outlined),
              ),
            ],
          ),
          (previouslySelectedMedicines.length == 2 &&
                  previouslySelectedMedicines.last.isNotEmpty)
              ? FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    '(or: ${previouslySelectedMedicines.last})',
                    style: TextStyle(
                      color: Color.fromRGBO(70, 70, 70, 1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}

class SearchableDropDownWidget extends ConsumerStatefulWidget {
  final int index;
  final List<String> medicineList;
  final List<MedicineModel> medicines;
  final Function callback;
  final String initialValue;
  final bool isAlternate;
  const SearchableDropDownWidget({
    Key? key,
    required this.medicineList,
    required this.index,
    required this.medicines,
    required this.callback,
    required this.initialValue,
    this.isAlternate = false,
  }) : super(key: key);

  @override
  ConsumerState<SearchableDropDownWidget> createState() =>
      _SearchableDropDownWidgetState();
}

class _SearchableDropDownWidgetState
    extends ConsumerState<SearchableDropDownWidget> {
  List<String> getSearchItems() {
    List<String> items = [];
    for (String medicine in widget.medicineList) items.add(medicine);
    items.remove(ConstantsForPrescriptionScreen.unSelectedTag);
    List<String> customMedicineDetails =
        ref.watch(customMedicinesProvider).toList();
    List<String> customMedicineNames = [];
    for (String customMedicine in customMedicineDetails) {
      customMedicineNames.add(customMedicine
          .split(ConstantsForPrescriptionScreen.alternateMedicineDelimiter)
          .first);
    }
    return [...items, ...customMedicineNames];
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      dropdownDecoratorProps: DropDownDecoratorProps(
        textAlign: TextAlign.center,
        dropdownSearchDecoration: InputDecoration(
          border: InputBorder.none,
        ),
      ),
      selectedItem: widget.initialValue,
      filterFn: (availableMedicine, filter) {
        return (availableMedicine
            .toLowerCase()
            .startsWith(filter.toLowerCase()));
      },
      popupProps: PopupProps.menu(
        showSearchBox: true,
        menuProps: MenuProps(
          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
          barrierColor: Color.fromRGBO(0, 0, 0, 0.094),
        ),
        searchFieldProps: TextFieldProps(
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: 'Search Medicine',
          ),
          autofocus: true,
        ),
      ),
      items: getSearchItems(),
      onChanged: (String? value) {
        try {
          print('1');
          if (widget.isAlternate && value == 'None') {
            print('2');
            ref.read(medicineDetailsListProvider.notifier).update((state) {
              print(' this is the current state ${state[widget.index].name}');
              state[widget.index].name =
                  '${state[widget.index].name.split(ConstantsForPrescriptionScreen.alternateMedicineDelimiter).first}${ConstantsForPrescriptionScreen.alternateMedicineDelimiter}';
              return state;
            });
            return;
          }
          if (value != null) {
            print('3');
            ref.read(medicineDetailsListProvider.notifier).update((state) {
              if (widget.isAlternate) {
                print('4');
                String firstMedicine = state[widget.index].name;
                List<String> temp = firstMedicine.split(
                    ConstantsForPrescriptionScreen.alternateMedicineDelimiter);
                if (temp.last.isEmpty) {
                  state[widget.index].name = '$firstMedicine$value';
                } else {
                  state[widget.index].name =
                      '${temp.first}${ConstantsForPrescriptionScreen.alternateMedicineDelimiter}$value';
                }
              } else {
                print('5');
                state[widget.index].name =
                    '$value${ConstantsForPrescriptionScreen.alternateMedicineDelimiter}';
              }

              print('6');

              bool isCustomMedicine = true;

              widget.medicines.forEach((element) {
                if (element.name == value) {
                  print('7');
                  state[widget.index].type =
                      element.type.substring(0, 3).toUpperCase();
                  if (element.dose != null) {
                    state[widget.index].dose = element.dose!;
                  }
                  if (element.when != null) {
                    state[widget.index].when = element.when!;
                  }
                  if (element.duration != null) {
                    state[widget.index].duration =
                        ref.read(medicineDetailsListProvider).last.duration;
                  }
                  try {
                    // dosageKey.currentState!
                    //     .prefillFunctionOnSelectMedicine(element.dose);
                    // whenKey.currentState!
                    //     .prefillFunctionOnSelectMedicine(element.when);
                    // durationKey.currentState!
                    //     .prefillFunctionOnSelectMedicine(element.duration);
                  } catch (e) {
                    print('error in prefilling');
                  }
                  isCustomMedicine = false;
                }
                if (element.name == value) {
                  print('8');
                  state[widget.index].saltComposition = element.saltComposition;
                }
              });

              if (isCustomMedicine) {
                print('9');
                List<String> customMeds = ref.read(customMedicinesProvider);
                for (String customMed in customMeds) {
                  if (customMed
                          .split(ConstantsForPrescriptionScreen
                              .alternateMedicineDelimiter)
                          .first ==
                      value) {
                    state[widget.index].type = customMed
                        .split(ConstantsForPrescriptionScreen
                            .alternateMedicineDelimiter)[1]
                        .substring(0, 3)
                        .toUpperCase();
                  }
                  if (customMed
                          .split(ConstantsForPrescriptionScreen
                              .alternateMedicineDelimiter)
                          .first ==
                      value) {
                    state[widget.index].saltComposition = customMed.split(
                        ConstantsForPrescriptionScreen
                            .alternateMedicineDelimiter)[2];
                  }
                }
              }
              return state;
            });
          }
          widget.callback();
        } catch (e, s) {
          print('caught an error in searchabledropdown');
          print(e.toString());
          print(s.toString());
        }
      },
    );
  }
}
