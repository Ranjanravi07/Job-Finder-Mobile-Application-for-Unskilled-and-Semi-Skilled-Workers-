import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({Key? key}) : super(key: key);

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  String _selectedCategory = 'all';
  bool _isMapView = false;
  String _searchQuery = '';
  
  // Track applied jobs locally
  final Map<String, String> _applicationStatuses = {
    'job-1': 'pending',
  };

  final List<Map<String, dynamic>> _jobs = [
    {
      'id': 'job-1',
      'title': 'Daily Wage Brick Mason Needed',
      'category': 'mason',
      'description': 'We need 3 experienced brick masons for a residential building construction in Balkumari. Lunch and tea will be provided at the site.',
      'wage': 1200,
      'location': 'Balkumari, Lalitpur',
      'employer': 'Ravi Ranjan Sah',
      'phone': '9841234567',
    },
    {
      'id': 'job-2',
      'title': 'House Painting Helpers Wanted',
      'category': 'painter',
      'description': 'Urgent requirement of 2 painters for high-quality exterior house painting. Brushes and safety gear provided. Wages paid daily.',
      'wage': 1000,
      'location': 'Gwarko, Lalitpur',
      'employer': 'Abdul Wahab Rain',
      'phone': '9803214567',
    },
    {
      'id': 'job-3',
      'title': 'Wiring Work for 3-Story Building',
      'category': 'electrician',
      'description': 'Complete wiring of a newly built house. Materials are on-site. Looking for an electrician with experience in Nepali standard boards.',
      'wage': 8000,
      'location': 'Sanepa, Lalitpur',
      'employer': 'Ajay Kumar Sah',
      'phone': '9851098765',
    },
    {
      'id': 'job-4',
      'title': 'Experienced Tipper Driver Needed',
      'category': 'driver',
      'description': 'Looking for a tipper driver with a valid heavy vehicle driving license for local site soil carrying. Must be honest and punctual.',
      'wage': 1500,
      'location': 'Kalanki, Kathmandu',
      'employer': 'Mohammad Faishal Rain',
      'phone': '9812345678',
    },
  ];

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'nameEn': 'All Jobs', 'nameNe': 'सबै काम'},
    {'id': 'mason', 'nameEn': 'Mason', 'nameNe': 'डकर्मी'},
    {'id': 'carpenter', 'nameEn': 'Carpenter', 'nameNe': 'सिकर्मी'},
    {'id': 'electrician', 'nameEn': 'Electrician', 'nameNe': 'बिजुली काम'},
    {'id': 'plumber', 'nameEn': 'Plumber', 'nameNe': 'प्लम्बर'},
    {'id': 'painter', 'nameEn': 'Painter', 'nameNe': 'पेन्टर'},
    {'id': 'driver', 'nameEn': 'Driver', 'nameNe': 'चालक'},
  ];

  void _applyForJob(String jobId, String lang) {
    setState(() {
      _applicationStatuses[jobId] = 'pending';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          lang == 'ne' 
            ? 'सफलतापूर्वक आवेदन गरियो! तपाईंको आवेदन प्रक्रियामा छ।' 
            : 'Applied successfully! Your application status is: Pending.'
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _callNumber(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Fallback
      debugPrint('Could not launch phone call to $phone');
    }
  }

  void _openWhatsApp(String phone) async {
    final Uri launchUri = Uri.parse("https://wa.me/977$phone");
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ModalRoute.of(context)!.settings.arguments as String? ?? 'en';

    final filteredJobs = _jobs.where((job) {
      if (_selectedCategory != 'all' && job['category'] != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty && 
          !job['title'].toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !job['location'].toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang == 'ne' ? 'जागिर खोज्नुहोस्' : 'Find Jobs',
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Text(
              'Balkumari, Lalitpur, Nepal',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        actions: [
          // Role switch button
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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search and View Toggle Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF0F172A),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: lang == 'ne' ? 'काम वा स्थान खोज्नुहोस्...' : 'Search jobs, locations...',
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Map/List toggle button
                IconButton.filled(
                  onPressed: () {
                    setState(() {
                      _isMapView = !_isMapView;
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(_isMapView ? Icons.list_rounded : Icons.map_rounded),
                ),
              ],
            ),
          ),

          // Skill Categories Slider
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      lang == 'ne' ? cat['nameNe']! : cat['nameEn']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF0F172A),
                    backgroundColor: const Color(0xFFF1F5F9),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat['id']!;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Job list or Map Mock view
          Expanded(
            child: _isMapView
                ? _buildMapViewMock(lang)
                : _buildJobList(filteredJobs, lang),
          ),
        ],
      ),
    );
  }

  Widget _buildMapViewMock(String lang) {
    return Container(
      color: const Color(0xFFE2E8F0),
      child: Stack(
        children: [
          // Grid pattern or static map representation
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map_rounded, size: 80, color: Color(0xFF94A3B8)),
                const SizedBox(height: 12),
                Text(
                  lang == 'ne' ? 'नजिकैका कामहरू नक्सामा हेर्नुहोस्' : 'Viewing Nearby Jobs on Map',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 4),
                const Text('Lalitpur, Nepal Area', style: TextStyle(color: Color(0xFF64748B))),
              ],
            ),
          ),
          // Interactive marker pins
          Positioned(
            left: 100,
            top: 150,
            child: _buildMapPin('job-1', 'Rs. 1,200', lang),
          ),
          Positioned(
            right: 120,
            top: 250,
            child: _buildMapPin('job-2', 'Rs. 1,000', lang),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPin(String jobId, String label, String lang) {
    final job = _jobs.firstWhere((j) => j['id'] == jobId);
    return GestureDetector(
      onTap: () => _showJobDetails(job, lang),
      child: Card(
        color: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded, color: Color(0xFF10B981), size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobList(List<Map<String, dynamic>> jobs, String lang) {
    if (jobs.isEmpty) {
      return Center(
        child: Text(
          lang == 'ne' ? 'काम भेटिएन।' : 'No jobs found in this category.',
          style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
        ),
      );
    }

    return ListView.builder(
      itemCount: jobs.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final job = jobs[index];
        final status = _applicationStatuses[job['id']];

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
                    Expanded(
                      child: Text(
                        job['title'],
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Rs. ${job['wage']}/day',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(job['location'], style: const TextStyle(color: Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  job['description'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF475569), fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // View details button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showJobDetails(job, lang),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          lang == 'ne' ? 'विवरण हेर्नुहोस्' : 'View Details',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Quick apply or show status
                    Expanded(
                      child: status == null
                          ? ElevatedButton(
                              onPressed: () => _applyForJob(job['id'], lang),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                lang == 'ne' ? 'तुरुन्त आवेदन' : 'Apply Now',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          : Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    lang == 'ne' ? 'आवेदन गरिएको' : 'Applied (Pending)',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569), fontSize: 12),
                                  ),
                                ],
                              ),
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

  void _showJobDetails(Map<String, dynamic> job, String lang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final status = _applicationStatuses[job['id']];

        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          job['title'],
                          style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                        ),
                      ),
                      // Text to Speech Voice Reader button
                      IconButton.filledTonal(
                        onPressed: () {
                          // Trigger speech simulation
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.volume_up_rounded, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      lang == 'ne' 
                                        ? 'पढ्दैछ: "${job['title']}. ज्याला दिनको ${job['wage']} रुपैया। ठेगाना ${job['location']}."'
                                        : 'Speaking: "${job['title']}. Wage is Rs. ${job['wage']} per day. Location is ${job['location']}."'
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF0F172A),
                            ),
                          );
                        },
                        icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.payments_outlined, color: Color(0xFF10B981)),
                        const SizedBox(width: 8),
                        Text(
                          'Rs. ${job['wage']} / ${lang == 'ne' ? 'प्रतिदिन' : 'Day'}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Job Details / विवरण', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(job['description'], style: const TextStyle(color: Color(0xFF475569), fontSize: 15, height: 1.5)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Text(job['location'], style: const TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Text(job['employer'], style: const TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Contact row
                  const Text('Direct Employer Connection / सिधा सम्पर्क', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _callNumber(job['phone']),
                          icon: const Icon(Icons.call, color: Colors.white),
                          label: Text(lang == 'ne' ? 'फोन गर्नुहोस्' : 'Direct Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openWhatsApp(job['phone']),
                          icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
                          label: const Text('WhatsApp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
