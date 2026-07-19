import 'dart:math';

import 'package:doctor/Models/MedicineDetailsModel.dart';
import 'package:doctor/Models/PrescriptionModel.dart';
import 'package:doctor/components/size_config.dart';
import 'package:doctor/screens/prescriptionScreen/components/constants.dart';
import 'package:doctor/screens/prescriptionScreen/components/providers.dart';
import 'package:doctor/screens/prescriptionScreen/components/requests.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:flutter/material.dart';

class CustomTagsWidget extends ConsumerWidget {
  final List<String> initialDiagnosticTags, initialSymptomsTags;
  final List<String> diagnosisTags, symptomsTags;
  const CustomTagsWidget({
    Key? key,
    required this.initialDiagnosticTags,
    required this.initialSymptomsTags,
    required this.symptomsTags,
    required this.diagnosisTags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IntrinsicHeight(
      child: Padding(
        padding: EdgeInsets.only(left: getProportionateWebScreenWidth(32)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FocusTraversalOrder(
                  order: NumericFocusOrder(0),
                  child: SimpleCustomTextFieldWidget(
                    title: 'Clinical History',
                    textEditingController: clinicalHistoryController,
                  ),
                ),
                SizedBox(
                  height: getProportionateWebScreenHeight(20),
                ),
                FocusTraversalOrder(
                  order: NumericFocusOrder(2),
                  child: SimpleCustomTextFieldWidget(
                    title: 'Notes',
                    textEditingController: notesController,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: getProportionateWebScreenWidth(30),
            ),
            VerticalDivider(
              color: Color(0xFFDCDCDC),
              thickness: 2,
              indent: getProportionateWebScreenWidth(40),
            ),
            SizedBox(
              width: getProportionateWebScreenWidth(30),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FocusTraversalOrder(
                  order: NumericFocusOrder(1),
                  child: CustomTaggedTextFieldWidget(
                    title: 'Symptoms',
                    hintText: 'No Symptoms',
                    textfieldTagsController: symptomsTextfieldTagsControler,
                    searchTags: symptomsTags,
                    initialTags: initialSymptomsTags,
                  ),
                ),
                SizedBox(
                  height: getProportionateWebScreenHeight(20),
                ),
                FocusTraversalOrder(
                  order: NumericFocusOrder(3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomTaggedTextFieldWidget(
                        title: 'Diagnosis',
                        hintText: 'No Diagnosis',
                        textfieldTagsController:
                            diagnosisTextfieldTagsControler,
                        searchTags: diagnosisTags,
                        initialTags: initialDiagnosticTags,
                      ),
                      SizedBox(
                        width: getProportionateWebScreenWidth(16),
                      ),
                      AutoFillButtonWidget()
                    ],
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

class AutoFillButtonWidget extends ConsumerWidget {
  const AutoFillButtonWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        if ((diagnosisTextfieldTagsControler.getTags ?? []).isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No Diagnosis Found',
                style: GoogleFonts.varelaRound(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Colors.black,
            ),
          );
          return;
        }
        PrescriptionModel prescriptionModel =
            await getSavedPrecTemplateByDiagnosis(
          diagnosis: diagnosisTextfieldTagsControler.getTags ?? [],
        );

        if (prescriptionModel.bookingId == -1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No Prescription Template Found',
                style: GoogleFonts.varelaRound(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        testsTextfieldTagsControler.clearTags();

        for (String tests in prescriptionModel.tests) {
          testsTextfieldTagsControler.addTag = tests;
        }

        ref.read(medicineDetailsListProvider.notifier).update((state) {
          ref
              .read(rebuildMedicineTableProvider.notifier)
              .update((state) => Random().nextInt(1000));

          ref
              .read(nextVisitProvider.notifier)
              .update((state) => prescriptionModel.nextVisit ?? '');

          if (prescriptionModel.medicines.isEmpty) {
            MedicineDetailsModel firstElement = MedicineDetailsModel(
              type: '',
              name: ConstantsForPrescriptionScreen.unSelectedTag,
              when: ConstantsForPrescriptionScreen.whenList.first,
              duration: ConstantsForPrescriptionScreen.durationList.first,
              dose: ConstantsForPrescriptionScreen.dosageList.first,
              saltComposition:
                  ConstantsForPrescriptionScreen.saltCompositionValue,
            );
            return [firstElement];
          }

          return prescriptionModel.medicines;
        });
      },
      child: Padding(
        padding: EdgeInsets.only(top: getProportionateWebScreenHeight(15)),
        child: Icon(
          Icons.auto_fix_high,
          color: Colors.black,
          size: 30,
        ),
      ),
    );
  }
}

class CustomTaggedTextFieldWidget extends ConsumerStatefulWidget {
  final String title, hintText;
  final List<String> searchTags;
  final List<String> initialTags;
  final TextfieldTagsController textfieldTagsController;
  const CustomTaggedTextFieldWidget({
    Key? key,
    required this.hintText,
    required this.title,
    required this.textfieldTagsController,
    required this.searchTags,
    required this.initialTags,
  }) : super(key: key);

  @override
  ConsumerState<CustomTaggedTextFieldWidget> createState() =>
      _CustomTextFieldState();
}

class _CustomTextFieldState extends ConsumerState<CustomTaggedTextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getProportionateScreenWidth(440),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateWebScreenWidth(12)),
            child: Text(
              widget.title,
              style: GoogleFonts.publicSans(
                color: Color(0xFF909090),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            height: getProportionateWebScreenHeight(9),
          ),
          Container(
            width: getProportionateWebScreenWidth(435),
            height: getProportionateWebScreenHeight(65),
            padding: EdgeInsets.only(left: getProportionateWebScreenWidth(21)),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2)),
              shadows: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 20,
                  offset: Offset(0, 2),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Center(
              child: TaggedTextField(
                hintText: widget.hintText,
                searchOptions: widget.searchTags,
                textfieldTagsController: widget.textfieldTagsController,
                initialTags: widget.initialTags,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaggedTextField extends ConsumerStatefulWidget {
  final String hintText;
  final List<String> searchOptions;
  final List<String> initialTags;
  final TextfieldTagsController textfieldTagsController;

  const TaggedTextField({
    Key? key,
    required this.hintText,
    required this.initialTags,
    required this.searchOptions,
    required this.textfieldTagsController,
  }) : super(key: key);

  @override
  ConsumerState<TaggedTextField> createState() => _TaggedTextFieldState();
}

class _TaggedTextFieldState extends ConsumerState<TaggedTextField> {
  String capitalizeFirstLetter(String s) {
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsMaxHeight: getProportionateWebScreenHeight(50),
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Container(
            width: getProportionateWebScreenWidth(350),
            color: Colors.white,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final String option = options.elementAt(index);
                return Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: getProportionateWebScreenWidth(320),
                    child: Material(
                      child: InkWell(
                        onTap: () {
                          onSelected(option);
                        },
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: getProportionateWebScreenHeight(15),
                            horizontal: getProportionateWebScreenWidth(12),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${capitalizeFirstLetter(option)}',
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        List<String> x = widget.searchOptions.where((String option) {
          return option.startsWith(textEditingValue.text.toLowerCase());
        }).toList();
        List<String> y = widget.searchOptions.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
        }).toList();
        y.removeWhere((element) => x.contains(element));
        x.addAll(y);
        return x;
      },
      onSelected: (String selectedTag) {
        widget.textfieldTagsController.addTag = selectedTag;
        ref.read(isPrescriptionSavedProvider.notifier).update((state) => false);
        print('Selected Tag: $selectedTag');
      },
      fieldViewBuilder: (context, ttec, tfn, onFieldSubmitted) {
        return TextFieldTags(
          initialTags: widget.initialTags,
          textEditingController: ttec,
          focusNode: tfn,
          textfieldTagsController: widget.textfieldTagsController,
          textSeparators: const [','],
          letterCase: LetterCase.normal,
          validator: (String tag) {
            if (widget.textfieldTagsController.getTags!.contains(tag)) {
              return 'you already entered that';
            }
            return null;
          },
          inputfieldBuilder: (context, tec, fn, error, onChanged, onSubmitted) {
            return ((context, sc, tags, onTagDelete) {
              return RawKeyboardListener(
                onKey: (RawKeyEvent event) {
                  if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                    print('Enter Detected');
                  }
                  if (event.isKeyPressed(LogicalKeyboardKey.backspace)) {
                    if (ttec.text.isEmpty && tags.isNotEmpty) {
                      onTagDelete(tags.last);
                    }
                  }
                },
                focusNode: fn,
                child: TextField(
                  controller: tec,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: widget.textfieldTagsController.hasTags
                        ? ''
                        : widget.hintText,
                    errorText: error,
                    prefixIcon: tags.isNotEmpty
                        ? SizedBox(
                            width: (tags.length > 3)
                                ? getProportionateScreenHeight(245)
                                : getProportionateWebScreenWidth(tags.length *
                                    getProportionateScreenWidth(80)),
                            child: SingleChildScrollView(
                              controller: sc,
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                  children: tags.map((String tag) {
                                return Container(
                                  height: getProportionateWebScreenHeight(33),
                                  color: Color(0xFFDEDEDE),
                                  margin: const EdgeInsets.only(right: 10.0),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        child: Text(
                                          '${capitalizeFirstLetter(tag)}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        onTap: () {
                                          if (sc.hasClients) {
                                            print('has Clients');
                                            sc.animateTo(
                                              0,
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              curve: Curves.easeInOut,
                                            );
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 4.0),
                                      InkWell(
                                        child: const Icon(
                                          Icons.cancel,
                                          size: 14.0,
                                        ),
                                        onTap: () {
                                          onTagDelete(tag);
                                        },
                                      )
                                    ],
                                  ),
                                );
                              }).toList()),
                            ),
                          )
                        : null,
                  ),
                  onChanged: (_) {
                    onChanged!(tec.text);
                    ref
                        .read(isPrescriptionSavedProvider.notifier)
                        .update((state) => false);
                  },
                  onSubmitted: onSubmitted,
                ),
              );
            });
          },
        );
      },
    );
  }
}

class TestsAndNextVisitRow extends StatelessWidget {
  final List<String> initialTestTags;
  final List<String> testsTags;
  const TestsAndNextVisitRow(
      {Key? key, required this.testsTags, required this.initialTestTags})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomTaggedTextFieldWidget(
            title: 'Tests',
            hintText: 'No Tests Prescribed',
            textfieldTagsController: testsTextfieldTagsControler,
            searchTags: testsTags,
            initialTags: initialTestTags,
          ),
          SizedBox(
            width: getProportionateWebScreenWidth(50),
          ),
          VerticalDivider(
            color: Color(0xFFDCDCDC),
            thickness: 2,
            indent: getProportionateWebScreenWidth(20),
          ),
          SizedBox(
            width: getProportionateWebScreenWidth(50),
          ),
          const NextVisitWidget(),
        ],
      ),
    );
  }
}

class NextVisitWidget extends ConsumerStatefulWidget {
  const NextVisitWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<NextVisitWidget> createState() => _NextVisitWidgetState();
}

class _NextVisitWidgetState extends ConsumerState<NextVisitWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: getProportionateWebScreenWidth(12)),
          child: Text(
            'Next Visit',
            style: GoogleFonts.publicSans(
              color: Color(0xFF909090),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(
          height: getProportionateWebScreenHeight(9),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(Duration(days: 0)),
                  lastDate: DateTime(2050),
                );
                if (date != null) {
                  String day =
                      (date.day ~/ 10 == 0) ? '0${date.day}' : '${date.day}';
                  String month = (date.month ~/ 10 == 0)
                      ? '0${date.month}'
                      : '${date.month}';
                  ref.read(nextVisitProvider.notifier).state =
                      '$day-$month-${date.year}';
                }
              },
              child: Container(
                width: getProportionateWebScreenWidth(349),
                height: getProportionateWebScreenHeight(65),
                padding:
                    EdgeInsets.only(left: getProportionateWebScreenWidth(21)),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2)),
                  shadows: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 20,
                      offset: Offset(0, 2),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset('assets/icons/calendar.png'),
                      VerticalDivider(
                        color: Color(0xFFDCDCDC),
                        thickness: 1,
                        indent: getProportionateWebScreenWidth(12),
                        endIndent: getProportionateWebScreenWidth(12),
                      ),
                      Text(
                        ref.watch(nextVisitProvider),
                        style: GoogleFonts.publicSans(
                          color: Color(0xFF212121),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: getProportionateWebScreenWidth(8),
            ),
            GestureDetector(
              child: Icon(
                Icons.cancel,
                color: Colors.grey,
                size: 20,
              ),
              onTap: () => ref.read(nextVisitProvider.notifier).state = '',
            )
          ],
        ),
      ],
    );
  }
}

class SimpleCustomTextFieldWidget extends StatelessWidget {
  final String title;
  final TextEditingController textEditingController;
  const SimpleCustomTextFieldWidget({
    Key? key,
    required this.title,
    required this.textEditingController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: getProportionateScreenWidth(350),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateWebScreenWidth(12)),
            child: Text(
              title,
              style: GoogleFonts.publicSans(
                color: Color(0xFF909090),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            height: getProportionateWebScreenHeight(9),
          ),
          Container(
            width: getProportionateWebScreenWidth(340),
            height: getProportionateWebScreenHeight(65),
            padding: EdgeInsets.only(left: getProportionateWebScreenWidth(21)),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2)),
              shadows: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 20,
                  offset: Offset(0, 2),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Center(
              child: TextField(
                controller: textEditingController,
                maxLines: 5,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
