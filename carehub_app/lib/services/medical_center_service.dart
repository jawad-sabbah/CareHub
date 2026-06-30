import '../core/api_client.dart';
import '../models/medical_center.dart';

class MedicalCenterService {
  static Future<List<MedicalCenterSummary>> getAll() async {
    final json = await ApiClient.get('/medical-centers', withAuth: true);
    final list = json['data'] as List;
    return list.map((c) => MedicalCenterSummary.fromJson(c as Map<String, dynamic>)).toList();
  }

  /// type: "hospital" | "clinic" | "lab"
  static Future<List<MedicalCenterSummary>> getByType(String type) async {
    final json = await ApiClient.get('/medical-centers/type/$type', withAuth: true);
    final list = json['data'] as List;
    return list.map((c) => MedicalCenterSummary.fromJson(c as Map<String, dynamic>)).toList();
  }

  static Future<List<MedicalCenterSummary>> search(String query) async {
    final json = await ApiClient.get(
      '/medical-centers/search',
      withAuth: true,
      queryParams: {'q': query},
    );
    final list = json['data'] as List;
    return list.map((c) => MedicalCenterSummary.fromJson(c as Map<String, dynamic>)).toList();
  }

  static Future<MedicalCenterDetail> getById(int id) async {
    final json = await ApiClient.get('/medical-centers/$id', withAuth: true);
    return MedicalCenterDetail.fromJson(json['data'] as Map<String, dynamic>);
  }
}