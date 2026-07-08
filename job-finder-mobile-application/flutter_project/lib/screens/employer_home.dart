import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class EmployerHomeScreen extends StatefulWidget {
  const EmployerHomeScreen({Key? key}) : super(key: key);

  @override
  State<EmployerHomeScreen> createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen> {
  bool _isVerified = true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _wageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedCategory = 'mason';

  // State mock collections
  final List<Map<String, dynamic>> _myJobs = [
    {
      'id': 'job-1',
      'title': 'Daily Wage Brick Mason Needed',
      'category': 'mason',
      'wage': 1200,
      'location': 'Balkumari, Lalitpur',
      'applicantsCount': 1,
    }
  ];

  final List<Map<String, dynamic>> _applicants = [
    {
      'id': 'app-1',
      'workerName': 'Hari Bahadur Shrestha',
      'workerSkill': 'Mason / Bricklayer',
      'workerPhone': '9845551122',
      'workerExperience': '5 Years',
      'workerWage': 'Rs. 1,200/day',
      'status': 'pending',
      'jobTitle': 'Daily Wage Brick Mason Needed',
    }
  ];

  void _postJob(String lang) {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _myJobs.add({
        'id': 'job-${DateTime.now().millisecondsSinceEpoch}',
        'title': _titleController.text,
        'category': _selectedCategory,
        'wage': int.tryParse(_wageController.text) ?? 1000,
        'location': _locationController.text,
        'applicantsCount': 0,
      });

      // Clear form
      _titleController.clear();
      _wageController.clear();
      _locationController.clear();
      _descController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          lang == 'ne' 
            ? 'काम सफलतापूर्वक थपियो! यो अब सार्वजनिक फिडमा देखिन्छ।' 
            : 'Job posted successfully! It is now live in the worker feed.'
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _updateApplicantStatus(int index, String status, String lang) {
    setState(() {
      _applicants[index]['status'] = status;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          lang == 'ne' 
            ? 'आवेदकको स्थिति अद्यावधिक गरियो।' 
            : 'Applicant status updated to: $status.'
        ),
        backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
      ),
    );
  }

  void _callNumber(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ModalRoute.of(context)!.settings.arguments as String? ?? 'en';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          foregroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang == 'ne' ? 'रोजगारदाता ड्यासबोर्ड' : 'Employer Dashboard',
                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Row(
                children: [
                  const Icon(Icons.verified, color: Color(0xFF10B981), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    lang == 'ne' ? 'प्रमाणित रोजगारदाता' : 'Verified Employer',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF10B981)),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/role-selection', arguments: lang);
              },
              icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
              label: Text(
                lang == 'ne' ? 'भूमिका बदल्नुहोस्' : 'Switch Role',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
          bottom: TabBar(
            indicatorColor: const Color(0xFF10B981),
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFF94A3B8),
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: lang == 'ne' ? 'काम थप्नुहोस्' : 'Post a Job'),
              Tab(text: lang == 'ne' ? 'आवेदकहरू' : 'Applicants'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Post Job Form & Active jobs list
            _buildPostJobTab(lang),
            // Tab 2: Applicant Management
            _buildApplicantsTab(lang),
          ],
        ),
      ),
    );
  }

  Widget _buildPostJobTab(String lang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Post Job Card Form
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      lang == 'ne' ? 'नयाँ कामको विज्ञापन हाल्नुहोस्' : 'Create New Job Listing',
                      style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 16),
                    
                    // Title
                    TextFormField(
                      controller: _titleController,
                      validator: (val) => val == null || val.isEmpty ? 'Title required' : null,
                      decoration: InputDecoration(
                        labelText: lang == 'ne' ? 'कामको शीर्षक (उदा: घर रंगाउने पेन्टर)' : 'Job Title (e.g. House Painter)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Wage
                    TextFormField(
                      controller: _wageController,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Wage required' : null,
                      decoration: InputDecoration(
                        labelText: lang == 'ne' ? 'दैनिक ज्याला (रु.)' : 'Daily Wage (NPR)',
                        prefixText: 'Rs. ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Location
                    TextFormField(
                      controller: _locationController,
                      validator: (val) => val == null || val.isEmpty ? 'Location required' : null,
                      decoration: InputDecoration(
                        labelText: lang == 'ne' ? 'काम गर्ने ठेगाना (उदा: बालकुमारी)' : 'Job Location (e.g. Balkumari)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: lang == 'ne' ? 'विवरण र सुविधाहरू' : 'Description & Benefits',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit
                    ElevatedButton(
                      onPressed: () => _postJob(lang),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        lang == 'ne' ? 'काम प्रकाशित गर्नुहोस्' : 'Publish Job Advertisement',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // My Posted Jobs Heading
          Text(
            lang == 'ne' ? 'तपाईंका सक्रिय कामहरू' : 'Your Live Job Advertisements',
            style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF475569)),
          ),
          const SizedBox(height: 12),

          // Render Live Posted Jobs
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _myJobs.length,
            itemBuilder: (context, index) {
              final job = _myJobs[index];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
                ),
                elevation: 0,
                child: ListTile(
                  title: Text(job['title'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  subtitle: Text('${job['location']} • Rs. ${job['wage']}/day', style: const TextStyle(color: Color(0xFF64748B))),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF0F172A).withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      '${job['applicantsCount']} applicants',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantsTab(String lang) {
    if (_applicants.isEmpty) {
      return Center(
        child: Text(
          lang == 'ne' ? 'कुनै आवेदकहरू छैनन्।' : 'No applicants yet.',
          style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
        ),
      );
    }

    return ListView.builder(
      itemCount: _applicants.length,
      padding: const EdgeInsets.all(20),
      itemBuilder: (context, index) {
        final app = _applicants[index];
        final isPending = app['status'] == 'pending';

        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    Text(
                      app['workerName'],
                      style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: app['status'] == 'accepted'
                            ? const Color(0xFF10B981).withOpacity(0.1)
                            : app['status'] == 'rejected'
                                ? Colors.red.withOpacity(0.1)
                                : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        app['status'].toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: app['status'] == 'accepted'
                              ? const Color(0xFF10B981)
                              : app['status'] == 'rejected'
                                  ? Colors.red
                                  : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Applied For: ${app['jobTitle']}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Skill / सिप', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                        Text(app['workerSkill'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Experience / अनुभव', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                        Text(app['workerExperience'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    // Action Buttons (Accept/Reject)
                    if (isPending) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _updateApplicantStatus(index, 'rejected', lang),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFF1F5F9)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            lang == 'ne' ? 'अस्वीकार' : 'Reject',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _updateApplicantStatus(index, 'accepted', lang),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            lang == 'ne' ? 'स्वीकार गर्नुहोस्' : 'Accept Applicant',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    
                    // Call Direct
                    IconButton.filledTonal(
                      onPressed: () => _callNumber(app['workerPhone']),
                      icon: const Icon(Icons.call, color: Color(0xFF0F172A)),
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
