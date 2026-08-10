import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String role; // 'worker' or 'employer'
  
  const ProfileSetupScreen({Key? key, this.role = 'worker'}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  
  int _currentPage = 0;
  bool _isLoading = false;
  
  // Form controllers
  final _nameController = TextEditingController();
  final _nameNeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _locationNeController = TextEditingController();
  final _experienceController = TextEditingController();
  final _govIdNumberController = TextEditingController();
  
  String? _selectedSkill;
  String? _selectedIndustry;
  String? _selectedGovIdType;
  String? _profilePhotoUrl;
  String? _govIdImageUrl;
  
  // NEW: Job Category and Work Preferences
  String? _selectedJobCategory;
  String? _preferredLocation;
  String? _selectedWorkType;
  String? _selectedShift;
  String? _expectedSalary;
  
  // Job categories with icons
  final List<Map<String, dynamic>> _jobCategories = [
    {'id': 'laborer', 'icon': Icons.construction, 'nameEn': 'Laborer', 'nameNe': 'श्रमिक'},
    {'id': 'electrician', 'icon': Icons.electrical_services, 'nameEn': 'Electrician', 'nameNe': 'इलेक्ट्रिसियन'},
    {'id': 'plumber', 'icon': Icons.plumbing, 'nameEn': 'Plumber', 'nameNe': 'प्लम्बर'},
    {'id': 'driver', 'icon': Icons.drive_eta, 'nameEn': 'Driver', 'nameNe': 'चालक'},
    {'id': 'painter', 'icon': Icons.format_paint, 'nameEn': 'Painter', 'nameNe': 'पेन्टर'},
    {'id': 'carpenter', 'icon': Icons.handyman, 'nameEn': 'Carpenter', 'nameNe': 'सिकर्मी'},
    {'id': 'mason', 'icon': Icons.foundation, 'nameEn': 'Mason', 'nameNe': 'डकर्मी'},
    {'id': 'cleaner', 'icon': Icons.cleaning_services, 'nameEn': 'Cleaner', 'nameNe': 'सरसफाईकर्मी'},
    {'id': 'farmer', 'icon': Icons.agriculture, 'nameEn': 'Farmer', 'nameNe': 'किसान'},
    {'id': 'cook', 'icon': Icons.restaurant, 'nameEn': 'Cook', 'nameNe': 'बावु'},
    {'id': 'welder', 'icon': Icons.build_circle, 'nameEn': 'Welder', 'nameNe': 'वेल्डर'},
    {'id': 'tailor', 'icon': Icons.checkroom, 'nameEn': 'Tailor', 'nameNe': 'सिलाईकार'},
    {'id': 'other', 'icon': Icons.work, 'nameEn': 'Other', 'nameNe': 'अन्य'},
  ];
  
  // Work type options
  final List<Map<String, String>> _workTypes = [
    {'id': 'daily-wage', 'nameEn': 'Daily Wage', 'nameNe': 'दैनिक ज्याला'},
    {'id': 'full-time', 'nameEn': 'Full Time', 'nameNe': 'पूरा समय'},
    {'id': 'part-time', 'nameEn': 'Part Time', 'nameNe': 'आंशिक समय'},
    {'id': 'contract', 'nameEn': 'Contract', 'nameNe': 'ठेक्का'},
  ];
  
  // Shift preferences
  final List<Map<String, String>> _shiftOptions = [
    {'id': 'day', 'nameEn': 'Day Shift', 'nameNe': 'दिनको पाला'},
    {'id': 'night', 'nameEn': 'Night Shift', 'nameNe': 'रातको पाला'},
    {'id': 'flexible', 'nameEn': 'Flexible', 'nameNe': 'लचिलो'},
  ];
  
  // Popular locations in Nepal
  final List<String> _popularLocations = [
    'Kathmandu', 'Lalitpur', 'Bhaktapur', 'Pokhara', 'Biratnagar',
    'Birgunj', 'Butwal', 'Bharatpur', 'Hetauda', 'Dharan',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _nameNeController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _locationNeController.dispose();
    _experienceController.dispose();
    _govIdNumberController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final totalPages = widget.role == 'worker' ? 4 : 3;
    if (_currentPage < totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage--;
      });
    }
  }


  void _selectJobCategory(String category, String lang) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedJobCategory = category;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          lang == 'ne' 
            ? '${_jobCategories.firstWhere((c) => c['id'] == category)['nameNe']} छानियो'
            : '${_jobCategories.firstWhere((c) => c['id'] == category)['nameEn']} selected',
        ),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _submitProfile(String lang) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final userId = 'user-${DateTime.now().millisecondsSinceEpoch}';
    
    final success = await profileProvider.createProfile(
      userId: userId,
      phone: _phoneController.text.trim(),
      name: _nameController.text.trim(),
      nameNe: _nameNeController.text.trim().isNotEmpty ? _nameNeController.text.trim() : null,
      role: widget.role,
      skill: widget.role == 'worker' ? _selectedSkill : null,
      industry: widget.role == 'employer' ? _selectedIndustry : null,
      location: _locationController.text.trim(),
      locationNe: _locationNeController.text.trim().isNotEmpty ? _locationNeController.text.trim() : null,
      profilePhotoUrl: _profilePhotoUrl,
      governmentIdType: _selectedGovIdType,
      governmentIdNumber: _govIdNumberController.text.trim(),
      governmentIdImageUrl: _govIdImageUrl,
      experience: _experienceController.text.trim().isNotEmpty ? _experienceController.text.trim() : null,
      jobCategory: _selectedJobCategory,
      preferredLocation: _preferredLocation,
      workType: _selectedWorkType,
      expectedSalary: _expectedSalary,
      shiftPreference: _selectedShift,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      final route = widget.role == 'worker' ? '/worker-home' : '/employer-home';
      Navigator.pushReplacementNamed(context, route, arguments: lang);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang == 'ne' ? 'प्रोफाइल सफलतापूर्वक सिर्जना गरियो!' : 'Profile created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang == 'ne' ? 'प्रोफाइल सिर्जना गर्न असफल।' : 'Failed to create profile.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final lang = ModalRoute.of(context)!.settings.arguments as String? ?? 'en';
    final isWorker = widget.role == 'worker';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lang == 'ne' 
            ? (isWorker ? 'कामदार प्रोफाइल सेटअप' : 'रोजगारदाता प्रोफाइल सेटअप')
            : (isWorker ? 'Worker Profile Setup' : 'Employer Profile Setup'),
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(lang),
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: isWorker
                  ? [
                      _buildBasicInfoPage(lang, isWorker),
                      _buildJobCategoryPage(lang),
                      _buildWorkPreferencesPage(lang),
                      _buildPhotoIdPage(lang),
                    ]
                  : [
                      _buildBasicInfoPage(lang, isWorker),
                      _buildPhotoIdPage(lang),
                    ],
              ),
            ),
          ),
          _buildNavigationButtons(lang),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String lang) {
    final totalPages = widget.role == 'worker' ? 4 : 2;
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: List.generate(totalPages, (index) {
          final isCompleted = index < _currentPage;
          final isCurrent = index == _currentPage;
          
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent 
                        ? const Color(0xFF10B981) 
                        : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < totalPages - 1) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }


  Widget _buildBasicInfoPage(String lang, bool isWorker) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            lang == 'ne' ? 'व्यक्तिगत जानकारी' : 'Personal Information',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: _nameController,
            validator: (val) => val == null || val.isEmpty 
              ? (lang == 'ne' ? 'नाम आवश्यक छ' : 'Name is required') 
              : null,
            decoration: InputDecoration(
              labelText: lang == 'ne' ? 'नाम (अंग्रेजीमा)' : 'Full Name (in English)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _nameNeController,
            decoration: InputDecoration(
              labelText: lang == 'ne' ? 'नाम (नेपालीमा) - वैकल्पिक' : 'Full Name (in Nepali) - Optional',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: (val) {
              if (val == null || val.isEmpty) {
                return lang == 'ne' ? 'फोन नम्बर आवश्यक छ' : 'Phone number is required';
              }
              if (val.length != 10) {
                return lang == 'ne' ? '१० अंकको फोन नम्बर हाल्नुहोस्' : 'Enter 10-digit phone number';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: lang == 'ne' ? 'मोबाइल नम्बर' : 'Mobile Number',
              prefixText: '+977 ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          if (isWorker) ...[
            TextFormField(
              controller: _experienceController,
              decoration: InputDecoration(
                labelText: lang == 'ne' ? 'अनुभव (उदा: ५ वर्ष)' : 'Experience (e.g., 5 Years)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }


  // NEW: Job Category Page with Large Cards
  Widget _buildJobCategoryPage(String lang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            lang == 'ne' ? 'तपाईं के काम गर्नुहुन्छ?' : 'What work do you do?',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lang == 'ne' ? 'एउटा छान्नुहोस्' : 'Select one category',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
          const SizedBox(height: 20),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _jobCategories.length,
            itemBuilder: (context, index) {
              final category = _jobCategories[index];
              final isSelected = _selectedJobCategory == category['id'];
              
              return GestureDetector(
                onTap: () => _selectJobCategory(category['id'] as String, lang),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                        ? const Color(0xFF10B981)
                        : const Color(0xFFE2E8F0),
                      width: isSelected ? 2.5 : 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          size: 28,
                          color: isSelected 
                            ? Colors.white
                            : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lang == 'ne' 
                          ? category['nameNe'] as String
                          : category['nameEn'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected 
                            ? const Color(0xFF10B981)
                            : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  // NEW: Work Preferences Page
  Widget _buildWorkPreferencesPage(String lang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            lang == 'ne' ? 'कहाँ र कसरी काम गर्न चाहनुहुन्छ?' : 'Where and how do you want to work?',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 24),

          // Preferred Location
          Text(
            lang == 'ne' ? '🟢 रुचाइएको स्थान' : '🟢 Preferred Location',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularLocations.map((location) {
              final isSelected = _preferredLocation == location;
              return FilterChip(
                selected: isSelected,
                label: Text(location),
                selectedColor: const Color(0xFF10B981).withOpacity(0.2),
                checkmarkColor: const Color(0xFF10B981),
                onSelected: (selected) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _preferredLocation = selected ? location : null;
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              labelText: lang == 'ne' ? 'वा अन्य स्थान लेख्नुहोस्' : 'Or type custom location',
              prefixIcon: const Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (val) {
              if (val.isNotEmpty) {
                setState(() {
                  _preferredLocation = val;
                });
              }
            },
          ),
          const SizedBox(height: 24),

          // Work Type
          Text(
            lang == 'ne' ? '🟢 कामको प्रकार' : '🟢 Work Type',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: _workTypes.map((workType) {
              final isSelected = _selectedWorkType == workType['id'];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedWorkType = workType['id'];
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? const Color(0xFF10B981)
                      : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                        ? const Color(0xFF10B981)
                        : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      lang == 'ne' ? workType['nameNe']! : workType['nameEn']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),


          // Shift Preference
          Text(
            lang == 'ne' ? '🟢 पाला प्राथमिकता' : '🟢 Shift Preference',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: _shiftOptions.map((shift) {
              final isSelected = _selectedShift == shift['id'];
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedShift = shift['id'];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? const Color(0xFF10B981)
                        : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                          ? const Color(0xFF10B981)
                          : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        lang == 'ne' ? shift['nameNe']! : shift['nameEn']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Expected Salary
          Text(
            lang == 'ne' ? '🟢 अपेक्षित तलब (न्यूनतम)' : '🟢 Expected Salary (Minimum)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: lang == 'ne' ? 'उदा: २५०००' : 'e.g., 25000',
              prefixText: 'NPR ',
              prefixStyle: const TextStyle(fontWeight: FontWeight.bold),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (val) {
              _expectedSalary = val;
            },
          ),
          const SizedBox(height: 8),
          Text(
            lang == 'ne' ? 'प्रति महिना' : 'per month',
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }


  Widget _buildPhotoIdPage(String lang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            lang == 'ne' ? 'फोटो र परिचय पत्र' : 'Photo & ID Verification',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 24),

          // Profile Photo
          Center(
            child: GestureDetector(
              onTap: () => _showImageSourceDialog('profile'),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: _profilePhotoUrl != null 
                      ? const Color(0xFF10B981) 
                      : const Color(0xFFE2E8F0),
                    width: 3,
                  ),
                ),
                child: _profilePhotoUrl != null
                    ? ClipOval(
                        child: Image.network(
                          _profilePhotoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person, size: 60, color: Color(0xFF94A3B8));
                          },
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt_outlined, size: 40, color: Color(0xFF64748B)),
                          const SizedBox(height: 8),
                          Text(
                            lang == 'ne' ? 'फोटो थप्नुहोस्' : 'Add Photo',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Government ID Type
          Text(
            lang == 'ne' ? 'सरकारी परिचय पत्रको प्रकार' : 'Government ID Type',
            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedGovIdType,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            hint: Text(lang == 'ne' ? 'परिचय पत्र छान्नुहोस्' : 'Select ID type'),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return lang == 'ne' ? 'कृपया परिचय पत्रको प्रकार छान्नुहोस्' : 'Please select an ID type';
              }
              return null;
            },
            items: [
              DropdownMenuItem(value: 'citizenship', child: Text(lang == 'ne' ? 'नागरिकता' : 'Citizenship')),
              DropdownMenuItem(value: 'nid', child: Text(lang == 'ne' ? 'राष्ट्रिय परिचयपत्र (NID)' : 'National ID (NID)')),
              DropdownMenuItem(value: 'license', child: Text(lang == 'ne' ? 'सवारी चालक अनुमति' : 'Driving License')),
              DropdownMenuItem(value: 'pan', child: Text(lang == 'ne' ? 'प्यान कार्ड' : 'PAN Card')),
            ],
            onChanged: (val) {
              setState(() {
                _selectedGovIdType = val;
                _govIdNumberController.clear(); // Clear number when type changes
              });
            },
          ),
          const SizedBox(height: 20),

          // Dynamic Government ID Number
          if (_selectedGovIdType != null) ...[
            Text(
              _getIdNumberLabel(_selectedGovIdType!, lang),
              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _govIdNumberController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
                hintText: lang == 'ne' ? 'नम्बर प्रविष्ट गर्नुहोस्' : 'Enter number',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return lang == 'ne' ? 'कृपया नम्बर प्रविष्ट गर्नुहोस्' : 'Please enter the ID number';
                }
                final validationError = _validateGovIdNumber(_selectedGovIdType!, val.trim(), lang);
                if (validationError != null) return validationError;
                return null;
              },
            ),
            const SizedBox(height: 20),
          ],
          
          // Government ID Image Slot
          Text(
            lang == 'ne' ? 'परिचय पत्रको फोटो' : 'ID Photo',
            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 8),
          FormField<String>(
            validator: (val) {
              if (_govIdImageUrl == null || _govIdImageUrl!.isEmpty) {
                return lang == 'ne' ? 'कृपया परिचय पत्रको फोटो अपलोड गर्नुहोस्' : 'Please upload your ID photo';
              }
              return null;
            },
            builder: (formFieldState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      _showImageSourceDialog('govId');
                      formFieldState.didChange(_govIdImageUrl);
                    },
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _govIdImageUrl != null
                              ? const Color(0xFF10B981)
                              : (formFieldState.hasError ? Colors.red : const Color(0xFFE2E8F0)),
                          width: 2,
                        ),
                      ),
                      child: _govIdImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                _govIdImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(child: Icon(Icons.error, color: Colors.red));
                                },
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.upload_file, size: 48, color: Color(0xFF94A3B8)),
                                const SizedBox(height: 12),
                                Text(
                                  lang == 'ne' ? 'फोटो अपलोड गर्न यहाँ थिच्नुहोस्' : 'Tap to upload ID photo',
                                  style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (formFieldState.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 12),
                      child: Text(
                        formFieldState.errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }


  void _showImageSourceDialog(String type) {
    final lang = ModalRoute.of(context)!.settings.arguments as String? ?? 'en';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type == 'profile' 
          ? (lang == 'ne' ? 'प्रोफाइल फोटो' : 'Profile Photo')
          : (lang == 'ne' ? 'सरकारी परिचय पत्र' : 'Government ID')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(lang == 'ne' ? 'क्यामेरा' : 'Camera'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  if (type == 'profile') {
                    _profilePhotoUrl = 'https://via.placeholder.com/150';
                  } else {
                    _govIdImageUrl = 'https://via.placeholder.com/300x200';
                  }
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(lang == 'ne' ? 'ग्यालरी' : 'Gallery'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  if (type == 'profile') {
                    _profilePhotoUrl = 'https://via.placeholder.com/150';
                  } else {
                    _govIdImageUrl = 'https://via.placeholder.com/300x200';
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(String lang) {
    final totalPages = widget.role == 'worker' ? 4 : 2;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  lang == 'ne' ? 'अघिल्लो' : 'Previous',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      if (_currentPage < totalPages - 1) {
                        _nextPage();
                      } else {
                        _submitProfile(lang);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      _currentPage < totalPages - 1
                          ? (lang == 'ne' ? 'अर्को' : 'Next')
                          : (lang == 'ne' ? 'प्रोफाइल सिर्जना गर्नुहोस्' : 'Create Profile'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _getIdNumberLabel(String type, String lang) {
    switch (type) {
      case 'citizenship':
        return lang == 'ne' ? 'नागरिकता नम्बर' : 'Citizenship ID Number';
      case 'nid':
        return lang == 'ne' ? 'राष्ट्रिय परिचयपत्र नम्बर (NID Number)' : 'NID Number';
      case 'license':
        return lang == 'ne' ? 'सवारी चालक अनुमति नम्बर' : 'Driving License Number';
      case 'pan':
        return lang == 'ne' ? 'प्यान नम्बर' : 'PAN Number';
      default:
        return lang == 'ne' ? 'परिचय पत्र नम्बर' : 'ID Number';
    }
  }

  String? _validateGovIdNumber(String type, String num, String lang) {
    switch (type) {
      case 'citizenship':
        if (!RegExp(r'^[a-zA-Z0-9\-\/]+$').hasMatch(num)) {
          return lang == 'ne' ? 'नागरिकता नम्बरको ढाँचा मिलेन' : 'Invalid Citizenship number format';
        }
        break;
      case 'nid':
        if (!RegExp(r'^\d{10}$').hasMatch(num)) {
          return lang == 'ne' ? 'राष्ट्रिय परिचयपत्र नम्बर १० अंकको हुनुपर्छ' : 'NID Number must be exactly 10 digits';
        }
        break;
      case 'license':
        if (!RegExp(r'^[a-zA-Z0-9\-]+$').hasMatch(num)) {
          return lang == 'ne' ? 'सवारी चालक अनुमति नम्बरको ढाँचा मिलेन' : 'Invalid Driving License format';
        }
        break;
      case 'pan':
        if (!RegExp(r'^\d{9}$').hasMatch(num)) {
          return lang == 'ne' ? 'प्यान नम्बर ९ अंकको हुनुपर्छ' : 'PAN Number must be exactly 9 digits';
        }
        break;
    }
    return null;
  }
}
