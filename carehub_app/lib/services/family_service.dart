import '../core/api_client.dart';
import '../models/family_member.dart';

class FamilyService {
  static Future<FamilyList> getFamily() async {
    final json = await ApiClient.get('/family', withAuth: true);
    return FamilyList.fromJson(json['data'] as Map<String, dynamic>);
  }

  /// Owner-only. Backend returns 403 if a non-owner calls this.
  /// NOTE: this does NOT send an email - the backend has no email
  /// invite flow wired up. The invited person's temporary password
  /// is their phone number; they activate via /auth/join-family-member
  /// using the policy code + owner's email.
  static Future<void> inviteFamilyMember({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String dateOfBirth,
    required String gender,
    required int relationId,
  }) async {
    await ApiClient.post('/family/invite-family-member', {
      'fullName': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'relation_id': relationId,
    }, withAuth: true);
  }

  /// Owner-only. Soft-deletes (deactivates) a family member.
  static Future<void> removeFamilyMember(int memberId) async {
    await ApiClient.delete('/family/$memberId', withAuth: true);
  }


/// Give Insurance -> search. Returns the owner's INACTIVE dependents
  /// (the ones a "remove" deactivated) that match the query. An empty
  /// query returns all of them.
  static Future<List<EligibleMember>> searchInactiveMembers(String query) async {
    final json = await ApiClient.get('/family/search', withAuth: true, queryParams: {'q': query});
    final list = json['data'] as List? ?? [];
    return list.map((e) => EligibleMember.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Give Insurance -> reactivate a previously removed dependent.
  static Future<void> reactivateMember({required int memberId}) async {
    await ApiClient.post('/family/reactivate', {
      'member_id': memberId,
    }, withAuth: true);
  }
  
  
}