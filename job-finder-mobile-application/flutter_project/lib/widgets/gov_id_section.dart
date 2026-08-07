import 'dart:io';

import 'package:flutter/material.dart';

import '../services/app_store.dart';
import '../services/image_pick_service.dart';
import '../theme/app_colors.dart';

/// Reusable "Government ID" upload section used by both the worker and the
/// employer profile-creation screens.
///
/// Mirrors the React Government ID blocks in `MobileSimulator.tsx`.
class GovIdSection extends StatefulWidget {
  const GovIdSection({
    Key? key,
    required this.govIdType,
    required this.govIdNum,
    required this.onTypeChanged,
    required this.onNumChanged,
    required this.files,
    required this.onFilePicked,
    required this.onFileRemoved,
    this.showRegistration = false,
    this.titleEn = 'Government ID',
    this.titleNe = 'सरकारी परिचय-पत्र',
  }) : super(key: key);

  final String govIdType;
  final String govIdNum;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onNumChanged;

  /// Keys: front, back, nid, license, pan, registration. Value is a local
  /// image file path (empty string means not uploaded).
  final Map<String, String> files;
  final void Function(String key, String value) onFilePicked;
  final void Function(String key) onFileRemoved;

  final bool showRegistration;
  final String titleEn;
  final String titleNe;

  @override
  State<GovIdSection> createState() => _GovIdSectionState();
}

class _GovIdSectionState extends State<GovIdSection> {
  bool get _isNe => AppStore.instance.lang == 'ne';

  String _label(String en, String ne) => _isNe ? ne : en;

  void _pick(String key) async {
    final path = await ImagePickService.instance.pickImage();
    if (path != null && mounted) {
      widget.onFilePicked(key, path);
    }
  }

  Widget _fileSlot(String key, String labelEn, String labelNe) {
    final path = widget.files[key] ?? '';
    final hasFile = path.isNotEmpty;
    return GestureDetector(
      onTap: hasFile ? null : () => _pick(key),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFile ? AppColors.indigo600 : AppColors.slate300,
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
                      width: 80,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(
                        width: 80,
                        height: 48,
                        child: Icon(Icons.insert_drive_file, color: AppColors.slate400),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.refresh, size: 14, color: AppColors.slate700),
                        tooltip: _label('Replace', 'बदल्नुहोस्'),
                        onPressed: () => _pick(key),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close, size: 14, color: Colors.white),
                        style: IconButton.styleFrom(backgroundColor: AppColors.red500),
                        tooltip: _label('Delete', 'मेटाउनुहोस्'),
                        onPressed: () => widget.onFileRemoved(key),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                children: [
                  const Icon(Icons.upload_file_rounded, color: AppColors.slate400),
                  const SizedBox(height: 6),
                  Text(
                    _label(labelEn, labelNe),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      border: Border.all(color: AppColors.slate200),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _label('Upload', 'फाइल छान्नुहोस्'),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate600,
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.slate100.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_rounded, size: 16, color: AppColors.indigo600),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _label(widget.titleEn, widget.titleNe),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: AppColors.slate900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.indigo600.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _label('REQUIRED', 'अनिवार्य'),
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: AppColors.indigo600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: widget.govIdType,
                  isExpanded: true,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.slate200),
                    ),
                  ),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  items: _typeOptions(),
                  onChanged: (v) {
                    if (v != null) widget.onTypeChanged(v);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: widget.govIdNum),
                  onChanged: widget.onNumChanged,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: _label('ID Number', 'आईडी नम्बर'),
                    hintStyle: const TextStyle(fontSize: 11),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.slate200),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.govIdType == 'citizenship')
            Row(
              children: [
                Expanded(child: _fileSlot('front', 'Citizenship - Front', 'नागरिकता - अगाडि')),
                const SizedBox(width: 8),
                Expanded(child: _fileSlot('back', 'Citizenship - Back', 'नागरिकता - पछाडि')),
              ],
            )
          else
            _fileSlot(
              widget.govIdType,
              _typeSingleLabel(widget.govIdType),
              _typeSingleLabelNe(widget.govIdType),
            ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _typeOptions() {
    return [
      _opt('citizenship', 'Citizenship Card', 'नागरिकता प्रमाण-पत्र'),
      _opt('nid', 'National ID (NID)', 'राष्ट्रिय परिचयपत्र (NID)'),
      _opt('license', 'Driving License', 'सवारी चालक अनुमति'),
      _opt('pan', 'PAN / VAT Card', 'प्यान/भ्याट (PAN Card)'),
      if (widget.showRegistration)
        _opt('registration', 'Business Registry', 'कम्पनी दर्ता प्रमाण'),
    ];
  }

  DropdownMenuItem<String> _opt(String id, String en, String ne) {
    return DropdownMenuItem<String>(
      value: id,
      child: Text(_label(en, ne), overflow: TextOverflow.ellipsis),
    );
  }

  String _typeSingleLabel(String type) {
    switch (type) {
      case 'nid':
        return 'Upload NID photo';
      case 'license':
        return 'Upload License photo';
      case 'pan':
        return 'Upload PAN/VAT photo';
      case 'registration':
        return 'Upload Registry photo';
      default:
        return 'Upload file';
    }
  }

  String _typeSingleLabelNe(String type) {
    switch (type) {
      case 'nid':
        return 'NID फोटो अपलोड गर्नुहोस्';
      case 'license':
        return 'ड्राइभिङ लाइसेन्स फोटो अपलोड गर्नुहोस्';
      case 'pan':
        return 'PAN/VAT फोटो अपलोड गर्नुहोस्';
      case 'registration':
        return 'दर्ता फोटो अपलोड गर्नुहोस्';
      default:
        return 'फाइल अपलोड गर्नुहोस्';
    }
  }
}
