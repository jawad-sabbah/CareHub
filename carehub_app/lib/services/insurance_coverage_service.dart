import '../core/api_client.dart';
import '../models/insurance_coverage.dart';

class InsuranceCoverageService {
  static Future<InsuranceCoverage> getCoverage() async {
    final json = await ApiClient.get('/insurance-coverage-details', withAuth: true);
    return InsuranceCoverage.fromJson(json['data'] as Map<String, dynamic>);
  }
}