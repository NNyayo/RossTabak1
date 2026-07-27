import 'dart:io';
import 'package:flutter/foundation.dart';

/// Centralized application paths.
/// All user-writable data goes to %APPDATA%/RossTabak on Windows,
/// ~/.local/share/RossTabak on Linux, ~/Library/Application Support on macOS.
class AppPaths {
  AppPaths._();

  /// Root directory for all application data (database, logs, config, backups).
  static String get _appDataRoot {
    if (Platform.isWindows) {
      final appData =
          Platform.environment['APPDATA'] ??
          Platform.environment['LOCALAPPDATA'] ??
          '${Platform.environment['USERPROFILE']}\\AppData\\Roaming';
      return '$appData\\RossTabak';
    } else if (Platform.isLinux) {
      final home = Platform.environment['HOME'] ?? '/tmp';
      return '$home/.local/share/RossTabak';
    } else if (Platform.isMacOS) {
      final home = Platform.environment['HOME'] ?? '/tmp';
      return '$home/Library/Application Support/RossTabak';
    } else {
      return 'ross_tabak_data';
    }
  }

  /// Directory for database files.
  static String get databaseDirectory {
    final dir = '$_appDataRoot/database';
    _ensureDir(dir);
    return dir;
  }

  /// Full path to the SQLite database file.
  static String get databasePath => '$databaseDirectory/rosstabak.db';

  /// Directory for log files.
  static String get logDirectory {
    final dir = '$_appDataRoot/logs';
    _ensureDir(dir);
    return dir;
  }

  /// Full path to the error log file.
  static String get errorLogPath => '$logDirectory/rosstabak_error.log';

  /// Directory for database backups.
  static String get backupDirectory {
    final dir = '$_appDataRoot/backups';
    _ensureDir(dir);
    return dir;
  }

  /// Ensures a directory exists (creates it with parents if missing).
  static void _ensureDir(String path) {
    final dir = Directory(path);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  /// Prints diagnostic paths to console (for startup debugging).
  static void printDiagnostics() {
    debugPrint('=== AppPaths Diagnostics ===');
    debugPrint('AppData root: $_appDataRoot');
    debugPrint('Database path: $databasePath');
    debugPrint('Log directory: $logDirectory');
    debugPrint('Backup directory: $backupDirectory');
    debugPrint('===========================');

    stdout.writeln('=== AppPaths Diagnostics ===');
    stdout.writeln('AppData root: $_appDataRoot');
    stdout.writeln('Database path: $databasePath');
    stdout.writeln('Log directory: $logDirectory');
    stdout.writeln('Backup directory: $backupDirectory');
    stdout.writeln('===========================');
  }
}
