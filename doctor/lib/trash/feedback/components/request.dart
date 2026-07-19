import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../components/urls.dart';

Future<String> submitFeedback(int patId, int rating, String comment) async {
  final response = await http.post(
    Uri.parse(writeFeedbackUrl),
    headers: header,
    body: jsonEncode(<String, dynamic>{
      "user_id": patId,
      "rating": rating,
      "comment": comment
    }),
  );
  if (response.statusCode == 200) {
    return "Success";
  } else {
    return "Some error occurred in submitting Feedback";
  }
}
