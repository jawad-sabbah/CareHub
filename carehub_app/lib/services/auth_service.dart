import '../core/api_client.dart';
import '../core/api_exception.dart';
import 'session.dart';

class AuthService {
  /// Image 4 - "Create Account" full registration form.
  /// Creates a new policy owner. Does NOT log them in automatically -
  /// the response has no token. Send them to Sign In after this succeeds.
  static Future<Map<String, dynamic>> registerOwner({
    required String fullName,
    required String email,
    required String phoneNumber, // exactly 8 digits, digits only
    required String dateOfBirth, // "YYYY-MM-DD"
    required String gender, // "M" or "F"
    required String password,
  }) async {
    final json = await ApiClient.post('/auth/register-owner', {
      'fullName': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'password': password,
    });
    return json['data'] as Map<String, dynamic>;
  }

  /// Image 2 - "Welcome Back" sign in.
  /// Used by BOTH owners and family members - there is no separate
  /// "member login" endpoint, just this one shared login.
  ///
  /// After logging in, also fetches /insurance-details once to read
  /// the user's isPrimary flag (owner vs. family member) and caches
  /// it in Session, so the home screen and other screens can check
  /// Session.isPrimary synchronously instead of each calling the API
  /// themselves just to know which role they're rendering for.
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final json = await ApiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final token = json['token'] as String;
    ApiClient.setToken(token);

    final user = json['data'] as Map<String, dynamic>;
    Session.username = user['username'] as String? ?? '';

    await _loadRoleIntoSession();

    return user;
  }

  /// Image 3 - "Join Family Plan".
  /// ONE-TIME activation for a dependent already invited by the owner
  /// (via /family/invite-family-member). Also returns a token, like
  /// login - after this, the member uses login() like everyone else
  /// from then on.
  static Future<Map<String, dynamic>> joinFamilyMember({
    required String policyCode,
    required String ownerEmail,
    required String fullName,
    required int relationId,
  }) async {
    final json = await ApiClient.post('/auth/join-family-member', {
      'policy_code': policyCode,
      'owner_email': ownerEmail,
      'fullName': fullName,
      'relation_id': relationId,
    });

    final token = json['token'] as String;
    ApiClient.setToken(token);

    final member = json['data'] as Map<String, dynamic>;
    Session.username = (member['username'] ?? member['fullName'] ?? '') as String;

    await _loadRoleIntoSession();

    return member;
  }

  /// Logout. The backend call is a no-op (doesn't invalidate the token
  /// server-side) - the real logout work is clearing the token and
  /// session here on the client, which happens regardless of whether
  /// the network call succeeds or fails (e.g. if the device is offline).
  static Future<void> logout() async {
    try {
      await ApiClient.post('/auth/logout', {}, withAuth: true);
    } on ApiException {
      // Ignore - logging out locally either way.
    } finally {
      ApiClient.setToken(null);
      Session.clear();
    }
  }

  /// Fetches /insurance-details and caches isPrimary into Session.
  /// Shared by both login() and joinFamilyMember() so this logic
  /// isn't duplicated in two places.
  ///
  /// If this call fails (e.g. a brand-new user has no insurance yet),
  /// defaults Session.isPrimary to false rather than blocking the
  /// whole login/join flow over a non-critical lookup.
  static Future<void> _loadRoleIntoSession() async {
    try {
      final detailsJson = await ApiClient.get('/insurance-details', withAuth: true);
      final details = detailsJson['data'] as Map<String, dynamic>;
      final userDetails = details['user'] as Map<String, dynamic>;
      Session.isPrimary = userDetails['isPrimary'] as bool? ?? false;
    } catch (_) {
      Session.isPrimary = false;
    }
  }
}