class MedicalRecordSummary {
  final int id;
  final String diagnosis;
  final String icd10Code;
  final String visitDate;
  final String center;
  final String centerType;

  MedicalRecordSummary({
    required this.id,
    required this.diagnosis,
    required this.icd10Code,
    required this.visitDate,
    required this.center,
    required this.centerType,
  });

  factory MedicalRecordSummary.fromJson(Map<String, dynamic> json) {
    return MedicalRecordSummary(
      id: json['id'] as int? ?? 0,
      diagnosis: json['diagnosis'] as String? ?? '',
      icd10Code: json['icd10Code'] as String? ?? '',
      visitDate: json['visitDate'] as String? ?? '',
      center: json['center'] as String? ?? '',
      centerType: json['centerType'] as String? ?? '',
    );
  }
}

class MedicalRecordsList {
  final int totalVisits;
  final String? lastVisit;
  final List<MedicalRecordSummary> records;

  MedicalRecordsList({
    required this.totalVisits,
    required this.lastVisit,
    required this.records,
  });

  factory MedicalRecordsList.fromJson(Map<String, dynamic> json) {
    final list = json['records'] as List? ?? [];
    return MedicalRecordsList(
      totalVisits: json['totalVisits'] as int? ?? 0,
      lastVisit: json['lastVisit'] as String?,
      records: list.map((r) => MedicalRecordSummary.fromJson(r as Map<String, dynamic>)).toList(),
    );
  }
}

class MedicalRecordService {
  final String serviceName;
  final String description;
  final String chiefComplaint;
  final String physicalExam;
  final double cost;
  final int coveragePercentage;
  final double insurancePays;
  final double patientPays;

  MedicalRecordService({
    required this.serviceName,
    required this.description,
    required this.chiefComplaint,
    required this.physicalExam,
    required this.cost,
    required this.coveragePercentage,
    required this.insurancePays,
    required this.patientPays,
  });

  factory MedicalRecordService.fromJson(Map<String, dynamic> json) {
    return MedicalRecordService(
      serviceName: json['serviceName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      chiefComplaint: json['chiefComplaint'] as String? ?? '',
      physicalExam: json['physicalExam'] as String? ?? '',
      cost: (json['cost'] as num?)?.toDouble() ?? 0,
      coveragePercentage: (json['coveragePercentage'] as num?)?.toInt() ?? 0,
      insurancePays: (json['insurancePays'] as num?)?.toDouble() ?? 0,
      patientPays: (json['patientPays'] as num?)?.toDouble() ?? 0,
    );
  }
}

class MedicalRecordDetail {
  final int id;
  final String diagnosis;
  final String icd10Code;
  final String visitDate;
  final String centerName;
  final List<MedicalRecordService> services;

  MedicalRecordDetail({
    required this.id,
    required this.diagnosis,
    required this.icd10Code,
    required this.visitDate,
    required this.centerName,
    required this.services,
  });

  factory MedicalRecordDetail.fromJson(Map<String, dynamic> json) {
    final servicesRaw = json['services'] as List? ?? [];
    return MedicalRecordDetail(
      id: json['id'] as int? ?? 0,
      diagnosis: json['diagnosis'] as String? ?? '',
      icd10Code: json['icd10Code'] as String? ?? '',
      visitDate: json['visitDate'] as String? ?? '',
      centerName: json['centerName'] as String? ?? '',
      services: servicesRaw.map((s) => MedicalRecordService.fromJson(s as Map<String, dynamic>)).toList(),
    );
  }
}