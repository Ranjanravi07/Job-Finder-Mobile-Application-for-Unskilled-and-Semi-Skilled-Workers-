import 'dart:io';

import 'package:flutter/material.dart';

import '../services/app_store.dart';
import '../services/image_pick_service.dart';
import '../theme/app_colors.dart';

class GovIdValidationResult {
  final bool isValid;
  final String? errorMessageEn;
  final String? errorMessageNe;

  GovIdValidationResult({
    required this.isValid,
    this.errorMessageEn,
    this.errorMessageNe,
  });

  String message(String lang) => lang == 'ne'
      ? (errorMessageNe ?? errorMessageEn ?? '')
      : (errorMessageEn ?? '');
}

String _getTypeNameEn(String type) {
  switch (type) {
    case 'citizenship':
      return 'Citizenship';
    case 'nid':
      return 'National ID';
    case 'license':
    case 'driving_license':
      return 'Driving License';
    case 'pan':
    case 'pan_card':
      return 'PAN Card';
    default:
      return 'Government ID';
  }
}

String _getTypeNameNe(String type) {
  switch (type) {
    case 'citizenship':
      return 'नागरिकता';
    case 'nid':
      return 'राष्ट्रिय परिचयपत्र';
    case 'license':
    case 'driving_license':
      return 'ड्राइभिङ लाइसेन्स';
    case 'pan':
    case 'pan_card':
      return 'प्यान कार्ड';
    default:
      return 'सरकारी परिचयपत्र';
  }
}

bool isValidGovIdNumber(String type, String idNum) {
  final clean = idNum.trim();
  if (clean.isEmpty) return false;
  switch (type) {
    case 'citizenship':
      return RegExp(r'^(\d{2}-\d{2}-\d{2}-\d{5}|\d+(/\d+)+|[a-zA-Z0-9\-\/]{4,25})$').hasMatch(clean);
    case 'nid':
      return RegExp(r'^(\d{10}|\d{3}-\d{3}-\d{3}-\d|\d{9,12})$').hasMatch(clean);
    case 'license':
    case 'driving_license':
      return RegExp(r'^(\d{2}-\d{2}-\d{8}|[a-zA-Z0-9\-]{5,20})$').hasMatch(clean);
    case 'pan':
    case 'pan_card':
      return RegExp(r'^\d{9}$').hasMatch(clean);
    default:
      return clean.length >= 3;
  }
}

GovIdValidationResult validateGovernmentIds({
  required List<String> selectedTypes,
  required Map<String, String> idNumbers,
  required Map<String, String> files,
}) {
  if (selectedTypes.isEmpty) {
    return GovIdValidationResult(
      isValid: false,
      errorMessageEn: 'Please select at least one Government ID.',
      errorMessageNe: 'कृपया कम्तीमा एउटा सरकारी परिचयपत्र छान्नुहोस्।',
    );
  }

  for (final type in selectedTypes) {
    final num = (idNumbers[type] ?? '').trim();
    final nameEn = _getTypeNameEn(type);
    final nameNe = _getTypeNameNe(type);

    if (num.isEmpty) {
      return GovIdValidationResult(
        isValid: false,
        errorMessageEn: 'Please enter your $nameEn number.',
        errorMessageNe: 'कृपया आफ्नो $nameNe नम्बर प्रविष्ट गर्नुहोस्।',
      );
    }

    if (!isValidGovIdNumber(type, num)) {
      return GovIdValidationResult(
        isValid: false,
        errorMessageEn: 'Please enter a valid $nameEn number.',
        errorMessageNe: 'कृपया अमान्य $nameNe नम्बर सच्याउनुहोस्।',
      );
    }

    if (type == 'citizenship') {
      final front = files['citizenship_front'] ?? files['front'] ?? '';
      final back = files['citizenship_back'] ?? files['back'] ?? '';
      if (front.isEmpty || back.isEmpty) {
        return GovIdValidationResult(
          isValid: false,
          errorMessageEn: 'Please upload both front and back images of your Citizenship card.',
          errorMessageNe: 'कृपया नागरिकताको अगाडि र पछाडिको फोटो अपलोड गर्नुहोस्।',
        );
      }
    } else {
      final img = files[type] ?? files['${type}_front'] ?? '';
      if (img.isEmpty) {
        return GovIdValidationResult(
          isValid: false,
          errorMessageEn: 'Please upload your $nameEn document.',
          errorMessageNe: 'कृपया आफ्नो $nameNe कागजात फोटो अपलोड गर्नुहोस्।',
        );
      }
    }
  }

  return GovIdValidationResult(isValid: true);
}

/// Reusable Multi-Selection "Government ID" upload section.
class GovIdSection extends StatefulWidget {
  const GovIdSection({
    super.key,
    required this.selectedTypes,
    required this.idNumbers,
    required this.onTypesChanged,
    required this.onNumChanged,
    required this.files,
    required this.onFilePicked,
    required this.onFileRemoved,
    this.titleEn = 'Government ID',
    this.titleNe = 'सरकारी परिचय-पत्र',
  });

  final List<String> selectedTypes;
  final Map<String, String> idNumbers;
  final ValueChanged<List<String>> onTypesChanged;
  final void Function(String type, String number) onNumChanged;

  /// Keys: citizenship_front, citizenship_back, nid, license, pan.
  final Map<String, String> files;
  final void Function(String key, String value) onFilePicked;
  final void Function(String key) onFileRemoved;

  final String titleEn;
  final String titleNe;

  @override
  State<GovIdSection> createState() => _GovIdSectionState();
}

class _GovIdSectionState extends State<GovIdSection> {
  bool get _isNe => AppStore.instance.lang == 'ne';

  String _label(String en, String ne) => _isNe ? ne : en;

  final Map<String, TextEditingController> _controllers = {};

  final List<Map<String, String>> _availableTypes = [
    {'id': 'citizenship', 'en': 'Citizenship', 'ne': 'नागरिकता'},
    {'id': 'nid', 'en': 'National ID (NID)', 'ne': 'राष्ट्रिय परिचयपत्र (NID)'},
    {'id': 'license', 'en': 'Driving License', 'ne': 'सवारी चालक अनुमति'},
    {'id': 'pan', 'en': 'PAN Card', 'ne': 'प्यान कार्ड'},
  ];

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant GovIdSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  void _syncControllers() {
    for (final item in _availableTypes) {
      final id = item['id']!;
      final currentNum = widget.idNumbers[id] ?? '';
      if (!_controllers.containsKey(id)) {
        _controllers[id] = TextEditingController(text: currentNum);
      } else if (_controllers[id]!.text != currentNum) {
        _controllers[id]!.text = currentNum;
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _toggleType(String typeId) {
    final list = List<String>.from(widget.selectedTypes);
    if (list.contains(typeId)) {
      list.remove(typeId);
    } else {
      list.add(typeId);
    }
    widget.onTypesChanged(list);
  }

  void _pick(String key) async {
    final path = await ImagePickService.instance.pickImage();
    if (path != null && mounted) {
      widget.onFilePicked(key, path);
    }
  }

  Widget _fileSlot(String key, String labelEn, String labelNe) {
    final path = widget.files[key] ?? widget.files[key.replaceFirst('citizenship_', '')] ?? '';
    final hasFile = path.isNotEmpty;
    return GestureDetector(
      onTap: hasFile ? null : () => _pick(key),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.appColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFile
                ? context.appColors.indigo600
                : context.appColors.slate300,
            width: 2,
          ),
        ),
        child: hasFile
            ? Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(path),
                      width: 90,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => SizedBox(
                        width: 90,
                        height: 52,
                        child: Icon(Icons.insert_drive_file,
                            color: context.appColors.slate600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(Icons.refresh,
                            size: 14, color: context.appColors.slate700),
                        tooltip: _label('Replace', 'बदल्नुहोस्'),
                        onPressed: () => _pick(key),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(Icons.close,
                            size: 14, color: context.appColors.white),
                        style: IconButton.styleFrom(
                            backgroundColor: context.appColors.red500),
                        tooltip: _label('Delete', 'मेटाउनुहोस्'),
                        onPressed: () => widget.onFileRemoved(key),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                children: [
                  Icon(Icons.upload_file_rounded,
                      color: context.appColors.slate600),
                  const SizedBox(height: 6),
                  Text(
                    _label(labelEn, labelNe),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: context.appColors.slate700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.appColors.slate50,
                      border: Border.all(color: context.appColors.slate200),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _label('Upload', 'फाइल छान्नुहोस्'),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.slate100.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.shield_rounded,
                  size: 18, color: context.appColors.indigo600),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _label(widget.titleEn, widget.titleNe),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: context.appColors.slate900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: context.appColors.indigo600.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _label('MIN 1 • MAX 4', 'कम्तीमा १ • धेरैमा ४'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: context.appColors.indigo600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _label('Select one or more Government IDs to submit:',
                'कम्तीमा एउटा वा बढी सरकारी परिचय-पत्र छान्नुहोस्:'),
            style: TextStyle(
              fontSize: 13,
              color: context.appColors.slate600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),

          // ID Selection Checkboxes Grid
          Column(
            children: _availableTypes.map((item) {
              final id = item['id']!;
              final isSelected = widget.selectedTypes.contains(id);
              return GestureDetector(
                onTap: () => _toggleType(id),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.appColors.indigo600.withValues(alpha: 0.08)
                        : context.appColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? context.appColors.indigo600
                          : context.appColors.slate300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        color: isSelected
                            ? context.appColors.indigo600
                            : context.appColors.slate600,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _label(item['en']!, item['ne']!),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: context.appColors.slate900,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          // Render inputs for each selected ID type
          if (widget.selectedTypes.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 10),
            ...widget.selectedTypes.map((typeId) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.appColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.appColors.slate300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified_rounded,
                            size: 16, color: context.appColors.indigo600),
                        const SizedBox(width: 6),
                        Text(
                          _label(_getTypeNameEn(typeId), _getTypeNameNe(typeId)),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: context.appColors.slate900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _idNumberHint(typeId),
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: context.appColors.slate800,
                          fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _controllers[typeId],
                      onChanged: (val) => widget.onNumChanged(typeId, val),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: _label('Enter ID number', 'नम्बर प्रविष्ट गर्नुहोस्'),
                        hintStyle: TextStyle(
                            fontSize: 13, color: context.appColors.slate600),
                        filled: true,
                        fillColor: context.appColors.slate50,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: context.appColors.slate300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (typeId == 'citizenship')
                      Row(
                        children: [
                          Expanded(
                              child: _fileSlot('citizenship_front',
                                  'Citizenship - Front', 'नागरिकता - अगाडि')),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _fileSlot('citizenship_back',
                                  'Citizenship - Back', 'नागरिकता - पछाडि')),
                        ],
                      )
                    else
                      _fileSlot(
                        typeId,
                        _typeSingleLabel(typeId),
                        _typeSingleLabelNe(typeId),
                      ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  String _typeSingleLabel(String type) {
    switch (type) {
      case 'nid':
        return 'Upload NID Document';
      case 'license':
        return 'Upload License Document';
      case 'pan':
        return 'Upload PAN Document';
      default:
        return 'Upload Document';
    }
  }

  String _typeSingleLabelNe(String type) {
    switch (type) {
      case 'nid':
        return 'NID फोटो अपलोड गर्नुहोस्';
      case 'license':
        return 'ड्राइभिङ लाइसेन्स फोटो';
      case 'pan':
        return 'प्यान कार्ड फोटो';
      default:
        return 'फाइल अपलोड गर्नुहोस्';
    }
  }

  String _idNumberHint(String type) {
    switch (type) {
      case 'citizenship':
        return _label('Citizenship Number', 'नागरिकता नम्बर');
      case 'nid':
        return _label('National ID (NID) Number', 'राष्ट्रिय परिचयपत्र नम्बर');
      case 'license':
        return _label('Driving License Number', 'लाइसेन्स नम्बर');
      case 'pan':
        return _label('PAN Number', 'प्यान नम्बर');
      default:
        return _label('ID Number', 'आईडी नम्बर');
    }
  }
}
