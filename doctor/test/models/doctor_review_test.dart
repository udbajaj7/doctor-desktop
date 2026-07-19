import 'dart:convert';

import 'package:doctor/Models/DoctorReview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DoctorReview survives a fromJson/toJson round trip', () {
    final original = <String, dynamic>{
      'doc_id': 3,
      'pat_id': 91,
      'id': 1001,
      'anonymous': true,
      'posted_at': '2024-05-01',
      'rating': 4,
      'review': 'Very thorough consultation.',
    };

    final review = DoctorReview.fromJson(original);
    expect(review.docId, 3);
    expect(review.patId, 91);
    expect(review.rating, 4);
    expect(review.anonymous, isTrue);

    final roundTripped =
        jsonDecode(review.toJson() as String) as Map<String, dynamic>;
    expect(roundTripped, equals(original));
  });
}
