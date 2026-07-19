class ReachedListModel {
  int age;
  String fName, gender, slotNumber, treatment, phoneNumber, lastName, notes;
  int prevPatientBookingID;
  int balance;
  bool consentOrNot;
  int installment;
  bool? fileAvailable;

  ReachedListModel({
    required this.notes,
    required this.age,
    required this.fName,
    required this.lastName,
    required this.phoneNumber,
    required this.gender,
    required this.slotNumber,
    required this.prevPatientBookingID,
    required this.treatment,
    required this.balance,
    required this.consentOrNot,
    required this.installment,
    required this.fileAvailable,
  });

  @override
  String toString() {
    return "$age $fName $gender $slotNumber $prevPatientBookingID";
  }
}
