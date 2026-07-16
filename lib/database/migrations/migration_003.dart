import 'package:sqflite/sqflite.dart';

abstract class MigrationBase3 {
  int get version;
  Future<void> execute(Database db);
}

class Migration003 implements MigrationBase3 {
  @override
  int get version => 3;

  @override
  Future<void> execute(Database db) async {
    // Placeholder for notifications migration
  }
}
