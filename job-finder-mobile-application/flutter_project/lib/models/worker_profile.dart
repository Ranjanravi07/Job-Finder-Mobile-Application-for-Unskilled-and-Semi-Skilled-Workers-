/// Mirrors the React `WorkerProfile` interface from `src/types.ts`.
class WorkerProfile {
  final String id;
  final String name;
  final String phone;
  final String mainSkill;
  final String experience; // e.g. "2 years", "Fresher"
  final int expectedWage;
  final String expectedWageType; // 'daily' | 'weekly'
  final String location;
  final String availability; // e.g. "Immediate", "Part-time"
  final String bio;
  final String govIdType;
  final String govIdNum;
  final String verificationStatus;
  final List<String> govIdFiles;
  final String profilePhoto;

  const WorkerProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.mainSkill,
    required this.experience,
    required this.expectedWage,
    required this.expectedWageType,
    required this.location,
    required this.availability,
    this.bio = '',
    this.govIdType = 'citizenship',
    this.govIdNum = '',
    this.verificationStatus = 'pending',
    this.govIdFiles = const [],
    this.profilePhoto = '',
  });

  WorkerProfile copyWith({
    String? id,
    String? name,
    String? phone,
    String? mainSkill,
    String? experience,
    int? expectedWage,
    String? expectedWageType,
    String? location,
    String? availability,
    String? bio,
    String? govIdType,
    String? govIdNum,
    String? verificationStatus,
    List<String>? govIdFiles,
    String? profilePhoto,
  }) {
    return WorkerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      mainSkill: mainSkill ?? this.mainSkill,
      experience: experience ?? this.experience,
      expectedWage: expectedWage ?? this.expectedWage,
      expectedWageType: expectedWageType ?? this.expectedWageType,
      location: location ?? this.location,
      availability: availability ?? this.availability,
      bio: bio ?? this.bio,
      govIdType: govIdType ?? this.govIdType,
      govIdNum: govIdNum ?? this.govIdNum,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      govIdFiles: govIdFiles ?? this.govIdFiles,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'mainSkill': mainSkill,
        'experience': experience,
        'expectedWage': expectedWage,
        'expectedWageType': expectedWageType,
        'location': location,
        'availability': availability,
        'bio': bio,
        'govIdType': govIdType,
        'govIdNum': govIdNum,
        'verificationStatus': verificationStatus,
        'govIdFiles': govIdFiles,
        'profilePhoto': profilePhoto,
      };

  factory WorkerProfile.fromMap(Map<String, dynamic> map) => WorkerProfile(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        mainSkill: map['mainSkill'] as String? ?? '',
        experience: map['experience'] as String? ?? 'Fresher',
        expectedWage: (map['expectedWage'] as num?)?.toInt() ?? 0,
        expectedWageType: map['expectedWageType'] as String? ?? 'daily',
        location: map['location'] as String? ?? '',
        availability: map['availability'] as String? ?? 'Immediate',
        bio: map['bio'] as String? ?? '',
        govIdType: map['govIdType'] as String? ?? 'citizenship',
        govIdNum: map['govIdNum'] as String? ?? '',
        verificationStatus: _parseVerificationStatus(map),
        govIdFiles: (map['govIdFiles'] as List?)?.cast<String>() ?? [],
        profilePhoto: map['profilePhoto'] as String? ?? '',
      );

  static String _parseVerificationStatus(Map<String, dynamic> map) {
    if (map.containsKey('verificationStatus')) {
      return map['verificationStatus'] as String? ?? 'pending';
    } else if (map.containsKey('governmentId') && map['governmentId'] is Map) {
      final gov = map['governmentId'] as Map;
      return gov['verificationStatus'] as String? ?? 'pending';
    }
    return 'pending';
  }
}
