import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/job.dart';
import '../services/app_store.dart';
import '../theme/app_colors.dart';

/// Mirrors the React `ACTIVE JOB DETAILS` modal bottom sheet.
class JobDetailsSheet extends StatelessWidget {
  const JobDetailsSheet({Key? key, required this.job}) : super(key: key);

  final Job job;

  bool get _isNe => AppStore.instance.lang == 'ne';

  String _t(String en, String ne) => _isNe ? ne : en;

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/977${job.employerPhone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.slate200,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Title & Audio Play Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.slate900,
                      height: 1.3,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => store.playJobAudio(job),
                  tooltip: 'Read details audibly (TTS)',
                  icon: Icon(Icons.volume_up_rounded, color: AppColors.slate800),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.slate100,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Wage detail
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.emerald500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.emerald500.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _t('Expected Wage:', 'प्रस्तावित ज्याला:'),
                    style: TextStyle(
                      color: AppColors.emerald600,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Rs. ${job.wage} / Day',
                    style: TextStyle(
                      color: AppColors.emerald600,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Description
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('Job Details', 'विवरण').toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: AppColors.slate400,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  job.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.slate600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Technical meta data row
            Row(
              children: [
                Expanded(
                  child: _MetaCell(
                    label: _t('Location', 'ठेगाना'),
                    value: job.location,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _MetaCell(
                    label: _t('Employer', 'रोजगारदाता'),
                    value: job.employerName,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Direct Connect Options
            Text(
              _t('Direct Employer Connection', 'सिधा रोजगारदाता सम्पर्क'),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: AppColors.slate500,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      store.setCallingName(job.employerName);
                      store.setCallingPhone(job.employerPhone);
                    },
                    icon: Icon(Icons.call_rounded, size: 16),
                    label: Text(_t('Direct Call', 'सिधा फोन')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.slate900,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openWhatsApp,
                    icon: Icon(Icons.chat_rounded, size: 16),
                    label: Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _MetaCell extends StatelessWidget {
  const _MetaCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: AppColors.slate400,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColors.slate700,
          ),
        ),
      ],
    );
  }
}
