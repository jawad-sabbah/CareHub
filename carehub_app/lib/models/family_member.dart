class FamilyMember {
  final int id;
  final String name;
  final String relation;
  final String gender;
  final String dateOfBirth;
  final bool isPrimary;
  final String status;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.gender,
    required this.dateOfBirth,
    required this.isPrimary,
    required this.status,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      relation: json['relation'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] as String? ?? '',
      isPrimary: json['isPrimary'] as bool? ?? false,
      status: json['status'] as String? ?? '',
    );
  }
}

class FamilyList {
  final int totalMembers;
  final String planStatus;
  final List<FamilyMember> members;

  FamilyList({
    required this.totalMembers,
    required this.planStatus,
    required this.members,
  });

  factory FamilyList.fromJson(Map<String, dynamic> json) {
    final list = json['members'] as List? ?? [];
    return FamilyList(
      totalMembers: json['totalMembers'] as int? ?? 0,
      planStatus: json['planStatus'] as String? ?? '',
      members: list.map((m) => FamilyMember.fromJson(m as Map<String, dynamic>)).toList(),
    );
  }
}