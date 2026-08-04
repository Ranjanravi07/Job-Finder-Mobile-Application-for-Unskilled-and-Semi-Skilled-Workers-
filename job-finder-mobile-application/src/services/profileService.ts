/**
 * Profile storage helpers.
 * Provides CRUD operations for `profilePhoto` and `govIdFiles` for
 * Worker and Employer profiles. This is a frontend-local implementation
 * backed by the app's `getLocalData`/`setLocalData` (LocalStorage) mock DB.
 */

import { getLocalData, setLocalData } from '../data';
import { WorkerProfile, EmployerProfile, UserRole } from '../types';

const fileToDataUrl = (file: File): Promise<string> => new Promise((resolve, reject) => {
  const reader = new FileReader();
  reader.onload = () => resolve(reader.result as string);
  reader.onerror = () => reject(new Error('Failed to read file'));
  reader.readAsDataURL(file);
});

const getKeyForRole = (role: UserRole) => role === 'worker' ? 'sim_workers' : 'sim_employers';

const readProfiles = (role: UserRole): (WorkerProfile | EmployerProfile)[] => {
  return getLocalData(getKeyForRole(role), [] as (WorkerProfile | EmployerProfile)[]);
};

const writeProfiles = (role: UserRole, profiles: (WorkerProfile | EmployerProfile)[]) => {
  setLocalData(getKeyForRole(role), profiles);
};

export async function createProfilePhoto(role: UserRole, profileId: string, file: File): Promise<string> {
  const dataUrl = await fileToDataUrl(file);
  const profiles = readProfiles(role);
  const updated = profiles.map(p => p.id === profileId ? { ...p, profilePhoto: dataUrl } : p);
  writeProfiles(role, updated);
  return dataUrl;
}

export function readProfilePhoto(role: UserRole, profileId: string): string | undefined {
  const profiles = readProfiles(role);
  const p = profiles.find(x => x.id === profileId);
  return p?.profilePhoto;
}

export async function updateProfilePhoto(role: UserRole, profileId: string, file: File): Promise<string> {
  return createProfilePhoto(role, profileId, file);
}

export function deleteProfilePhoto(role: UserRole, profileId: string): void {
  const profiles = readProfiles(role);
  const updated = profiles.map(p => p.id === profileId ? { ...p, profilePhoto: undefined } : p);
  writeProfiles(role, updated);
}

// Government ID files CRUD
export async function addGovIdFile(role: UserRole, profileId: string, file: File): Promise<string> {
  const dataUrl = await fileToDataUrl(file);
  const profiles = readProfiles(role);
  const updated = profiles.map(p => {
    if (p.id === profileId) {
      const existing = Array.isArray((p as any).govIdFiles) ? (p as any).govIdFiles.slice() : [];
      existing.push(dataUrl);
      return { ...p, govIdFiles: existing } as typeof p;
    }
    return p;
  });
  writeProfiles(role, updated);
  return dataUrl;
}

export function listGovIdFiles(role: UserRole, profileId: string): string[] {
  const profiles = readProfiles(role);
  const p = profiles.find(x => x.id === profileId) as any;
  return Array.isArray(p?.govIdFiles) ? p.govIdFiles : [];
}

export async function updateGovIdFile(role: UserRole, profileId: string, index: number, file: File): Promise<string> {
  const dataUrl = await fileToDataUrl(file);
  const profiles = readProfiles(role);
  const updated = profiles.map(p => {
    if (p.id === profileId) {
      const existing = Array.isArray((p as any).govIdFiles) ? (p as any).govIdFiles.slice() : [];
      if (index >= 0 && index < existing.length) existing[index] = dataUrl;
      return { ...p, govIdFiles: existing } as typeof p;
    }
    return p;
  });
  writeProfiles(role, updated);
  return dataUrl;
}

export function deleteGovIdFile(role: UserRole, profileId: string, index: number): void {
  const profiles = readProfiles(role);
  const updated = profiles.map(p => {
    if (p.id === profileId) {
      const existing = Array.isArray((p as any).govIdFiles) ? (p as any).govIdFiles.slice() : [];
      if (index >= 0 && index < existing.length) existing.splice(index, 1);
      return { ...p, govIdFiles: existing } as typeof p;
    }
    return p;
  });
  writeProfiles(role, updated);
}

export default {
  createProfilePhoto,
  readProfilePhoto,
  updateProfilePhoto,
  deleteProfilePhoto,
  addGovIdFile,
  listGovIdFiles,
  updateGovIdFile,
  deleteGovIdFile
};
