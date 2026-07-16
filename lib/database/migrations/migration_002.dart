import 'package:sqflite/sqflite.dart';

abstract class MigrationBase2 {
  int get version;
  Future<void> execute(Database db);
}

class Migration002 implements MigrationBase2 {
  @override
  int get version => 2;

  @override
  Future<void> execute(Database db) async {
    // Placeholder for future migration (reports, analytics, etc.)
  }
}
