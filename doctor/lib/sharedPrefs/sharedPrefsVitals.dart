import 'package:doctor/Models/VitalsObject.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefVitals {
  Future<VitalsObject> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    VitalsObject vitalsObject = VitalsObject.decode(prefs.getString(key) ?? "");
    return vitalsObject;
  }

  void save(String key, VitalsObject vitalsObject) async {
    String endcodedData = VitalsObject.encode(vitalsObject);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, endcodedData);
  }
}
