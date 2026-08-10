import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/job.dart';
import '../models/job_application.dart';
import '../models/worker_profile.dart';
import '../services/app_store.dart';
import '../services/firebase_service.dart';
import '../services/chat_service.dart';
import '../theme/app_colors.dart';

class JobApplicantsScreen extends StatelessWidget {
  final Job job;

  const JobApplicantsScreen({super.key, required this.job});

  bool get _isNe => AppStore.instance.lang == 'ne';
  String _t(String en, String ne) => _isNe ? ne : en;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.slate50,
      appBar: AppBar(
        backgroundColor: context.appColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: context.appColors.slate900),
        title: Text(
          _t('Job Applicants', 'कामदारहरूको आवेदन'),
          style: GoogleFonts.spaceGrotesk(
            color: context.appColors.slate900,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: StreamBuilder<List<JobApplication>>(
        stream: FirebaseService.instance.getApplicationsForJob(job.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final applications = snapshot.data ?? [];
          if (applications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search_rounded,
                      size: 64, color: context.appColors.slate300),
                  SizedBox(height: 16),
                  Text(
                    _t('No applicants yet.', 'कुनै आवेदन आएको छैन।'),
                    style: TextStyle(
                      color: context.appColors.slate700,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              return _ApplicantCard(
                application: applications[index],
                isNe: _isNe,
              );
            },
          );
        },
      ),
    );
  }
}

class _ApplicantCard extends StatefulWidget {
  final JobApplication application;
  final bool isNe;

  const _ApplicantCard({
    required this.application,
    required this.isNe,
  });

  @override
  State<_ApplicantCard> createState() => _ApplicantCardState();
}

class _ApplicantCardState extends State<_ApplicantCard> {
  String _t(String en, String ne) => widget.isNe ? ne : en;
  bool _isProcessing = false;

  Future<void> _updateStatus(String status) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      await FirebaseService.instance
          .updateApplicationStatus(widget.application.id, status);
      if (status == 'accepted' && AppStore.instance.activeEmployer != null) {
        final updatedApp = widget.application.copyWith(status: status);
        await ChatService.instance
            .createConversation(updatedApp, AppStore.instance.activeEmployer!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'),
            backgroundColor: context.appColors.red500),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WorkerProfile?>(
      future: FirebaseService.instance
          .getWorkerProfile(widget.application.workerId),
      builder: (context, snapshot) {
        final worker = snapshot.data;
        final name = worker?.name ?? widget.application.workerName;
        final skill = worker?.mainSkill ?? widget.application.workerSkill;
        final location = worker?.location ?? 'N/A';
        final exp = worker?.experience ?? 'N/A';
        final photo = worker?.profilePhoto;

        return Container(
          margin: EdgeInsets.only(bottom: 16),
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
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: context.appColors.slate200,
                    backgroundImage: (photo != null && photo.isNotEmpty)
                        ? (photo.startsWith('http')
                            ? NetworkImage(photo)
                            : null) as ImageProvider?
                        : null,
                    child: (photo == null || photo.isEmpty)
                        ? Icon(Icons.person,
                            color: context.appColors.slate600, size: 28)
                        : null,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.appColors.slate900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${skill.toUpperCase()} • $exp',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.appColors.slate700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 12, color: context.appColors.slate600),
                            SizedBox(width: 4),
                            Text(
                              location,
                              style: TextStyle(
                                fontSize: 14,
                                color: context.appColors.slate700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (widget.application.status == 'pending')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => _updateStatus('rejected'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.appColors.red600,
                          side: BorderSide(color: context.appColors.red200),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(_t('Reject', 'अस्वीकार गर्नुहोस्')),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => _updateStatus('accepted'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.appColors.emerald600,
                          foregroundColor: context.appColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isProcessing
                            ? SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: context.appColors.white),
                              )
                            : Text(_t('Accept', 'स्वीकार गर्नुहोस्')),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: widget.application.status == 'accepted'
                        ? context.appColors.emerald50
                        : context.appColors.red50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.application.status == 'accepted'
                        ? _t('Accepted', 'स्वीकृत')
                        : _t('Rejected', 'अस्वीकृत'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.application.status == 'accepted'
                          ? context.appColors.emerald700
                          : context.appColors.red700,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
