import 'package:flutter/foundation.dart';

import '../controllers/auth_controller.dart';
import '../models/employee.dart';

class AuthProvider extends ChangeNotifier {
  final AuthController controller = AuthController();

  Employee? currentEmployee;
  bool isLoading = false;
  String? errorMessage;

  AuthProvider() {
    controller.addListener(_onControllerChanged);
    controller.restoreSession();
  }

  void _onControllerChanged() {
    currentEmployee = controller.currentUser;
    notifyListeners();
  }

  bool get isAuthenticated => currentEmployee != null;

  Future<bool> signIn(String login, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final success = await controller.signIn(login, password);
    isLoading = false;

    if (!success) {
      errorMessage = controller.errorMessage ?? 'Неверный логин или пароль';
    } else {
      currentEmployee = controller.currentUser;
    }

    notifyListeners();
    return success;
  }

  Future<void> signOut() async {
    await controller.signOut();
    currentEmployee = null;
    notifyListeners();
  }
}
