import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../constants/app_constants.dart';
import '../constants/app_roles.dart';
import '../core/password_hash.dart';
import 'migrations/migration_001_initial.dart';
import 'migrations/migration_002_add_comments_and_settings.dart';
import 'migrations/migration_003_add_shift_reports.dart';
import 'migrations/migration_005_add_foreign_keys.dart';
import 'migrations/migration_006_add_task_templates_and_system_logs.dart';
import 'migrations/migration_007_add_store_id_to_tasks.dart';
import 'migrations/migration_008_add_is_active_to_tasks.dart';
import 'migrations/migration_009_add_task_comments.dart';
import 'migrations/migration_010_add_notifications.dart';
import 'migrations/migration_011_add_daily_tasks_and_requests.dart';
import 'migrations/migration_012_add_store_id_to_daily_tasks.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  /// Writes a diagnostic message to the same log file used by main.dart.
  /// Falls back silently if logging fails.
  static void _logToFile(String message) {
    try {
      final logDir = Directory(_getLogDirectoryPath());
      if (!logDir.existsSync()) {
        logDir.createSync(recursive: true);
      }
      final file = File(_getLogFilePath());
      file.writeAsStringSync(
        '${DateTime.now().toIso8601String()} | $message\n',
        mode: FileMode.append,
      );
    } catch (_) {
      // Silently ignore log write failures to avoid recursion.
    }
  }

  /// Returns the path to the logs directory next to the executable.
  static String _getLogDirectoryPath() {
    if (Platform.isWindows) {
      final exeDir = File(Platform.resolvedExecutable).parent.path;
      return '$exeDir/logs';
    } else if (Platform.isLinux) {
      final exeDir = File(Platform.resolvedExecutable).parent.path;
      return '$exeDir/logs';
    } else if (Platform.isMacOS) {
      final home = Platform.environment['HOME'] ?? '/tmp';
      return '$home/Library/Logs/RossTabak';
    } else {
      return 'logs';
    }
  }

  /// Full path to the error log file.
  static String _getLogFilePath() =>
      '${_getLogDirectoryPath()}/rosstabak_error.log';

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    _logToFile(
      'DB: dbPath=$dbPath, fileName=$fileName, fullPath=$path, version=${AppConstants.dbVersion}',
    );

    try {
      final db = await openDatabase(
        path,
        version: AppConstants.dbVersion,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
          _logToFile('DB: PRAGMA foreign_keys = ON executed');
        },
        onCreate: (db, version) async {
          _logToFile('DB: onCreate called, version=$version');
          await _createDB(db, version);
          _logToFile('DB: onCreate completed');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          _logToFile(
            'DB: onUpgrade called, oldVersion=$oldVersion, newVersion=$newVersion',
          );
          await _upgradeDB(db, oldVersion, newVersion);
          _logToFile('DB: onUpgrade completed');
        },
        onOpen: (db) async {
          _logToFile('DB: onOpen called');
          if (await _needsEmployeeSchemaUpgrade(db)) {
            _logToFile(
              'DB: applying fifthStageMigrations (employee schema upgrade)',
            );
            for (final query in fifthStageMigrations) {
              await db.execute(query);
            }
            _logToFile('DB: fifthStageMigrations applied');
          }
          await _ensureAdminExists(db);
          _logToFile('DB: onOpen completed');
        },
      );
      _logToFile('DB: openDatabase completed successfully');
      return db;
    } catch (e, stackTrace) {
      _logToFile('DB: openDatabase FAILED: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> _ensureAdminExists(Database db) async {
    _logToFile('DB: _ensureAdminExists checking for admin user');
    try {
      final existingAdmin = await db.query(
        'employees',
        where: 'login = ? AND role = ?',
        whereArgs: [AppConstants.adminLogin, AppRoles.admin],
        limit: 1,
      );

      if (existingAdmin.isEmpty) {
        _logToFile(
          'DB: _ensureAdminExists admin not found, creating default admin',
        );
        final now = DateTime.now().toIso8601String();
        final adminPassword = 'admin123';

        final adminData = {
          'last_name': AppConstants.adminLastName,
          'first_name': AppConstants.adminFirstName,
          'middle_name': AppConstants.adminMiddleName,
          'login': AppConstants.adminLogin,
          'password': PasswordHasher.hash(adminPassword),
          'role': AppRoles.admin,
          'is_active': 1,
          'created_at': now,
        };

        await db.insert('employees', adminData);
        _logToFile('DB: _ensureAdminExists admin created');

        await _ensureDefaultCategories(db);
      } else {
        _logToFile('DB: _ensureAdminExists admin already exists');
      }
    } catch (e, stackTrace) {
      _logToFile('DB: _ensureAdminExists FAILED: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> _ensureDefaultCategories(Database db) async {
    _logToFile('DB: _ensureDefaultCategories checking for default categories');
    try {
      final existing = await db.query(
        'task_categories',
        where: 'name = ?',
        whereArgs: ['Склад'],
        limit: 1,
      );

      if (existing.isEmpty) {
        _logToFile('DB: _ensureDefaultCategories creating default categories');
        final categories = [
          {'name': 'Склад', 'description': 'Задачи по работе со складом'},
          {'name': 'Витрина', 'description': 'Задачи по работе с витриной'},
          {'name': 'Уборка', 'description': 'Задачи по уборке'},
          {'name': 'Инвентаризация', 'description': 'Задачи по инвентаризации'},
          {
            'name': 'Оборудование',
            'description': 'Задачи по обслуживанию оборудования',
          },
          {'name': 'Персонал', 'description': 'Задачи по работе с персоналом'},
        ];

        for (final cat in categories) {
          await db.insert('task_categories', {
            ...cat,
            'is_active': 1,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
        _logToFile('DB: _ensureDefaultCategories completed');
      } else {
        _logToFile('DB: _ensureDefaultCategories categories already exist');
      }
    } catch (e, stackTrace) {
      _logToFile('DB: _ensureDefaultCategories FAILED: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<bool> _tableHasColumn(Database db, String table, String column) async {
    final result = await db.rawQuery('PRAGMA table_info($table)');
    return result.any((row) => row['name'] == column);
  }

  Future<bool> _needsEmployeeSchemaUpgrade(Database db) async {
    final hasLastName = await _tableHasColumn(db, 'employees', 'last_name');
    return !hasLastName;
  }

  Future<void> _createDB(Database db, int version) async {
    for (final query in initialMigrations) {
      await db.execute(query);
    }

    for (final query in secondStageMigrations) {
      await db.execute(query);
    }

    for (final query in thirdStageMigrations) {
      await db.execute(query);
    }

    for (final query in fifthStageMigrations) {
      await db.execute(query);
    }

    for (final query in sixthStageMigrations) {
      await db.execute(query);
    }

    for (final query in seventhStageMigrations) {
      await db.execute(query);
    }

    for (final query in eighthStageMigrations) {
      await db.execute(query);
    }

    for (final query in ninthStageMigrations) {
      await db.execute(query);
    }

    for (final query in tenthStageMigrations) {
      await db.execute(query);
    }

    for (final query in eleventhStageMigrations) {
      await db.execute(query);
    }

    for (final query in twelfthStageMigrations) {
      await db.execute(query);
    }
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      for (final query in secondStageMigrations) {
        await db.execute(query);
      }
    }

    if (oldVersion < 3) {
      for (final query in thirdStageMigrations) {
        await db.execute(query);
      }
    }

    if (oldVersion < 5) {
      for (final query in fifthStageMigrations) {
        await db.execute(query);
      }
    }

    if (oldVersion < 6) {
      for (final query in sixthStageMigrations) {
        await db.execute(query);
      }
    }

    if (oldVersion < 7) {
      for (final query in seventhStageMigrations) {
        await db.execute(query);
      }
    }

    if (oldVersion < 8) {
      for (final query in eighthStageMigrations) {
        await db.execute(query);
      }
    }

    if (oldVersion < 9) {
      for (final query in ninthStageMigrations) {
        await db.execute(query);
      }
    }

    if (oldVersion < 10) {
      for (final query in tenthStageMigrations) {
        await db.execute(query);
      }
    }

    if (oldVersion < 11) {
      for (final query in eleventhStageMigrations) {
        await db.execute(query);
      }
    }

    if (oldVersion < 12) {
      for (final query in twelfthStageMigrations) {
        await db.execute(query);
      }
    }
  }
}
