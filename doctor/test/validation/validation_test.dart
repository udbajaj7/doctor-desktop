import 'package:doctor/components/constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('email validation', () {
    test('accepts well-formed addresses', () {
      expect(emailValidatorRegExp.hasMatch('asha@example.com'), isTrue);
      expect(emailValidatorRegExp.hasMatch('r.k.dev@clinic.in'), isTrue);
    });

    test('rejects malformed addresses', () {
      expect(emailValidatorRegExp.hasMatch('not-an-email'), isFalse);
      expect(emailValidatorRegExp.hasMatch('missing@domain'), isFalse);
      expect(emailValidatorRegExp.hasMatch('@example.com'), isFalse);
    });
  });
}
