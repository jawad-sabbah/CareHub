import '../core/api_client.dart';
import '../models/medical_record.dart';

class MedicalRecordsService {
  /// type: "all" | "hospital" | "clinic" | "lab"
  static Future<MedicalRecordsList> getMedicalRecords({String type = 'all'}) async {
    final json = await ApiClient.get(
      '/medical-records',
      withAuth: true,
      queryParams: {'type': type},
    );
    return MedicalRecordsList.fromJson(json['data'] as Map<String, dynamic>);
  }

  static Future<MedicalRecordDetail> getRecordDetail(int recordId) async {
    final json = await ApiClient.get('/medical-records/$recordId', withAuth: true);
    return MedicalRecordDetail.fromJson(json['data'] as Map<String, dynamic>);
  }
}