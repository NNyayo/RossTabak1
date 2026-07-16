import 'package:flutter/foundation.dart';

import '../models/task_category.dart';
import '../repositories/task_category_repository.dart';

class TaskCategoryController extends ChangeNotifier {
  final TaskCategoryRepository _repository = TaskCategoryRepository();

  List<TaskCategory> categories = [];
  bool isLoading = false;

  Future<void> loadCategories() async {
    isLoading = true;
    notifyListeners();
    categories = await _repository.getCategories();
    isLoading = false;
    notifyListeners();
  }

  Future<List<TaskCategory>> getAllCategories() async {
    return _repository.getAllCategories();
  }

  Future<int> createCategory(TaskCategory category) async {
    final id = await _repository.createCategory(category);
    await loadCategories();
    return id;
  }

  Future<void> updateCategory(TaskCategory category) async {
    await _repository.updateCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await _repository.deleteCategory(id);
    await loadCategories();
  }

  Future<void> restoreCategory(int id) async {
    await _repository.restoreCategory(id);
    await loadCategories();
  }
}
