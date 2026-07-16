import 'package:flutter/foundation.dart';

import '../models/employee.dart';
import '../repositories/auth_repository.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthController extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  AuthState state = AuthState.initial;
  Employee? currentUser;
  String? errorMessage;

  Future<void> restoreSession() async {
    state = AuthState.loading;
    notifyListeners();

    try {
      final has = await _repository.hasSession();
      if (!has) {
        state = AuthState.unauthenticated;
        currentUser = null;
        notifyListeners();
        return;
      }

      final id = await _repository.getSavedUserId();
      if (id == null) {
        state = AuthState.unauthenticated;
        currentUser = null;
        notifyListeners();
        return;
      }

      final user = await _repository.getCurrentUser(id);
      if (user == null) {
        state = AuthState.unauthenticated;
        currentUser = null;
      } else {
        state = AuthState.authenticated;
        currentUser = user;
      }
    } catch (e) {
      state = AuthState.error;
      errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<bool> signIn(String login, String password) async {
    state = AuthState.loading;
    notifyListeners();

    try {
      final user = await _repository.login(login, password);
      if (user == null) {
        state = AuthState.unauthenticated;
        notifyListeners();
        return false;
      }

      currentUser = user;
      await _repository.saveSession(user.id ?? 0);
      state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      state = AuthState.error;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _repository.logout();
    currentUser = null;
    state = AuthState.unauthenticated;
    notifyListeners();
  }
}
