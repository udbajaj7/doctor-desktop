import 'package:doctor/Models/DoctorModel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DoctorModel.fromJson', () {
    final json = <String, dynamic>{
      'id': 42,
      'category': 'Dentist',
      'first_name': 'Asha',
      'last_name': 'Rao',
      'gender': 'female',
      'age': 39,
      'phone_number': '9990001111',
      'email': 'asha@example.com',
      'registration_number': 'REG-123',
      'specialization': 'Orthodontics',
      'degrees': 'BDS, MDS',
      'appointment_fees': 500,
      'clinic_name': 'Smile Clinic',
      'clinic_address': '12 MG Road',
      'city': 'Pune',
      'avg_time': 15,
      'timing': <dynamic>[],
      'contact_number': '02012345678',
      'pat_per_slot': 2,
    };

    test('maps every field from the API payload', () {
      final doctor = DoctorModel.fromJson(json);

      expect(doctor.id, 42);
      expect(doctor.category, 'Dentist');
      expect(doctor.firstName, 'Asha');
      expect(doctor.lastName, 'Rao');
      expect(doctor.gender, 'female');
      expect(doctor.age, 39);
      expect(doctor.phoneNumber, '9990001111');
      expect(doctor.email, 'asha@example.com');
      expect(doctor.registrationNumber, 'REG-123');
      expect(doctor.specialization, 'Orthodontics');
      expect(doctor.degrees, 'BDS, MDS');
      expect(doctor.appointmentFees, 500);
      expect(doctor.clinicName, 'Smile Clinic');
      expect(doctor.clinicAddress, '12 MG Road');
      expect(doctor.city, 'Pune');
      expect(doctor.avgTime, 15);
      expect(doctor.contactNumber, '02012345678');
      expect(doctor.patPerSlot, 2);
    });

    test('copyWith produces an independent, equal-valued instance', () {
      final doctor = DoctorModel.fromJson(json);
      final copy = DoctorModel.copyWith(doctor);

      expect(identical(copy, doctor), isFalse);
      expect(copy.id, doctor.id);
      expect(copy.email, doctor.email);
      expect(copy.appointmentFees, doctor.appointmentFees);
      expect(copy.city, doctor.city);
    });
  });
}
