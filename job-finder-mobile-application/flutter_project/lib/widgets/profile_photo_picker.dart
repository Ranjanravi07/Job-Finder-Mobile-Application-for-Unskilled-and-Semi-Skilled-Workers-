import 'dart:io';

import 'package:flutter/material.dart';

import '../services/app_store.dart';
import '../services/image_pick_service.dart';
import '../theme/app_colors.dart';

/// Profile photo selector/uploader with replace + delete.
///
/// Mirrors the React profile-photo blocks in `MobileSimulator.tsx`.
class ProfilePhotoPicker extends StatelessWidget {
  const ProfilePhotoPicker({
    Key? key,
    required this.photoPath,
    required this.onChanged,
    this.size = 64,
    this.borderColor = AppColors.indigo600,
    this.labelEn = 'Profile Photo',
    this.labelNe = 'प्रोफाइल फोटो',
  }) : super(key: key);

  final String photoPath;
  final ValueChanged<String> onChanged;
  final double size;
  final Color borderColor;
  final String labelEn;
  final String labelNe;

  bool get _isNe => AppStore.instance.lang == 'ne';

  Future<void> _pick() async {
    final path = await ImagePickService.instance.pickImage();
    if (path != null) onChanged(path);
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath.isNotEmpty;
    final label = _isNe ? labelNe : labelEn;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: AppColors.slate400,
          ),
        ),
        const SizedBox(height: 8),
        if (hasPhoto)
          Stack(
            children: [
              ClipOval(
                child: Image.file(
                  File(photoPath),
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: size,
                    height: size,
                    color: AppColors.slate100,
                    child: const Icon(Icons.person, color: AppColors.slate400),
                  ),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _pick,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: const Icon(Icons.refresh, size: 14, color: AppColors.slate700),
                      ),
                    ),
                    const SizedBox(width: 2),
                    GestureDetector(
                      onTap: () => onChanged(''),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.red500,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        else
          GestureDetector(
            onTap: _pick,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.slate100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.slate300,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(Icons.person_add_alt_rounded, color: AppColors.slate400, size: size * 0.5),
            ),
          ),
        const SizedBox(height: 8),
        if (!hasPhoto)
          Text(
            _isNe ? 'फोटो अपलोड गर्नुहोस्' : 'Upload a single profile photo',
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.slate400,
            ),
          ),
      ],
    );
  }
}
