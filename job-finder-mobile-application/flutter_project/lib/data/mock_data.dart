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
  SkillCategory(id: 'laborer', nameEn: 'Laborer', nameNe: 'मजदुर', icon: 'Users'),
  SkillCategory(id: 'electrician', nameEn: 'Electrician', nameNe: 'इलेक्ट्रिसियन', icon: 'Zap'),
  SkillCategory(id: 'plumber', nameEn: 'Plumber', nameNe: 'प्लम्बर', icon: 'Droplet'),
  SkillCategory(id: 'driver', nameEn: 'Driver', nameNe: 'ड्राइभर', icon: 'Car'),
  SkillCategory(id: 'painter', nameEn: 'Painter', nameNe: 'पेन्टर', icon: 'Paintbrush'),
  SkillCategory(id: 'carpenter', nameEn: 'Carpenter', nameNe: 'सिकर्मी', icon: 'Wrench'),
  SkillCategory(id: 'mason', nameEn: 'Mason', nameNe: 'डकर्मी', icon: 'Hammer'),
  SkillCategory(id: 'cleaner', nameEn: 'Cleaner', nameNe: 'सफाई गर्ने', icon: 'Home'),
  SkillCategory(id: 'farmer', nameEn: 'Farmer', nameNe: 'किसान', icon: 'Sun'),
  SkillCategory(id: 'cook', nameEn: 'Cook', nameNe: 'भान्छे', icon: 'Coffee'),
  SkillCategory(id: 'welder', nameEn: 'Welder', nameNe: 'वेल्डर', icon: 'Settings'),
  SkillCategory(id: 'tailor', nameEn: 'Tailor', nameNe: 'सुचिकार', icon: 'Scissors'),
  SkillCategory(id: 'others', nameEn: 'Others', nameNe: 'अन्य', icon: 'List'),
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
