
class ProfileData {
  final int id;
  final String userName;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String gender;

  ProfileData({
    required this.id,
    required this.userName,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] as int,
      userName: json['userName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
    );
  }
}