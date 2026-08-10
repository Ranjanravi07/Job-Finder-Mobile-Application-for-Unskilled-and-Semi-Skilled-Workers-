import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/app_store.dart';
import '../theme/app_colors.dart';
import '../widgets/gov_id_section.dart';
import '../widgets/profile_photo_picker.dart';
import 'package:flutter/services.dart';
import '../services/speech_service.dart';
import '../widgets/voice_parse_dialog.dart';

/// Mirrors the React `WORKER PROFILE CREATION` screen.
class WorkerProfileCreationScreen extends StatefulWidget {
  const WorkerProfileCreationScreen({Key? key}) : super(key: key);

  @override
  State<WorkerProfileCreationScreen> createState() => _WorkerProfileCreationScreenState();
}

class _WorkerProfileCreationScreenState extends State<WorkerProfileCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _expController = TextEditingController(text: 'Fresher');
  String _selectedCategory = '';
  bool _isSubmitting = false;

  final List<Map<String, String>> _jobCategories = [
    {'id': 'laborer', 'en': 'Laborer', 'ne': 'मजदुर', 'icon': '👷'},
    {'id': 'electrician', 'en': 'Electrician', 'ne': 'इलेक्ट्रिसियन', 'icon': '⚡'},
    {'id': 'plumber', 'en': 'Plumber', 'ne': 'प्लम्बर', 'icon': '🔧'},
    {'id': 'driver', 'en': 'Driver', 'ne': 'ड्राइभर', 'icon': '🚗'},
    {'id': 'painter', 'en': 'Painter', 'ne': 'पेन्टर', 'icon': '🎨'},
    {'id': 'carpenter', 'en': 'Carpenter', 'ne': 'सिकर्मी', 'icon': '🪚'},
    {'id': 'mason', 'en': 'Mason', 'ne': 'डकर्मी', 'icon': '🧱'},
    {'id': 'cleaner', 'en': 'Cleaner', 'ne': 'सफाई गर्ने', 'icon': '🧹'},
    {'id': 'farmer', 'en': 'Farmer', 'ne': 'किसान', 'icon': '🌾'},
    {'id': 'cook', 'en': 'Cook', 'ne': 'भान्छे', 'icon': '🍳'},
    {'id': 'welder', 'en': 'Welder', 'ne': 'वेल्डर', 'icon': '🔩'},
    {'id': 'tailor', 'en': 'Tailor', 'ne': 'सुचिकार', 'icon': '🧵'},
    {'id': 'others', 'en': 'Others', 'ne': 'अन्य', 'icon': '➕'},
  ];
  final List<Map<String, String>> _locations = [
    {'id': 'kathmandu', 'en': 'Kathmandu', 'ne': 'काठमाडौं', 'icon': '📍'},
    {'id': 'lalitpur', 'en': 'Lalitpur', 'ne': 'ललितपुर', 'icon': '📍'},
    {'id': 'bhaktapur', 'en': 'Bhaktapur', 'ne': 'भक्तपुर', 'icon': '📍'},
    {'id': 'janakpur', 'en': 'Janakpur', 'ne': 'जनकपुर', 'icon': '📍'},
    {'id': 'pokhara', 'en': 'Pokhara', 'ne': 'पोखरा', 'icon': '📍'},
    {'id': 'biratnagar', 'en': 'Biratnagar', 'ne': 'विराटनगर', 'icon': '📍'},
    {'id': 'birgunj', 'en': 'Birgunj', 'ne': 'वीरगन्ज', 'icon': '📍'},
    {'id': 'bharatpur', 'en': 'Bharatpur', 'ne': 'भरतपुर', 'icon': '📍'},
    {'id': 'butwal', 'en': 'Butwal', 'ne': 'बुटवल', 'icon': '📍'},
    {'id': 'nepalgunj', 'en': 'Nepalgunj', 'ne': 'नेपालगन्ज', 'icon': '📍'},
    {'id': 'other', 'en': 'Other', 'ne': 'अन्य', 'icon': '📍'},
    {'id': 'any', 'en': 'Any Location', 'ne': 'कुनै पनि स्थान', 'icon': '🌍'},
  ];
  String _selectedLocation = '';

  String _photoPath = '';
  String _govIdType = 'citizenship';
  String _govIdNum = '';
  final Map<String, String> _files = {};

  AppStore get store => AppStore.instance;

  bool get _isNe => store.lang == 'ne';

  String _t(String en, String ne) => _isNe ? ne : en;

  void _openVoiceWizard() {
    showDialog(
      context: context,
      builder: (_) => VoiceParseDialog(
        onConfirm: (profile) {
          if (profile['name'] != null) _nameController.text = '${profile['name']}';
          if (profile['mainSkill'] != null) _selectedCategory = '${profile['mainSkill']}';
          if (profile['experience'] != null) _expController.text = '${profile['experience']}';
          if (profile['location'] != null) _selectedLocation = '${profile['location']}';
          setState(() {});
        },
      ),
    );
  }

  Future<void> _submit() async {
    String? error;
    if (_nameController.text.trim().isEmpty) {
      error = _t('Please enter your full name.', 'कृपया आफ्नो पूरा नाम प्रविष्ट गर्नुहोस्।');
    } else if (_selectedCategory.isEmpty) {
      error = _t('Please select your job category.', 'कृपया आफ्नो कामको वर्ग छान्नुहोस्।');
    } else if (_expController.text.trim().isEmpty) {
      error = _t('Please enter your experience.', 'कृपया आफ्नो अनुभव प्रविष्ट गर्नुहोस्।');
    } else if (_selectedLocation.isEmpty) {
      error = _t('Please select your preferred location.', 'कृपया आफ्नो रोजगारीको स्थान छान्नुहोस्।');
    } else if (_photoPath.isEmpty) {
      error = _t('Please upload a profile photo.', 'कृपया प्रोफाइल फोटो अपलोड गर्नुहोस्।');
    } else if (_govIdNum.trim().isEmpty) {
      error = _t(
          'Please enter your Government ID number.',
          'कृपया सरकारी परिचय-पत्र नम्बर प्रविष्ट गर्नुहोस्।');
    } else if (!_validateGovId(_govIdType, _govIdNum.trim())) {
      error = _t(
          'Invalid Government ID format for the selected type.',
          'चयन गरिएको प्रकारको लागि अमान्य सरकारी परिचय-पत्र ढाँचा।');
    } else if (_govIdType == 'citizenship' &&
        (_files['front'] == null || _files['back'] == null ||
            (_files['front'] ?? '').isEmpty || (_files['back'] ?? '').isEmpty)) {
      error = _t(
          'Please upload both front and back images of the Citizenship card.',
          'कृपया नागरिकताको अगाडि र पछाडिको फोटो अपलोड गर्नुहोस्।');
    } else if ((_files[_govIdType] ?? '').isEmpty) {
      error = _t('Please upload the required ID photo.', 'कृपया आवश्यक ID फोटो अपलोड गर्नुहोस्।');
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.red500),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    store.createWorkerProfile(
      name: _nameController.text.trim(),
      mainSkill: _selectedCategory,
      experience: _expController.text.trim(),
      location: _selectedLocation,
      profilePhoto: _photoPath,
      govIdType: _govIdType,
      govIdNum: _govIdNum.trim(),
      govIdFiles: _files.values.toList(),
    );
    
    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pushReplacementNamed(context, '/worker-home');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _expController.dispose();
    super.dispose();
  }

  Widget _label(String en, String ne) {
    return Text(
      _t(en, ne),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
        color: AppColors.slate800,
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 11, color: AppColors.slate600),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.slate200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.slate900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _t('Simple Profile Setup', 'सजिलो प्रोफाइल निर्माण'),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.slate900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openVoiceWizard,
            tooltip: _t('Voice Onboarding', 'आवाज दर्ता'),
            icon: Icon(Icons.mic_rounded, color: AppColors.emerald600),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile photo
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Center(
                  child: ProfilePhotoPicker(
                    photoPath: _photoPath,
                    onChanged: (v) => setState(() => _photoPath = v),
                    labelEn: 'Profile Photo (Worker)',
                    labelNe: 'प्रोफाइल फोटो (कामदार)',
                  ),
                ),
              ),
              SizedBox(height: 16),

              _label('Full Name', 'कामदारको पूरा नाम'),
              SizedBox(height: 6),
              TextField(
                controller: _nameController,
                style: TextStyle(color: AppColors.slate900, fontWeight: FontWeight.w600),
                decoration: _inputDecoration(hint: 'Ram Bahadur'),
              ),
              SizedBox(height: 14),

              SizedBox(height: 8),
              
              // SECTION 1: JOB CATEGORY
              Text(
                _t('What work do you do?', 'तपाईं के काम गर्नुहुन्छ?'),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemCount: _jobCategories.length,
                itemBuilder: (context, index) {
                  final cat = _jobCategories[index];
                  final isSelected = _selectedCategory == cat['id'];
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      SpeechService.instance.speak(_t(cat['en']!, cat['ne']!), store.lang);
                      setState(() {
                        _selectedCategory = cat['id']!;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.slate900 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.slate900 : AppColors.slate200,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(cat['icon']!, style: TextStyle(fontSize: 28)),
                          SizedBox(height: 8),
                          Text(
                            cat['en']!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppColors.slate700,
                            ),
                          ),
                          Text(
                            cat['ne']!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white70 : AppColors.slate700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 24),

              // SECTION 2: WORK PREFERENCES
              Text(
                _t('Where do you want to work?', 'तपाईं कहाँ काम गर्न चाहनुहुन्छ?'),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                ),
              ),
              SizedBox(height: 12),

              _label('Preferred location', 'रोजगारीको स्थान'),
              SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.1,
                ),
                itemCount: _locations.length,
                itemBuilder: (context, index) {
                  final loc = _locations[index];
                  final isSelected = _selectedLocation == loc['id'];
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      SpeechService.instance.speak(_t(loc['en']!, loc['ne']!), store.lang);
                      setState(() {
                        _selectedLocation = loc['id']!;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.slate900 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.slate900 : AppColors.slate200,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(loc['icon']!, style: TextStyle(fontSize: 22)),
                          SizedBox(height: 6),
                          Text(
                            loc['en']!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppColors.slate700,
                            ),
                          ),
                          Text(
                            loc['ne']!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white70 : AppColors.slate700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 14),

              _label('Experience', 'अनुभव'),
              SizedBox(height: 6),
              TextField(
                controller: _expController,
                style: TextStyle(color: AppColors.slate900, fontWeight: FontWeight.w600),
                decoration: _inputDecoration(
                    hint: _t('Type years or description (e.g. 2 Years)',
                        'वर्ष/अनुभव लेख्नुहोस्')),
              ),
              const SizedBox(height: 20),

              // Government ID
              GovIdSection(
                govIdType: _govIdType,
                govIdNum: _govIdNum,
                onTypeChanged: (v) => setState(() => _govIdType = v),
                onNumChanged: (v) => setState(() => _govIdNum = v),
                files: _files,
                onFilePicked: (key, value) => setState(() => _files[key] = value),
                onFileRemoved: (key) => setState(() => _files.remove(key)),
              ),
              const SizedBox(height: 24),

              // Submit
              ElevatedButton(
                onPressed: _isSubmitting ? null : () async => await _submit(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.slate900,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_rounded, color: AppColors.emerald400, size: 18),
                          SizedBox(width: 8),
                          Text(
                            _t('Verify & Save Profile', 'सुरक्षित गर्नुहोस्'),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  'ROJGAR VERIFIED RECRUITMENT • GOVT OF NEPAL COMPLIANCE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _typeSingleLabelNe(String type) {
    switch (type) {
      case 'nid':
        return 'NID फोटो अपलोड गर्नुहोस्';
      case 'license':
        return 'ड्राइभिङ लाइसेन्स फोटो अपलोड गर्नुहोस्';
      case 'pan':
        return 'PAN/VAT फोटो अपलोड गर्नुहोस्';
      default:
        return 'फाइल अपलोड गर्नुहोस्';
    }
  }

  bool _validateGovId(String type, String num) {
    switch (type) {
      case 'citizenship':
        return RegExp(r'^[a-zA-Z0-9\-\/]+$').hasMatch(num);
      case 'nid':
        return RegExp(r'^\d{10}$').hasMatch(num);
      case 'license':
        return RegExp(r'^[a-zA-Z0-9\-]+$').hasMatch(num);
      case 'pan':
        return RegExp(r'^\d{9}$').hasMatch(num);
      default:
        return num.isNotEmpty;
    }
  }
}
