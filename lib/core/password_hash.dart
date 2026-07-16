import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  static const _salt = 'rosstabak-manager-salt-v1';

  static String hash(String password) {
    final bytes = utf8.encode('$_salt:$password');
    final digest = sha256.convert(bytes);
    return 'sha256:${digest.toString()}';
  }

  static bool verify(String plaintext, String stored) {
    if (stored.startsWith('sha256:')) {
      return hash(plaintext) == stored;
    }
    return plaintext == stored;
  }

  static bool isHashed(String stored) {
    return stored.startsWith('sha256:');
  }
}
