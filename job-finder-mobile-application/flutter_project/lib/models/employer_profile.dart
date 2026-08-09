/// Mirrors the React `EmployerProfile` interface from `src/types.ts`.
class EmployerProfile {
  final String id;
  final String name;
  final String companyName;
  final String phone;
  final String location;
  final String verificationStatus;
  final String type; // 'business' | 'individual'
  final String role;
  final String govIdType;
  final String govIdNum;
  final List<String> govIdFiles;
  final String profilePhoto;

  const EmployerProfile({
    required this.id,
    required this.name,
    required this.companyName,
    required this.phone,
    required this.location,
    this.verificationStatus = 'pending',
    this.type = 'individual',
    this.role = 'Contractor',
    this.govIdType = 'citizenship',
    this.govIdNum = '',
    this.govIdFiles = const [],
    this.profilePhoto = '',
  });

  EmployerProfile copyWith({
    String? id,
    String? name,
    String? companyName,
    String? phone,
    String? location,
    String? verificationStatus,
    String? type,
    String? role,
    String? govIdType,
    String? govIdNum,
    List<String>? govIdFiles,
    String? profilePhoto,
  }) {
    return EmployerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      type: type ?? this.type,
      role: role ?? this.role,
      govIdType: govIdType ?? this.govIdType,
      govIdNum: govIdNum ?? this.govIdNum,
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
        'verificationStatus': verificationStatus,
        'type': type,
        'role': role,
        'govIdType': govIdType,
        'govIdNum': govIdNum,
        'govIdFiles': govIdFiles,
        'profilePhoto': profilePhoto,
      };

  factory EmployerProfile.fromMap(Map<String, dynamic> map) => EmployerProfile(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        companyName: map['companyName'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        location: map['location'] as String? ?? '',
        verificationStatus: _parseVerificationStatus(map),
        type: map['type'] as String? ?? 'individual',
        role: map['role'] as String? ?? 'Contractor',
        govIdType: map['govIdType'] as String? ?? 'citizenship',
        govIdNum: map['govIdNum'] as String? ?? '',
        govIdFiles: (map['govIdFiles'] as List?)?.cast<String>() ?? [],
        profilePhoto: map['profilePhoto'] as String? ?? '',
      );

  static String _parseVerificationStatus(Map<String, dynamic> map) {
    if (map.containsKey('verificationStatus')) {
      return map['verificationStatus'] as String? ?? 'pending';
    } else if (map.containsKey('governmentId') && map['governmentId'] is Map) {
      final gov = map['governmentId'] as Map;
      return gov['verificationStatus'] as String? ?? 'pending';
    } else if (map.containsKey('isVerified')) {
      // Legacy fallback
      return (map['isVerified'] == true) ? 'verified' : 'pending';
    }
    return 'pending';
  }
}
