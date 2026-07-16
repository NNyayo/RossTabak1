import '../controllers/auth_controller.dart';

class RouteGuard {
  /// Checks whether [controller]'s current user has one of allowed roles.
  static bool canActivate(
    AuthController controller,
    List<String> allowedRoles,
  ) {
    final user = controller.currentUser;
    if (user == null) return false;
    return allowedRoles.contains(user.role);
  }
}
