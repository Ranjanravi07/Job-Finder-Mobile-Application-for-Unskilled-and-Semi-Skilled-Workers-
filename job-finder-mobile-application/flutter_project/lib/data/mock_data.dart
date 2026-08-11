import '../models/job.dart';
import '../models/worker_profile.dart';
import '../models/employer_profile.dart';
import '../models/job_application.dart';
import '../models/chat_message.dart';

/// Skill categories with bilingual labels.
/// Mirrors `SKILL_CATEGORIES` from `src/data.ts`.
class SkillCategory {
  final String id;
  final String nameEn;
  final String nameNe;
  final String icon;

  const SkillCategory({
    required this.id,
    required this.nameEn,
    required this.nameNe,
    required this.icon,
  });
}

const List<SkillCategory> kSkillCategories = [
  SkillCategory(
      id: 'mason',
      nameEn: 'Mason / Bricklayer',
      nameNe: 'डकर्मी (ढुंगा/ईट्टा कामदार)',
      icon: 'Hammer'),
  SkillCategory(
      id: 'carpenter',
      nameEn: 'Carpenter',
      nameNe: 'सिकर्मी (काठ कामदार)',
      icon: 'Wrench'),
  SkillCategory(
      id: 'electrician',
      nameEn: 'Electrician',
      nameNe: 'इलेक्ट्रीशियन (बिजुली कामदार)',
      icon: 'Zap'),
  SkillCategory(
      id: 'plumber',
      nameEn: 'Plumber',
      nameNe: 'प्लम्बर (खानेपानी कामदार)',
      icon: 'Droplet'),
  SkillCategory(
      id: 'painter',
      nameEn: 'Painter',
      nameNe: 'पेन्टर (रंगरोगन कामदार)',
      icon: 'Paintbrush'),
  SkillCategory(
      id: 'driver', nameEn: 'Driver', nameNe: 'चालक (ड्राइभर)', icon: 'Car'),
  SkillCategory(
      id: 'laborer',
      nameEn: 'General Laborer',
      nameNe: 'साधारण मजदुर (लेबर)',
      icon: 'Users'),
  SkillCategory(
      id: 'domestic',
      nameEn: 'Domestic Helper',
      nameNe: 'घरेलु कामदार',
      icon: 'Home'),
];

/// Short label used inside category chips / selects (first word of name).
String skillShortLabel(SkillCategory cat, String lang) {
  final name = lang == 'ne' ? cat.nameNe : cat.nameEn;
  return name.split(' ').first;
}

/// Mirrors `NEPAL_LOCATIONS` from `src/data.ts`.
const List<String> kNepalLocations = [
  'Balkumari, Lalitpur',
  'Gwarko, Lalitpur',
  'Lagankhel, Lalitpur',
  'Koteshwor, Kathmandu',
  'Kalanki, Kathmandu',
  'Baneshwor, Kathmandu',
  'Chabahil, Kathmandu',
  'Sanepa, Lalitpur',
  'Tripureshwar, Kathmandu',
  'Chhipaharnawa, Parsa',
  'Janakpur Dham, Dhanusa',
  'Chipledhunga, Pokhara',
];

/// Mirrors `INITIAL_JOBS` from `src/data.ts`.
const List<Job> kInitialJobs = [];

/// Mirrors `INITIAL_WORKERS` from `src/data.ts`.
const List<WorkerProfile> kInitialWorkers = [];

/// Mirrors `INITIAL_APPLICATIONS` from `src/data.ts`.
const List<JobApplication> kInitialApplications = [];

/// Mirrors the inline initial `employers` state in `MobileSimulator.tsx`.
const List<EmployerProfile> kInitialEmployers = [];

/// Mirrors the inline initial `chatMessages` state in `MobileSimulator.tsx`.
Map<String, List<ChatMessage>> kInitialChatMessages() => {};
