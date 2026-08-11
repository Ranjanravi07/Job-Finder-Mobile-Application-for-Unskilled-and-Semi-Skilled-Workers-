import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/employer_profile.dart';
import '../models/job.dart';
import '../models/job_application.dart';
import '../models/worker_profile.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a local image file to Firebase Storage and return its public download URL.
  Future<String> uploadFile(String localPath, String storagePath) async {
    if (localPath.isEmpty) return '';
    if (localPath.startsWith('http://') || localPath.startsWith('https://')) {
      return localPath; // Already a remote network URL
    }
    final file = File(localPath);
    if (!await file.exists()) {
      return localPath;
    }
    try {
      final ref = _storage.ref().child(storagePath);
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // Log storage exception during development
      print('FirebaseStorage upload warning: $e');
      return localPath; // Fallback to local path if storage bucket unconfigured
    }
  }

  /// Get jobs for an employer
  Stream<List<Job>> getEmployerJobs(String employerId) {
    return _firestore
        .collection('jobs')
        .where('employerId', isEqualTo: employerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (!data.containsKey('id')) {
          data['id'] = doc.id;
        }
        return Job.fromMap(data);
      }).toList();
    });
  }

  /// Get applications for a specific job
  Stream<List<JobApplication>> getApplicationsForJob(String jobId) {
    return _firestore
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (!data.containsKey('id')) {
          data['id'] = doc.id;
        }
        return JobApplication.fromMap(data);
      }).toList();
    });
  }

  /// Get applications for a specific worker
  Stream<List<JobApplication>> getApplicationsForWorker(String workerId) {
    return _firestore
        .collection('applications')
        .where('workerId', isEqualTo: workerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (!data.containsKey('id')) {
          data['id'] = doc.id;
        }
        return JobApplication.fromMap(data);
      }).toList();
    });
  }

  /// Get applications for a specific employer
  Stream<List<JobApplication>> getApplicationsForEmployer(String employerId) {
    return _firestore
        .collection('applications')
        .where('employerId', isEqualTo: employerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (!data.containsKey('id')) {
          data['id'] = doc.id;
        }
        return JobApplication.fromMap(data);
      }).toList();
    });
  }

  /// Get worker profile by ID
  Future<WorkerProfile?> getWorkerProfile(String workerId) async {
    try {
      var doc = await _firestore.collection('workers').doc(workerId).get();
      if (!doc.exists) {
        doc = await _firestore.collection('profiles').doc(workerId).get();
      }
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (!data.containsKey('id')) {
          data['id'] = doc.id;
        }
        return WorkerProfile.fromMap(data);
      }
    } catch (e) {
      print('Error reading worker profile: $e');
    }
    return null;
  }

  /// Get employer profile by ID
  Future<EmployerProfile?> getEmployerProfile(String employerId) async {
    try {
      final doc =
          await _firestore.collection('employers').doc(employerId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (!data.containsKey('id')) {
          data['id'] = doc.id;
        }
        return EmployerProfile.fromMap(data);
      }
    } catch (e) {
      print('Error reading employer profile: $e');
    }
    return null;
  }

  /// Get worker profile by phone
  Future<WorkerProfile?> getWorkerProfileByPhone(String phone) async {
    try {
      final String rawPhone = phone.replaceAll('+977', '');
      final String normalizedPhone = '+977$rawPhone';
      final phoneList = {phone, rawPhone, normalizedPhone}.toList();

      final query = await _firestore.collection('workers').where('phone', whereIn: phoneList).limit(1).get();
      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        if (!data.containsKey('id')) {
          data['id'] = query.docs.first.id;
        }
        return WorkerProfile.fromMap(data);
      }
      
      // Fallback check profiles
      final profilesQuery = await _firestore.collection('profiles').where('phone', whereIn: phoneList).limit(1).get();
      if (profilesQuery.docs.isNotEmpty) {
        final data = profilesQuery.docs.first.data();
        if (!data.containsKey('id')) {
          data['id'] = profilesQuery.docs.first.id;
        }
        return WorkerProfile.fromMap(data);
      }
    } catch (e) {
      print('Error querying worker profile by phone: $e');
    }
    return null;
  }

  /// Get employer profile by phone
  Future<EmployerProfile?> getEmployerProfileByPhone(String phone) async {
    try {
      final String rawPhone = phone.replaceAll('+977', '');
      final String normalizedPhone = '+977$rawPhone';
      final phoneList = {phone, rawPhone, normalizedPhone}.toList();

      final query = await _firestore.collection('employers').where('phone', whereIn: phoneList).limit(1).get();
      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        if (!data.containsKey('id')) {
          data['id'] = query.docs.first.id;
        }
        return EmployerProfile.fromMap(data);
      }
    } catch (e) {
      print('Error querying employer profile by phone: $e');
    }
    return null;
  }

  /// Stream worker profile
  Stream<WorkerProfile?> streamWorkerProfile(String workerId) {
    return _firestore
        .collection('workers')
        .doc(workerId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;
      if (!data.containsKey('id')) data['id'] = doc.id;
      return WorkerProfile.fromMap(data);
    });
  }

  /// Stream employer profile
  Stream<EmployerProfile?> streamEmployerProfile(String employerId) {
    return _firestore
        .collection('employers')
        .doc(employerId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;
      if (!data.containsKey('id')) data['id'] = doc.id;
      return EmployerProfile.fromMap(data);
    });
  }

  /// Save or update worker profile
  Future<void> saveWorkerProfile(WorkerProfile profile) async {
    await _firestore
        .collection('workers')
        .doc(profile.id)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  /// Save or update employer profile
  Future<void> saveEmployerProfile(EmployerProfile profile) async {
    await _firestore
        .collection('employers')
        .doc(profile.id)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  /// Update KYC info for a user (worker or employer)
  Future<void> updateKyc({
    required String collection,
    required String userId,
    required String govIdType,
    required String govIdNum,
    required List<String> govIdFiles,
    Map<String, Map<String, dynamic>>? governmentIds,
  }) async {
    final Map<String, dynamic> data = {
      'govIdType': govIdType,
      'govIdNum': govIdNum,
      'govIdFiles': govIdFiles,
      'verificationStatus': 'pending',
    };
    if (governmentIds != null) {
      data['governmentIds'] = governmentIds;
    }
    await _firestore
        .collection(collection)
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }

  /// Update complete KYC and profile info for a user (worker or employer)
  Future<void> updateKycAndProfile({
    required String collection,
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    final Map<String, dynamic> payload = Map<String, dynamic>.from(data);
    payload['verificationStatus'] = 'pending';
    await _firestore
        .collection(collection)
        .doc(userId)
        .set(payload, SetOptions(merge: true));
  }

  /// Create a job application in Firestore and increment job applicantCount
  Future<void> createJobApplication(JobApplication app) async {
    await _firestore.collection('applications').doc(app.id).set(app.toMap());
    // Increment applicant count on job doc
    await _firestore.collection('jobs').doc(app.jobId).update({
      'applicantCount': FieldValue.increment(1),
    }).catchError((_) {});
  }

  /// Update application status
  Future<void> updateApplicationStatus(
      String applicationId, String status) async {
    await _firestore.collection('applications').doc(applicationId).update({
      'status': status,
    });
  }

  /// Close a job to prevent further applications
  Future<void> closeJob(String jobId) async {
    await _firestore.collection('jobs').doc(jobId).update({
      'status': 'closed',
    });
  }

  /// Get all active workers
  Stream<List<WorkerProfile>> streamWorkers() {
    return _firestore
        .collection('workers')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (!data.containsKey('id')) {
          data['id'] = doc.id;
        }
        return WorkerProfile.fromMap(data);
      }).toList();
    });
  }

  /// Get active (open) jobs for workers
  Stream<List<Job>> streamActiveJobs() {
    return _firestore
        .collection('jobs')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (!data.containsKey('id')) {
          data['id'] = doc.id;
        }
        return Job.fromMap(data);
      }).toList();
    });
  }

  /// Get a single job by ID
  Future<Job?> getJob(String jobId) async {
    final doc = await _firestore.collection('jobs').doc(jobId).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      if (!data.containsKey('id')) data['id'] = doc.id;
      return Job.fromMap(data);
    }
    return null;
  }

  /// Create a new job in Firestore
  Future<void> createJob(Job job) async {
    await _firestore.collection('jobs').doc(job.id).set(job.toMap());
  }

  /// Send a chat message to Firestore
  Future<void> sendMessage(
      String conversationId, Map<String, dynamic> messageData) async {
    final msgId =
        messageData['id'] ?? 'msg-${DateTime.now().millisecondsSinceEpoch}';
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(msgId)
        .set(messageData);

    await _firestore.collection('conversations').doc(conversationId).set({
      'lastMessage': messageData['text'] ?? '',
      'lastMessageTime': messageData['timestamp'] ?? DateTime.now().toIso8601String(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Stream chat messages for a conversation
  Stream<List<Map<String, dynamic>>> streamMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  /// Creates an admin notification document in Firestore `notifications` collection
  Future<void> createAdminNotification({
    required String type,
    required String title,
    required String message,
    String? relatedUserId,
    String? relatedJobId,
    String? relatedApplicationId,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'type': type,
        'title': title,
        'message': message,
        'recipientRole': 'admin',
        'relatedUserId': relatedUserId,
        'relatedJobId': relatedJobId,
        'relatedApplicationId': relatedApplicationId,
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }
}
