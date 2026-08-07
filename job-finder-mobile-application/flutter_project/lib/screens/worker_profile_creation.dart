import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/app_store.dart';
import '../theme/app_colors.dart';
import '../widgets/gov_id_section.dart';
import '../widgets/profile_photo_picker.dart';
import '../widgets/voice_parse_dialog.dart';

/// Mirrors the React `WORKER PROFILE CREATION` screen.
class WorkerProfileCreationScreen extends StatefulWidget {
  const WorkerProfileCreationScreen({Key? key}) : super(key: key);

  @override
  State<WorkerProfileCreationScreen> createState() => _WorkerProfileCreationScreenState();
}

class _WorkerProfileCreationScreenState extends State<WorkerProfileCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _skillController = TextEditingController(text: 'laborer');
  final TextEditingController _expController = TextEditingController(text: 'Fresher');
  final TextEditingController _locController = TextEditingController(text: 'Balkumari, Lalitpur');

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
          if (profile['mainSkill'] != null) _skillController.text = '${profile['mainSkill']}';
          if (profile['experience'] != null) _expController.text = '${profile['experience']}';
          if (profile['location'] != null) _locController.text = '${profile['location']}';
          setState(() {});
        },
      ),
    );
  }

  void _submit() {
    String? error;
    if (_nameController.text.trim().isEmpty) {
      error = _t('Please enter your full name.', 'कृपया आफ्नो पूरा नाम प्रविष्ट गर्नुहोस्।');
    } else if (_skillController.text.trim().isEmpty) {
      error = _t('Please enter your primary skill.', 'कृपया मुख्य सिप प्रविष्ट गर्नुहोस्।');
    } else if (_expController.text.trim().isEmpty) {
      error = _t('Please enter your experience.', 'कृपया आफ्नो अनुभव प्रविष्ट गर्नुहोस्।');
    } else if (_locController.text.trim().isEmpty) {
      error = _t('Please enter your location.', 'कृपया आफ्नो स्थान प्रविष्ट गर्नुहोस्।');
    } else if (_photoPath.isEmpty) {
      error = _t('Please upload a profile photo.', 'कृपया प्रोफाइल फोटो अपलोड गर्नुहोस्।');
    } else if (_govIdNum.trim().isEmpty) {
      error = _t('Please enter your Government ID number.', 'कृपया सरकारी परिचय-पत्र नम्बर प्रविष्ट गर्नुहोस्।');
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

    store.createWorkerProfile(
      name: _nameController.text.trim(),
      mainSkill: _skillController.text.trim(),
      experience: _expController.text.trim(),
      location: _locController.text.trim(),
      profilePhoto: _photoPath,
      govId: '${_govIdType.toUpperCase()} - $_govIdNum',
      govIdFiles: _files.values.toList(),
    );
    Navigator.pushReplacementNamed(context, '/worker-home');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skillController.dispose();
    _expController.dispose();
    _locController.dispose();
    super.dispose();
  }

  Widget _label(String en, String ne) {
    return Text(
      _t(en, ne),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1,
        color: AppColors.slate500,
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11, color: AppColors.slate400),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.slate200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.slate900),
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
            icon: const Icon(Icons.mic_rounded, color: AppColors.emerald600),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile photo
              Container(
                padding: const EdgeInsets.all(14),
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
              const SizedBox(height: 16),

              _label('Full Name', 'कामदारको पूरा नाम'),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration: _inputDecoration(hint: 'Ram Bahadur'),
              ),
              const SizedBox(height: 14),

              _label('Primary Skill', 'मुख्य सिप'),
              const SizedBox(height: 6),
              TextField(
                controller: _skillController,
                decoration: _inputDecoration(
                    hint: _t('Type primary skill / role', 'मुख्य सिप लेख्नुहोस्')),
              ),
              const SizedBox(height: 14),

              _label('Experience', 'अनुभव'),
              const SizedBox(height: 6),
              TextField(
                controller: _expController,
                decoration: _inputDecoration(
                    hint: _t('Type years or description (e.g. 2 Years)',
                        'वर्ष/अनुभव लेख्नुहोस्')),
              ),
              const SizedBox(height: 14),

              _label('Your Location', 'ठेगाना'),
              const SizedBox(height: 6),
              TextField(
                controller: _locController,
                decoration: _inputDecoration(hint: 'Type your location'),
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
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.slate900,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_rounded, color: AppColors.emerald400, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _t('Verify & Save Profile', 'सुरक्षित गर्नुहोस्'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Center(
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
}
