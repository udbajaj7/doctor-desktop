import 'package:doctor/components/urls.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('API endpoint configuration', () {
    test('base URL is HTTPS and slash-terminated', () {
      expect(siteUrl, startsWith('https://'));
      expect(siteUrl, endsWith('/'));
    });

    test('endpoints are composed from the configured base URL', () {
      expect(signInUrl, '${siteUrl}login/');
      expect(phoneRegUrl, '${siteUrl}send_otp/');
      expect(docUrl, '${siteUrl}doctor/');
      expect(getAllPatientsUrl, '${docUrl}getAllPatients/');
      expect(savePrescrption, '${docUrl}savePrescription/');
    });

    test('a positive request timeout is configured', () {
      expect(kRequestTimeout, greaterThan(Duration.zero));
    });
  });
}
