import 'package:flutter_test/flutter_test.dart';
import 'package:rosstabak_manager/constants/app_shifts.dart';
import 'package:rosstabak_manager/core/password_hash.dart';

void main() {
  group('AppShifts Tests', () {
    test('should have correct shift type values', () {
      expect(AppShifts.day, 'DAY');
      expect(AppShifts.night, 'NIGHT');
    });
  });

  group('PasswordHasher Tests', () {
    test('should hash password consistently', () {
      final password = 'test_password_123';
      final hash1 = PasswordHasher.hash(password);
      final hash2 = PasswordHasher.hash(password);

      expect(hash1, hash2);
    });

    test('should produce different hashes for different passwords', () {
      final hash1 = PasswordHasher.hash('password1');
      final hash2 = PasswordHasher.hash('password2');

      expect(hash1, isNot(hash2));
    });

    test('should verify correct password', () {
      final password = 'my_secret_password';
      final hash = PasswordHasher.hash(password);

      expect(PasswordHasher.verify(password, hash), true);
    });

    test('should reject wrong password', () {
      final password = 'correct_password';
      final wrongPassword = 'wrong_password';
      final hash = PasswordHasher.hash(password);

      expect(PasswordHasher.verify(wrongPassword, hash), false);
    });

    test('hash should not equal plain password', () {
      final password = 'simple_pass';
      final hash = PasswordHasher.hash(password);

      expect(hash, isNot(password));
      expect(hash.length, greaterThan(password.length));
    });
  });
}
