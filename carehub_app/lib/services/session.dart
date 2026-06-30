/// Holds the current user's role status for the duration of the app
/// session, so screens don't need to re-fetch /insurance-details just
/// to know whether to show owner-only actions.
///
/// Set this once right after login (see AuthService.login or wherever
/// you navigate to the home screen), then read Session.isPrimary
/// anywhere in the UI.
class Session {
  static bool isPrimary = false;
  static String username = '';

  static void clear() {
    isPrimary = false;
    username = '';
  }
}