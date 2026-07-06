class FamilyMember {
  final int id;
  final String name;
  final String relation;
  final String gender;
  final String dateOfBirth;
  final bool isPrimary;
  final String status;
  final String? email;
  final String? phoneNumber; 

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.gender,
    required this.dateOfBirth,
    required this.isPrimary,
    required this.status,
    this.email,
    this.phoneNumber,
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
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
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

class EligibleMember {
  final int id;
  final String name;
  final String email;

  EligibleMember({required this.id, required this.name, required this.email});

  factory EligibleMember.fromJson(Map<String, dynamic> json) {
    return EligibleMember(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}