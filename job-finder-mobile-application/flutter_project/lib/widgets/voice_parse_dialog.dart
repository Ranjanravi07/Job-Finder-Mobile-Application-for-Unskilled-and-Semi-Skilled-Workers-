import 'package:flutter/material.dart';

import '../services/app_store.dart';
import '../services/voice_parser.dart';
import '../theme/app_colors.dart';

class _Preset {
  final String labelEn;
  final String labelNe;
  final String textEn;
  final String textNe;

  const _Preset(this.labelEn, this.labelNe, this.textEn, this.textNe);
}

const List<_Preset> _presets = [
  _Preset(
    'Dictate: Suresh Kumar BK, Painter, Balkumari, 1100 per day',
    'बोल्नुहोस्: सुरेश कुमार विक, पेन्टर, बालकुमारी, दिनको ११००',
    'My name is Suresh Kumar BK. I am an experienced house painter from Balkumari Lalitpur. '
        'I am looking for exterior or interior painting jobs. My daily wage expectation is eleven hundred rupees. '
        'I am ready to start immediately.',
    'मेरो नाम सुरेश कुमार विक हो। म बालकुमारी ललितपुरमा बस्छु र म पेन्टरको काम गर्छु। '
        'मलाई रंगरोगनको काममा २ वर्षको अनुभव छ। मलाई प्रतिदिन एघार सय रुपैयाँ ज्याला चाहिन्छ र म तुरुन्तै काम गर्न सक्छु।',
  ),
  _Preset(
    'Dictate: Ram Bahadur, Plumber, Sanepa, 1500 per day',
    'बोल्नुहोस्: राम बहादुर, प्लम्बर, सानेपा, दिनको १५००',
    'Hello, I am Ram Bahadur. I am a plumber living in Sanepa Lalitpur. '
        'I have a tool kit and can do complete pipe fitting and leakage repairs. '
        'I expect fifteen hundred rupees daily pay.',
    'नमस्ते म राम बहादुर हो। म सानेपा ललितपुरमा बस्ने प्लम्बर कामदार हुँ। '
        'म खानेपानी पाइप फिटिङ र चुहावट मर्मतको काम गर्छु। मेरो दैनिक ज्याला १५०० रुपैयाँ हो।',
  ),
];

/// Smart voice-parsing wizard dialog.
///
/// Mirrors the React `SMART VOICE PARSING WIZARD` modal in `MobileSimulator.tsx`.
class VoiceParseDialog extends StatefulWidget {
  const VoiceParseDialog({super.key, required this.onConfirm});

  final void Function(Map<String, dynamic> profile) onConfirm;

  @override
  State<VoiceParseDialog> createState() => _VoiceParseDialogState();
}

class _VoiceParseDialogState extends State<VoiceParseDialog> {
  late final TextEditingController _speechController = TextEditingController();
  bool _parsing = false;
  Map<String, dynamic>? _parsed;

  bool get _isNe => AppStore.instance.lang == 'ne';

  void _parse(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _parsing = true;
    });
    // Simulate a network round-trip to the parsing API.
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _parsing = false;
        _parsed = VoiceParser.parse(text, AppStore.instance.lang);
      });
    });
  }

  @override
  void dispose() {
    _speechController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.appColors.slate900,
      insetPadding: EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded,
                      color: context.appColors.emerald500, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Gemini Voice Onboarding',
                      style: TextStyle(
                        color: context.appColors.emerald400,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close',
                      style: TextStyle(
                          color: context.appColors.slate600,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                _isNe
                    ? 'सिमुलेटरमा आवाज रेकर्ड गर्न तलका कुनै पनि उदाहरण थिच्नुहोस् वा आफ्नै वाक्य टाइप गर्नुहोस्। एआईले तपाइको विवरण पत्ता लगाउनेछ!'
                    : 'Tap any preset speech dictation below to simulate speaking, or type your own description. '
                        'The AI will extract name, skill, location, and daily wages!',
                style: TextStyle(
                  color: context.appColors.slate300,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 12),
              Text(
                _isNe ? 'उदाहरणहरू' : 'Preset Speaking Examples',
                style: TextStyle(
                  color: context.appColors.slate700,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              ..._presets.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      final text = _isNe ? p.textNe : p.textEn;
                      _speechController.text = text;
                      _parse(text);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.appColors.slate800),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isNe ? p.labelNe : p.labelEn,
                            style: TextStyle(
                              color: context.appColors.emerald400,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '"${_isNe ? p.textNe : p.textEn}"',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.appColors.slate600,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _speechController,
                maxLines: 3,
                style: TextStyle(color: context.appColors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: _isNe
                      ? 'मेरो नाम श्याम हो। म सिकर्मी हुँ...'
                      : 'Speak/type your work interest...',
                  hintStyle: TextStyle(color: context.appColors.slate700),
                  filled: true,
                  fillColor: Color(0xFF0F172A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.appColors.slate800),
                  ),
                ),
              ),
              if (_speechController.text.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _parse(_speechController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.appColors.emerald500,
                    foregroundColor: context.appColors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Parse with Gemini AI',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
              if (_parsing) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.appColors.slate800),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: context.appColors.emerald400,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _isNe
                            ? 'एआईले आवाज विश्लेषण गर्दैछ...'
                            : 'AI is parsing speech...',
                        style: TextStyle(
                          color: context.appColors.slate300,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_parsed != null && !_parsing) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: context.appColors.emerald500
                            .withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: context.appColors.emerald400, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Extracted Details',
                            style: TextStyle(
                              color: context.appColors.emerald400,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _DetailRow(
                          icon: '👤',
                          label: 'Name:',
                          value: '${_parsed!['name']}'),
                      _DetailRow(
                          icon: '🛠️',
                          label: 'Skill:',
                          value: '${_parsed!['mainSkill']}'),
                      _DetailRow(
                          icon: '💰',
                          label: 'Wage:',
                          value: 'Rs. ${_parsed!['expectedWage']} / day'),
                      _DetailRow(
                          icon: '📍',
                          label: 'Location:',
                          value: '${_parsed!['location']}'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _parsed = null;
                                });
                              },
                              child: Text(
                                'Discard',
                                style: TextStyle(
                                  color: context.appColors.slate600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onConfirm(_parsed!);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.appColors.emerald500,
                                foregroundColor: context.appColors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Confirm & Save Profile',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
                text: '$icon ',
                style: TextStyle(color: context.appColors.slate300)),
            TextSpan(
              text: '$label ',
              style: TextStyle(
                color: context.appColors.slate300,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: context.appColors.slate300,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
