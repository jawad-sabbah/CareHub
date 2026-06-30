class InsuranceDetails {
  final int userId;
  final String userName;
  final bool isPrimary;
  final int insuranceId;
  final String policyCode;
  final String providerName;
  final String status;
  final String startDate;
  final String expiryDate;
  final int planId;
  final String planName;
  final int coveragePercentage;
  final double annualLimit;
  final String description;

  InsuranceDetails({
    required this.userId,
    required this.userName,
    required this.isPrimary,
    required this.insuranceId,
    required this.policyCode,
    required this.providerName,
    required this.status,
    required this.startDate,
    required this.expiryDate,
    required this.planId,
    required this.planName,
    required this.coveragePercentage,
    required this.annualLimit,
    required this.description,
  });

  factory InsuranceDetails.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final insurance = json['insurance'] as Map<String, dynamic>;
    final plan = json['plan'] as Map<String, dynamic>;

    return InsuranceDetails(
      userId: user['id'] as int? ?? 0,
      userName: user['name'] as String? ?? '',
      isPrimary: user['isPrimary'] as bool? ?? false,
      insuranceId: insurance['id'] as int? ?? 0,
      policyCode: insurance['policyCode'] as String? ?? '',
      providerName: insurance['providerName'] as String? ?? '',
      status: insurance['status'] as String? ?? '',
      startDate: insurance['startDate'] as String? ?? '',
      expiryDate: insurance['expiryDate'] as String? ?? '',
      planId: plan['id'] as int? ?? 0,
      planName: plan['name'] as String? ?? '',
      coveragePercentage: (plan['coveragePercentage'] as num?)?.toInt() ?? 0,
      // annualLimit can arrive as a String ("100000.00") since it's a
      // Postgres NUMERIC column - parse defensively either way.
      annualLimit: double.tryParse(plan['annualLimit']?.toString() ?? '') ?? 0,
      description: plan['description'] as String? ?? '',
    );
  }
}