class MedicalCenterSummary {
  final int id;
  final String name;
  final String type;
  final String address;
  final String phone;
  final bool isOpen;

  MedicalCenterSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.phone,
    required this.isOpen,
  });

  /// Handles two different shapes from the backend:
  /// - getAllMedicalCenters returns a real boolean: "is_open": true/false
  /// - search/type-filter return a string: "status": "open"/"closed"
  /// This factory normalizes both into a single `isOpen` bool so the
  /// UI doesn't need to know which endpoint the data came from.
  factory MedicalCenterSummary.fromJson(Map<String, dynamic> json) {
    bool open;
    if (json.containsKey('is_open')) {
      open = json['is_open'] as bool? ?? true;
    } else {
      open = (json['status'] as String?)?.toLowerCase() != 'closed';
    }

    return MedicalCenterSummary(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      isOpen: open,
    );
  }
}

class MedicalCenterDetail {
  final int id;
  final String name;
  final String type;
  final String address;
  final String phone;
  final String? imageUrl;
  final String description;
  final String email;
  final bool isOpen;

  MedicalCenterDetail({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.phone,
    required this.imageUrl,
    required this.description,
    required this.email,
    required this.isOpen,
  });

  factory MedicalCenterDetail.fromJson(Map<String, dynamic> json) {
    return MedicalCenterDetail(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String? ?? '',
      email: json['email'] as String? ?? '',
      // getMedicalCenterById returns is_open as a string: "open"/"closed"
      isOpen: (json['is_open'] as String?)?.toLowerCase() != 'closed',
    );
  }
}