/// Mirrors the React `EmployerProfile` interface from `src/types.ts`.
class EmployerProfile {
  final String id;
  final String name;
  final String companyName;
  final String phone;
  final String location;
  final bool isVerified;
  final String type; // 'business' | 'individual'
  final String role;
  final String govId;
  final List<String> govIdFiles;
  final String profilePhoto;

  const EmployerProfile({
    required this.id,
    required this.name,
    required this.companyName,
    required this.phone,
    required this.location,
    this.isVerified = true,
    this.type = 'individual',
    this.role = 'Contractor',
    this.govId = '',
    this.govIdFiles = const [],
    this.profilePhoto = '',
  });

  EmployerProfile copyWith({
    String? id,
    String? name,
    String? companyName,
    String? phone,
    String? location,
    bool? isVerified,
    String? type,
    String? role,
    String? govId,
    List<String>? govIdFiles,
    String? profilePhoto,
  }) {
    return EmployerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      isVerified: isVerified ?? this.isVerified,
      type: type ?? this.type,
      role: role ?? this.role,
      govId: govId ?? this.govId,
      govIdFiles: govIdFiles ?? this.govIdFiles,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'companyName': companyName,
        'phone': phone,
        'location': location,
        'isVerified': isVerified,
        'type': type,
        'role': role,
        'govId': govId,
        'govIdFiles': govIdFiles,
        'profilePhoto': profilePhoto,
      };

  factory EmployerProfile.fromMap(Map<String, dynamic> map) => EmployerProfile(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        companyName: map['companyName'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        location: map['location'] as String? ?? '',
        isVerified: map['isVerified'] as bool? ?? true,
        type: map['type'] as String? ?? 'individual',
        role: map['role'] as String? ?? 'Contractor',
        govId: map['govId'] as String? ?? '',
        govIdFiles: (map['govIdFiles'] as List?)?.cast<String>() ?? [],
        profilePhoto: map['profilePhoto'] as String? ?? '',
      );
}
