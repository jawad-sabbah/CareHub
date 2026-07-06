class InsuranceCard {
  final int id;
  final String policyCode;
  final String providerName;
  final String status;
  final String planName;
  final String startDate;
  final String expiryDate;
  final String? qrCodeBase64; // full data URI: "data:image/png;base64,...."

  InsuranceCard({
    required this.id,
    required this.policyCode,
    required this.providerName,
    required this.status,
    required this.planName,
    required this.startDate,
    required this.expiryDate,
    required this.qrCodeBase64,
  });

  factory InsuranceCard.fromJson(Map<String, dynamic> json) {
    return InsuranceCard(
      id: json['id'] as int,
      policyCode: json['policyCode'] as String? ?? '',
      providerName: json['providerName'] as String? ?? '',
      status: json['status'] as String? ?? '',
      planName: json['planName'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      expiryDate: json['expiryDate'] as String? ?? '',
      qrCodeBase64: json['qrCode'] as String?,
    );
  }
}

class RecentMedicalRecord {
  final int id;
  final String serviceName;
  final String medicalCenter;
  final String visitDate;

  RecentMedicalRecord({
    required this.id,
    required this.serviceName,
    required this.medicalCenter,
    required this.visitDate,
  });

  factory RecentMedicalRecord.fromJson(Map<String, dynamic> json) {
    return RecentMedicalRecord(
      id: json['id'] as int,
      serviceName: json['serviceName'] as String? ?? '',
      medicalCenter: json['medicalCenter'] as String? ?? '',
      visitDate: json['visitDate'] as String? ?? '',
    );
  }
}

class DashboardData {
  final int userId;
  final String username;
  final InsuranceCard? insuranceCard; // null if no active policy
  final List<RecentMedicalRecord> recentMedicalRecords;
  final int familyMembersCount;
  final int medicalRecordsCount;

  final double? annualLimit;
  final double? usedAmount;
  final List<MonthlyVisit> monthlyVisits;

  DashboardData({
    required this.userId,
    required this.username,
    required this.insuranceCard,
    required this.recentMedicalRecords,
    required this.familyMembersCount,
    required this.medicalRecordsCount,
    this.annualLimit,
    this.usedAmount,
    this.monthlyVisits = const [],
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final card = json['insuranceCard'] as Map<String, dynamic>?;
    final records = json['recentMedicalRecords'] as List? ?? [];
    final counts = json['counts'] as Map<String, dynamic>? ?? {};
    final coverage = json['coverage'] as Map<String, dynamic>?;
    final visits = json['monthlyVisits'] as List? ?? [];

    return DashboardData(
      userId: user['id'] as int,
      username: user['username'] as String? ?? '',
      insuranceCard: card != null ? InsuranceCard.fromJson(card) : null,
      recentMedicalRecords: records
          .map((r) => RecentMedicalRecord.fromJson(r as Map<String, dynamic>))
          .toList(),
      familyMembersCount: counts['familyMembers'] as int? ?? 0,
      medicalRecordsCount: counts['medicalRecords'] as int? ?? 0,
        annualLimit: (coverage?['annualLimit'] as num?)?.toDouble(),
        usedAmount: (coverage?['usedAmount'] as num?)?.toDouble(),
        monthlyVisits: visits
            .map((m) => MonthlyVisit.fromJson(m as Map<String, dynamic>))
            .toList(),
    );
  }
}


class MonthlyVisit {
  final String label; // e.g. "Jan"
  final int count;

  MonthlyVisit({required this.label, required this.count});

  factory MonthlyVisit.fromJson(Map<String, dynamic> json) {
    return MonthlyVisit(
      label: json['label'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}