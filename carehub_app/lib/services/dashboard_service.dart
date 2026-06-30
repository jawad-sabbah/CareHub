import '../core/api_client.dart';
import '../models/dashboard_data.dart';

class DashboardService {
  static Future<DashboardData> getDashboard() async {
    final json = await ApiClient.get('/dashboard', withAuth: true);
    return DashboardData.fromJson(json['data'] as Map<String, dynamic>);
  }
}