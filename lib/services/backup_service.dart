import 'dart:io';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

class BackupService {
  static final BackupService instance = BackupService._();
  BackupService._();

  Future<String> get _backupDir async {
    final dbPath = await getDatabasesPath();
    final backupDir = Directory('$dbPath/backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir.path;
  }

  Future<String> createBackup() async {
    final dbPath = await getDatabasesPath();
    final dbName = 'rosstabak.db';
    final source = '$dbPath/$dbName';

    final backupDir = await _backupDir;
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final destination = '$backupDir/rosstabak_backup_$timestamp.db';

    final sourceFile = File(source);
    if (!await sourceFile.exists()) {
      throw Exception('База данных не найдена');
    }

    await sourceFile.copy(destination);
    return destination;
  }

  Future<String> restoreFromFile(String filePath) async {
    final dbPath = await getDatabasesPath();
    final dbName = 'rosstabak.db';
    final destination = '$dbPath/$dbName';

    final source = File(filePath);
    if (!await source.exists()) {
      throw Exception('Файл резервной копии не найден');
    }

    // Close database connection — database is always re-opened on next access
    await DatabaseHelper.instance.close();

    await source.copy(destination);
    return destination;
  }

  Future<List<String>> listBackups() async {
    final dir = await _backupDir;
    final backupDir = Directory(dir);
    if (!await backupDir.exists()) return [];

    final files = await backupDir
        .list()
        .where((entity) {
          return entity is File && entity.path.endsWith('.db');
        })
        .map((e) => e.path)
        .toList();

    files.sort((a, b) => b.compareTo(a));
    return files;
  }
}
