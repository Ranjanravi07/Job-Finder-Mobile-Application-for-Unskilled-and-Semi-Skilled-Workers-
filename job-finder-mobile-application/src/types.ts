/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

export interface Job {
  id: string;
  title: string;
  category: string;
  description: string;
  wage: number;
  wageType: 'daily' | 'weekly';
  location: string;
  employerId: string;
  employerName: string;
  employerPhone: string;
  employerWhatsApp: string;
  requiredSkills: string[];
  datePosted: string;
  lat: number;
  lng: number;
  applicantsCount: number;
}

export interface WorkerProfile {
  id: string;
  name: string;
  phone: string;
  mainSkill: string;
  experience: string; // e.g. "2 years", "Fresher"
  expectedWage: number;
  expectedWageType: 'daily' | 'weekly';
  location: string;
  availability: string; // e.g. "Immediate", "Part-time"
  bio?: string;
  govId?: string;
  profilePhoto?: string;
}

export interface EmployerProfile {
  id: string;
  name: string;
  companyName: string;
  phone: string;
  location: string;
  isVerified: boolean;
  type: 'business' | 'individual';
  role?: string;
  govId?: string;
  profilePhoto?: string;
}

export interface JobApplication {
  id: string;
  jobId: string;
  workerId: string;
  workerName: string;
  workerPhone: string;
  workerSkill: string;
  status: 'pending' | 'accepted' | 'rejected';
  appliedAt: string;
}

export type Language = 'en' | 'ne';

export type UserRole = 'worker' | 'employer';
