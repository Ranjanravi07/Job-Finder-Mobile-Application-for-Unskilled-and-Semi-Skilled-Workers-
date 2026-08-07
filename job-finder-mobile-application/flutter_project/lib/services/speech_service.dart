import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-speech helper.
///
/// Mirrors the `speakAloud` helper from `src/components/MobileSimulator.tsx`
/// (web `speechSynthesis`). Uses the `flutter_tts` plugin on mobile.
class SpeechService {
  SpeechService._();

  static final SpeechService instance = SpeechService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    try {
      await _tts.awaitSpeakCompletion(true);
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  Future<void> speak(String text, String lang) async {
    try {
      await _ensureInit();
      await _tts.stop();
      await _tts.setLanguage(lang == 'ne' ? 'ne-NP' : 'en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.speak(text);
    } catch (_) {
      // TTS is best-effort in the simulator; never crash the app.
    }
  }
}
