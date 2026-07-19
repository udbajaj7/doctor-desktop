class VitalsModel {
  String pulse;
  String bp;
  String weight;
  String height;
  String temperature;
  String spo2;

  VitalsModel({
    required this.pulse,
    required this.bp,
    required this.weight,
    required this.height,
    required this.temperature,
    required this.spo2,
  });

  factory VitalsModel.fromJson(Map<String, dynamic> json) {
    return VitalsModel(
      pulse: (json['pulse'] ?? '').toString(),
      bp: (json['bloodPressure'] ?? '').toString(),
      weight: (json['weight'] ?? '').toString(),
      height: (json['height'] ?? '').toString(),
      temperature: (json['temperature'] ?? '').toString(),
      spo2: (json['spo2'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pulse': pulse,
      'bp': bp,
      'weight': weight,
      'height': height,
      'temperature': temperature,
      'spo2': spo2,
    };
  }
}
