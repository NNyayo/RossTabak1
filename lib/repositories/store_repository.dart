import '../database/database_helper.dart';
import '../models/store.dart';

class StoreRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> addStore(Store store) async {
    final db = await _databaseHelper.database;
    final map = store.toMap();
    map['created_at'] = map['created_at'] ?? DateTime.now().toIso8601String();
    return await db.insert('stores', map);
  }

  Future<List<Store>> getStores() async {
    final db = await _databaseHelper.database;

    final info = await db.rawQuery('PRAGMA table_info(stores)');
    final hasIsActive = info.any((row) => row['name'] == 'is_active');

    final storesData = await db.query(
      'stores',
      where: hasIsActive ? 'is_active = ?' : 'isActive = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return storesData.map((data) => Store.fromMap(data)).toList();
  }

  Future<List<Store>> getAllStores() async {
    final db = await _databaseHelper.database;
    final storesData = await db.query('stores', orderBy: 'name ASC');
    return storesData.map((data) => Store.fromMap(data)).toList();
  }

  Future<Store?> getStoreById(int id) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'stores',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Store.fromMap(result.first);
  }

  Future<void> updateStore(Store store) async {
    final db = await _databaseHelper.database;
    await db.update(
      'stores',
      store.toMap(),
      where: 'id = ?',
      whereArgs: [store.id],
    );
  }

  Future<void> deleteStore(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'stores',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> restoreStore(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'stores',
      {'is_active': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
