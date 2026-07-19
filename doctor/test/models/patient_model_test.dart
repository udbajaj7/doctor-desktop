import 'dart:convert';

import 'package:doctor/Models/PatientModel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PatientModel.fromJson', () {
    test('parses a complete payload', () {
      final patient = PatientModel.fromJson(<String, dynamic>{
        'id': 7,
        'first_name': 'Ravi',
        'last_name': 'Kumar',
        'phone_number': '9876543210',
        'email': 'ravi@example.com',
        'age': 28,
        'gender': 'male',
        'city': 'Delhi',
        'address': '5 Ring Road',
      });

      expect(patient.id, 7);
      expect(patient.firstName, 'Ravi');
      expect(patient.lastName, 'Kumar');
      expect(patient.address, '5 Ring Road');
    });

    test('defaults nullable last_name and address to empty strings', () {
      final patient = PatientModel.fromJson(<String, dynamic>{
        'id': 8,
        'first_name': 'Sana',
        'last_name': null,
        'phone_number': '9000000000',
        'email': 'sana@example.com',
        'age': 31,
        'gender': 'female',
        'city': 'Mumbai',
        'address': null,
      });

      expect(patient.lastName, '');
      expect(patient.address, '');
    });
  });

  group('PatientModel.toJson', () {
    test('serialises the API-facing fields', () {
      final patient = PatientModel(
        id: 7,
        email: 'ravi@example.com',
        gender: 'male',
        firstName: 'Ravi',
        lastName: 'Kumar',
        city: 'Delhi',
        age: 28,
        phoneNumber: '9876543210',
        address: '5 Ring Road',
      );

      final decoded = jsonDecode(patient.toJson() as String) as Map<String, dynamic>;

      expect(decoded['first_name'], 'Ravi');
      expect(decoded['phone_number'], '9876543210');
      expect(decoded['age'], 28);
      // `toJson` (create flow) intentionally omits the id.
      expect(decoded.containsKey('id'), isFalse);
    });

    test('toJson2 includes the id for update flows', () {
      final patient = PatientModel(
        id: 7,
        email: 'ravi@example.com',
        gender: 'male',
        firstName: 'Ravi',
        lastName: 'Kumar',
        city: 'Delhi',
        age: 28,
        phoneNumber: '9876543210',
        address: '5 Ring Road',
      );

      final decoded =
          jsonDecode(patient.toJson2() as String) as Map<String, dynamic>;

      expect(decoded['id'], 7);
    });
  });
}
