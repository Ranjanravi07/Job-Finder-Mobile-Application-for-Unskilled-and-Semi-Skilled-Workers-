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
  SkillCategory(id: 'mason', nameEn: 'Mason / Bricklayer', nameNe: 'डकर्मी (ढुंगा/ईट्टा कामदार)', icon: 'Hammer'),
  SkillCategory(id: 'carpenter', nameEn: 'Carpenter', nameNe: 'सिकर्मी (काठ कामदार)', icon: 'Wrench'),
  SkillCategory(id: 'electrician', nameEn: 'Electrician', nameNe: 'इलेक्ट्रीशियन (बिजुली कामदार)', icon: 'Zap'),
  SkillCategory(id: 'plumber', nameEn: 'Plumber', nameNe: 'प्लम्बर (खानेपानी कामदार)', icon: 'Droplet'),
  SkillCategory(id: 'painter', nameEn: 'Painter', nameNe: 'पेन्टर (रंगरोगन कामदार)', icon: 'Paintbrush'),
  SkillCategory(id: 'driver', nameEn: 'Driver', nameNe: 'चालक (ड्राइभर)', icon: 'Car'),
  SkillCategory(id: 'laborer', nameEn: 'General Laborer', nameNe: 'साधारण मजदुर (लेबर)', icon: 'Users'),
  SkillCategory(id: 'domestic', nameEn: 'Domestic Helper', nameNe: 'घरेलु कामदार', icon: 'Home'),
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
const List<Job> kInitialJobs = [
  Job(
    id: 'job-1',
    title: 'Daily Wage Brick Mason Needed',
    category: 'mason',
    description:
        'We need 3 experienced brick masons for a residential building construction in Balkumari. Lunch and tea will be provided at the site.',
    wage: 1200,
    wageType: 'daily',
    location: 'Balkumari, Lalitpur',
    employerId: 'emp-1',
    employerName: 'Ravi Ranjan Sah (Contractor)',
    employerPhone: '9841234567',
    employerWhatsApp: '9841234567',
    requiredSkills: ['Brick Laying', 'Plastering', 'Cement Mixing'],
    datePosted: '2026-07-06T10:00:00Z',
    lat: 27.6715,
    lng: 85.3395,
    applicantsCount: 1,
  ),
  Job(
    id: 'job-2',
    title: 'House Painting Helpers Wanted',
    category: 'painter',
    description:
        'Urgent requirement of 2 painters for high-quality exterior house painting. Brushes and safety gear provided. Wages paid daily.',
    wage: 1000,
    wageType: 'daily',
    location: 'Gwarko, Lalitpur',
    employerId: 'emp-2',
    employerName: 'Abdul Wahab Rain',
    employerPhone: '9803214567',
    employerWhatsApp: '9803214567',
    requiredSkills: ['Wall Scraping', 'Primer Coating', 'Exterior Painting'],
    datePosted: '2026-07-07T08:30:00Z',
    lat: 27.6675,
    lng: 85.3333,
    applicantsCount: 0,
  ),
  Job(
    id: 'job-3',
    title: 'Wiring Work for 3-Story Building',
    category: 'electrician',
    description:
        'Complete wiring of a newly built house. Materials are on-site. Looking for a lead electrician with experience in Nepali standard distribution boards.',
    wage: 8000,
    wageType: 'weekly',
    location: 'Sanepa, Lalitpur',
    employerId: 'emp-3',
    employerName: 'Ajay Kumar Sah',
    employerPhone: '9851098765',
    employerWhatsApp: '9851098765',
    requiredSkills: ['Conduit Fitting', 'DB Wiring', 'Switch Board Installation'],
    datePosted: '2026-07-07T12:00:00Z',
    lat: 27.6833,
    lng: 85.3050,
    applicantsCount: 2,
  ),
  Job(
    id: 'job-4',
    title: 'Water Pipe fitting & Repair',
    category: 'plumber',
    description:
        'Leak repair and new CPVC pipeline setup for a restaurant kitchen. Work is small but needs urgent attention today.',
    wage: 1500,
    wageType: 'daily',
    location: 'Lagankhel, Lalitpur',
    employerId: 'emp-1',
    employerName: 'Ravi Ranjan Sah (Contractor)',
    employerPhone: '9841234567',
    employerWhatsApp: '9841234567',
    requiredSkills: ['Leakage Repair', 'CPVC Pipe Fitting', 'Drainage Repair'],
    datePosted: '2026-07-07T14:15:00Z',
    lat: 27.6690,
    lng: 85.3210,
    applicantsCount: 0,
  ),
  Job(
    id: 'job-5',
    title: 'Experienced Tipper Driver Needed',
    category: 'driver',
    description:
        'Looking for a tipper driver with a valid heavy vehicle driving license for local site soil carrying. Must be honest and punctual.',
    wage: 1500,
    wageType: 'daily',
    location: 'Kalanki, Kathmandu',
    employerId: 'emp-4',
    employerName: 'Mohammad Faishal Rain',
    employerPhone: '9812345678',
    employerWhatsApp: '9812345678',
    requiredSkills: ['Heavy License', 'Tipper Driving', 'Vehicle Maintenance'],
    datePosted: '2026-07-05T09:00:00Z',
    lat: 27.6938,
    lng: 85.2811,
    applicantsCount: 0,
  ),
];

/// Mirrors `INITIAL_WORKERS` from `src/data.ts`.
const List<WorkerProfile> kInitialWorkers = [
  WorkerProfile(
    id: 'work-1',
    name: 'Hari Bahadur Shrestha',
    phone: '9845551122',
    mainSkill: 'mason',
    experience: '5 Years',
    expectedWage: 1200,
    expectedWageType: 'daily',
    location: 'Lagankhel, Lalitpur',
    availability: 'Immediate',
    bio: 'Dedicated brick mason. Have worked on over 10 housing projects in Kathmandu valley.',
  ),
  WorkerProfile(
    id: 'work-2',
    name: 'Suresh Kumar BK',
    phone: '9801122334',
    govIdType: 'citizenship',
    govIdNum: '11-22-33-44',
    mainSkill: 'painter',
    experience: '2 Years',
    expectedWage: 950,
    expectedWageType: 'daily',
    location: 'Balkumari, Lalitpur',
    availability: 'Immediate',
    bio: 'Fast house painter, specialized in exterior colors and textures.',
  ),
];

/// Mirrors `INITIAL_APPLICATIONS` from `src/data.ts`.
const List<JobApplication> kInitialApplications = [
  JobApplication(
    id: 'app-1',
    jobId: 'job-1',
    workerId: 'work-1',
    workerName: 'Hari Bahadur Shrestha',
    workerPhone: '9845551122',
    workerSkill: 'mason',
    status: 'pending',
    appliedAt: '2026-07-07T11:20:00Z',
  ),
];

/// Mirrors the inline initial `employers` state in `MobileSimulator.tsx`.
const List<EmployerProfile> kInitialEmployers = [
  EmployerProfile(
    id: 'emp-1',
    name: 'Ravi Ranjan Sah',
    companyName: 'Ravi Construction & Co.',
    phone: '9841234567',
    location: 'Balkumari, Lalitpur',
    verificationStatus: 'verified',
    type: 'individual',
    role: 'Contractor',
    govIdType: 'citizenship',
    govIdNum: '55-44-33-22',
    profilePhoto:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&h=150&q=80',
  ),
  EmployerProfile(
    id: 'emp-2',
    name: 'Abdul Wahab Rain',
    companyName: 'Rain Painting Services',
    phone: '9803214567',
    location: 'Gwarko, Lalitpur',
    verificationStatus: 'verified',
    type: 'individual',
    role: 'Contractor',
    govIdType: 'citizenship',
    govIdNum: '10-20-30-40',
    profilePhoto:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&h=150&q=80',
  ),
  EmployerProfile(
    id: 'emp-3',
    name: 'Ajay Kumar Sah',
    companyName: 'Sah Electrical Solutions',
    phone: '9851098765',
    location: 'Sanepa, Lalitpur',
    verificationStatus: 'verified',
    type: 'business',
    role: 'Business Owner',
    govIdType: 'citizenship',
    govIdNum: '99-88-77-66',
    profilePhoto:
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=150&h=150&q=80',
  ),
  EmployerProfile(
    id: 'emp-4',
    name: 'Mohammad Faishal Rain',
    companyName: 'Faishal Heavy Movers',
    phone: '9812345678',
    location: 'Kalanki, Kathmandu',
    verificationStatus: 'verified',
    type: 'business',
    role: 'Business Owner',
    govIdType: 'citizenship',
    govIdNum: '12-34-56-78',
    profilePhoto:
        'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=150&h=150&q=80',
  ),
];

/// Mirrors the inline initial `chatMessages` state in `MobileSimulator.tsx`.
Map<String, List<ChatMessage>> kInitialChatMessages() => {
      'Ravi Ranjan Sah': [
        const ChatMessage(
            sender: 'other',
            text: 'Namaste! Are you available for a painting job tomorrow?',
            time: 'Yesterday'),
        const ChatMessage(
            sender: 'user',
            text: 'Yes, I am available. What is the location?',
            time: 'Yesterday'),
        const ChatMessage(
            sender: 'other',
            text: 'Balkumari, Lalitpur. Daily wage is Rs. 1200.',
            time: 'Yesterday'),
      ],
      'Ajay Kumar Sah': [
        const ChatMessage(
            sender: 'other',
            text: 'Hi, we saw your profile. Do you do wiring for DB boxes?',
            time: '2 days ago'),
      ],
      'Hari Bahadur Shrestha': [
        const ChatMessage(
            sender: 'other',
            text: 'Hi Sir, I saw your job post for brick layers. Is it still open?',
            time: 'Yesterday'),
      ],
    };
