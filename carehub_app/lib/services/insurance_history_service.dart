import '../core/api_client.dart';
import '../models/insurance_history.dart';

class InsuranceHistoryService {
  static Future<InsuranceHistoryList> getHistory({String search = ''}) async {
    final json = await ApiClient.get(
      '/insurance-history',
      withAuth: true,
      queryParams: search.isNotEmpty ? {'search': search} : null,
    );
    return InsuranceHistoryList.fromJson(json['data'] as Map<String, dynamic>);
  }
}