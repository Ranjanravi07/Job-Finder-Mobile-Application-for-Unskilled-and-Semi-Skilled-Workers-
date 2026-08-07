import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

/// Provider for managing user profile state across the app
/// Handles profile creation, updates, and retrieval from Firestore
class ProfileProvider with ChangeNotifier {
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getters
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _profile != null;

  /// Load profile from Firestore by user ID
  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final doc = await _firestore.collection('profiles').doc(userId).get();
      
      if (doc.exists) {
        _profile = UserProfile.fromFirestore(doc);
      } else {
        _profile = null;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading profile: $e');
    }
  }

  /// Create or update user profile in Firestore
  Future<bool> saveProfile(UserProfile profile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedProfile = profile.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('profiles')
          .doc(profile.id)
          .set(updatedProfile.toFirestore(), SetOptions(merge: true));

      _profile = updatedProfile;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error saving profile: $e');
      return false;
    }
  }

  /// Update specific profile fields
  Future<bool> updateProfile({
    String? name,
    String? nameNe,
    String? skill,
    String? industry,
    String? location,
    String? locationNe,
    String? profilePhotoUrl,
    String? governmentIdType,
    String? governmentIdNumber,
    String? governmentIdImageUrl,
    String? experience,
    String? jobCategory,
    String? preferredLocation,
    String? workType,
    String? expectedSalary,
    String? shiftPreference,
    String? status,
  }) async {
    if (_profile == null) return false;

    final updatedProfile = _profile!.copyWith(
      name: name,
      nameNe: nameNe,
      skill: skill,
      industry: industry,
      location: location,
      locationNe: locationNe,
      profilePhotoUrl: profilePhotoUrl,
      governmentIdType: governmentIdType,
      governmentIdNumber: governmentIdNumber,
      governmentIdImageUrl: governmentIdImageUrl,
      experience: experience,
      jobCategory: jobCategory,
      preferredLocation: preferredLocation,
      workType: workType,
      expectedSalary: expectedSalary,
      shiftPreference: shiftPreference,
      status: status,
      updatedAt: DateTime.now(),
    );

    return await saveProfile(updatedProfile);
  }

  /// Create initial profile during registration
  Future<bool> createProfile({
    required String userId,
    required String phone,
    required String name,
    String? nameNe,
    required String role,
    String? skill,
    String? industry,
    required String location,
    String? locationNe,
    String? profilePhotoUrl,
    String? governmentIdType,
    String? governmentIdNumber,
    String? governmentIdImageUrl,
    String? experience,
    String? jobCategory,
    String? preferredLocation,
    String? workType,
    String? expectedSalary,
    String? shiftPreference,
  }) async {
    final newProfile = UserProfile(
      id: userId,
      phone: phone,
      name: name,
      nameNe: nameNe,
      role: role,
      skill: skill,
      industry: industry,
      location: location,
      locationNe: locationNe,
      profilePhotoUrl: profilePhotoUrl,
      governmentIdType: governmentIdType,
      governmentIdNumber: governmentIdNumber,
      governmentIdImageUrl: governmentIdImageUrl,
      rating: 0.0,
      jobsCompleted: 0,
      experience: experience,
      jobCategory: jobCategory,
      preferredLocation: preferredLocation,
      workType: workType,
      expectedSalary: expectedSalary,
      shiftPreference: shiftPreference,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: 'pending',
    );

    return await saveProfile(newProfile);
  }

  /// Clear profile (used during logout)
  void clearProfile() {
    _profile = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Reset error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
