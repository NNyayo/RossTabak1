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

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

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

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onOpen: (db) async {
        if (await _needsEmployeeSchemaUpgrade(db)) {
          for (final query in fifthStageMigrations) {
            await db.execute(query);
          }
        }
        await _ensureAdminExists(db);
      },
    );
  }

  Future<void> _ensureAdminExists(Database db) async {
    final existingAdmin = await db.query(
      'employees',
      where: 'login = ? AND role = ?',
      whereArgs: [AppConstants.adminLogin, AppRoles.admin],
      limit: 1,
    );

    if (existingAdmin.isEmpty) {
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

      await _ensureDefaultCategories(db);
    }
  }

  Future<void> _ensureDefaultCategories(Database db) async {
    final existing = await db.query(
      'task_categories',
      where: 'name = ?',
      whereArgs: ['Склад'],
      limit: 1,
    );

    if (existing.isEmpty) {
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
  }
}
