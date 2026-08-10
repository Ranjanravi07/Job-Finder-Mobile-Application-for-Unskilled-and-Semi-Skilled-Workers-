import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/job.dart';
import '../models/job_application.dart';
import '../models/conversation.dart';
import '../services/chat_service.dart';
import '../services/firebase_service.dart';
import '../models/employer_profile.dart';
import '../services/app_store.dart';
import '../theme/app_colors.dart';
import '../widgets/update_kyc_dialog.dart';
import 'phone_dialer.dart';
import 'job_applicants_screen.dart';

/// Mirrors the React `EMPLOYER DASHBOARD` screen (Jobs / Post / Applicants /
/// Chat / Profile).
class EmployerHomeScreen extends StatefulWidget {
  const EmployerHomeScreen({super.key});

  @override
  State<EmployerHomeScreen> createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen> {
  AppStore get store => AppStore.instance;

  bool _editingProfile = false;
  late EmployerProfile _editDraft;

  final TextEditingController _postTitleController = TextEditingController();
  final TextEditingController _postWageController =
      TextEditingController(text: '1200');
  final TextEditingController _postLocController = TextEditingController();
  final TextEditingController _postDescController = TextEditingController();
  final TextEditingController _chatController = TextEditingController();

  bool get _isNe => store.lang == 'ne';

  String _t(String en, String ne) => _isNe ? ne : en;

  @override
  void dispose() {
    _postTitleController.dispose();
    _postWageController.dispose();
    _postLocController.dispose();
    _postDescController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  void _startCall(String name, String phone) {
    store.setCallingName(name);
    store.setCallingPhone(phone);
    showPhoneDialer(context, name: name, phone: phone).then((_) {
      store.setCallingPhone(null);
      store.setCallingName(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.slate50,
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          return Column(
            children: [
              Expanded(
                child: switch (store.employerTab) {
                  'jobs' => _buildJobsTab(),
                  'post' => _buildPostTab(),
                  'applicants' => _buildApplicantsTab(),
                  'chat' => _buildChatTab(),
                  _ => _buildProfileTab(),
                },
              ),
              _buildBottomNav(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    final tabs = [
      (
        id: 'jobs',
        icon: Icons.business_center_rounded,
        label: _t('Jobs', 'कामहरू')
      ),
      (
        id: 'post',
        icon: Icons.add_circle_outline_rounded,
        label: _t('Post Job', 'थप्नुहोस्')
      ),
      (
        id: 'applicants',
        icon: Icons.assignment_rounded,
        label: _t('Applicants', 'आवेदक')
      ),
      (id: 'chat', icon: Icons.chat_bubble_rounded, label: _t('Chat', 'च्याट')),
      (
        id: 'profile',
        icon: Icons.settings_rounded,
        label: _t('Profile', 'प्रोफाइल')
      ),
    ];

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: context.appColors.white,
        border: Border(top: BorderSide(color: context.appColors.slate100)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        children: tabs.map((tab) {
          final isActive = store.employerTab == tab.id;
          return Expanded(
            child: InkWell(
              onTap: () => store.setEmployerTab(tab.id),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? Color(0xFFE8F0FE) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      tab.icon,
                      size: 20,
                      color: isActive
                          ? context.appColors.blue600
                          : context.appColors.slate400,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    tab.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                      color: isActive
                          ? context.appColors.slate900
                          : context.appColors.slate500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // JOBS TAB
  // ---------------------------------------------------------------------
  Widget _buildJobsTab() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: context.appColors.slate900,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.business_center_rounded,
                          color: context.appColors.emerald400, size: 16),
                      SizedBox(width: 6),
                      Text(
                        _t('Employer Portal', 'काम दिने पोर्टल'),
                        style: TextStyle(
                          color: context.appColors.slate100,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.verified_rounded,
                          color: context.appColors.emerald400, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Verified Contractor',
                        style: TextStyle(
                          color: context.appColors.emerald400,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live postings
              Text(
                _t('Your Live Postings', 'तपाईंका विज्ञापनहरू'),
                style: _sectionStyle,
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<Job>>(
                stream: FirebaseService.instance.getEmployerJobs(
                    store.activeEmployer?.id ?? 'emp-verified'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                            color: context.appColors.blue600));
                  }
                  final myJobs = snapshot.data ?? [];
                  if (myJobs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _t('No live postings yet.', 'कुनै विज्ञापन छैन।'),
                        style: TextStyle(
                            color: context.appColors.slate700, fontSize: 14),
                      ),
                    );
                  }
                  return Column(
                    children: myJobs.map((job) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  JobApplicantsScreen(job: job),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: context.appColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: context.appColors.slate100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          job.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: context.appColors.slate900,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${job.location} • Rs. ${job.wage}/day',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: context.appColors.slate700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  StreamBuilder<List<JobApplication>>(
                                    stream: FirebaseService.instance
                                        .getApplicationsForJob(job.id),
                                    builder: (context, appSnapshot) {
                                      final count =
                                          appSnapshot.data?.length ?? 0;
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE8F0FE),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '$count applicants',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            color: context.appColors.blue600,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              if (job.status == 'closed')
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _t('Applications Closed', 'आवेदन बन्द भयो'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: context.appColors.red500,
                                    ),
                                  ),
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: OutlinedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text(_t('Close Applications?',
                                              'आवेदन बन्द गर्ने?')),
                                          content: Text(_t(
                                              'Are you sure you want to stop accepting applications for this job? Existing applicants will not be affected.',
                                              'के तपाईं यो कामको लागि थप आवेदनहरू बन्द गर्न निश्चित हुनुहुन्छ? पुराना आवेदनहरू मेटिने छैनन्।')),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: Text(_t(
                                                  'Cancel', 'रद्द गर्नुहोस्')),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    context.appColors.red500,
                                                foregroundColor:
                                                    context.appColors.white,
                                              ),
                                              onPressed: () async {
                                                Navigator.pop(ctx);
                                                await FirebaseService.instance
                                                    .closeJob(job.id);
                                              },
                                              child: Text(_t(
                                                  'Close', 'बन्द गर्नुहोस्')),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: context.appColors.red500,
                                      side: BorderSide(
                                          color: context.appColors.red200),
                                      minimumSize: Size(double.infinity, 36),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      _t('Close Applications',
                                          'आवेदन बन्द गर्नुहोस्'),
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              SizedBox(height: 8),

              // Browse workers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _t('Browse Available Workers', 'नजिकैका उपलब्ध कामदारहरू'),
                    style: _sectionStyle,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          context.appColors.emerald500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'VERIFIED ID',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: context.appColors.emerald600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...store.workers.map((worker) {
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.appColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.appColors.slate100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  worker.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: context.appColors.slate900,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: context.appColors.slate100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        worker.mainSkill.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: context.appColors.slate600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '• ${worker.experience} exp',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: context.appColors.slate700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: context.appColors.emerald50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Rs. ${worker.expectedWage}/day',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: context.appColors.emerald600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      _t('Invitation to apply sent successfully!',
                                          'निमन्त्रणा पठाइयो!'),
                                    ),
                                    backgroundColor:
                                        context.appColors.emerald500,
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: context.appColors.slate100,
                                foregroundColor: context.appColors.slate800,
                                side: BorderSide.none,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _t('Invite to Job', 'कामको लागि बोलाउनुहोस्'),
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _startCall(worker.name, worker.phone),
                            icon: Icon(Icons.call_rounded, size: 14),
                            label: Text(_t('Call', 'कल')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.appColors.emerald500,
                              foregroundColor: context.appColors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  TextStyle get _sectionStyle => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
        color: context.appColors.slate600,
      );

  // ---------------------------------------------------------------------
  // POST JOB TAB
  // ---------------------------------------------------------------------
  Widget _buildPostTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appColors.slate100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add_rounded, color: context.appColors.blue600),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _t('Publish New Advertisement',
                        'नयाँ कामको विज्ञापन थप्नुहोस्'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: context.appColors.slate900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _formLabel(_t('Job Title', 'कामको शीर्षक')),
            const SizedBox(height: 6),
            TextField(
              controller: _postTitleController,
              style: TextStyle(
                  color: context.appColors.slate900,
                  fontWeight: FontWeight.w600),
              decoration:
                  _formDecoration(hint: 'e.g. Mason for House Brick laying'),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _formLabel(_t('Category', 'कामको विधा')),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: store.postCategory,
                        isExpanded: true,
                        decoration: _formDecoration(),
                        style: TextStyle(
                            color: context.appColors.slate900,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                        icon: Icon(Icons.arrow_drop_down,
                            color: context.appColors.slate900),
                        dropdownColor: context.appColors.white,
                        items: kSkillCategories
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                    skillShortLabel(c, store.lang),
                                    style: TextStyle(
                                        color: context.appColors.slate900),
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) store.setPostCategory(v);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _formLabel(_t('Daily Wage', 'ज्याला (प्रतिदिन)')),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _postWageController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                            color: context.appColors.slate900,
                            fontWeight: FontWeight.w600),
                        decoration: _formDecoration(),
                        onChanged: (v) {
                          store.setPostWage(int.tryParse(v) ?? 1000);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _formLabel(_t('Location', 'ठेगाना')),
            const SizedBox(height: 6),
            TextField(
              controller: _postLocController,
              style: TextStyle(
                  color: context.appColors.slate900,
                  fontWeight: FontWeight.w600),
              decoration: _formDecoration(
                  hint:
                      _t('📍  Type location...', '📍  स्थान लेख्नुहोस्...')),
            ),
            const SizedBox(height: 14),
            _formLabel(_t('Details', 'विवरण')),
            const SizedBox(height: 6),
            TextField(
              controller: _postDescController,
              maxLines: 3,
              style: TextStyle(
                  color: context.appColors.slate900,
                  fontWeight: FontWeight.w600),
              decoration:
                  _formDecoration(hint: 'Describe exact requirements...'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (store.activeEmployer?.verificationStatus == 'pending') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Your account is waiting for admin verification.'),
                      backgroundColor: context.appColors.red500,
                    ),
                  );
                  return;
                }
                if (store.activeEmployer?.verificationStatus == 'inactive') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Your account is blocked/inactive.'),
                      backgroundColor: context.appColors.red500,
                    ),
                  );
                  return;
                }

                store.setPostTitle(_postTitleController.text);
                store.setPostDesc(_postDescController.text);
                store.setPostLocation(_postLocController.text.trim());
                if (store.postTitle.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Job title is required'),
                      backgroundColor: context.appColors.red500,
                    ),
                  );
                  return;
                }
                if (store.postLocation.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_t('Please enter the job location.',
                          'कृपया कामको स्थान लेख्नुहोस्।')),
                      backgroundColor: context.appColors.red500,
                    ),
                  );
                  return;
                }
                store.postJob();
                _postTitleController.clear();
                _postDescController.clear();
                _postLocController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_t(
                        'Job posted successfully!', 'काम सफलतापूर्वक थपियो!')),
                    backgroundColor: context.appColors.emerald500,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.appColors.slate900,
                foregroundColor: context.appColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _t('Publish Live Ad', 'काम प्रकाशित गर्नुहोस्'),
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
        color: context.appColors.slate900,
      ),
    );
  }

  InputDecoration _formDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14, color: context.appColors.slate600),
      filled: true,
      fillColor: context.appColors.slate50,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.appColors.slate200),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // APPLICANTS TAB
  // ---------------------------------------------------------------------
  Widget _buildApplicantsTab() {
    if (store.applications.isEmpty) {
      return Center(
        child: Text(
          'No applicants yet.',
          style: TextStyle(fontSize: 14, color: context.appColors.slate600),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: store.applications.length,
      itemBuilder: (context, index) {
        final app = store.applications[index];
        final jobs = store.jobs.where((j) => j.id == app.jobId).toList();
        final jobInfo = jobs.isNotEmpty ? jobs.first : null;
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.appColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.appColors.slate100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.workerName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: context.appColors.slate900,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text.rich(
                          TextSpan(
                            text: 'Applied to: ',
                            style: TextStyle(
                                fontSize: 13,
                                color: context.appColors.slate700),
                            children: [
                              TextSpan(
                                text: jobInfo?.title ?? 'N/A',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: context.appColors.slate700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(app.status),
                ],
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.appColors.slate50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _meta('CATEGORY', app.workerSkill.toUpperCase()),
                    ),
                    Expanded(
                      child: _meta('EXPECTED WAGE', 'Rs. 1,200/day'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (app.status == 'pending') ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            store.updateApplicantStatus(app.id, 'rejected'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.appColors.red500,
                          backgroundColor: context.appColors.slate100,
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          _t('Reject', 'अस्वीकार'),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            store.updateApplicantStatus(app.id, 'accepted'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.appColors.emerald500,
                          foregroundColor: context.appColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          _t('Accept', 'स्वीकार गर्नुहोस्'),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _startCall(app.workerName, app.workerPhone),
                      icon: Icon(Icons.call_rounded, size: 14),
                      label: Text(_t('Call', 'फोन')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.appColors.slate900,
                        foregroundColor: context.appColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusBadge(String status) {
    final (color, bg, border) = switch (status) {
      'accepted' => (
          context.appColors.emerald600,
          context.appColors.emerald500.withValues(alpha: 0.1),
          context.appColors.emerald500.withValues(alpha: 0.2)
        ),
      'rejected' => (
          context.appColors.red500,
          context.appColors.red500.withValues(alpha: 0.1),
          context.appColors.red500.withValues(alpha: 0.2)
        ),
      _ => (
          context.appColors.slate500,
          context.appColors.slate100,
          context.appColors.slate200
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Text(
        status.toUpperCase(),
        style:
            TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Widget _meta(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: context.appColors.slate600,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: context.appColors.slate700,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // CHAT TAB
  // ---------------------------------------------------------------------
  Widget _buildChatTab() {
    if (store.activeChatChannel != null) {
      return _buildChatConversation(store.activeChatChannel!);
    }
    final activeEmployer = store.activeEmployer;
    if (activeEmployer == null) {
      return const Center(child: Text('No employer found'));
    }

    return StreamBuilder<List<Conversation>>(
      stream: ChatService.instance
          .getConversationsForUser(activeEmployer.id, 'employer'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error loading chats',
                  style: TextStyle(color: context.appColors.red500)));
        }

        final conversations = snapshot.data ?? [];
        if (conversations.isEmpty) {
          return Center(
              child: Text(_t('No active chats yet.', 'कुनै च्याट छैन।'),
                  style: TextStyle(color: context.appColors.slate700)));
        }

        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text(
              _t('Your Chat Inbox', 'मेरो च्याटहरू'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: context.appColors.slate900,
              ),
            ),
            const SizedBox(height: 12),
            ...conversations.map((conv) {
              final user = conv.workerName;
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: context.appColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.appColors.slate100),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        context.appColors.indigo600.withValues(alpha: 0.1),
                    child: Text(
                      user.isNotEmpty ? user.characters.first : '?',
                      style: TextStyle(
                        color: context.appColors.indigo600,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        user,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: context.appColors.slate900,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    conv.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13, color: context.appColors.slate700),
                  ),
                  onTap: () => store.setActiveChatChannel(conv.id),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildChatConversation(String conversationId) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          color: context.appColors.slate900,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_rounded,
                    color: context.appColors.slate300, size: 20),
                onPressed: () => store.setActiveChatChannel(null),
              ),
              Expanded(
                child: Text(
                  _t('Conversation', 'च्याट'),
                  style: TextStyle(
                    color: context.appColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Message>>(
            stream: ChatService.instance.getMessages(conversationId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final messages = snapshot.data ?? [];
              return ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: messages.length,
                itemBuilder: (context, index) => _chatBubble(messages[index]),
              );
            },
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            children: [
              _presetChip(
                  _t('When can you start?', 'तपाईं कहिले आउन सक्नुहुन्छ?')),
              _presetChip(
                  _t('Quality work is expected.', 'काम राम्रो गर्नुपर्छ।')),
              _presetChip(
                  _t('Wages will be Rs. 1200.', 'ज्याला १२ सय दिनेछु।')),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          color: context.appColors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: _t('Type message...', 'सन्देश लेख्नुहोस्...'),
                    hintStyle: TextStyle(
                        fontSize: 14, color: context.appColors.slate600),
                    filled: true,
                    fillColor: context.appColors.slate50,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: context.appColors.slate200),
                    ),
                  ),
                  onSubmitted: (_) => _sendChat(conversationId),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _sendChat(conversationId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appColors.indigo600,
                  foregroundColor: context.appColors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: const CircleBorder(),
                ),
                child: const Icon(Icons.send_rounded, size: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendChat(String conversationId) {
    if (_chatController.text.trim().isEmpty) return;
    ChatService.instance.sendMessage(
        conversationId, store.activeEmployer!.id, _chatController.text);
    _chatController.clear();
  }

  Widget _presetChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => _chatController.text = label,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: context.appColors.slate100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.appColors.slate200),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.appColors.slate700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _chatBubble(Message msg) {
    final isUser = msg.senderId == store.activeEmployer!.id;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 2),
            padding: EdgeInsets.all(12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? context.appColors.indigo600
                  : context.appColors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              border:
                  isUser ? null : Border.all(color: context.appColors.slate200),
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: isUser
                    ? context.appColors.white
                    : context.appColors.slate800,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              msg.timestamp != null
                  ? "${msg.timestamp!.hour}:${msg.timestamp!.minute.toString().padLeft(2, '0')}"
                  : 'Now',
              style: TextStyle(fontSize: 13, color: context.appColors.slate600),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // PROFILE TAB
  // ---------------------------------------------------------------------
  Widget _buildProfileTab() {
    final active = store.activeEmployer;
    if (active == null) {
      return const Center(child: Text('No profile found.'));
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Brand header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.appColors.brandBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: 0.785,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: context.appColors.white, width: 2),
                        ),
                        child: Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: context.appColors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ROJGAR FINDER',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: context.appColors.slate900,
                      ),
                    ),
                    Text(
                      'रोजगार खोजकर्ता • Nepal',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.appColors.slate700),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.appColors.blue600.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: context.appColors.emerald500,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'ONLINE',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: context.appColors.blue600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        if (_editingProfile)
          _buildEmployerEditForm(active)
        else
          _buildEmployerProfileCard(active),

        // Settings header
        Row(
          children: [
            Icon(Icons.settings_rounded,
                size: 14, color: context.appColors.slate700),
            SizedBox(width: 6),
            Text(
              'Profile & System Settings',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: context.appColors.slate900,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),

        _buildSettingsCard(),

        SizedBox(height: 16),

        // Logout
        OutlinedButton(
          onPressed: _logout,
          style: OutlinedButton.styleFrom(
            foregroundColor: context.appColors.red500,
            backgroundColor: context.appColors.red50,
            side: BorderSide(color: context.appColors.red200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text(
            'LOGOUT ACCOUNT (बाहिर निस्कनुहोस्)',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
        ),
      ],
    );
  }

  void _logout() {
    store.setPhone('');
    store.setUserId('');
    store.setRole(null);
    store.setEmployerTab('jobs');
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Widget _buildEmployerProfileCard(EmployerProfile localActive) {
    return StreamBuilder<EmployerProfile?>(
      stream: FirebaseService.instance.streamEmployerProfile(localActive.id),
      builder: (context, snapshot) {
        final active = snapshot.data ?? localActive;

        final statusColor = active.verificationStatus == 'verified'
            ? context.appColors.emerald700
            : active.verificationStatus == 'pending'
                ? Colors.orange
                : context.appColors.red700;
        final statusBg = active.verificationStatus == 'verified'
            ? context.appColors.emerald500.withValues(alpha: 0.15)
            : active.verificationStatus == 'pending'
                ? Colors.orange.withValues(alpha: 0.15)
                : context.appColors.red500.withValues(alpha: 0.15);

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.appColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.appColors.slate200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (active.profilePhoto.isNotEmpty)
                    ClipOval(
                      child: Image.network(
                        active.profilePhoto,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _avatar(active.name, 48),
                      ),
                    )
                  else
                    _avatar(active.name, 48),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                active.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: context.appColors.slate900,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                active.verificationStatus.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${active.role} • ${active.companyName}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: context.appColors.slate600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Divider(height: 1, color: context.appColors.slate100),
              const SizedBox(height: 12),
              _row(_t('Phone Number', 'मोबाइल नम्बर'), '+977 ${active.phone}'),
              _row(_t('Main Location', 'मुख्य स्थान'), active.location),
              if (active.governmentIds != null && active.governmentIds!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_t('Submitted Government IDs:', 'पेश गरिएका सरकारी परिचय-पत्रहरू:'),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.appColors.slate800)),
                    const SizedBox(height: 4),
                    ...active.governmentIds!.entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text('🛡️ ${e.key.toUpperCase()}: ${e.value['idNumber'] ?? ''}',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.appColors.slate700)),
                        )),
                    const SizedBox(height: 6),
                  ],
                )
              else
                _row(
                  _t('Government Verification ID', 'सरकारी परिचय-पत्र'),
                  active.govIdNum.isEmpty
                      ? 'N/A'
                      : '${active.govIdType.toUpperCase()} - ${active.govIdNum}',
                  valueColor: context.appColors.blue600,
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  _editDraft = active;
                  setState(() => _editingProfile = true);
                },
                icon: Text('✏️', style: TextStyle(fontSize: 14)),
                label: Text(
                  _t('Edit Profile Information',
                      'प्रोफाइल विवरण परिमार्जन गर्नुहोस्'),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.appColors.brandBlue,
                  backgroundColor: context.appColors.slate50,
                  side: BorderSide(color: context.appColors.slate200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => UpdateKycDialog(
                      collection: 'employers',
                      userId: active.id,
                      currentGovIdType: active.govIdType,
                      currentGovIdNum: active.govIdNum,
                    ),
                  );
                },
                icon: Icon(Icons.shield_outlined, size: 14),
                label: Text(
                  _t('Update KYC', 'KYC अपडेट गर्नुहोस्'),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.appColors.slate700,
                  backgroundColor: context.appColors.white,
                  side: BorderSide(color: context.appColors.slate300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _avatar(String name, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.appColors.slate200,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name.characters.first.toUpperCase() : '?',
          style: TextStyle(
            color: context.appColors.slate600,
            fontSize: size * 0.45,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.appColors.slate600,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: valueColor ?? context.appColors.slate800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployerEditForm(EmployerProfile active) {
    final nameC = TextEditingController(text: _editDraft.name);
    final phoneC = TextEditingController(text: _editDraft.phone);
    final roleC = TextEditingController(text: _editDraft.role);
    final locC = TextEditingController(text: _editDraft.location);
    final companyC = TextEditingController(text: _editDraft.companyName);
    final govTypeC = TextEditingController(text: _editDraft.govIdType);
    final govNumC = TextEditingController(text: _editDraft.govIdNum);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                onPressed: () => setState(() => _editingProfile = false),
              ),
              SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('Edit Profile Info', 'प्रोफाइल सम्पादन'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: context.appColors.slate900,
                    ),
                  ),
                  Text(
                    _t('Update your identity details',
                        'विवरण परिमार्जन गर्नुहोस्'),
                    style: TextStyle(
                        fontSize: 13, color: context.appColors.slate600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _editField(_t('Full Name', 'रोजगारदाताको नाम'), nameC),
          const SizedBox(height: 10),
          _editField(_t('Phone Number', 'सम्पर्क नम्बर'), phoneC),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _editField(_t('Role', 'भूमिका'), roleC)),
              const SizedBox(width: 8),
              Expanded(child: _editField(_t('Location', 'स्थान'), locC)),
            ],
          ),
          const SizedBox(height: 10),
          _editField(_t('Company Name', 'कम्पनी / फर्म'), companyC),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _editField(_t('Gov ID Type', 'ID प्रकार'), govTypeC)),
              const SizedBox(width: 8),
              Expanded(
                  child: _editField(_t('Gov ID Number', 'ID नम्बर'), govNumC)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _editingProfile = false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.appColors.slate700,
                    backgroundColor: context.appColors.slate100,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    _t('Cancel', 'रद्द'),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (nameC.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Name is required'),
                          backgroundColor: context.appColors.red500,
                        ),
                      );
                      return;
                    }
                    store.updateEmployerProfile({
                      'name': nameC.text.trim(),
                      'phone': phoneC.text.trim(),
                      'role': roleC.text.trim(),
                      'location': locC.text.trim(),
                      'companyName': companyC.text.trim().isNotEmpty
                          ? companyC.text.trim()
                          : 'Individual',
                      'govIdType': govTypeC.text.trim(),
                      'govIdNum': govNumC.text.trim(),
                      'profilePhoto': active.profilePhoto,
                    }, active.id);
                    setState(() => _editingProfile = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.appColors.brandBlue,
                    foregroundColor: context.appColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    _t('Save', 'सुरक्षित गर्नुहोस्'),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _editField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: context.appColors.slate600,
          ),
        ),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: context.appColors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.appColors.slate200),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.slate200),
      ),
      child: Column(
        children: [
          _settingRow(
            title: _t('Application Language', 'एपको भाषा'),
            subtitle: _t('Change app interface language', 'एपको लागि भाषा चयन'),
            child: _segmentedLang(),
          ),
          Divider(height: 20, color: context.appColors.slate50),
          _settingRow(
            title: _t('Application Theme', 'एपको थिम'),
            subtitle:
                _t('Light, Dark, or System theme', 'लाइट, डार्क वा सिस्टम थिम'),
            child: _segmentedTheme(),
          ),
          Divider(height: 20, color: context.appColors.slate50),
          _settingRow(
            title: _t('Voice Assistance Synthesizer', 'ध्वनि/आवाज सहायता'),
            subtitle:
                _t('Speak-aloud voice prompts', 'बोलेर कामदार खोज्ने सहायता'),
            child: _switch(
                store.voiceFeedbackEnabled, store.setVoiceFeedbackEnabled),
          ),
          Divider(height: 20, color: context.appColors.slate50),
          _settingRow(
            title: _t('Worker Match Audio Alerts', 'नयाँ कामदार मिलान सङ्केत'),
            subtitle: _t(
                'Sound alert on match discovery', 'सङ्केत ध्वनीहरू प्ले गर्ने'),
            child:
                _switch(store.soundAlertsEnabled, store.setSoundAlertsEnabled),
          ),
        ],
      ),
    );
  }

  Widget _segmentedTheme() {
    final options = [
      (id: 'light', en: 'Light', ne: 'लाइट'),
      (id: 'dark', en: 'Dark', ne: 'डार्क'),
      (id: 'system', en: 'System', ne: 'सिस्टम'),
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: options.map((o) {
        final active = store.themePref == o.id;
        return GestureDetector(
          onTap: () => store.setThemePref(o.id),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: active ? context.appColors.brandBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _isNe ? o.ne : o.en,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: active
                    ? context.appColors.white
                    : context.appColors.slate500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _segmentedLang() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ['en', 'ne'].map((id) {
        final active = store.lang == id;
        final label = id == 'en' ? 'English' : 'नेपाली';
        return GestureDetector(
          onTap: () => store.setLang(id),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: active ? context.appColors.brandBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: active
                    ? context.appColors.white
                    : context.appColors.slate500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _switch(bool value, ValueChanged<bool> onChanged) {
    return Switch(
      value: value,
      activeThumbColor: context.appColors.emerald500,
      onChanged: onChanged,
    );
  }

  Widget _settingRow({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: context.appColors.slate800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.slate600,
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}
