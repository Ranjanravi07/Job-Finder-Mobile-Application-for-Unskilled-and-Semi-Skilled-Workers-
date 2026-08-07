import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/job.dart';
import '../models/chat_message.dart';
import '../models/worker_profile.dart';
import '../services/app_store.dart';
import '../theme/app_colors.dart';
import 'job_details_sheet.dart';
import 'phone_dialer.dart';

/// Mirrors the React `WORKER HOME` screen (Jobs / Applications / Chat / Profile).
class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({Key? key}) : super(key: key);

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
      backgroundColor: AppColors.slate50,
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
      (id: 'jobs', icon: Icons.business_center_rounded, label: _t('Jobs', 'कामहरू')),
      (id: 'applications', icon: Icons.assignment_rounded, label: _t('Applications', 'आवेदन')),
      (id: 'chat', icon: Icons.chat_bubble_rounded, label: _t('Chat', 'च्याट')),
      (id: 'profile', icon: Icons.settings_rounded, label: _t('Profile', 'प्रोफाइल')),
    ];

    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.slate100)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFE8F0FE) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      tab.icon,
                      size: 20,
                      color: isActive ? AppColors.brandBlue : AppColors.slate400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tab.label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                      color: isActive ? AppColors.slate900 : AppColors.slate500,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppColors.slate900,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.business_center_rounded,
                          color: AppColors.emerald400, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _t('Find Jobs', 'काम खोज्नुहोस्'),
                        style: const TextStyle(
                          color: AppColors.emerald400,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Lalitpur / Kathmandu',
                    style: TextStyle(color: AppColors.slate300, fontSize: 10),
                  ),
                ],
              ),
              // Employer mode switch
              TextButton(
                onPressed: () {
                  store.setRole('employer');
                  Navigator.pushReplacementNamed(context, '/employer-home');
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white10,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: Text(
                  _t('Employer Mode', 'रोजगारदाता मोड'),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),

        // Search + view toggle
        Container(
          padding: const EdgeInsets.all(12),
          color: AppColors.slate900.withValues(alpha: 0.95),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 18, color: AppColors.slate400),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: _t('Search jobs...', 'काम खोज्नुहोस्...'),
                            hintStyle: const TextStyle(fontSize: 12, color: AppColors.slate400),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 12, color: AppColors.slate800),
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
                  backgroundColor: AppColors.emerald500,
                  foregroundColor: Colors.white,
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
              ...kSkillCategories.map((cat) => _chip(cat.id, skillShortLabel(cat, store.lang))),
            ],
          ),
        ),

        // List / Map content
        Expanded(
          child: store.isMapView ? _buildMapView() : _buildJobFeed(),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppColors.slate900 : AppColors.slate100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : AppColors.slate600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapView() {
    final jobs = store.jobs;
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.slate200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate300),
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Text(
                '📍 ${_t('Nearby Jobs on Map', 'नक्सामा नजिकैका कामहरू')}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate500,
                ),
              ),
            ),
          ),
          if (jobs.isNotEmpty) _mapPin(const Alignment(0.3, -0.25), jobs[0]),
          if (jobs.length > 1) _mapPin(const Alignment(-0.3, 0.25), jobs[1]),
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Text(
              _t('Tap on the map pins to view job details', 'नक्साको पिनमा थिचेर जागिरको विवरण हेर्नुहोस्'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: AppColors.slate500,
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.slate900,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.emerald500, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.emerald400, size: 12),
              Text(
                'Rs. ${job.wage}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobFeed() {
    final jobs = store.filteredJobs;
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 32, color: AppColors.slate300),
            const SizedBox(height: 8),
            Text(
              _t('No jobs matches your filters.', 'कुनै पनि काम भेटिएन।'),
              style: const TextStyle(fontSize: 12, color: AppColors.slate400),
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
    final isApplied = store.applications.any((app) => app.jobId == job.id);
    final myApp = store.applications.where((app) => app.jobId == job.id).toList();
    final status = myApp.isNotEmpty ? myApp.first.status : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 6)],
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
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: AppColors.slate400),
                        const SizedBox(width: 4),
                        Text(
                          job.location,
                          style: const TextStyle(fontSize: 10, color: AppColors.slate500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emerald500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.emerald500.withValues(alpha: 0.2)),
                ),
                child: Text(
                  'Rs. ${job.wage}/d',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.emerald500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            job.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.slate500,
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
                    backgroundColor: AppColors.slate100,
                    foregroundColor: AppColors.slate800,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _t('View Details', 'विवरण हेर्नुहोस्'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
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
                              ? AppColors.emerald500.withValues(alpha: 0.1)
                              : status == 'rejected'
                                  ? AppColors.red500.withValues(alpha: 0.1)
                                  : AppColors.slate100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: status == 'accepted'
                                  ? AppColors.emerald600
                                  : status == 'rejected'
                                      ? AppColors.red500
                                      : AppColors.slate500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              status == 'accepted'
                                  ? _t('ACCEPTED', 'स्वीकृत')
                                  : status == 'rejected'
                                      ? _t('DECLINED', 'अस्वीकृत')
                                      : _t('PENDING', 'अपेक्षित'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: status == 'accepted'
                                    ? AppColors.emerald600
                                    : status == 'rejected'
                                        ? AppColors.red500
                                        : AppColors.slate500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () => store.applyForJob(job.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.emerald500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _t('One-Tap Apply', 'आवेदन दिनुहोस्'),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // APPLICATIONS TAB
  // ---------------------------------------------------------------------
  Widget _buildApplicationsTab() {
    final active = store.activeWorker;
    final myApps = store.applications
        .where((app) => app.workerId == active?.id)
        .toList();

    if (myApps.isEmpty) {
      return const Center(
        child: Text(
          'No submitted applications yet. Use one-tap apply!',
          style: TextStyle(fontSize: 12, color: AppColors.slate400),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myApps.length,
      itemBuilder: (context, index) {
        final app = myApps[index];
        final job = store.jobs.where((j) => j.id == app.jobId).toList();
        final jobInfo = job.isNotEmpty ? job.first : null;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.slate100),
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
                          jobInfo?.title ?? 'Unknown Job',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppColors.slate900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text.rich(
                          TextSpan(
                            text: _t('Employer: ', 'रोजगारदाता: '),
                            style: const TextStyle(fontSize: 10, color: AppColors.slate500),
                            children: [
                              TextSpan(
                                text: jobInfo?.employerName ?? 'N/A',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slate700,
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
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _Meta(label: _t('Location', 'ठेगाना').toUpperCase(), value: jobInfo?.location ?? 'Nepal'),
                    ),
                    Expanded(
                      child: _Meta(
                        label: _t('Offered Wage', 'प्रस्तावित ज्याला').toUpperCase(),
                        value: 'Rs. ${jobInfo?.wage ?? 1200}/day',
                        valueColor: AppColors.emerald600,
                      ),
                    ),
                  ],
                ),
              ),
              if (app.status == 'accepted') ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _startCall(
                      jobInfo?.employerName ?? 'Contractor',
                      jobInfo?.employerPhone ?? '9851044321',
                    ),
                    icon: const Icon(Icons.call_rounded, size: 14),
                    label: Text(
                      _t('Call Employer Now', 'रोजगारदातालाई कल गर्नुहोस्'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald500,
                      foregroundColor: Colors.white,
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
  }

  Widget _statusBadge(String status) {
    final (color, bg, border) = switch (status) {
      'accepted' => (AppColors.emerald600, AppColors.emerald500.withValues(alpha: 0.1), AppColors.emerald500.withValues(alpha: 0.2)),
      'rejected' => (AppColors.red500, AppColors.red500.withValues(alpha: 0.1), AppColors.red500.withValues(alpha: 0.2)),
      _ => (AppColors.slate500, AppColors.slate100, AppColors.slate200),
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
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color),
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
    const channels = ['Ravi Ranjan Sah', 'Ajay Kumar Sah'];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          _t('Your Chat Inbox', 'मेरो च्याटहरू'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppColors.slate900,
          ),
        ),
        const SizedBox(height: 12),
        ...channels.map((user) {
          final msgs = store.chatMessages[user] ?? [];
          final lastMsg = msgs.isNotEmpty ? msgs.last : null;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate100),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.indigo600.withValues(alpha: 0.1),
                child: Text(
                  user.characters.first,
                  style: const TextStyle(
                    color: AppColors.indigo600,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    user,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.slate900,
                    ),
                  ),
                  Text(
                    lastMsg?.time ?? 'Now',
                    style: const TextStyle(fontSize: 9, color: AppColors.slate400),
                  ),
                ],
              ),
              subtitle: Text(
                lastMsg?.text ?? 'No messages yet.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: AppColors.slate500),
              ),
              onTap: () => store.setActiveChatChannel(user),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildChatConversation(String channel) {
    final messages = store.chatMessages[channel] ?? [];
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          color: AppColors.slate900,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.slate300, size: 20),
                onPressed: () => store.setActiveChatChannel(null),
              ),
              Expanded(
                child: Text(
                  channel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.emerald500,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Messages
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: messages.length,
            itemBuilder: (context, index) => _chatBubble(messages[index]),
          ),
        ),
        // Presets
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            children: [
              _presetChip(_t('I am ready for the work.', 'म काम गर्न तयार छु।')),
              _presetChip(_t('Where is the exact location?', 'स्थान कहाँ हो?')),
              _presetChip(_t('I will arrive tomorrow morning.', 'म भोलि बिहान आउनेछु।')),
            ],
          ),
        ),
        // Input
        Container(
          padding: const EdgeInsets.all(10),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: _t('Type message...', 'सन्देश लेख्नुहोस्...'),
                    hintStyle: const TextStyle(fontSize: 12, color: AppColors.slate400),
                    filled: true,
                    fillColor: AppColors.slate50,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: AppColors.slate200),
                    ),
                  ),
                  onChanged: (v) => store.setNewMsgText(v),
                  onSubmitted: (_) => _sendChat(channel),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _sendChat(channel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.indigo600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  void _sendChat(String channel) {
    store.setNewMsgText(_chatController.text);
    store.sendChatMessage(channel);
    _chatController.clear();
  }

  Widget _presetChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => _chatController.text = label,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.slate100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.slate700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _chatBubble(ChatMessage msg) {
    final isUser = msg.sender == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 2),
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isUser ? AppColors.indigo600 : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              border: isUser ? null : Border.all(color: AppColors.slate200),
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: isUser ? Colors.white : AppColors.slate800,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              msg.time,
              style: const TextStyle(fontSize: 9, color: AppColors.slate400),
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
      padding: const EdgeInsets.all(16),
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
                  decoration: const BoxDecoration(
                    color: AppColors.emerald600,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: 0.785,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ROJGAR WORKER',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.slate900,
                      ),
                    ),
                    Text(
                      'कामदार पोर्टल • Nepal',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.slate500),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.emerald500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.emerald500,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'ONLINE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.emerald600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_editingProfile)
          _buildWorkerEditForm(active)
        else
          _buildWorkerProfileCard(active),

        const SizedBox(height: 16),

        // Settings header
        Row(
          children: [
            const Icon(Icons.settings_rounded, size: 14, color: AppColors.slate500),
            const SizedBox(width: 6),
            Text(
              _t('Profile & System Settings', 'प्रणाली सेटिंग्स र प्राथमिकताहरू'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.slate900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Settings card
        _buildSettingsCard(),

        const SizedBox(height: 16),

        // Logout
        OutlinedButton(
          onPressed: _logout,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.red500,
            backgroundColor: AppColors.red50,
            side: const BorderSide(color: AppColors.red200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text(
            'LOGOUT ACCOUNT (बाहिर निस्कनुहोस्)',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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

  Widget _buildWorkerProfileCard(WorkerProfile active) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
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
                    errorBuilder: (_, __, ___) => _avatar(active.name, 48, AppColors.emerald500),
                  ),
                )
              else
                _avatar(active.name, 48, AppColors.emerald500),
              const SizedBox(width: 12),
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
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.slate900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.emerald500.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'VERIFIED',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: AppColors.emerald700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${active.mainSkill.toUpperCase()} • ${active.experience} Exp',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppColors.slate400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.slate100),
          const SizedBox(height: 12),
          _row(_t('Phone Number', 'मोबाइल नम्बर'), '+977 ${active.phone}'),
          _row(_t('Location', 'स्थान'), active.location),
          _row(
            _t('Govt Verification ID', 'सरकारी परिचय-पत्र'),
            active.govId.isNotEmpty ? '🛡️ ${active.govId}' : _t('Not Provided', 'सत्यापन आवश्यक'),
            valueColor: active.govId.isNotEmpty ? AppColors.slate800 : AppColors.emerald700,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              _editDraft = active;
              setState(() => _editingProfile = true);
            },
            icon: const Text('✏️', style: TextStyle(fontSize: 12)),
            label: Text(
              _t('Edit Profile Information', 'प्रोफाइल विवरण परिमार्जन गर्नुहोस्'),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.emerald600,
              backgroundColor: AppColors.slate50,
              side: const BorderSide(color: AppColors.slate200),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
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
            color: Colors.white,
            fontSize: size * 0.45,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.slate400),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: valueColor ?? AppColors.slate800,
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
    final govC = TextEditingController(text: _editDraft.govId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
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
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('Edit Profile Info', 'प्रोफाइल सम्पादन'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.slate900,
                    ),
                  ),
                  Text(
                    _t('Update your worker details', 'विवरण परिमार्जन गर्नुहोस्'),
                    style: const TextStyle(fontSize: 9, color: AppColors.slate400),
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
              Expanded(child: _editField(_t('Phone Number', 'सम्पर्क नम्बर'), phoneC)),
              const SizedBox(width: 8),
              Expanded(child: _editField(_t('Government ID', 'सरकारी परिचय-पत्र'), govC)),
            ],
          ),
          const SizedBox(height: 10),
          _editField(_t('Location', 'स्थान'), locC),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _editField(_t('Primary Skill / Role', 'मुख्य सिप / भूमिका'), skillC)),
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
                    foregroundColor: AppColors.slate700,
                    backgroundColor: AppColors.slate100,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    _t('Cancel', 'रद्द'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (nameC.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Name is required'),
                          backgroundColor: AppColors.red500,
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
                      'govId': govC.text.trim(),
                      'profilePhoto': active.profilePhoto,
                    }, active.id);
                    setState(() => _editingProfile = false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    _t('Save', 'सुरक्षित गर्नुहोस्'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
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
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: AppColors.slate400,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.slate200),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          // Theme
          _settingRow(
            title: _t('Application Theme', 'एपको थिम'),
            subtitle: _t('Light, Dark, or System theme', 'लाइट, डार्क वा सिस्टम थिम'),
            child: _segmentedTheme(),
          ),
          const Divider(height: 20, color: AppColors.slate50),
          // Language
          _settingRow(
            title: _t('Application Language', 'एपको भाषा'),
            subtitle: _t('Change app interface language', 'एपको लागि भाषा चयन'),
            child: _segmentedLang(),
          ),
          const Divider(height: 20, color: AppColors.slate50),
          // Voice feedback
          _settingRow(
            title: _t('Voice Assistance Synthesizer', 'ध्वनि/आवाज सहायता'),
            subtitle: _t('Speak-aloud voice prompts', 'बोलेर कामदार खोज्ने सहायता'),
            child: _switch(store.voiceFeedbackEnabled, store.setVoiceFeedbackEnabled),
          ),
          const Divider(height: 20, color: AppColors.slate50),
          // Sound alerts
          _settingRow(
            title: _t('Worker Match Audio Alerts', 'नयाँ कामदार मिलान सङ्केत'),
            subtitle: _t('Sound alert on match discovery', 'सङ्केत ध्वनीहरू प्ले गर्ने'),
            child: _switch(store.soundAlertsEnabled, store.setSoundAlertsEnabled),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: active ? AppColors.brandBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _isNe ? o.ne : o.en,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: active ? Colors.white : AppColors.slate500,
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: active ? AppColors.brandBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: active ? Colors.white : AppColors.slate500,
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
      activeThumbColor: AppColors.emerald500,
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
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.slate800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate400,
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
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: AppColors.slate400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: valueColor ?? AppColors.slate700,
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
