import 'package:http/http.dart' as http;
import 'package:intl_phone_field/phone_number.dart';
import 'dart:convert';

import '../../../components/urls.dart';

const Map<String, String> _jsonHeaders = <String, String>{
  'Accept': '*/*',
  'Content-Type': 'application/json',
};

Future<String> funcSendPhoneNumber(PhoneNumber phoneNo, String password) async {
  try {
    var response = await http
        .post(Uri.parse(phoneRegUrl),
            body: jsonEncode(<String, String>{
              "phone_number": phoneNo.number.toString(),
              "password": password,
              "user_type": "doctor"
            }),
            headers: _jsonHeaders)
        .timeout(kRequestTimeout);
    if (response.statusCode == 200) {
      return "Success";
    } else {
      var responseJson = json.decode(response.body.toString());
      return "Error: " + responseJson["message"];
    }
  } catch (e) {
    return "Error: Unable to send OTP. Please check your connection and try again.";
  }
}

Future<String> funcSendPhoneNumberForPwdChange(PhoneNumber phoneNo) async {
  try {
    var response = await http
        .post(Uri.parse(forgetPassOtpUrl),
            body: jsonEncode(<String, String>{"phone_number": phoneNo.number}),
            headers: _jsonHeaders)
        .timeout(kRequestTimeout);
    if (response.statusCode == 200) {
      return "Success";
    } else {
      var responseJson = json.decode(response.body.toString());
      return "Error: " + responseJson["message"];
    }
  } catch (e) {
    return "Error: Unable to send OTP. Please check your connection and try again.";
  }
}

Future<String> sendOtpForVerification(String otp, String phoneNo) async {
  try {
    var response = await http
        .post(Uri.parse(otpVerificationUrl),
            body: jsonEncode(<String, String>{
              "phone_number": phoneNo,
              "otp": otp,
            }),
            headers: _jsonHeaders)
        .timeout(kRequestTimeout);
    var jsonResponse = json.decode(response.body.toString());
    if (jsonResponse["status"] == 200) {
      return "Success";
    } else {
      return "Error: " + jsonResponse["message"];
    }
  } catch (e) {
    return "Error: Unable to verify OTP. Please check your connection and try again.";
  }
}
