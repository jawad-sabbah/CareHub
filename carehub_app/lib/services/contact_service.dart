import '../core/api_client.dart';

class ContactService {
  static Future<void> sendMessage({
    required String subject,
    required String message,
  }) async {
    await ApiClient.post('/contact-us', {
      'subject': subject,
      'message': message,
    }, withAuth: true);
  }
}