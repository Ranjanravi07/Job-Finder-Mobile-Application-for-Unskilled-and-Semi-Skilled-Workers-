import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/app_store.dart';
import '../theme/app_colors.dart';
import '../widgets/gov_id_section.dart';
import '../widgets/profile_photo_picker.dart';

/// Mirrors the React `EMPLOYER PROFILE CREATION` screen.
class EmployerProfileCreationScreen extends StatefulWidget {
  const EmployerProfileCreationScreen({Key? key}) : super(key: key);

  @override
  State<EmployerProfileCreationScreen> createState() =>
      _EmployerProfileCreationScreenState();
}

class _EmployerProfileCreationScreenState extends State<EmployerProfileCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController(text: 'Contractor');
  final TextEditingController _locController =
      TextEditingController(text: 'Balkumari, Lalitpur');
  final TextEditingController _companyController = TextEditingController();
  bool _isSubmitting = false;

  String _photoPath = '';
  String _govIdType = 'citizenship';
  String _govIdNum = '';
  final Map<String, String> _files = {};

  AppStore get store => AppStore.instance;

  bool get _isNe => store.lang == 'ne';

  String _t(String en, String ne) => _isNe ? ne : en;

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
      case 'registration':
        return RegExp(r'^[a-zA-Z0-9\-\/]+$').hasMatch(num);
      default:
        return num.isNotEmpty;
    }
  }

  Future<void> _submit() async {
    String? error;
    if (_nameController.text.trim().isEmpty) {
      error = _t('Please enter your full name.', 'कृपया आफ्नो पूरा नाम प्रविष्ट गर्नुहोस्।');
    } else if (_roleController.text.trim().isEmpty) {
      error = _t('Please enter your role / title.', 'कृपया भूमिका प्रविष्ट गर्नुहोस्।');
    } else if (_locController.text.trim().isEmpty) {
      error = _t('Please enter your location.', 'कृपया स्थान प्रविष्ट गर्नुहोस्।');
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
        ((_files['front'] ?? '').isEmpty || (_files['back'] ?? '').isEmpty)) {
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

    store.createEmployerProfile(
      name: _nameController.text.trim(),
      role: _roleController.text.trim(),
      location: _locController.text.trim(),
      companyName: _companyController.text.trim().isNotEmpty
          ? _companyController.text.trim()
          : 'Individual',
      govIdType: _govIdType,
      govIdNum: _govIdNum.trim(),
      govIdFiles: _files.values.toList(),
      profilePhoto: _photoPath,
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
        borderSide: BorderSide(color: AppColors.indigo600),
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
          _t('Employer Profile Setup', 'रोजगारदाता प्रोफाइल निर्माण'),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.slate900,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate200),
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
                style: TextStyle(color: AppColors.slate900, fontWeight: FontWeight.w600),
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
                          style: TextStyle(color: AppColors.slate900, fontWeight: FontWeight.w600),
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
                          style: TextStyle(color: AppColors.slate900, fontWeight: FontWeight.w600),
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
                style: TextStyle(color: AppColors.slate900, fontWeight: FontWeight.w600),
                decoration: _inputDecoration(hint: 'e.g. Gupta Construction'),
              ),
              const SizedBox(height: 20),

              // Government ID with registration option
              GovIdSection(
                govIdType: _govIdType,
                govIdNum: _govIdNum,
                onTypeChanged: (v) => setState(() => _govIdType = v),
                onNumChanged: (v) => setState(() => _govIdNum = v),
                files: _files,
                onFilePicked: (key, value) => setState(() => _files[key] = value),
                onFileRemoved: (key) => setState(() => _files.remove(key)),
                showRegistration: true,
                titleEn: 'Government ID Verification',
                titleNe: 'सरकारी परिचय-पत्र (सत्यापन)',
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
                            _t('Verify ID & Start Hiring', 'सुरक्षित गर्नुहोस्'),
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
}
