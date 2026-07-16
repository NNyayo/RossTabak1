import 'dart:async';

import 'package:flutter/foundation.dart';

abstract class BaseController<T> extends ChangeNotifier {
  final Future<List<T>> Function() _loader;
  List<T> items = [];
  bool isLoading = false;

  BaseController(this._loader);

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    items = await _loader();
    isLoading = false;
    notifyListeners();
  }
}
