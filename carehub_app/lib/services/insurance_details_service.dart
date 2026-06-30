import '../core/api_client.dart';
import '../models/insurance_details.dart';

class InsuranceDetailsService {
  static Future<InsuranceDetails> getDetails() async {
    final json = await ApiClient.get('/insurance-details', withAuth: true);
    return InsuranceDetails.fromJson(json['data'] as Map<String, dynamic>);
  }
}