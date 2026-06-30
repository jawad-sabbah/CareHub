// lib/services/profile_service.dart

import '../core/api_client.dart';
import '../models/profile_data.dart';

class ProfileService {
  static Future<ProfileData> getProfile() async {
    final json = await ApiClient.get('/profile', withAuth: true);
    return ProfileData.fromJson(json['data'] as Map<String, dynamic>);
  }

  static Future<void> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String gender,
  }) async {
    await ApiClient.put('/profile/update', {
      'fullName': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'gender': gender,
    }, withAuth: true);
  }

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await ApiClient.put('/profile/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    }, withAuth: true);
  }
}