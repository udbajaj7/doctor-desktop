import 'dart:convert';

import 'package:doctor/components/urls.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('initializeHeader (authentication)', () {
    test('builds a HTTP Basic authorization header from stored credentials',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'phoneNumber': '9990001111',
        'password': 's3cr3t!',
      });
      prefs = await SharedPreferences.getInstance();

      initializeHeader();

      final expected =
          'Basic ' + base64.encode(utf8.encode('9990001111:s3cr3t!'));
      expect(header['authorization'], expected);
      expect(header['Content-Type'], 'application/json; charset=UTF-8');
    });

    test('never stores the raw password in the header value', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'phoneNumber': '9990001111',
        'password': 'plaintextpw',
      });
      prefs = await SharedPreferences.getInstance();

      initializeHeader();

      expect(header['authorization'], startsWith('Basic '));
      expect(header['authorization'], isNot(contains('plaintextpw')));
    });
  });
}
