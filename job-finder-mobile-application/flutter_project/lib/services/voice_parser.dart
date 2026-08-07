import '../data/mock_data.dart';

/// Simple local parser that mimics the server-side Gemini voice parsing used
/// by the React app (`/api/voice-parse`).
///
/// Returns profile fields extracted from a spoken/typed dictation.
class VoiceParser {
  VoiceParser._();

  static Map<String, dynamic> parse(String text, String lang) {
    final lower = text.toLowerCase();
    final result = <String, dynamic>{};

    // ---- Name -----------------------------------------------------------
    final nameMatch = RegExp(
      r"(?:my name is|i am|i'm)\s+([a-zA-Z][a-zA-Z\s]{2,20}?)(?=,|\.|$| and )",
      caseSensitive: false,
    ).firstMatch(text);
    if (nameMatch != null) {
      result['name'] = _titleCase(nameMatch.group(1)!.trim());
    } else {
      // Nepali: मेरो नाम X हो
      final neMatch =
          RegExp(r'मेरो नाम\s+([\u0900-\u097F\s]{2,30}?)(?=हो|।|\.|$)').firstMatch(text);
      if (neMatch != null) {
        result['name'] = neMatch.group(1)!.trim();
      }
    }
    result['name'] ??= lang == 'ne' ? 'हरि थापा' : 'Hari Thapa';

    // ---- Skill ----------------------------------------------------------
    final skillMap = <String, String>{
      'painter': 'painter',
      'paint': 'painter',
      'पेन्टर': 'painter',
      'रंगरोगन': 'painter',
      'plumber': 'plumber',
      'प्लम्बर': 'plumber',
      'पाइप': 'plumber',
      'mason': 'mason',
      'bricklayer': 'mason',
      'brick': 'mason',
      'डकर्मी': 'mason',
      'electrician': 'electrician',
      'wiring': 'electrician',
      'इलेक्ट्रीशियन': 'electrician',
      'बिजुली': 'electrician',
      'carpenter': 'carpenter',
      'सिकर्मी': 'carpenter',
      'driver': 'driver',
      'चालक': 'driver',
      'laborer': 'laborer',
      'मजदुर': 'laborer',
    };
    String? skill;
    for (final entry in skillMap.entries) {
      if (lower.contains(entry.key.toLowerCase())) {
        skill = entry.value;
        break;
      }
    }
    result['mainSkill'] = skill ?? 'laborer';

    // ---- Experience -----------------------------------------------------
    final expMatch = RegExp(r'(\d+)\s*(?:years|yrs|वर्ष|बर्ष)').firstMatch(text);
    if (expMatch != null) {
      result['experience'] = '${expMatch.group(1)} Years';
    } else {
      result['experience'] = 'Fresher';
    }

    // ---- Wage -----------------------------------------------------------
    final wageMatch =
        RegExp(r'(?:expect|expecting|daily wage|daily pay|ज्याला|प्रतिदिन)[\s:एघार]\D*?(\d{3,5})')
            .firstMatch(text);
    if (wageMatch != null) {
      result['expectedWage'] = int.tryParse(wageMatch.group(1)!) ?? 1000;
    } else {
      // fall back to the first standalone 3-4 digit number
      final anyWage = RegExp(r'\b(\d{3,4})\b').firstMatch(text);
      result['expectedWage'] = anyWage != null ? (int.tryParse(anyWage.group(1)!) ?? 1000) : 1000;
    }

    // ---- Location -------------------------------------------------------
    String? location;
    for (final loc in kNepalLocations) {
      if (lower.contains(loc.split(',')[0].toLowerCase())) {
        location = loc;
        break;
      }
    }
    result['location'] = location ?? 'Balkumari, Lalitpur';

    return result;
  }

  static String _titleCase(String input) {
    return input
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
