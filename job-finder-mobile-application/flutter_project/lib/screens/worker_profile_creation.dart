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
  const WorkerProfileCreationScreen({super.key});

  @override
  State<WorkerProfileCreationScreen> createState() =>
      _WorkerProfileCreationScreenState();
}

class _WorkerProfileCreationScreenState
    extends State<WorkerProfileCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _expController =
      TextEditingController(text: 'Fresher');
  final TextEditingController _locationController = TextEditingController();
  String _selectedCategory = '';
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _jobCategories = [
    {'id': 'laborer', 'en': 'Laborer', 'ne': 'मजदुर', 'icon': Icons.construction},
    {'id': 'electrician', 'en': 'Electrician', 'ne': 'इलेक्ट्रिसियन', 'icon': Icons.electrical_services},
    {'id': 'plumber', 'en': 'Plumber', 'ne': 'प्लम्बर', 'icon': Icons.plumbing},
    {'id': 'driver', 'en': 'Driver', 'ne': 'ड्राइभर', 'icon': Icons.directions_car},
    {'id': 'painter', 'en': 'Painter', 'ne': 'पेन्टर', 'icon': Icons.format_paint},
    {'id': 'carpenter', 'en': 'Carpenter', 'ne': 'सिकर्मी', 'icon': Icons.carpenter},
    {'id': 'mason', 'en': 'Mason', 'ne': 'डकर्मी', 'icon': Icons.foundation},
    {'id': 'cleaner', 'en': 'Cleaner', 'ne': 'सफाई गर्ने', 'icon': Icons.cleaning_services},
    {'id': 'farmer', 'en': 'Farmer', 'ne': 'किसान', 'icon': Icons.agriculture},
    {'id': 'cook', 'en': 'Cook', 'ne': 'भान्छे', 'icon': Icons.restaurant},
    {'id': 'welder', 'en': 'Welder', 'ne': 'वेल्डर', 'icon': Icons.build_circle},
    {'id': 'tailor', 'en': 'Tailor', 'ne': 'सुचिकार', 'icon': Icons.content_cut},
    {'id': 'others', 'en': 'Others', 'ne': 'अन्य', 'icon': Icons.category},
  ];
  // Location options removed as per requirements

  String _photoPath = '';
  List<String> _selectedGovTypes = ['citizenship'];
  final Map<String, String> _govIdNumbers = {};
  final Map<String, String> _files = {};

  AppStore get store => AppStore.instance;

  bool get _isNe => store.lang == 'ne';

  String _t(String en, String ne) => _isNe ? ne : en;

  void _openVoiceWizard() {
    showDialog(
      context: context,
      builder: (_) => VoiceParseDialog(
        onConfirm: (profile) {
          if (profile['name'] != null) {
            _nameController.text = '${profile['name']}';
          }
          if (profile['mainSkill'] != null) {
            _selectedCategory = '${profile['mainSkill']}';
          }
          if (profile['experience'] != null) {
            _expController.text = '${profile['experience']}';
          }
          if (profile['location'] != null) {
            _locationController.text = '${profile['location']}';
          }
          setState(() {});
        },
      ),
    );
  }

  Future<void> _submit() async {
    String? error;
    if (_nameController.text.trim().isEmpty) {
      error = _t('Please enter your full name.',
          'कृपया आफ्नो पूरा नाम प्रविष्ट गर्नुहोस्।');
    } else if (_selectedCategory.isEmpty) {
      error = _t('Please select your job category.',
          'कृपया आफ्नो कामको वर्ग छान्नुहोस्।');
    } else if (_expController.text.trim().isEmpty) {
      error = _t('Please enter your experience.',
          'कृपया आफ्नो अनुभव प्रविष्ट गर्नुहोस्।');
    } else if (_locationController.text.trim().isEmpty) {
      error = _t('Please enter your preferred location.',
          'कृपया आफ्नो मनपर्ने स्थान लेख्नुहोस्।');
    } else if (_photoPath.isEmpty) {
      error = _t('Please upload a profile photo.',
          'कृपया प्रोफाइल फोटो अपलोड गर्नुहोस्।');
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error), backgroundColor: context.appColors.red500),
      );
      return;
    }

    // Validate Government IDs
    final kycVal = validateGovernmentIds(
      selectedTypes: _selectedGovTypes,
      idNumbers: _govIdNumbers,
      files: _files,
    );
    if (!kycVal.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(kycVal.message(store.lang)),
          backgroundColor: context.appColors.red500,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final primaryType = _selectedGovTypes.first;
    final primaryNum = _govIdNumbers[primaryType] ?? '';

    final Map<String, Map<String, dynamic>> govMap = {};
    for (final type in _selectedGovTypes) {
      final num = (_govIdNumbers[type] ?? '').trim();
      final docs = <String>[];
      if (type == 'citizenship') {
        final f = _files['citizenship_front'] ?? _files['front'] ?? '';
        final b = _files['citizenship_back'] ?? _files['back'] ?? '';
        if (f.isNotEmpty) docs.add(f);
        if (b.isNotEmpty) docs.add(b);
      } else {
        final img = _files[type] ?? _files['${type}_front'] ?? '';
        if (img.isNotEmpty) docs.add(img);
      }
      govMap[type] = {
        'idNumber': num,
        'documentFiles': docs,
        'submittedAt': DateTime.now().toIso8601String(),
      };
    }

    try {
      await store.createWorkerProfile(
        name: _nameController.text.trim(),
        mainSkill: _selectedCategory,
        experience: _expController.text.trim(),
        location: _locationController.text.trim(),
        profilePhoto: _photoPath,
        govIdType: primaryType,
        govIdNum: primaryNum.trim(),
        govIdFiles: _files.values.toList(),
        governmentIds: govMap,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: context.appColors.red500,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (store.role == 'employer') {
        Navigator.pushReplacementNamed(context, '/employer-home');
      } else {
        Navigator.pushReplacementNamed(context, '/worker-home');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _expController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Widget _label(String en, String ne) {
    return Text(
      _t(en, ne),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
        color: context.appColors.slate800,
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14, color: context.appColors.slate600),
      filled: true,
      fillColor: context.appColors.white,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.appColors.slate200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.appColors.slate900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _t('Simple Profile Setup', 'सजिलो प्रोफाइल निर्माण'),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: context.appColors.slate900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openVoiceWizard,
            tooltip: _t('Voice Onboarding', 'आवाज दर्ता'),
            icon: Icon(Icons.mic_rounded, color: context.appColors.emerald600),
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
                  color: context.appColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.appColors.slate200),
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
                style: TextStyle(
                    color: context.appColors.slate900,
                    fontWeight: FontWeight.w600),
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
                  color: context.appColors.slate900,
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
                      SpeechService.instance
                          .speak(_t(cat['en']!, cat['ne']!), store.lang);
                      setState(() {
                        _selectedCategory = cat['id']!;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.appColors.slate900
                            : context.appColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? context.appColors.slate900
                              : context.appColors.slate200,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            cat['icon'] as IconData,
                            size: 28,
                            color: isSelected
                                ? context.appColors.white
                                : context.appColors.slate800,
                          ),
                          SizedBox(height: 8),
                          Text(
                            cat['en']!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? context.appColors.white
                                  : context.appColors.slate700,
                            ),
                          ),
                          Text(
                            cat['ne']!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? context.appColors.white
                                      .withValues(alpha: 0.7)
                                  : context.appColors.slate700,
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
                _t('Enter your preferred location',
                    'आफ्नो मनपर्ने स्थान लेख्नुहोस्'),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.appColors.slate900,
                ),
              ),
              SizedBox(height: 12),

              TextField(
                controller: _locationController,
                style: TextStyle(
                    color: context.appColors.slate900,
                    fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: _t('Type location...', 'स्थान लेख्नुहोस्...'),
                  hintStyle: TextStyle(
                      fontSize: 14, color: context.appColors.slate600),
                  prefixIcon: Icon(Icons.search,
                      color: context.appColors.slate600, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.mic, color: context.appColors.emerald600),
                    onPressed: _openVoiceWizard,
                    tooltip: _t('Voice Input', 'आवाजबाट लेख्नुहोस्'),
                  ),
                  filled: true,
                  fillColor: context.appColors.white,
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.appColors.slate200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.appColors.slate900),
                  ),
                ),
              ),
              SizedBox(height: 14),

              _label('Experience', 'अनुभव'),
              SizedBox(height: 6),
              TextField(
                controller: _expController,
                style: TextStyle(
                    color: context.appColors.slate900,
                    fontWeight: FontWeight.w600),
                decoration: _inputDecoration(
                    hint: _t('Type years or description (e.g. 2 Years)',
                        'वर्ष/अनुभव लेख्नुहोस्')),
              ),
              const SizedBox(height: 20),

              // Government ID
              GovIdSection(
                selectedTypes: _selectedGovTypes,
                idNumbers: _govIdNumbers,
                onTypesChanged: (types) => setState(() => _selectedGovTypes = types),
                onNumChanged: (type, idNum) => setState(() => _govIdNumbers[type] = idNum),
                files: _files,
                onFilePicked: (key, value) =>
                    setState(() => _files[key] = value),
                onFileRemoved: (key) => setState(() => _files.remove(key)),
              ),
              const SizedBox(height: 24),

              // Submit
              ElevatedButton(
                onPressed: _isSubmitting ? null : () async => await _submit(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appColors.slate900,
                  foregroundColor: context.appColors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: context.appColors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_rounded,
                              color: context.appColors.emerald400, size: 18),
                          SizedBox(width: 8),
                          Text(
                            _t('Verify & Save Profile', 'सुरक्षित गर्नुहोस्'),
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w900),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.slate600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
