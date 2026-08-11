import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/job.dart';
import '../models/job_application.dart';
import '../models/conversation.dart';
import '../services/chat_service.dart';
import '../models/worker_profile.dart';
import '../services/app_store.dart';
import '../theme/app_colors.dart';
import '../services/firebase_service.dart';
import '../widgets/update_kyc_dialog.dart';
import 'job_details_sheet.dart';
import 'phone_dialer.dart';

/// Mirrors the React `WORKER HOME` screen (Jobs / Applications / Chat / Profile).
class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  AppStore get store => AppStore.instance;

  bool _editingProfile = false;
  late WorkerProfile _editDraft;

  bool get _isNe => store.lang == 'ne';

  String _t(String en, String ne) => _isNe ? ne : en;

  // ---------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------
  void _showJobDetails(Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JobDetailsSheet(job: job),
    );
  }

  void _startCall(String name, String phone) {
    store.setCallingName(name);
    store.setCallingPhone(phone);
    showPhoneDialer(context, name: name, phone: phone).then((_) {
      store.setCallingPhone(null);
      store.setCallingName(null);
    });
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------
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
                child: switch (store.workerTab) {
                  'jobs' => _buildJobsTab(),
                  'applications' => _buildApplicationsTab(),
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
        id: 'applications',
        icon: Icons.assignment_rounded,
        label: _t('Applications', 'आवेदन')
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
          final isActive = store.workerTab == tab.id;
          return Expanded(
            child: InkWell(
              onTap: () => store.setWorkerTab(tab.id),
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
                          ? context.appColors.brandBlue
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: context.appColors.white,
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
                        _t('Find Jobs', 'काम खोज्नुहोस्'),
                        style: TextStyle(
                          color: context.appColors.emerald400,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Lalitpur / Kathmandu',
                    style: TextStyle(
                        color: context.appColors.slate300, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Search + view toggle
        Container(
          padding: EdgeInsets.all(12),
          color: context.appColors.white,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: context.appColors.slate100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded,
                          size: 18, color: context.appColors.slate500),
                      SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: _t('Search jobs...', 'काम खोज्नुहोस्...'),
                            hintStyle: TextStyle(
                                fontSize: 14,
                                color: context.appColors.slate500),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: TextStyle(
                              fontSize: 14, color: context.appColors.slate900),
                          onChanged: (v) => store.setSearchQuery(v),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => store.setIsMapView(!store.isMapView),
                tooltip: store.isMapView ? 'List View' : 'Map View',
                style: IconButton.styleFrom(
                  backgroundColor: context.appColors.emerald500,
                  foregroundColor: context.appColors.white,
                ),
                icon: Icon(
                  store.isMapView ? Icons.list_rounded : Icons.map_rounded,
                  size: 18,
                ),
              ),
            ],
          ),
        ),

        // Category chips
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: [
              _chip('all', _t('All', 'सबै काम')),
              ...kSkillCategories.map(
                  (cat) => _chip(cat.id, skillShortLabel(cat, store.lang))),
            ],
          ),
        ),

        // List / Map content
        Expanded(
          child: StreamBuilder<List<Job>>(
            stream: FirebaseService.instance.streamActiveJobs(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final firebaseJobs = snapshot.data ?? [];

              // Apply existing filters: category, location, wage, search
              final filtered = firebaseJobs.where((job) {
                if (store.selectedCategory != 'all' &&
                    job.category != store.selectedCategory) {
                  return false;
                }
                if (store.selectedLocationFilter != 'all' &&
                    store.selectedLocationFilter != 'any') {
                  if (job.location.toLowerCase() !=
                      store.selectedLocationFilter.toLowerCase()) {
                    return false;
                  }
                }
                if (job.wage > store.maxWageFilter) return false;
                if (store.searchQuery.trim().isNotEmpty) {
                  final q = store.searchQuery.toLowerCase();
                  if (!job.title.toLowerCase().contains(q) &&
                      !job.location.toLowerCase().contains(q) &&
                      !job.description.toLowerCase().contains(q)) {
                    return false;
                  }
                }
                return true;
              }).toList();

              return store.isMapView
                  ? _buildMapView(filtered)
                  : _buildJobFeed(filtered);
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(String id, String label) {
    final active = store.selectedCategory == id;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => store.setSelectedCategory(id),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? context.appColors.slate900
                : context.appColors.slate100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: active
                    ? context.appColors.white
                    : context.appColors.slate600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapView(List<Job> jobs) {
    return Container(
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.appColors.slate200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.slate300),
      ),
      child: Stack(
        children: [
          // dotted "map" background
          Positioned.fill(
            child: CustomPaint(
              painter: _DottedGridPainter(),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.appColors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.appColors.slate200),
              ),
              child: Text(
                '📍 ${_t('Nearby Jobs on Map', 'नक्सामा नजिकैका कामहरू')}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.slate700,
                ),
              ),
            ),
          ),
          if (jobs.isNotEmpty) _mapPin(Alignment(0.3, -0.25), jobs[0]),
          if (jobs.length > 1) _mapPin(Alignment(-0.3, 0.25), jobs[1]),
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Text(
              _t('Tap on the map pins to view job details',
                  'नक्साको पिनमा थिचेर जागिरको विवरण हेर्नुहोस्'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: context.appColors.slate700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapPin(Alignment alignment, Job job) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: () => _showJobDetails(job),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: context.appColors.slate900,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.appColors.emerald500, width: 2),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on_rounded,
                  color: context.appColors.emerald400, size: 12),
              Text(
                'Rs. ${job.wage}',
                style: TextStyle(
                  color: context.appColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobFeed(List<Job> jobs) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 32, color: context.appColors.slate300),
            SizedBox(height: 8),
            Text(
              _t('No jobs matches your filters.', 'कुनै पनि काम भेटिएन।'),
              style: TextStyle(fontSize: 14, color: context.appColors.slate600),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: jobs.length,
      itemBuilder: (context, index) => _jobCard(jobs[index]),
    );
  }

  Widget _jobCard(Job job) {
    final active = store.activeWorker;
    return StreamBuilder<List<JobApplication>>(
      stream: active != null 
          ? FirebaseService.instance.getApplicationsForWorker(active.id)
          : const Stream.empty(),
      builder: (context, snapshot) {
        final applications = snapshot.data ?? [];
        final isApplied = applications.any((app) => app.jobId == job.id);
        final myApp = applications.where((app) => app.jobId == job.id).toList();
        final status = myApp.isNotEmpty ? myApp.first.status : null;

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.appColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.appColors.slate100),
            boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 6)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                      job.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: context.appColors.slate900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 12, color: context.appColors.slate600),
                        SizedBox(width: 4),
                        Text(
                          job.location,
                          style: TextStyle(
                              fontSize: 13, color: context.appColors.slate700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.appColors.emerald500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color:
                          context.appColors.emerald500.withValues(alpha: 0.2)),
                ),
                child: Text(
                  'Rs. ${job.wage}/d',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.emerald500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            job.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: context.appColors.slate700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showJobDetails(job),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: context.appColors.slate100,
                    foregroundColor: context.appColors.slate800,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _t('View Details', 'विवरण हेर्नुहोस्'),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: isApplied
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: status == 'accepted'
                              ? context.appColors.emerald500
                                  .withValues(alpha: 0.1)
                              : status == 'rejected'
                                  ? context.appColors.red500
                                      .withValues(alpha: 0.1)
                                  : context.appColors.slate100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: status == 'accepted'
                                  ? context.appColors.emerald600
                                  : status == 'rejected'
                                      ? context.appColors.red500
                                      : context.appColors.slate500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              status == 'accepted'
                                  ? _t('ACCEPTED', 'स्वीकृत')
                                  : status == 'rejected'
                                      ? _t('DECLINED', 'अस्वीकृत')
                                      : _t('PENDING', 'अपेक्षित'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: status == 'accepted'
                                    ? context.appColors.emerald600
                                    : status == 'rejected'
                                        ? context.appColors.red500
                                        : context.appColors.slate500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : job.status == 'closed'
                        ? Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: context.appColors.slate100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _t('Applications Closed', 'आवेदन बन्द भयो'),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: context.appColors.slate700,
                              ),
                            ),
                          )
                        : StreamBuilder<WorkerProfile?>(
                            stream: FirebaseService.instance
                                .streamWorkerProfile(
                                    store.activeWorker?.id ?? ''),
                            builder: (context, snapshot) {
                              final currentStatus =
                                  snapshot.data?.verificationStatus ??
                                      store.activeWorker?.verificationStatus;
                              return ElevatedButton(
                                onPressed: () {
                                  if (currentStatus == 'pending') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Your profile is waiting for admin verification.'),
                                        backgroundColor:
                                            context.appColors.red500,
                                      ),
                                    );
                                    return;
                                  }
                                  if (currentStatus == 'inactive' ||
                                      currentStatus == 'blocked') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Your account is blocked/inactive.'),
                                        backgroundColor:
                                            context.appColors.red500,
                                      ),
                                    );
                                    return;
                                  }
                                  store.applyForJob(job);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.appColors.emerald500,
                                  foregroundColor: context.appColors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _t('One-Tap Apply', 'आवेदन दिनुहोस्'),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                              );
                            }),
              ),
            ],
          ),
        ],
      ),
    );
      },
    );
  }

  // ---------------------------------------------------------------------
  // APPLICATIONS TAB
  // ---------------------------------------------------------------------
  Widget _buildApplicationsTab() {
    final active = store.activeWorker;
    if (active == null) return const SizedBox.shrink();

    return StreamBuilder<List<JobApplication>>(
      stream: FirebaseService.instance.getApplicationsForWorker(active.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final myApps = snapshot.data ?? [];

        if (myApps.isEmpty) {
          return Center(
            child: Text(
              _t('No submitted applications yet. Use one-tap apply!',
                  'कुनै आवेदन छैन। एक-ट्याप अप्लाई प्रयोग गर्नुहोस्!'),
              style: TextStyle(fontSize: 14, color: context.appColors.slate600),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: myApps.length,
          itemBuilder: (context, index) {
            final app = myApps[index];
            return FutureBuilder<Job?>(
              future: FirebaseService.instance.getJob(app.jobId),
              builder: (context, jobSnapshot) {
                final jobInfo = jobSnapshot.data;
                final isLoading = jobSnapshot.connectionState == ConnectionState.waiting;
                final status = app.status;

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
                                if (isLoading)
                                  const SizedBox(
                                    height: 16,
                                    width: 100,
                                    child: LinearProgressIndicator(),
                                  )
                                else
                                  Text(
                                    jobInfo?.title ?? 'Unknown Job',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: context.appColors.slate900,
                                    ),
                                  ),
                                SizedBox(height: 2),
                                if (!isLoading)
                                  Text.rich(
                                    TextSpan(
                                      text: _t('Employer: ', 'रोजगारदाता: '),
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: context.appColors.slate700),
                                      children: [
                                        TextSpan(
                                          text: jobInfo?.employerName ?? 'N/A',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: context.appColors.slate900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          _statusBadge(status),
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
                              child: _Meta(
                                  label: _t('Location', 'ठेगाना').toUpperCase(),
                                  value: jobInfo?.location ?? 'Nepal'),
                            ),
                            Expanded(
                              child: _Meta(
                                label: _t('Offered Wage', 'प्रस्तावित ज्याला')
                                    .toUpperCase(),
                                value: 'Rs. ${jobInfo?.wage ?? 1200}/day',
                                valueColor: context.appColors.emerald600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (status == 'accepted') ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _startCall(
                              jobInfo?.employerName ?? 'Contractor',
                              jobInfo?.employerPhone ?? '9851044321',
                            ),
                            icon: Icon(Icons.call_rounded, size: 14),
                            label: Text(
                              _t('Call Employer Now', 'रोजगारदातालाई कल गर्नुहोस्'),
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.appColors.emerald500,
                              foregroundColor: context.appColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
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

  // ---------------------------------------------------------------------
  // CHAT TAB
  // ---------------------------------------------------------------------
  Widget _buildChatTab() {
    if (store.activeChatChannel != null) {
      return _buildChatConversation(store.activeChatChannel!);
    }
    return _buildChatInbox();
  }

  Widget _buildChatInbox() {
    final activeWorker = store.activeWorker;
    if (activeWorker == null) {
      return const Center(child: Text('No worker profile found'));
    }

    return StreamBuilder<List<Conversation>>(
      stream: ChatService.instance
          .getConversationsForUser(activeWorker.id, 'worker'),
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
              child: Text('No chats available',
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
              final user = conv.employerName;
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
        // Header
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
        // Messages
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
        // Presets
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            children: [
              _presetChip(
                  _t('I am ready for the work.', 'म काम गर्न तयार छु।')),
              _presetChip(_t('Where is the exact location?', 'स्थान कहाँ हो?')),
              _presetChip(_t(
                  'I will arrive tomorrow morning.', 'म भोलि बिहान आउनेछु।')),
            ],
          ),
        ),
        // Input
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

  final TextEditingController _chatController = TextEditingController();

  void _sendChat(String conversationId) {
    if (_chatController.text.trim().isEmpty) return;
    ChatService.instance.sendMessage(
        conversationId, store.activeWorker!.id, _chatController.text);
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
    final isUser = msg.senderId == store.activeWorker!.id;
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
    final active = store.activeWorker;
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
                    color: context.appColors.emerald600,
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
                      'ROJGAR WORKER',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: context.appColors.slate900,
                      ),
                    ),
                    Text(
                      'कामदार पोर्टल • Nepal',
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
                color: context.appColors.emerald500.withValues(alpha: 0.1),
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
                      color: context.appColors.emerald600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        if (_editingProfile)
          _buildWorkerEditForm(active)
        else
          _buildWorkerProfileCard(active),

        SizedBox(height: 16),

        // Settings header
        Row(
          children: [
            Icon(Icons.settings_rounded,
                size: 14, color: context.appColors.slate700),
            SizedBox(width: 6),
            Text(
              _t('Profile & System Settings',
                  'प्रणाली सेटिंग्स र प्राथमिकताहरू'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: context.appColors.slate900,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),

        // Settings card
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
    store.setWorkerTab('jobs');
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Widget _buildWorkerProfileCard(WorkerProfile localActive) {
    return StreamBuilder<WorkerProfile?>(
      stream: FirebaseService.instance.streamWorkerProfile(localActive.id),
      builder: (context, snapshot) {
        final active = snapshot.data ?? localActive;
        final statusColor = active.verificationStatus == 'verified'
            ? context.appColors.emerald700
            : active.verificationStatus == 'pending'
                ? Colors.orange
                : context.appColors.red500;
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
                        errorBuilder: (_, __, ___) => _avatar(
                            active.name, 48, context.appColors.emerald500),
                      ),
                    )
                  else
                    _avatar(active.name, 48, context.appColors.emerald500),
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
                            SizedBox(width: 6),
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
                          '${active.mainSkill.toUpperCase()} • ${active.experience} Exp',
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
              _row(_t('Location', 'स्थान'), active.location),
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
                  _t('Govt Verification ID', 'सरकारी परिचय-पत्र'),
                  active.govIdNum.isNotEmpty
                      ? '🛡️ ${active.govIdType.toUpperCase()} - ${active.govIdNum}'
                      : _t('Not Provided', 'सत्यापन आवश्यक'),
                  valueColor: active.govIdNum.isNotEmpty
                      ? context.appColors.slate800
                      : context.appColors.emerald700,
                ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
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
                style: ElevatedButton.styleFrom(
                  foregroundColor: context.appColors.white,
                  backgroundColor: context.appColors.slate900,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => UpdateKycDialog(
                      collection: 'workers',
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
                style: ElevatedButton.styleFrom(
                  foregroundColor: context.appColors.white,
                  backgroundColor: context.appColors.slate900,
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

  Widget _avatar(String name, double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          name.isNotEmpty ? name.characters.first.toUpperCase() : '?',
          style: TextStyle(
            color: context.appColors.white,
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
                color: context.appColors.slate600),
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

  Widget _buildWorkerEditForm(WorkerProfile active) {
    final nameC = TextEditingController(text: _editDraft.name);
    final phoneC = TextEditingController(text: _editDraft.phone);
    final locC = TextEditingController(text: _editDraft.location);
    final skillC = TextEditingController(text: _editDraft.mainSkill);
    final expC = TextEditingController(text: _editDraft.experience);
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
                    _t('Update your worker details',
                        'विवरण परिमार्जन गर्नुहोस्'),
                    style: TextStyle(
                        fontSize: 13, color: context.appColors.slate600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _editField(_t('Full Name', 'कामदारको नाम'), nameC),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child:
                      _editField(_t('Phone Number', 'सम्पर्क नम्बर'), phoneC)),
              const SizedBox(width: 8),
              Expanded(
                  child: _editField(_t('Gov ID Type', 'ID प्रकार'), govTypeC)),
              const SizedBox(width: 8),
              Expanded(
                  child: _editField(_t('Gov ID Number', 'ID नम्बर'), govNumC)),
            ],
          ),
          const SizedBox(height: 10),
          _editField(_t('Location', 'स्थान'), locC),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _editField(
                      _t('Primary Skill / Role', 'मुख्य सिप / भूमिका'),
                      skillC)),
              const SizedBox(width: 8),
              Expanded(child: _editField(_t('Experience', 'अनुभव'), expC)),
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
                    store.updateWorkerProfile({
                      'name': nameC.text.trim(),
                      'phone': phoneC.text.trim(),
                      'location': locC.text.trim(),
                      'mainSkill': skillC.text.trim(),
                      'experience': expC.text.trim(),
                      'govIdType': govTypeC.text.trim(),
                      'govIdNum': govNumC.text.trim(),
                      'profilePhoto': active.profilePhoto,
                    }, active.id);
                    setState(() => _editingProfile = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.appColors.emerald500,
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
          // Theme
          _settingRow(
            title: _t('Application Theme', 'एपको थिम'),
            subtitle:
                _t('Light, Dark, or System theme', 'लाइट, डार्क वा सिस्टम थिम'),
            child: _segmentedTheme(),
          ),
          Divider(height: 20, color: context.appColors.slate50),
          // Language
          _settingRow(
            title: _t('Application Language', 'एपको भाषा'),
            subtitle: _t('Change app interface language', 'एपको लागि भाषा चयन'),
            child: _segmentedLang(),
          ),
          Divider(height: 20, color: context.appColors.slate50),
          // Voice feedback
          _settingRow(
            title: _t('Voice Assistance Synthesizer', 'ध्वनि/आवाज सहायता'),
            subtitle:
                _t('Speak-aloud voice prompts', 'बोलेर कामदार खोज्ने सहायता'),
            child: _switch(
                store.voiceFeedbackEnabled, store.setVoiceFeedbackEnabled),
          ),
          Divider(height: 20, color: context.appColors.slate50),
          // Sound alerts
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

class _Meta extends StatelessWidget {
  const _Meta({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
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
            color: valueColor ?? context.appColors.slate700,
          ),
        ),
      ],
    );
  }
}

class _DottedGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    const step = 16.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
