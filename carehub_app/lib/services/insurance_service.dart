import '../core/api_client.dart';
import '../models/virtual_card_model.dart';

class InsuranceService {

  static Future<VirtualCardModel> getCard(int memberId) async {

    final json = await ApiClient.get(
      '/family/cards/$memberId',
      withAuth: true,
    );

    return VirtualCardModel.fromJson(
      json['data'] as Map<String, dynamic>,
    );
  }
}