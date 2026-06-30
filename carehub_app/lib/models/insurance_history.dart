class InsuranceHistoryEntry {
  final int id;
  final String planName;
  final String providerName;
  final String policyCode;
  final String actionType; // "used" | "renewed" | "expired"
  final String description;
  final String startDate;
  final String expiryDate;
  final String createdAt;

  InsuranceHistoryEntry({
    required this.id,
    required this.planName,
    required this.providerName,
    required this.policyCode,
    required this.actionType,
    required this.description,
    required this.startDate,
    required this.expiryDate,
    required this.createdAt,
  });

  factory InsuranceHistoryEntry.fromJson(Map<String, dynamic> json) {
    return InsuranceHistoryEntry(
      id: json['id'] as int,
      planName: json['planName'] as String? ?? '',
      providerName: json['providerName'] as String? ?? '',
      policyCode: json['policyCode'] as String? ?? '',
      actionType: json['actionType'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      expiryDate: json['expiryDate'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

class InsuranceHistoryList {
  final int totalPolicies;
  final List<InsuranceHistoryEntry> history;

  InsuranceHistoryList({required this.totalPolicies, required this.history});

  factory InsuranceHistoryList.fromJson(Map<String, dynamic> json) {
    final list = json['history'] as List? ?? [];
    return InsuranceHistoryList(
      totalPolicies: json['totalPolicies'] as int? ?? 0,
      history: list.map((h) => InsuranceHistoryEntry.fromJson(h as Map<String, dynamic>)).toList(),
    );
  }
}