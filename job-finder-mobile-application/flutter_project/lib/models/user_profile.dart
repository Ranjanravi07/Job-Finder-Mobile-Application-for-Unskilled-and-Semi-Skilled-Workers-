import 'package:cloud_firestore/cloud_firestore.dart';

/// User profile model for both workers and employers
/// Supports English and Nepali language fields
class UserProfile {
  final String id;
  final String phone;
  final String name;
  final String? nameNe; // Nepali name (optional)
  final String role; // 'worker' or 'employer'
  final String? skill; // For workers: mason, painter, electrician, etc.
  final String? industry; // For employers: construction, factory, etc.
  final String location;
  final String? locationNe; // Nepali location (optional)
  final String? profilePhotoUrl;
  final String? governmentIdType; // e.g., 'Citizenship', 'Passport', 'PAN'
  final String? governmentIdNumber;
  final String? governmentIdImageUrl;
  final double? rating;
  final int? jobsCompleted;
  final String? experience; // e.g., '5 Years'

  // Job Category and Work Preferences (for workers)
  final String? jobCategory; // laborer, electrician, plumber, driver, etc.
  final String? preferredLocation; // Preferred work location
  final String? workType; // 'full-time', 'part-time', 'daily-wage', 'contract'
  final String? expectedSalary; // Minimum expected salary
  final String? shiftPreference; // 'day', 'night', 'flexible'

  final DateTime createdAt;
  final DateTime? updatedAt;
  final String status; // 'pending', 'active', 'inactive'

  UserProfile({
    required this.id,
    required this.phone,
    required this.name,
    this.nameNe,
    required this.role,
    this.skill,
    this.industry,
    required this.location,
    this.locationNe,
    this.profilePhotoUrl,
    this.governmentIdType,
    this.governmentIdNumber,
    this.governmentIdImageUrl,
    this.rating,
    this.jobsCompleted,
    this.experience,
    this.jobCategory,
    this.preferredLocation,
    this.workType,
    this.expectedSalary,
    this.shiftPreference,
    required this.createdAt,
    this.updatedAt,
    this.status = 'pending',
  });

  /// Create UserProfile from Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      phone: data['phone'] ?? '',
      name: data['name'] ?? '',
      nameNe: data['nameNe'],
      role: data['role'] ?? 'worker',
      skill: data['skill'],
      industry: data['industry'],
      location: data['location'] ?? '',
      locationNe: data['locationNe'],
      profilePhotoUrl: data['profilePhotoUrl'],
      governmentIdType: data['governmentIdType'],
      governmentIdNumber: data['governmentIdNumber'],
      governmentIdImageUrl: data['governmentIdImageUrl'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      jobsCompleted: data['jobsCompleted'] ?? 0,
      experience: data['experience'],
      jobCategory: data['jobCategory'],
      preferredLocation: data['preferredLocation'],
      workType: data['workType'],
      expectedSalary: data['expectedSalary'],
      shiftPreference: data['shiftPreference'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'pending',
    );
  }

  /// Convert UserProfile to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'phone': phone,
      'name': name,
      'nameNe': nameNe,
      'role': role,
      'skill': skill,
      'industry': industry,
      'location': location,
      'locationNe': locationNe,
      'profilePhotoUrl': profilePhotoUrl,
      'governmentIdType': governmentIdType,
      'governmentIdNumber': governmentIdNumber,
      'governmentIdImageUrl': governmentIdImageUrl,
      'rating': rating ?? 0.0,
      'jobsCompleted': jobsCompleted ?? 0,
      'experience': experience,
      'jobCategory': jobCategory,
      'preferredLocation': preferredLocation,
      'workType': workType,
      'expectedSalary': expectedSalary,
      'shiftPreference': shiftPreference,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'status': status,
    };
  }

  /// Create a copy of UserProfile with updated fields
  UserProfile copyWith({
    String? id,
    String? phone,
    String? name,
    String? nameNe,
    String? role,
    String? skill,
    String? industry,
    String? location,
    String? locationNe,
    String? profilePhotoUrl,
    String? governmentIdType,
    String? governmentIdNumber,
    String? governmentIdImageUrl,
    double? rating,
    int? jobsCompleted,
    String? experience,
    String? jobCategory,
    String? preferredLocation,
    String? workType,
    String? expectedSalary,
    String? shiftPreference,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return UserProfile(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      nameNe: nameNe ?? this.nameNe,
      role: role ?? this.role,
      skill: skill ?? this.skill,
      industry: industry ?? this.industry,
      location: location ?? this.location,
      locationNe: locationNe ?? this.locationNe,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      governmentIdType: governmentIdType ?? this.governmentIdType,
      governmentIdNumber: governmentIdNumber ?? this.governmentIdNumber,
      governmentIdImageUrl: governmentIdImageUrl ?? this.governmentIdImageUrl,
      rating: rating ?? this.rating,
      jobsCompleted: jobsCompleted ?? this.jobsCompleted,
      experience: experience ?? this.experience,
      jobCategory: jobCategory ?? this.jobCategory,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      workType: workType ?? this.workType,
      expectedSalary: expectedSalary ?? this.expectedSalary,
      shiftPreference: shiftPreference ?? this.shiftPreference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  /// Get display name based on language
  String getDisplayName(String lang) {
    return lang == 'ne' && nameNe != null && nameNe!.isNotEmpty
        ? nameNe!
        : name;
  }

  /// Get display location based on language
  String getDisplayLocation(String lang) {
    return lang == 'ne' && locationNe != null && locationNe!.isNotEmpty
        ? locationNe!
        : location;
  }

  /// Get initials for avatar
  String get initials {
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, role: $role, phone: $phone)';
  }
}
