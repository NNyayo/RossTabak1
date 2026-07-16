import 'package:flutter/foundation.dart';

import '../models/store.dart';
import '../repositories/store_repository.dart';

class StoreController extends ChangeNotifier {
  final StoreRepository _repository = StoreRepository();

  List<Store> stores = [];
  bool isLoading = false;

  Future<void> loadStores() async {
    isLoading = true;
    notifyListeners();
    stores = await _repository.getStores();
    isLoading = false;
    notifyListeners();
  }

  Future<List<Store>> getAllStores() async {
    return _repository.getAllStores();
  }

  Future<int> createStore(Store s) async {
    final id = await _repository.addStore(s);
    await loadStores();
    return id;
  }

  Future<void> updateStore(Store s) async {
    await _repository.updateStore(s);
    await loadStores();
  }

  Future<void> deleteStore(int id) async {
    await _repository.deleteStore(id);
    await loadStores();
  }

  Future<void> restoreStore(int id) async {
    await _repository.restoreStore(id);
    await loadStores();
  }
}
