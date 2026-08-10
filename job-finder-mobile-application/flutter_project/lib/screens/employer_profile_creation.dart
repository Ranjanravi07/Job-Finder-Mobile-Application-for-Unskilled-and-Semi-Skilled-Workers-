import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/app_store.dart';
import '../theme/app_colors.dart';
import '../widgets/gov_id_section.dart';
import '../widgets/profile_photo_picker.dart';

/// Mirrors the React `EMPLOYER PROFILE CREATION` screen.
class EmployerProfileCreationScreen extends StatefulWidget {
  const EmployerProfileCreationScreen({super.key});

  @override
  State<EmployerProfileCreationScreen> createState() =>
      _EmployerProfileCreationScreenState();
}

class _EmployerProfileCreationScreenState
    extends State<EmployerProfileCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController =
      TextEditingController(text: 'Contractor');
  final TextEditingController _locController =
      TextEditingController(text: 'Balkumari, Lalitpur');
  final TextEditingController _companyController = TextEditingController();
  bool _isSubmitting = false;

  String _photoPath = '';
  List<String> _selectedGovTypes = ['citizenship'];
  final Map<String, String> _govIdNumbers = {};
  final Map<String, String> _files = {};

  AppStore get store => AppStore.instance;

  bool get _isNe => store.lang == 'ne';

  String _t(String en, String ne) => _isNe ? ne : en;

  Future<void> _submit() async {
    String? error;
    if (_nameController.text.trim().isEmpty) {
      error = _t('Please enter your full name.',
          'कृपया आफ्नो पूरा नाम प्रविष्ट गर्नुहोस्।');
    } else if (_roleController.text.trim().isEmpty) {
      error = _t('Please enter your role / title.',
          'कृपया भूमिका प्रविष्ट गर्नुहोस्।');
    } else if (_locController.text.trim().isEmpty) {
      error =
          _t('Please enter your location.', 'कृपया स्थान प्रविष्ट गर्नुहोस्।');
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

    await store.createEmployerProfile(
      name: _nameController.text.trim(),
      role: _roleController.text.trim(),
      location: _locController.text.trim(),
      companyName: _companyController.text.trim().isNotEmpty
          ? _companyController.text.trim()
          : 'Individual',
      govIdType: primaryType,
      govIdNum: primaryNum.trim(),
      govIdFiles: _files.values.toList(),
      profilePhoto: _photoPath,
      governmentIds: govMap,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pushReplacementNamed(context, '/employer-home');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _locController.dispose();
    _companyController.dispose();
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
        borderSide: BorderSide(color: context.appColors.indigo600),
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
          _t('Employer Profile Setup', 'रोजगारदाता प्रोफाइल निर्माण'),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: context.appColors.slate900,
          ),
        ),
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
                    labelEn: 'Profile Photo (Employer)',
                    labelNe: 'प्रोफाइल फोटो (रोजगारदाता)',
                  ),
                ),
              ),
              SizedBox(height: 16),

              _label('Full Name', 'रोजगारदाताको पूरा नाम'),
              SizedBox(height: 6),
              TextField(
                controller: _nameController,
                style: TextStyle(
                    color: context.appColors.slate900,
                    fontWeight: FontWeight.w600),
                decoration: _inputDecoration(hint: 'Ravi Ranjan Sah'),
              ),
              SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Role / Title', 'भूमिका'),
                        SizedBox(height: 6),
                        TextField(
                          controller: _roleController,
                          style: TextStyle(
                              color: context.appColors.slate900,
                              fontWeight: FontWeight.w600),
                          decoration: _inputDecoration(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Primary Location', 'स्थान'),
                        SizedBox(height: 6),
                        TextField(
                          controller: _locController,
                          style: TextStyle(
                              color: context.appColors.slate900,
                              fontWeight: FontWeight.w600),
                          decoration: _inputDecoration(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),

              _label('Company Name (Optional)', 'कम्पनी / फर्मको नाम (ऐच्छिक)'),
              SizedBox(height: 6),
              TextField(
                controller: _companyController,
                style: TextStyle(
                    color: context.appColors.slate900,
                    fontWeight: FontWeight.w600),
                decoration: _inputDecoration(hint: 'e.g. Gupta Construction'),
              ),
              const SizedBox(height: 20),

              // Government ID with registration option
              GovIdSection(
                selectedTypes: _selectedGovTypes,
                idNumbers: _govIdNumbers,
                onTypesChanged: (types) => setState(() => _selectedGovTypes = types),
                onNumChanged: (type, idNum) => setState(() => _govIdNumbers[type] = idNum),
                files: _files,
                onFilePicked: (key, value) =>
                    setState(() => _files[key] = value),
                onFileRemoved: (key) => setState(() => _files.remove(key)),
                titleEn: 'Government ID Verification',
                titleNe: 'सरकारी परिचय-पत्र (सत्यापन)',
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
                            _t('Verify ID & Start Hiring',
                                'सुरक्षित गर्नुहोस्'),
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
