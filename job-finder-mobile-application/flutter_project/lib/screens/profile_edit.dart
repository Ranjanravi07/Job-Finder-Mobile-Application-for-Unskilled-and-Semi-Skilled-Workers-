import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasChanges = false;

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _nameNeController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _locationNeController;
  late TextEditingController _experienceController;
  late TextEditingController _govIdNumberController;

  String? _selectedSkill;
  String? _selectedIndustry;
  String? _selectedGovIdType;
  String? _profilePhotoUrl;
  String? _govIdImageUrl;

  // Skill options for workers
  final List<Map<String, String>> _skillOptions = [
    {'id': 'mason', 'nameEn': 'Mason / Bricklayer', 'nameNe': 'डकर्मी'},
    {'id': 'carpenter', 'nameEn': 'Carpenter', 'nameNe': 'सिकर्मी'},
    {'id': 'electrician', 'nameEn': 'Electrician', 'nameNe': 'बिजुली काम'},
    {'id': 'plumber', 'nameEn': 'Plumber', 'nameNe': 'प्लम्बर'},
    {'id': 'painter', 'nameEn': 'Painter', 'nameNe': 'पेन्टर'},
    {'id': 'driver', 'nameEn': 'Driver', 'nameNe': 'चालक'},
    {'id': 'domestic', 'nameEn': 'Domestic Helper', 'nameNe': 'गृह सहायक'},
    {'id': 'factory', 'nameEn': 'Factory Worker', 'nameNe': 'कारखाना कामदार'},
    {'id': 'security', 'nameEn': 'Security Guard', 'nameNe': 'सुरक्षा गार्ड'},
    {'id': 'other', 'nameEn': 'Other', 'nameNe': 'अन्य'},
  ];

  // Industry options for employers
  final List<Map<String, String>> _industryOptions = [
    {'id': 'construction', 'nameEn': 'Construction', 'nameNe': 'निर्माण'},
    {'id': 'domestic', 'nameEn': 'Household / Domestic', 'nameNe': 'घरायसी'},
    {'id': 'factory', 'nameEn': 'Factory / Manufacturing', 'nameNe': 'कारखाना'},
    {'id': 'logistics', 'nameEn': 'Logistics / Delivery', 'nameNe': 'रसद'},
    {'id': 'security', 'nameEn': 'Security Services', 'nameNe': 'सुरक्षा सेवा'},
    {'id': 'agriculture', 'nameEn': 'Agriculture', 'nameNe': 'कृषि'},
    {'id': 'other', 'nameEn': 'Other', 'nameNe': 'अन्य'},
  ];

  // Government ID types
  final List<Map<String, String>> _govIdTypes = [
    {'id': 'citizenship', 'nameEn': 'Citizenship', 'nameNe': 'नागरिकता'},
    {'id': 'nid', 'nameEn': 'National ID (NID)', 'nameNe': 'राष्ट्रिय परिचयपत्र (NID)'},
    {'id': 'license', 'nameEn': 'Driving License', 'nameNe': 'सवारी चालक अनुमति'},
    {'id': 'pan', 'nameEn': 'PAN Card', 'nameNe': 'प्यान कार्ड'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameNeController = TextEditingController();
    _phoneController = TextEditingController();
    _locationController = TextEditingController();
    _locationNeController = TextEditingController();
    _experienceController = TextEditingController();
    _govIdNumberController = TextEditingController();

    // Load existing profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  void _loadProfileData() {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final profile = profileProvider.profile;

    if (profile != null) {
      _nameController.text = profile.name;
      _nameNeController.text = profile.nameNe ?? '';
      _phoneController.text = profile.phone;
      _locationController.text = profile.location;
      _locationNeController.text = profile.locationNe ?? '';
      _experienceController.text = profile.experience ?? '';
      _govIdNumberController.text = profile.governmentIdNumber ?? '';

      setState(() {
        _selectedSkill = profile.skill;
        _selectedIndustry = profile.industry;
        _selectedGovIdType = profile.governmentIdType;
        _profilePhotoUrl = profile.profilePhotoUrl;
        _govIdImageUrl = profile.governmentIdImageUrl;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameNeController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _locationNeController.dispose();
    _experienceController.dispose();
    _govIdNumberController.dispose();
    super.dispose();
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveChanges(String lang) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    final success = await profileProvider.updateProfile(
      name: _nameController.text.trim(),
      nameNe: _nameNeController.text.trim().isNotEmpty ? _nameNeController.text.trim() : null,
      skill: _selectedSkill,
      industry: _selectedIndustry,
      location: _locationController.text.trim(),
      locationNe: _locationNeController.text.trim().isNotEmpty ? _locationNeController.text.trim() : null,
      profilePhotoUrl: _profilePhotoUrl,
      governmentIdType: _selectedGovIdType,
      governmentIdNumber: _govIdNumberController.text.trim(),
      governmentIdImageUrl: _govIdImageUrl,
      experience: _experienceController.text.trim().isNotEmpty ? _experienceController.text.trim() : null,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang == 'ne' ? 'प्रोफाइल अपडेट गरियो!' : 'Profile updated successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang == 'ne' ? 'अपडेट गर्न असफल। कृपया पुनः प्रयास गर्नुहोस्।' : 'Failed to update. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog(String type) {
    final lang = ModalRoute.of(context)!.settings.arguments as String? ?? 'en';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          type == 'profile'
              ? (lang == 'ne' ? 'प्रोफाइल फोटो' : 'Profile Photo')
              : (lang == 'ne' ? 'सरकारी परिचय पत्र' : 'Government ID'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(lang == 'ne' ? 'क्यामेरा' : 'Camera'),
              onTap: () {
                Navigator.pop(context);
                _simulateImageUpload(type);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(lang == 'ne' ? 'ग्यालरी' : 'Gallery'),
              onTap: () {
                Navigator.pop(context);
                _simulateImageUpload(type);
              },
            ),
            if (type == 'profile' && _profilePhotoUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  lang == 'ne' ? 'फोटो हटाउनुहोस्' : 'Remove Photo',
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _profilePhotoUrl = null;
                    _markAsChanged();
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  void _simulateImageUpload(String type) {
    // Simulate image upload - in production, use image_picker and Firebase Storage
    setState(() {
      if (type == 'profile') {
        _profilePhotoUrl = 'https://via.placeholder.com/150';
      } else {
        _govIdImageUrl = 'https://via.placeholder.com/300x200';
      }
      _markAsChanged();
    });

    final lang = ModalRoute.of(context)!.settings.arguments as String? ?? 'en';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(lang == 'ne' ? 'फोटो अपलोड गरियो (डेमो)' : 'Photo uploaded (Demo)'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final lang = ModalRoute.of(context)!.settings.arguments as String? ?? 'en';
    
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang == 'ne' ? 'परिवर्तनहरू छन्' : 'Unsaved Changes'),
        content: Text(
          lang == 'ne'
              ? 'तपाईंका परिवर्तनहरू सुरक्षित गरिएको छैन। के तपाईं निस्कन चाहनुहुन्छ?'
              : 'You have unsaved changes. Are you sure you want to exit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(lang == 'ne' ? 'रद्द गर्नुहोस्' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              lang == 'ne' ? 'निस्कनुहोस्' : 'Exit',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final lang = ModalRoute.of(context)!.settings.arguments as String? ?? 'en';
    final profileProvider = Provider.of<ProfileProvider>(context);
    final profile = profileProvider.profile;

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          foregroundColor: Colors.white,
          title: Text(
            lang == 'ne' ? 'प्रोफाइल सम्पादन' : 'Edit Profile',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Text(
            lang == 'ne' ? 'प्रोफाइल भेटिएन' : 'Profile not found',
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    final isWorker = profile.role == 'worker';

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            lang == 'ne' ? 'प्रोफाइल सम्पादन' : 'Edit Profile',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton.icon(
              onPressed: _isLoading ? null : () => _saveChanges(lang),
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.check, color: Colors.white),
              label: Text(
                lang == 'ne' ? 'सुरक्षित गर्नुहोस्' : 'Save',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Photo Section
                Center(
                  child: GestureDetector(
                    onTap: () => _showImageSourceDialog('profile'),
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFF10B981),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: _profilePhotoUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    _profilePhotoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildInitialsAvatar(profile);
                                    },
                                  ),
                                )
                              : _buildInitialsAvatar(profile),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Personal Information Section
                _buildSectionTitle(
                  lang == 'ne' ? 'व्यक्तिगत जानकारी' : 'Personal Information',
                  Icons.person_outline,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _nameController,
                  onChanged: (_) => _markAsChanged(),
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
                  onChanged: (_) => _markAsChanged(),
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
                  onChanged: (_) => _markAsChanged(),
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
                const SizedBox(height: 24),

                // Professional Information Section
                _buildSectionTitle(
                  isWorker
                      ? (lang == 'ne' ? 'व्यावसायिक जानकारी' : 'Professional Details')
                      : (lang == 'ne' ? 'व्यवसाय जानकारी' : 'Business Details'),
                  Icons.work_outline,
                ),
                const SizedBox(height: 12),

                // Skill selection (for workers)
                if (isWorker) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedSkill,
                    decoration: InputDecoration(
                      labelText: lang == 'ne' ? 'मुख्य सीप' : 'Primary Skill',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    hint: Text(lang == 'ne' ? 'सीप छान्नुहोस्' : 'Select your skill'),
                    items: _skillOptions.map((skill) {
                      return DropdownMenuItem(
                        value: skill['id'],
                        child: Text(lang == 'ne' ? skill['nameNe']! : skill['nameEn']!),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedSkill = val;
                        _markAsChanged();
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _experienceController,
                    onChanged: (_) => _markAsChanged(),
                    decoration: InputDecoration(
                      labelText: lang == 'ne' ? 'अनुभव (उदा: ५ वर्ष)' : 'Experience (e.g., 5 Years)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Industry selection (for employers)
                if (!isWorker) ...[
                  DropdownButtonFormField<String>(
                    value: _selectedIndustry,
                    decoration: InputDecoration(
                      labelText: lang == 'ne' ? 'व्यवसायको प्रकार' : 'Industry Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    hint: Text(lang == 'ne' ? 'उद्योग छान्नुहोस्' : 'Select your industry'),
                    items: _industryOptions.map((industry) {
                      return DropdownMenuItem(
                        value: industry['id'],
                        child: Text(lang == 'ne' ? industry['nameNe']! : industry['nameEn']!),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedIndustry = val;
                        _markAsChanged();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                TextFormField(
                  controller: _locationController,
                  onChanged: (_) => _markAsChanged(),
                  validator: (val) => val == null || val.isEmpty
                      ? (lang == 'ne' ? 'स्थान आवश्यक छ' : 'Location is required')
                      : null,
                  decoration: InputDecoration(
                    labelText: lang == 'ne' ? 'ठेगाना (अंग्रेजीमा)' : 'Location (in English)',
                    hintText: lang == 'ne' ? 'उदा: बालकुमारी, ललितपुर' : 'e.g., Balkumari, Lalitpur',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _locationNeController,
                  onChanged: (_) => _markAsChanged(),
                  decoration: InputDecoration(
                    labelText: lang == 'ne' ? 'ठेगाना (नेपालीमा) - वैकल्पिक' : 'Location (in Nepali) - Optional',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Government ID Section
                _buildSectionTitle(
                  lang == 'ne' ? 'परिचय पत्र प्रमाणीकरण' : 'ID Verification',
                  Icons.verified_user_outlined,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _selectedGovIdType,
                  decoration: InputDecoration(
                    labelText: lang == 'ne' ? 'परिचय पत्रको प्रकार' : 'Government ID Type',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  hint: Text(lang == 'ne' ? 'परिचय पत्र छान्नुहोस्' : 'Select ID type'),
                  items: _govIdTypes.map((idType) {
                    return DropdownMenuItem(
                      value: idType['id'],
                      child: Text(lang == 'ne' ? idType['nameNe']! : idType['nameEn']!),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedGovIdType = val;
                      _markAsChanged();
                    });
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _govIdNumberController,
                  onChanged: (_) => _markAsChanged(),
                  decoration: InputDecoration(
                    labelText: _selectedGovIdType != null 
                        ? _getIdNumberLabel(_selectedGovIdType!, lang) 
                        : (lang == 'ne' ? 'परिचय पत्र नम्बर' : 'ID Number'),
                    hintText: lang == 'ne' ? 'नम्बर प्रविष्ट गर्नुहोस्' : 'Enter number',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return lang == 'ne' ? 'कृपया नम्बर प्रविष्ट गर्नुहोस्' : 'Please enter the ID number';
                    }
                    if (_selectedGovIdType != null) {
                      final validationError = _validateGovIdNumber(_selectedGovIdType!, val.trim(), lang);
                      if (validationError != null) return validationError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Government ID Image
                GestureDetector(
                  onTap: () => _showImageSourceDialog('govId'),
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _govIdImageUrl != null
                            ? const Color(0xFF10B981)
                            : const Color(0xFFE2E8F0),
                        width: 2,
                      ),
                    ),
                    child: _govIdImageUrl != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  _govIdImageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildIdPlaceholder(lang);
                                  },
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : _buildIdPlaceholder(lang),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(UserProfile profile) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF10B981),
      ),
      child: Center(
        child: Text(
          profile.initials,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0F172A)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildIdPlaceholder(String lang) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.add_photo_alternate_outlined,
          size: 48,
          color: Color(0xFF64748B),
        ),
        const SizedBox(height: 12),
        Text(
          lang == 'ne' ? 'सरकारी परिचय पत्रको फोटो' : 'Government ID Photo',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          lang == 'ne' ? 'छवि अपलोड गर्न ट्याप गर्नुहोस्' : 'Tap to upload image',
          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
      ],
    );
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
