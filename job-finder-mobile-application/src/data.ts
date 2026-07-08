/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import { Job, WorkerProfile, EmployerProfile, JobApplication } from './types';

export const SKILL_CATEGORIES = [
  { id: 'mason', nameEn: 'Mason / Bricklayer', nameNe: 'डकर्मी (ढुंगा/ईट्टा कामदार)', icon: 'Hammer' },
  { id: 'carpenter', nameEn: 'Carpenter', nameNe: 'सिकर्मी (काठ कामदार)', icon: 'Wrench' },
  { id: 'electrician', nameEn: 'Electrician', nameNe: 'इलेक्ट्रीशियन (बिजुली कामदार)', icon: 'Zap' },
  { id: 'plumber', nameEn: 'Plumber', nameNe: 'प्लम्बर (खानेपानी कामदार)', icon: 'Droplet' },
  { id: 'painter', nameEn: 'Painter', nameNe: 'पेन्टर (रंगरोगन कामदार)', icon: 'Paintbrush' },
  { id: 'driver', nameEn: 'Driver', nameNe: 'चालक (ड्राइभर)', icon: 'Car' },
  { id: 'laborer', nameEn: 'General Laborer', nameNe: 'साधारण मजदुर (लेबर)', icon: 'Users' },
  { id: 'domestic', nameEn: 'Domestic Helper', nameNe: 'घरेलु कामदार', icon: 'Home' },
];

export const NEPAL_LOCATIONS = [
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

export const INITIAL_JOBS: Job[] = [
  {
    id: 'job-1',
    title: 'Daily Wage Brick Mason Needed',
    category: 'mason',
    description: 'We need 3 experienced brick masons for a residential building construction in Balkumari. Lunch and tea will be provided at the site.',
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
  },
  {
    id: 'job-2',
    title: 'House Painting Helpers Wanted',
    category: 'painter',
    description: 'Urgent requirement of 2 painters for high-quality exterior house painting. Brushes and safety gear provided. Wages paid daily.',
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
  },
  {
    id: 'job-3',
    title: 'Wiring Work for 3-Story Building',
    category: 'electrician',
    description: 'Complete wiring of a newly built house. Materials are on-site. Looking for a lead electrician with experience in Nepali standard distribution boards.',
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
  },
  {
    id: 'job-4',
    title: 'Water Pipe fitting & Repair',
    category: 'plumber',
    description: 'Leak repair and new CPVC pipeline setup for a restaurant kitchen. Work is small but needs urgent attention today.',
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
  },
  {
    id: 'job-5',
    title: 'Experienced Tipper Driver Needed',
    category: 'driver',
    description: 'Looking for a tipper driver with a valid heavy vehicle driving license for local site soil carrying. Must be honest and punctual.',
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
  },
];

export const INITIAL_WORKERS: WorkerProfile[] = [
  {
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
  },
  {
    id: 'work-2',
    name: 'Suresh Kumar BK',
    phone: '9801122334',
    mainSkill: 'painter',
    experience: '2 Years',
    expectedWage: 950,
    expectedWageType: 'daily',
    location: 'Balkumari, Lalitpur',
    availability: 'Immediate',
    bio: 'Fast house painter, specialized in exterior colors and textures.',
  },
];

export const INITIAL_APPLICATIONS: JobApplication[] = [
  {
    id: 'app-1',
    jobId: 'job-1',
    workerId: 'work-1',
    workerName: 'Hari Bahadur Shrestha',
    workerPhone: '9845551122',
    workerSkill: 'mason',
    status: 'pending',
    appliedAt: '2026-07-07T11:20:00Z',
  },
];

// LocalStorage helpers to simulate Firebase auth & Firestore locally for immediate preview
export const getLocalData = <T>(key: string, defaultValue: T): T => {
  if (typeof window === 'undefined') return defaultValue;
  const stored = localStorage.getItem(key);
  if (!stored) {
    localStorage.setItem(key, JSON.stringify(defaultValue));
    return defaultValue;
  }
  try {
    return JSON.parse(stored) as T;
  } catch {
    return defaultValue;
  }
};

export const setLocalData = <T>(key: string, data: T): void => {
  if (typeof window === 'undefined') return;
  localStorage.setItem(key, JSON.stringify(data));
};
