import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> setupTestDatabase() async {
  databaseFactory = databaseFactoryFfi;
}
