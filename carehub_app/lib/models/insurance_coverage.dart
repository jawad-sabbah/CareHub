class InsuranceCoverage {
  final int userId;
  final String username;
  final String policyCode;
  final String providerName;
  final String status;
  final String expiryDate;
  final String planName;
  final int coveragePercentage;
  final double annualLimit;
  final double usedAmount;
  final double remainingAmount;
  final List<String> benefits;

  InsuranceCoverage({
    required this.userId,
    required this.username,
    required this.policyCode,
    required this.providerName,
    required this.status,
    required this.expiryDate,
    required this.planName,
    required this.coveragePercentage,
    required this.annualLimit,
    required this.usedAmount,
    required this.remainingAmount,
    required this.benefits,
  });

  factory InsuranceCoverage.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final insurance = json['insurance'] as Map<String, dynamic>;
    final plan = json['plan'] as Map<String, dynamic>;
    final benefitsRaw = json['benefits'] as List? ?? [];

    return InsuranceCoverage(
      userId: user['id'] as int? ?? 0,
      username: user['username'] as String? ?? '',
      policyCode: insurance['policy_code'] as String? ?? '',
      providerName: insurance['provider_name'] as String? ?? '',
      status: insurance['status'] as String? ?? '',
      expiryDate: insurance['expiry_date'] as String? ?? '',
      planName: plan['name'] as String? ?? '',
      coveragePercentage: (plan['coverage_percentage'] as num?)?.toInt() ?? 0,
      annualLimit: (plan['annual_limit'] as num?)?.toDouble() ?? 0,
      usedAmount: (plan['used_amount'] as num?)?.toDouble() ?? 0,
      remainingAmount: (plan['remaining_amount'] as num?)?.toDouble() ?? 0,
      // benefits can contain a single null if the plan has no rows in
      // insurance_plan_benefit - filter that out rather than showing
      // a blank/crashing list tile.
      benefits: benefitsRaw.whereType<String>().toList(),
    );
  }
}