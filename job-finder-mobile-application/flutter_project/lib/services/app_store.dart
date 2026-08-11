import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/mock_data.dart';
import '../models/chat_message.dart';
import '../models/employer_profile.dart';
import '../models/job.dart';
import '../models/job_application.dart';
import '../models/worker_profile.dart';
import 'chat_service.dart';
import 'firebase_service.dart';
import 'otp/api_otp_service.dart';
import 'otp/otp_service.dart';
import 'speech_service.dart';
import 'storage_service.dart';

/// Central application state.
///
/// Mirrors the `useState` + handler logic from the React
/// `src/components/MobileSimulator.tsx` component.
class AppStore extends ChangeNotifier {
  AppStore._();

  static final AppStore instance = AppStore._();

  final StorageService _storage = StorageService.instance;
  
  /// The OTP service responsible for generating and validating OTPs.
  final OtpService otpService = ApiOtpService();

  // ---------------------------------------------------------------
  // Navigation & user session
  // ---------------------------------------------------------------
  String lang = 'en';
  String phone = '';
  String userId = '';
  String? role; // 'worker' | 'employer'

  // ---------------------------------------------------------------
  // "Database" mock state (persisted)
  // ---------------------------------------------------------------
  List<Job> jobs = List.of(kInitialJobs);
  List<WorkerProfile> workers = List.of(kInitialWorkers);
  List<EmployerProfile> employers = List.of(kInitialEmployers);
  List<JobApplication> applications = List.of(kInitialApplications);
  Map<String, List<ChatMessage>> chatMessages = kInitialChatMessages();

  // ---------------------------------------------------------------
  // UI filter states (Worker)
  // ---------------------------------------------------------------
  String selectedCategory = 'all';
  bool isMapView = false;
  String searchQuery = '';
  double maxWageFilter = 10000;
  String selectedLocationFilter = 'all';
  Job? activeJobDetails;

  // ---------------------------------------------------------------
  // Dialog simulated views
  // ---------------------------------------------------------------
  bool voiceInputOpen = false;
  bool parsingVoice = false;
  String speechText = '';
  Map<String, dynamic>? voiceParsedProfile;
  String? callingPhone;
  String? callingName;

  // ---------------------------------------------------------------
  // Tab states
  // ---------------------------------------------------------------
  String workerTab = 'jobs'; // jobs | applications | chat | sync | profile
  String employerTab = 'jobs'; // jobs | post | applicants | chat | sync | profile

  // ---------------------------------------------------------------
  // System settings
  // ---------------------------------------------------------------
  bool voiceFeedbackEnabled = true;
  bool soundAlertsEnabled = true;
  String themePref = 'light'; // system | light | dark

  // ---------------------------------------------------------------
  // Sync / match logs
  // ---------------------------------------------------------------
  List<String> matchLogs = [];
  bool isSyncing = false;
  double syncProgress = 100;
  String lastSyncTime = 'Never';

  // ---------------------------------------------------------------
  // Chat
  // ---------------------------------------------------------------
  String? activeChatChannel;
  String newMsgText = '';

  // ---------------------------------------------------------------
  // Post job form
  // ---------------------------------------------------------------
  String postTitle = '';
  String postCategory = 'mason';
  int postWage = 1200;
  String postLocation = 'Balkumari, Lalitpur';
  String postDesc = '';

  // ---------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------
  bool initialized = false;

  Future<void> init() async {
    if (initialized) return;
    await _storage.init();

    lang = _storage.getString('lang', 'en');
    phone = _storage.getString('sim_phone', '');
    userId = _storage.getString('sim_user_id', '');
    role = _storage.getString('sim_role', '') == '' ? null : _storage.getString('sim_role', '');
    voiceFeedbackEnabled = _storage.getBool('sys_voice_feedback', true);
    soundAlertsEnabled = _storage.getBool('sys_sound_alerts', true);
    themePref = _storage.getString('sys_theme_pref', 'light');

    jobs = _storage
        .getList('sim_jobs', List.of(kInitialJobs).map((e) => e.toMap()).toList())
        .map(Job.fromMap)
        .toList();
    workers = _storage
        .getList('sim_workers', List.of(kInitialWorkers).map((e) => e.toMap()).toList())
        .map(WorkerProfile.fromMap)
        .toList();
    employers = _storage
        .getList('sim_employers', List.of(kInitialEmployers).map((e) => e.toMap()).toList())
        .map(EmployerProfile.fromMap)
        .toList();
    applications = _storage
        .getList('sim_applications', List.of(kInitialApplications).map((e) => e.toMap()).toList())
        .map(JobApplication.fromMap)
        .toList();

    chatMessages = _loadChatMessages();

    initialized = true;
    notifyListeners();
  }

  Map<String, List<ChatMessage>> _loadChatMessages() {
    final stored = _storage.getList('sim_chat_messages', []);
    if (stored.isEmpty) {
      return kInitialChatMessages();
    }
    try {
      final map = <String, List<ChatMessage>>{};
      for (final entry in stored) {
        final name = entry['channel'] as String? ?? '';
        final messages = ((entry['messages'] as List?) ?? [])
            .map((m) => ChatMessage.fromMap(m as Map<String, dynamic>))
            .toList();
        if (name.isNotEmpty) map[name] = messages;
      }
      return map;
    } catch (_) {
      return kInitialChatMessages();
    }
  }

  void _persistChatMessages() {
    final data = chatMessages.entries
        .map((e) => {
              'channel': e.key,
              'messages': e.value.map((m) => m.toMap()).toList(),
            })
        .toList();
    _storage.setList('sim_chat_messages', data);
  }

  // ---------------------------------------------------------------
  // Persistence helpers
  // ---------------------------------------------------------------
  void _persistJobs() => _storage.setList('sim_jobs', jobs.map((e) => e.toMap()).toList());

  void _persistWorkers() =>
      _storage.setList('sim_workers', workers.map((e) => e.toMap()).toList());

  void _persistEmployers() =>
      _storage.setList('sim_employers', employers.map((e) => e.toMap()).toList());

  void _persistApplications() => _storage
      .setList('sim_applications', applications.map((e) => e.toMap()).toList());

  // ---------------------------------------------------------------
  // Setters
  // ---------------------------------------------------------------
  void setLang(String value) {
    lang = value;
    _storage.setStringValue('lang', value);
    notifyListeners();
  }

  void setPhone(String value) {
    phone = value;
    _storage.setStringValue('sim_phone', value);
    notifyListeners();
  }

  void setUserId(String value) {
    userId = value;
    _storage.setStringValue('sim_user_id', value);
    notifyListeners();
  }

  void setRole(String? value) {
    role = value;
    _storage.setStringValue('sim_role', value ?? '');
    
    // Auto-apply job matching filters for workers
    if (value == 'worker' && activeWorker != null) {
      selectedCategory = activeWorker!.mainSkill;
      selectedLocationFilter = activeWorker!.location;
    }
    
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    phone = '';
    userId = '';
    role = null;
    selectedCategory = 'all';
    selectedLocationFilter = 'all';
    activeChatChannel = null;
    _storage.setStringValue('sim_phone', '');
    _storage.setStringValue('sim_user_id', '');
    _storage.setStringValue('sim_role', '');
    notifyListeners();
  }

  void setWorkerTab(String value) {
    workerTab = value;
    if (value != 'chat') activeChatChannel = null;
    notifyListeners();
  }

  void setEmployerTab(String value) {
    employerTab = value;
    if (value != 'chat') activeChatChannel = null;
    notifyListeners();
  }

  void setSelectedCategory(String value) {
    selectedCategory = value;
    notifyListeners();
  }

  void setIsMapView(bool value) {
    isMapView = value;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void setMaxWageFilter(double value) {
    maxWageFilter = value;
    notifyListeners();
  }

  void setSelectedLocationFilter(String value) {
    selectedLocationFilter = value;
    notifyListeners();
  }

  void setActiveJobDetails(Job? job) {
    activeJobDetails = job;
    notifyListeners();
  }

  void setVoiceInputOpen(bool value) {
    voiceInputOpen = value;
    notifyListeners();
  }

  void setSpeechText(String value) {
    speechText = value;
    notifyListeners();
  }

  void setVoiceParsedProfile(Map<String, dynamic>? value) {
    voiceParsedProfile = value;
    notifyListeners();
  }

  void setCallingPhone(String? value) {
    callingPhone = value;
    notifyListeners();
  }

  void setCallingName(String? value) {
    callingName = value;
    notifyListeners();
  }

  void setActiveChatChannel(String? value) {
    activeChatChannel = value;
    notifyListeners();
  }

  void setNewMsgText(String value) {
    newMsgText = value;
    notifyListeners();
  }

  void setThemePref(String value) {
    themePref = value;
    _storage.setStringValue('sys_theme_pref', value);
    notifyListeners();
  }

  void setVoiceFeedbackEnabled(bool value) {
    voiceFeedbackEnabled = value;
    _storage.setBoolValue('sys_voice_feedback', value);
    notifyListeners();
  }

  void setSoundAlertsEnabled(bool value) {
    soundAlertsEnabled = value;
    _storage.setBoolValue('sys_sound_alerts', value);
    notifyListeners();
  }

  void setPostTitle(String value) {
    postTitle = value;
    notifyListeners();
  }

  void setPostCategory(String value) {
    postCategory = value;
    notifyListeners();
  }

  void setPostWage(int value) {
    postWage = value;
    notifyListeners();
  }

  void setPostLocation(String value) {
    postLocation = value;
    notifyListeners();
  }

  void setPostDesc(String value) {
    postDesc = value;
    notifyListeners();
  }

  // ---------------------------------------------------------------
  // Derived helpers
  // ---------------------------------------------------------------
  WorkerProfile? get activeWorker {
    if (workers.isEmpty) return null;
    return workers.firstWhere(
      (w) => w.phone == phone,
      orElse: () => workers.first,
    );
  }

  EmployerProfile? get activeEmployer {
    if (employers.isEmpty) return null;
    return employers.firstWhere(
      (e) => e.phone == phone,
      orElse: () => employers.first,
    );
  }

  List<Job> get filteredJobs {
    return jobs.where((job) {
      if (selectedCategory != 'all' && job.category != selectedCategory) return false;
      if (selectedLocationFilter != 'all' && selectedLocationFilter != 'any' && job.location != selectedLocationFilter) {
        return false;
      }
      if (job.wage > maxWageFilter) return false;
      if (searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchTitle = job.title.toLowerCase().contains(q);
        final matchLoc = job.location.toLowerCase().contains(q);
        final matchDesc = job.description.toLowerCase().contains(q);
        if (!matchTitle && !matchLoc && !matchDesc) return false;
      }
      return true;
    }).toList();
  }

  // ---------------------------------------------------------------
  // Action handlers (mirrors MobileSimulator.tsx)
  // ---------------------------------------------------------------
  Future<void> sendOtp(Function(String) onError, Function(String) onSuccess) async {
    if (phone.length < 10) {
      onError(lang == 'ne' ? 'कृपया १० अंकको सहि मोबाइल नम्बर हाल्नुहोस्।' : 'Please enter a valid 10-digit mobile number.');
      return;
    }
    try {
      await otpService.sendOtp(phone);
      onSuccess('OTP Sent successfully.');
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> verifyOtp(String otpCode, Function(String) onError, Function(bool, bool) onVerified) async {
    if (otpCode.trim().isEmpty) {
      onError(lang == 'ne' ? 'कृपया ओटिपी कोड हाल्नुहोस्।' : 'Please enter the OTP code.');
      return;
    }
    
    try {
      await otpService.verifyOtp(phone, otpCode.trim()).timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('OTP Verification timed out. Please check your connection.');
      });

      // Normalize phone for unique identification (e.g. +97798...)
      final normalizedPhone = phone.startsWith('+977') ? phone : '+977$phone';
      
      WorkerProfile? workerDoc;
      EmployerProfile? employerDoc;

      try {
        // Find existing profiles by normalized phone number
        workerDoc = await FirebaseService.instance.getWorkerProfileByPhone(normalizedPhone)
            .timeout(const Duration(seconds: 10));
        employerDoc = await FirebaseService.instance.getEmployerProfileByPhone(normalizedPhone)
            .timeout(const Duration(seconds: 10));
      } catch (dbErr) {
        print('Firestore fetch error: $dbErr');
        throw Exception('Database request timed out or failed. Please check your internet connection.');
      }

      // If they exist, use their exact document ID to preserve their session.
      // If not, generate a deterministic UID based on their phone number.
      final String determinedUid = workerDoc?.id ?? employerDoc?.id ?? 'uid_${normalizedPhone.replaceAll('+', '')}';
      
      setUserId(determinedUid);

      if (workerDoc != null) {
        workers = [workerDoc];
        _persistWorkers();
      }
      if (employerDoc != null) {
        employers = [employerDoc];
        _persistEmployers();
      }

      onVerified(workerDoc != null, employerDoc != null);
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> createWorkerProfile({
    String? name,
    String? mainSkill,
    String? experience,
    String? location,
    String? profilePhoto,
    String? govIdType,
    String? govIdNum,
    List<String>? govIdFiles,
    Map<String, Map<String, dynamic>>? governmentIds,
  }) async {
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    final String uid = (authUid != null && authUid.isNotEmpty)
        ? authUid
        : 'worker-${DateTime.now().millisecondsSinceEpoch}';

    String photoUrl = profilePhoto ?? '';
    if (photoUrl.isNotEmpty) {
      photoUrl = await FirebaseService.instance
          .uploadFile(photoUrl, 'profile_photos/$uid/avatar.jpg');
    }

    final List<String> uploadedGovFiles = [];
    if (govIdFiles != null) {
      for (int i = 0; i < govIdFiles.length; i++) {
        final uploaded = await FirebaseService.instance
            .uploadFile(govIdFiles[i], 'kyc/$uid/doc_$i.jpg');
        uploadedGovFiles.add(uploaded);
      }
    }

    final Map<String, Map<String, dynamic>>? uploadedGovMap =
        governmentIds != null ? Map.from(governmentIds) : null;
    if (uploadedGovMap != null) {
      for (final entry in uploadedGovMap.entries) {
        final docs = (entry.value['documentFiles'] as List?)?.cast<String>() ?? [];
        final List<String> uploadedDocs = [];
        for (int i = 0; i < docs.length; i++) {
          final up = await FirebaseService.instance
              .uploadFile(docs[i], 'kyc/$uid/${entry.key}_$i.jpg');
          uploadedDocs.add(up);
        }
        entry.value['documentFiles'] = uploadedDocs;
      }
    }

    final newProfile = WorkerProfile(
      id: uid,
      name: (name ?? '').isNotEmpty ? name! : 'Anonymous Worker',
      phone: phone.isNotEmpty ? phone : '9845112233',
      mainSkill: (mainSkill ?? '').isNotEmpty ? mainSkill! : 'laborer',
      experience: (experience ?? '').isNotEmpty ? experience! : 'Fresher',
      expectedWage: 1000,
      expectedWageType: 'daily',
      location: (location ?? '').isNotEmpty ? location! : 'Balkumari, Lalitpur',
      availability: 'Immediate',
      profilePhoto: photoUrl,
      govIdType: govIdType ?? 'citizenship',
      govIdNum: govIdNum ?? '',
      govIdFiles: uploadedGovFiles,
      verificationStatus: 'pending',
      governmentIds: uploadedGovMap,
    );
    workers = [...workers, newProfile];
    _persistWorkers();
    setRole('worker');

    // Save directly to Firestore
    await FirebaseService.instance.saveWorkerProfile(newProfile);
    await FirebaseService.instance.createAdminNotification(
      type: 'worker_registered',
      title: 'New Worker Registered',
      message: '${newProfile.name} registered as ${newProfile.mainSkill}',
      relatedUserId: newProfile.id,
    );
    notifyListeners();
  }

  Future<void> updateWorkerProfile(Map<String, dynamic> updated, String profileId) async {
    WorkerProfile? updatedProfile;
    workers = workers.map((w) {
      if (w.id == profileId) {
        updatedProfile = w.copyWith(
          name: updated['name'] as String? ?? w.name,
          phone: updated['phone'] as String? ?? w.phone,
          location: updated['location'] as String? ?? w.location,
          mainSkill: updated['mainSkill'] as String? ?? w.mainSkill,
          experience: updated['experience'] as String? ?? w.experience,
          govIdType: updated['govIdType'] as String? ?? w.govIdType,
          govIdNum: updated['govIdNum'] as String? ?? w.govIdNum,
          profilePhoto: updated['profilePhoto'] as String? ?? w.profilePhoto,
          verificationStatus: 'pending',
          governmentIds: updated['governmentIds'] as Map<String, Map<String, dynamic>>? ?? w.governmentIds,
        );
        return updatedProfile!;
      }
      return w;
    }).toList().cast<WorkerProfile>();
    _persistWorkers();
    if (updatedProfile != null) {
      await FirebaseService.instance.saveWorkerProfile(updatedProfile!);
    }
    notifyListeners();
  }

  Future<void> createEmployerProfile({
    String? name,
    String? companyName,
    String? role,
    String? location,
    String? govIdType,
    String? govIdNum,
    List<String>? govIdFiles,
    String? profilePhoto,
    Map<String, Map<String, dynamic>>? governmentIds,
  }) async {
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    final String uid = (authUid != null && authUid.isNotEmpty)
        ? authUid
        : 'emp-${DateTime.now().millisecondsSinceEpoch}';

    String photoUrl = profilePhoto ?? '';
    if (photoUrl.isNotEmpty) {
      photoUrl = await FirebaseService.instance
          .uploadFile(photoUrl, 'profile_photos/$uid/avatar.jpg');
    }

    final List<String> uploadedGovFiles = [];
    if (govIdFiles != null) {
      for (int i = 0; i < govIdFiles.length; i++) {
        final uploaded = await FirebaseService.instance
            .uploadFile(govIdFiles[i], 'kyc/$uid/doc_$i.jpg');
        uploadedGovFiles.add(uploaded);
      }
    }

    final Map<String, Map<String, dynamic>>? uploadedGovMap =
        governmentIds != null ? Map.from(governmentIds) : null;
    if (uploadedGovMap != null) {
      for (final entry in uploadedGovMap.entries) {
        final docs = (entry.value['documentFiles'] as List?)?.cast<String>() ?? [];
        final List<String> uploadedDocs = [];
        for (int i = 0; i < docs.length; i++) {
          final up = await FirebaseService.instance
              .uploadFile(docs[i], 'kyc/$uid/${entry.key}_$i.jpg');
          uploadedDocs.add(up);
        }
        entry.value['documentFiles'] = uploadedDocs;
      }
    }

    final newProfile = EmployerProfile(
      id: uid,
      name: (name ?? '').isNotEmpty ? name! : 'Anonymous Employer',
      companyName: (companyName ?? '').isNotEmpty ? companyName! : 'Individual Project',
      phone: phone.isNotEmpty ? phone : '9851012345',
      location: (location ?? '').isNotEmpty ? location! : 'Balkumari, Lalitpur',
      verificationStatus: 'pending',
      type: 'individual',
      role: (role ?? '').isNotEmpty ? role! : 'Contractor',
      govIdType: govIdType ?? 'citizenship',
      govIdNum: govIdNum ?? '',
      govIdFiles: uploadedGovFiles,
      profilePhoto: photoUrl.isNotEmpty
          ? photoUrl
          : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&h=150&q=80',
      governmentIds: uploadedGovMap,
    );
    employers = [...employers, newProfile];
    _persistEmployers();
    setRole('employer');

    // Save directly to Firestore
    await FirebaseService.instance.saveEmployerProfile(newProfile);
    await FirebaseService.instance.createAdminNotification(
      type: 'employer_registered',
      title: 'New Employer Registered',
      message: '${newProfile.companyName} registered in ${newProfile.location}',
      relatedUserId: newProfile.id,
    );
    notifyListeners();
  }

  Future<void> updateEmployerProfile(Map<String, dynamic> updated, String profileId) async {
    EmployerProfile? updatedProfile;
    employers = employers.map((e) {
      if (e.id == profileId) {
        updatedProfile = e.copyWith(
          name: updated['name'] as String? ?? e.name,
          phone: updated['phone'] as String? ?? e.phone,
          role: updated['role'] as String? ?? e.role,
          location: updated['location'] as String? ?? e.location,
          companyName: updated['companyName'] as String? ?? e.companyName,
          govIdType: updated['govIdType'] as String? ?? e.govIdType,
          govIdNum: updated['govIdNum'] as String? ?? e.govIdNum,
          profilePhoto: updated['profilePhoto'] as String? ?? e.profilePhoto,
          verificationStatus: 'pending',
          governmentIds: updated['governmentIds'] as Map<String, Map<String, dynamic>>? ?? e.governmentIds,
        );
        return updatedProfile!;
      }
      return e;
    }).toList().cast<EmployerProfile>();
    _persistEmployers();
    if (updatedProfile != null) {
      await FirebaseService.instance.saveEmployerProfile(updatedProfile!);
    }
    notifyListeners();
  }

  Future<void> applyForJob(Job job) async {
    final active = activeWorker;
    final newApp = JobApplication(
      id: 'app-${DateTime.now().millisecondsSinceEpoch}',
      jobId: job.id,
      workerId: active?.id ?? 'work-1',
      workerName: active?.name ?? 'Hari Bahadur Shrestha',
      workerPhone: active?.phone ?? '9845551122',
      workerSkill: active?.mainSkill ?? 'mason',
      employerId: job.employerId,
      status: 'pending',
      appliedAt: DateTime.now().toIso8601String(),
    );
    applications = [...applications, newApp];
    _persistApplications();
    notifyListeners();

    // Persist application to Firestore
    await FirebaseService.instance.createJobApplication(newApp);
    await FirebaseService.instance.createAdminNotification(
      type: 'application_submitted',
      title: 'New Application Submitted',
      message: '${newApp.workerName} applied for job',
      relatedUserId: newApp.workerId,
      relatedJobId: newApp.jobId,
      relatedApplicationId: newApp.id,
    );

    SpeechService.instance.speak(
      lang == 'ne'
          ? "आवेदन सफलतापूर्वक पठाइयो। रोजगारदाताले छिट्टै सम्पर्क गर्नेछ।"
          : "Application submitted successfully. The employer will contact you shortly.",
      lang,
    );
  }

  Future<void> postJob() async {
    if (postTitle.trim().isEmpty) return;
    final emp = activeEmployer;
    final newJob = Job(
      id: 'job-${DateTime.now().millisecondsSinceEpoch}',
      title: postTitle,
      category: postCategory,
      description: postDesc.isNotEmpty
          ? postDesc
          : 'Urgent need for a skilled $postCategory at $postLocation.',
      wage: postWage,
      wageType: 'daily',
      location: postLocation,
      employerId: emp?.id ?? 'emp-verified',
      employerName: emp?.name ?? 'NCIT Construction Group',
      employerPhone: phone.isNotEmpty ? phone : (emp?.phone ?? '9851012345'),
      employerWhatsApp: phone.isNotEmpty ? phone : (emp?.phone ?? '9851012345'),
      requiredSkills: [postCategory, 'Manual Labor', 'Safety Gear'],
      datePosted: DateTime.now().toIso8601String(),
      lat: 27.6715 + (DateTime.now().millisecondsSinceEpoch % 100) / 10000 - 0.005,
      lng: 85.3395 + (DateTime.now().millisecondsSinceEpoch % 100) / 10000 - 0.005,
      applicantsCount: 0,
    );
    jobs = [newJob, ...jobs];
    _persistJobs();
    postTitle = '';
    postDesc = '';
    notifyListeners();

    // Persist new job to Firestore
    await FirebaseService.instance.createJob(newJob);
    await FirebaseService.instance.createAdminNotification(
      type: 'job_posted',
      title: 'New Job Posted',
      message: '${newJob.title} posted by ${newJob.employerName}',
      relatedJobId: newJob.id,
      relatedUserId: newJob.employerId,
    );
  }

  Future<void> updateApplicantStatus(String appId, String status) async {
    JobApplication? updatedApp;
    applications = applications.map((app) {
      if (app.id == appId) {
        updatedApp = app.copyWith(status: status);
        return updatedApp!;
      }
      return app;
    }).toList();
    _persistApplications();
    await FirebaseService.instance.updateApplicationStatus(appId, status);
    notifyListeners();

    if (status == 'accepted' && updatedApp != null && activeEmployer != null) {
      try {
        await ChatService.instance.createConversation(updatedApp!, activeEmployer!);
      } catch (e) {
        print("Error creating conversation: $e");
      }
    }
  }

  void sendChatMessage(String channel) {
    if (newMsgText.trim().isEmpty) return;
    final nowStr = _nowTime();
    final updated = Map<String, List<ChatMessage>>.from(chatMessages);
    updated[channel] = [
      ...(updated[channel] ?? []),
      ChatMessage(sender: 'user', text: newMsgText, time: nowStr),
    ];
    chatMessages = updated;
    newMsgText = '';
    _persistChatMessages();
    notifyListeners();

    // Simulate reply after 1.5 seconds.
    Future.delayed(const Duration(milliseconds: 1500), () {
      String reply = lang == 'ne'
          ? "नमस्ते! थप कुराकानीको लागि कृपया मलाई सिधै फोन गर्नुहोस्।"
          : "Namaste! Please call me directly to discuss.";
      if (channel == 'Ravi Ranjan Sah') {
        reply = lang == 'ne'
            ? "हुन्छ, भोलि बिहान ७ बजे साइटमा आउनुहोला। सम्पर्क नम्बर: ९८४१२३४५६७।"
            : "Great! Please come to the Balkumari site tomorrow morning at 7 AM. Call me at 9841234567.";
      } else if (channel == 'Ajay Kumar Sah') {
        reply = lang == 'ne'
            ? "काम राम्रो छ, एकपटक सानेपा आइदिनुहोस्।"
            : "The wiring work is standard. Please meet me once at Sanepa.";
      } else if (channel == 'Hari Bahadur Shrestha') {
        reply = lang == 'ne'
            ? "हो काम बाँकी छ, भोलिदेखि सुरु गर्न सक्नुहुन्छ?"
            : "Yes, the bricklaying work is still available. Can you start tomorrow?";
      }
      final updatedReply = Map<String, List<ChatMessage>>.from(chatMessages);
      updatedReply[channel] = [
        ...(updatedReply[channel] ?? []),
        ChatMessage(sender: 'other', text: reply, time: nowStr),
      ];
      chatMessages = updatedReply;
      _persistChatMessages();
      notifyListeners();
      SpeechService.instance.speak(reply, lang);
    });
  }

  void startSync() {
    if (isSyncing) return;
    isSyncing = true;
    syncProgress = 0;
    notifyListeners();

    var current = 0;
    Timer.periodic(const Duration(milliseconds: 150), (t) {
      current += 10;
      syncProgress = current.toDouble();
      if (syncProgress >= 100) {
        t.cancel();
        isSyncing = false;
        final now = DateTime.now();
        lastSyncTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        final logMsg = lang == 'ne'
            ? "[${now.hour}:${now.minute}] नयाँ मिल्दो काम भेटियो: रंगरोगन कामदार (पेन्टर) ललितपुर!"
            : "[${now.hour}:${now.minute}] Matched 1 new local job: Painter needed at Gwarko!";
        matchLogs = [logMsg, ...matchLogs];
        notifyListeners();
        SpeechService.instance.speak(
          lang == 'ne'
              ? "अफलाईन सिन्क्रोनाइजेसन सफल भयो। नयाँ काम थपियो।"
              : "Offline synchronization completed. New matched job alerts downloaded.",
          lang,
        );
      } else {
        notifyListeners();
      }
    });
  }

  void clearMatchLogs() {
    matchLogs = [];
    notifyListeners();
  }

  void playJobAudio(Job job) {
    final text = lang == 'ne'
        ? 'कामको विवरण: ${job.title}. ज्याला दैनिक ${job.wage} रुपैयाँ। ठेगाना: ${job.location}. कामको बारेमा: ${job.description}'
        : 'Job title: ${job.title}. Wage expectation is ${job.wage} rupees per day. Job location is ${job.location}. Description: ${job.description}';
    SpeechService.instance.speak(text, lang);
  }

  /// Reset simulator database to defaults (mirrors the RESET button).
  Future<void> resetAll() async {
    await _storage.clearAll();
    lang = 'en';
    phone = '';
    userId = '';
    role = null;
    jobs = List.of(kInitialJobs);
    workers = List.of(kInitialWorkers);
    employers = List.of(kInitialEmployers);
    applications = List.of(kInitialApplications);
    chatMessages = kInitialChatMessages();
    workerTab = 'jobs';
    employerTab = 'jobs';
    matchLogs = [];
    activeChatChannel = null;
    callingPhone = null;
    callingName = null;
    activeJobDetails = null;
    notifyListeners();
  }

  String _nowTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
