import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/employer_profile.dart';
import '../models/worker_profile.dart';
import '../services/app_store.dart';
import '../services/firebase_service.dart';
import '../theme/app_colors.dart';
import 'gov_id_section.dart';
import 'profile_photo_picker.dart';

/// Complete Profile & Government ID / KYC Update dialog.
class UpdateKycDialog extends StatefulWidget {
  final String collection; // 'workers' or 'employers'
  final String userId;
  final String currentGovIdType;
  final String currentGovIdNum;

  const UpdateKycDialog({
    super.key,
    required this.collection,
    required this.userId,
    this.currentGovIdType = 'citizenship',
    this.currentGovIdNum = '',
  });

  @override
  State<UpdateKycDialog> createState() => _UpdateKycDialogState();
}

class _UpdateKycDialogState extends State<UpdateKycDialog> {
  AppStore get store => AppStore.instance;
  bool get _isWorker => widget.collection == 'workers';
  bool get _isNe => store.lang == 'ne';
  String _t(String en, String ne) => _isNe ? ne : en;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _locController;

  // Worker specific
  late TextEditingController _expController;
  late String _selectedCategory;

  // Employer specific
  late TextEditingController _roleController;
  late TextEditingController _companyController;

  String _photoPath = '';
  late List<String> _selectedGovTypes;
  final Map<String, String> _govIdNumbers = {};
  final Map<String, String> _files = {};
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _jobCategories = [
    {'id': 'laborer', 'en': 'Laborer', 'ne': 'मजदुर'},
    {'id': 'electrician', 'en': 'Electrician', 'ne': 'इलेक्ट्रिसियन'},
    {'id': 'plumber', 'en': 'Plumber', 'ne': 'प्लम्बर'},
    {'id': 'driver', 'en': 'Driver', 'ne': 'ड्राइभर'},
    {'id': 'painter', 'en': 'Painter', 'ne': 'पेन्टर'},
    {'id': 'carpenter', 'en': 'Carpenter', 'ne': 'सिकर्मी'},
    {'id': 'mason', 'en': 'Mason', 'ne': 'डकर्मी'},
    {'id': 'cleaner', 'en': 'Cleaner', 'ne': 'सफाई गर्ने'},
    {'id': 'farmer', 'en': 'Farmer', 'ne': 'किसान'},
    {'id': 'cook', 'en': 'Cook', 'ne': 'भान्छे'},
    {'id': 'welder', 'en': 'Welder', 'ne': 'वेल्डर'},
    {'id': 'tailor', 'en': 'Tailor', 'ne': 'सुचिकार'},
    {'id': 'others', 'en': 'Others', 'ne': 'अन्य'},
  ];

  @override
  void initState() {
    super.initState();

    if (_isWorker) {
      final WorkerProfile w = store.workers.firstWhere(
        (item) => item.id == widget.userId,
        orElse: () => store.activeWorker ??
            WorkerProfile(
              id: widget.userId,
              name: '',
              phone: store.phone,
              mainSkill: 'laborer',
              experience: 'Fresher',
              expectedWage: 1000,
              expectedWageType: 'daily',
              location: 'Balkumari, Lalitpur',
              availability: 'Immediate',
            ),
      );

      _nameController = TextEditingController(text: w.name);
      _phoneController = TextEditingController(text: w.phone.isNotEmpty ? w.phone : store.phone);
      _locController = TextEditingController(
          text: w.location.isNotEmpty ? w.location : 'Balkumari, Lalitpur');
      _expController = TextEditingController(text: w.experience.isNotEmpty ? w.experience : 'Fresher');
      _selectedCategory =
          w.mainSkill.isNotEmpty ? w.mainSkill : 'laborer';
      _photoPath = w.profilePhoto;

      _roleController = TextEditingController();
      _companyController = TextEditingController();

      _initGovIds(w.governmentIds, w.govIdType, w.govIdNum, w.govIdFiles);
    } else {
      final EmployerProfile e = store.employers.firstWhere(
        (item) => item.id == widget.userId,
        orElse: () => store.activeEmployer ??
            EmployerProfile(
              id: widget.userId,
              name: '',
              companyName: 'Individual',
              phone: store.phone,
              location: 'Balkumari, Lalitpur',
            ),
      );

      _nameController = TextEditingController(text: e.name);
      _phoneController = TextEditingController(text: e.phone.isNotEmpty ? e.phone : store.phone);
      _locController = TextEditingController(
          text: e.location.isNotEmpty ? e.location : 'Balkumari, Lalitpur');
      _roleController = TextEditingController(text: e.role.isNotEmpty ? e.role : 'Contractor');
      _companyController =
          TextEditingController(text: e.companyName.isNotEmpty ? e.companyName : 'Individual');
      _photoPath = e.profilePhoto;

      _expController = TextEditingController();
      _selectedCategory = 'laborer';

      _initGovIds(e.governmentIds, e.govIdType, e.govIdNum, e.govIdFiles);
    }
  }

  void _initGovIds(
    Map<String, Map<String, dynamic>>? govIdsMap,
    String? fallbackType,
    String? fallbackNum,
    List<String>? fallbackFiles,
  ) {
    if (govIdsMap != null && govIdsMap.isNotEmpty) {
      _selectedGovTypes = govIdsMap.keys.toList();
      for (final entry in govIdsMap.entries) {
        final key = entry.key;
        final val = entry.value;
        _govIdNumbers[key] = val['idNumber'] as String? ?? '';
        final docs = (val['documentFiles'] as List?)?.cast<String>() ?? [];
        if (key == 'citizenship') {
          if (docs.isNotEmpty) _files['citizenship_front'] = docs[0];
          if (docs.length > 1) _files['citizenship_back'] = docs[1];
        } else if (docs.isNotEmpty) {
          _files[key] = docs[0];
        }
      }
    } else {
      final initType = (fallbackType ?? widget.currentGovIdType).isNotEmpty
          ? (fallbackType ?? widget.currentGovIdType)
          : 'citizenship';
      _selectedGovTypes = [initType];
      final num = fallbackNum ?? widget.currentGovIdNum;
      if (num.isNotEmpty) {
        _govIdNumbers[initType] = num;
      }
      if (fallbackFiles != null && fallbackFiles.isNotEmpty) {
        if (initType == 'citizenship') {
          _files['citizenship_front'] = fallbackFiles[0];
          if (fallbackFiles.length > 1) {
            _files['citizenship_back'] = fallbackFiles[1];
          }
        } else {
          _files[initType] = fallbackFiles[0];
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locController.dispose();
    _expController.dispose();
    _roleController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // 1. Validate complete profile fields
    if (_nameController.text.trim().isEmpty) {
      _showError(_t('Please enter your full name.',
          'कृपया आफ्नो पूरा नाम प्रविष्ट गर्नुहोस्।'));
      return;
    }
    if (_locController.text.trim().isEmpty) {
      _showError(_t('Please enter your location.',
          'कृपया स्थान प्रविष्ट गर्नुहोस्।'));
    }
    if (_isWorker) {
      if (_selectedCategory.isEmpty) {
        _showError(_t('Please select your job category.',
            'कृपया कामको वर्ग छान्नुहोस्।'));
        return;
      }
      if (_expController.text.trim().isEmpty) {
        _showError(_t('Please enter your experience.',
            'कृपया अनुभव प्रविष्ट गर्नुहोस्।'));
        return;
      }
    } else {
      if (_roleController.text.trim().isEmpty) {
        _showError(_t('Please enter your role / title.',
            'कृपया भूमिका प्रविष्ट गर्नुहोस्।'));
        return;
      }
    }

    // 2. Validate Government IDs
    final kycVal = validateGovernmentIds(
      selectedTypes: _selectedGovTypes,
      idNumbers: _govIdNumbers,
      files: _files,
    );

    if (!kycVal.isValid) {
      _showError(kycVal.message(store.lang));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String uploadedPhoto = _photoPath;
      if (uploadedPhoto.isNotEmpty) {
        uploadedPhoto = await FirebaseService.instance.uploadFile(
          uploadedPhoto,
          'profile_photos/${widget.userId}/avatar.jpg',
        );
      }

      final Map<String, Map<String, dynamic>> govMap = {};
      for (final type in _selectedGovTypes) {
        final idNum = (_govIdNumbers[type] ?? '').trim();
        final docs = <String>[];
        if (type == 'citizenship') {
          final f = _files['citizenship_front'] ?? _files['front'] ?? '';
          final b = _files['citizenship_back'] ?? _files['back'] ?? '';
          if (f.isNotEmpty) {
            final upF = await FirebaseService.instance.uploadFile(
              f,
              'kyc/${widget.userId}/citizenship_front.jpg',
            );
            docs.add(upF);
          }
          if (b.isNotEmpty) {
            final upB = await FirebaseService.instance.uploadFile(
              b,
              'kyc/${widget.userId}/citizenship_back.jpg',
            );
            docs.add(upB);
          }
        } else {
          final img = _files[type] ?? _files['${type}_front'] ?? '';
          if (img.isNotEmpty) {
            final upImg = await FirebaseService.instance.uploadFile(
              img,
              'kyc/${widget.userId}/$type.jpg',
            );
            docs.add(upImg);
          }
        }
        govMap[type] = {
          'idNumber': idNum,
          'documentFiles': docs,
          'submittedAt': DateTime.now().toIso8601String(),
        };
      }

      final List<String> allGovFiles = [];
      for (final g in govMap.values) {
        final dList = (g['documentFiles'] as List?)?.cast<String>() ?? [];
        allGovFiles.addAll(dList);
      }

      final primaryType = _selectedGovTypes.first;
      final primaryNum = _govIdNumbers[primaryType] ?? '';

      final Map<String, dynamic> updatePayload = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'location': _locController.text.trim(),
        'profilePhoto': uploadedPhoto,
        'govIdType': primaryType,
        'govIdNum': primaryNum.trim(),
        'govIdFiles': allGovFiles,
        'governmentIds': govMap,
        'verificationStatus': 'pending',
      };

      if (_isWorker) {
        updatePayload['mainSkill'] = _selectedCategory;
        updatePayload['experience'] = _expController.text.trim();
      } else {
        updatePayload['role'] = _roleController.text.trim();
        updatePayload['companyName'] = _companyController.text.trim().isNotEmpty
            ? _companyController.text.trim()
            : 'Individual';
      }

      // Save to Firebase
      await FirebaseService.instance.updateKycAndProfile(
        collection: widget.collection,
        userId: widget.userId,
        data: updatePayload,
      );

      // Update local AppStore state
      if (_isWorker) {
        store.updateWorkerProfile(updatePayload, widget.userId);
      } else {
        store.updateEmployerProfile(updatePayload, widget.userId);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_t(
              'KYC & Profile submitted for verification. Verification status set to PENDING.',
              'KYC र प्रोफाइल प्रमाणीकरणको लागि पेश गरियो। प्रमाणीकरण स्थिति पेन्डिङमा छ।',
            )),
            backgroundColor: context.appColors.emerald500,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to update KYC: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: context.appColors.red500),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: context.appColors.slate600),
      filled: true,
      fillColor: context.appColors.slate50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: context.appColors.slate300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: context.appColors.white,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _t('Update KYC & Complete Profile',
                          'KYC तथा पूरा प्रोफाइल अद्यावधिक'),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.appColors.slate900,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: context.appColors.slate600),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Profile photo picker
              Center(
                child: ProfilePhotoPicker(
                  photoPath: _photoPath,
                  onChanged: (val) => setState(() => _photoPath = val),
                  labelEn: 'Profile Photo',
                  labelNe: 'प्रोफाइल फोटो',
                ),
              ),
              const SizedBox(height: 16),

              // Full Name
              Text(_t('Full Name', 'पूरा नाम'),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: context.appColors.slate800)),
              const SizedBox(height: 4),
              TextField(
                controller: _nameController,
                decoration: _inputDecoration(hint: 'e.g. Ravi Ranjan Sah'),
              ),
              const SizedBox(height: 12),

              // Phone Number & Location Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_t('Phone Number', 'फोन नम्बर'),
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: context.appColors.slate800)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration(hint: '98XXXXXXXX'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_t('Primary Location', 'स्थान'),
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: context.appColors.slate800)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _locController,
                          decoration: _inputDecoration(hint: 'e.g. Kathmandu'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Role specific inputs
              if (_isWorker) ...[
                Text(_t('Job Category / Skill', 'कामको वर्ग / सीप'),
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: context.appColors.slate800)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory.isNotEmpty
                      ? _selectedCategory
                      : 'laborer',
                  isExpanded: true,
                  decoration: _inputDecoration(),
                  items: _jobCategories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat['id'] as String,
                      child: Text(_t(cat['en'] as String, cat['ne'] as String)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                const SizedBox(height: 12),
                Text(_t('Experience', 'अनुभव'),
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: context.appColors.slate800)),
                const SizedBox(height: 4),
                TextField(
                  controller: _expController,
                  decoration: _inputDecoration(hint: 'e.g. 2 Years / Fresher'),
                ),
              ] else ...[
                Text(_t('Role / Title', 'भूमिका / पद'),
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: context.appColors.slate800)),
                const SizedBox(height: 4),
                TextField(
                  controller: _roleController,
                  decoration: _inputDecoration(hint: 'e.g. Contractor'),
                ),
                const SizedBox(height: 12),
                Text(_t('Company / Firm Name', 'कम्पनीको नाम'),
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: context.appColors.slate800)),
                const SizedBox(height: 4),
                TextField(
                  controller: _companyController,
                  decoration: _inputDecoration(hint: 'e.g. Gupta Construction'),
                ),
              ],
              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 10),

              // Multi-Selection Government ID section
              GovIdSection(
                selectedTypes: _selectedGovTypes,
                idNumbers: _govIdNumbers,
                onTypesChanged: (types) =>
                    setState(() => _selectedGovTypes = types),
                onNumChanged: (type, idNum) =>
                    setState(() => _govIdNumbers[type] = idNum),
                files: _files,
                onFilePicked: (key, value) =>
                    setState(() => _files[key] = value),
                onFileRemoved: (key) => setState(() => _files.remove(key)),
                titleEn: 'Government ID Documents',
                titleNe: 'सरकारी परिचय-पत्र कागजातहरू',
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appColors.emerald500,
                  foregroundColor: context.appColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: context.appColors.white, strokeWidth: 2),
                      )
                    : Text(
                        _t('Submit Complete Profile & KYC',
                            'पूरा प्रोफाइल र KYC पेश गर्नुहोस्'),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
