class MedicineDetailsModel {
  String name;
  String when;
  String duration;
  String dose;
  String type;
  String saltComposition;

  MedicineDetailsModel({
    required this.type,
    required this.name,
    required this.when,
    required this.duration,
    required this.dose,
    required this.saltComposition,
  });

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "name": name,
      "when": when,
      "duration": duration,
      "dose": dose,
      "composition": saltComposition,
    };
  }

  factory MedicineDetailsModel.fromJson(Map<String, dynamic> json) {
    return MedicineDetailsModel(
      type: json["type"],
      name: json["name"],
      when: json["when"],
      duration: json["duration"],
      dose: json["dose"],
      saltComposition: json["composition"] ?? '',
    );
  }
}
