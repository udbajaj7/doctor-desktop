class ConstantsForPrescriptionScreen {
  static const String unSelectedTag = '--Select--';
  static const String emptyInputTag = '';
  static const double cellHeight = 70.0;
  static const String saltCompositionValue = ' ';

  static const String alternateMedicineDelimiter = '|';

  //first value in the lists are the default values.
  static const List<String> dosageList = <String>[
    '1-0-1',
    '1-0-0',
    '0-1-0',
    '0-0-1',
    '1-1-0',
    '0-1-1',
    '1-1-1',
    'SOS',
    '2-0-2',
    '2-2-2',
    '1-1-1-1',
    '1-1-1-1-1',
    'Other'
  ];
  static const List<String> whenList = <String>[
    'After Food',
    'Empty Stomach',
    'Before Food',
    'Before Breakfast',
    'After Breakfast',
    'Before Lunch',
    'After Lunch',
    'Before Dinner',
    'After Dinner',
    'Bed Time',
    'Other'
  ];

  static const List<String> frequencyList = <String>[
    'Daily',
    'Weekly',
    'Monthly',
    'NA',
  ];

  static const List<String> durationList = <String>[
    '5 Days',
    '1 Day',
    '2 Days',
    '3 Days',
    '1 Week',
    '10 Days',
    '2 Weeks',
    '1 Month',
    '2 Months',
    'NA',
  ];

  static const List<String> medicineTypeList = [
    'Tablet',
    'Capsule',
    'Syrup',
    'Nasal Spray',
    'Cream',
    'Inhaler',
    'Injection',
    'Gel',
    'Oral Suspension',
    'Oral Drop',
    'Oral Solution',
  ];
}
