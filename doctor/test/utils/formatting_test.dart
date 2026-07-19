import 'package:doctor/components/urls.dart';
import 'package:doctor/screens/loginScreen/components/requests.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('date/time formatting for the API', () {
    test('dateToString zero-pads day and month as dd-MM-yyyy', () {
      expect(dateToString(DateTime(2024, 3, 7)), '07-03-2024');
      expect(dateToString(DateTime(2024, 12, 25)), '25-12-2024');
    });

    test('timeToString zero-pads to HHmm', () {
      expect(timeToString(const TimeOfDay(hour: 9, minute: 5)), '0905');
      expect(timeToString(const TimeOfDay(hour: 18, minute: 30)), '1830');
    });
  });

  group('clinic slot parsing', () {
    test('computeSlot parses a padded HHmm string', () {
      final slot = computeSlot('0930');
      expect(slot.hour, 9);
      expect(slot.minute, 30);
    });

    test('computeSlot tolerates unpadded and comma-suffixed values', () {
      final slot = computeSlot('930,');
      expect(slot.hour, 9);
      expect(slot.minute, 30);
    });

    test('computeSlot and convertToString are inverses', () {
      const original = TimeOfDay(hour: 14, minute: 5);
      final encoded = convertToString(original);
      expect(encoded, '1405');
      final decoded = computeSlot(encoded);
      expect(decoded, original);
    });
  });
}
