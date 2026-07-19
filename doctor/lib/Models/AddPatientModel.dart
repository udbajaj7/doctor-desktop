class AddPatientModel {
  String firstName;
  String lastName;
  int? age;
  String phoneNo;
  String treatment;
  String gender;
  String address;

  bool getEarly;
  AddPatientModel(this.firstName, this.lastName, this.age, this.phoneNo,
      this.treatment, this.gender, this.getEarly, this.address);
}
