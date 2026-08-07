# How to Add Job Category & Work Preferences Features

## Current Status
The app is running at: **http://localhost:3001**

The mobile simulator shows the worker profile creation screen, but it needs the Job Category and Work Preferences sections.

## Quick Implementation Guide

### Step 1: Add State Variables
Open `src/components/MobileSimulator.tsx` and add these state variables around line 125 (after the existing worker setup states):

```typescript
// Add after line 133 (after workerSetupGovIdBackFile state)
const [selectedJobCategory, setSelectedJobCategory] = useState<string>('');
const [preferredLocation, setPreferredLocation] = useState<string>('');
const [selectedWorkType, setSelectedWorkType] = useState<string>('');
const [selectedShift, setSelectedShift] = useState<string>('');
const [expectedSalary, setExpectedSalary] = useState<string>('');
```

### Step 2: Add Constants
Add these constants after the `SKILL_CATEGORIES` import or around line 50 in the component:

```typescript
const JOB_CATEGORIES = [
  { id: 'laborer', icon: '👷', nameEn: 'Laborer', nameNe: 'श्रमिक' },
  { id: 'electrician', icon: '⚡', nameEn: 'Electrician', nameNe: 'इलेक्ट्रिसियन' },
  { id: 'plumber', icon: '🔧', nameEn: 'Plumber', nameNe: 'प्लम्बर' },
  { id: 'driver', icon: '🚗', nameEn: 'Driver', nameNe: 'चालक' },
  { id: 'painter', icon: '🎨', nameEn: 'Painter', nameNe: 'पेन्टर' },
  { id: 'carpenter', icon: '🪚', nameEn: 'Carpenter', nameNe: 'सिकर्मी' },
  { id: 'mason', icon: '🧱', nameEn: 'Mason', nameNe: 'डकर्मी' },
  { id: 'cleaner', icon: '🧹', nameEn: 'Cleaner', nameNe: 'सरसफाईकर्मी' },
  { id: 'farmer', icon: '🌾', nameEn: 'Farmer', nameNe: 'किसान' },
  { id: 'cook', icon: '🍳', nameEn: 'Cook', nameNe: 'बावु' },
  { id: 'welder', icon: '🔩', nameEn: 'Welder', nameNe: 'वेल्डर' },
  { id: 'tailor', icon: '🧵', nameEn: 'Tailor', nameNe: 'सिलाईकार' },
  { id: 'other', icon: '🛠️', nameEn: 'Other', nameNe: 'अन्य' },
];

const WORK_TYPES = [
  { id: 'daily-wage', nameEn: 'Daily Wage', nameNe: 'दैनिक ज्याला' },
  { id: 'full-time', nameEn: 'Full Time', nameNe: 'पूरा समय' },
  { id: 'part-time', nameEn: 'Part Time', nameNe: 'आंशिक समय' },
  { id: 'contract', nameEn: 'Contract', nameNe: 'ठेक्का' },
];

const SHIFT_OPTIONS = [
  { id: 'day', nameEn: 'Day Shift', nameNe: 'दिनको पाला' },
  { id: 'night', nameEn: 'Night Shift', nameNe: 'रातको पाला' },
  { id: 'flexible', nameEn: 'Flexible', nameNe: 'लचिलो' },
];

const POPULAR_LOCATIONS = [
  'Kathmandu', 'Lalitpur', 'Bhaktapur', 'Pokhara', 'Biratnagar',
  'Birgunj', 'Butwal', 'Bharatpur', 'Hetauda', 'Dharan',
];
```

### Step 3: Add UI Sections
Find line 1050 (after the Main Skill Dropdown) and insert the complete JSX from the file:
`src/components/JobCategoryAndWorkPreferences.tsx`

The sections should appear after the "Main Skill" field and before the "Experience" field.

### Step 4: Update WorkerProfile Type
Open `src/types.ts` and add these fields to the WorkerProfile interface:

```typescript
export interface WorkerProfile {
  // ... existing fields
  jobCategory?: string;
  preferredLocation?: string;
  workType?: string;
  expectedSalary?: string;
  shiftPreference?: string;
}
```

### Step 5: Update handleCreateWorkerProfile
Update the function call around line 1100 to include the new fields:

```typescript
handleCreateWorkerProfile({
  name: nameInput,
  mainSkill: skillInput,
  experience: expInput,
  location: locInput,
  profilePhoto: workerSetupPhoto,
  govId: `${workerSetupGovIdType.toUpperCase()} - ${workerSetupGovIdNum}`,
  govIdFiles: workerSetupGovIdFiles,
  // NEW fields:
  jobCategory: selectedJobCategory,
  preferredLocation: preferredLocation,
  workType: selectedWorkType,
  expectedSalary: expectedSalary,
  shiftPreference: selectedShift,
});
```

## What You'll See

### Job Category Section
- 13 large card buttons with icons
- Single selection with green highlight
- Haptic feedback (vibration on mobile)
- Voice feedback support
- Bilingual labels (English/Nepali)

### Work Preferences Section
- **Location:** Chip-based selection + custom input
- **Work Type:** 4 options (Daily Wage, Full Time, Part Time, Contract)
- **Shift Preference:** 3 options (Day, Night, Flexible)
- **Expected Salary:** NPR input with per month label

## Testing the Features

1. Open http://localhost:3001
2. Click "English" or "नेपाली"
3. Login with any phone number
4. Select "Job Seeker (Worker)"
5. You'll see the profile creation screen
6. The new sections will appear after "Main Skill"

## Job Matching Logic

After the worker saves their profile:
```
Worker Profile:
- Category: Electrician
- Location: Lalitpur
- Work Type: Full Time
- Salary: NPR 25,000
- Shift: Day

Job Posted:
- Category: Electrician
- Location: Lalitpur
- Salary: NPR 28,000
- Shift: Day

Result: ✅ MATCH - Worker sees this job!
```

## Need Help?

The complete implementation is in:
- **Flutter version:** `flutter_project/lib/screens/profile_setup.dart`
- **React version (code to add):** `src/components/JobCategoryAndWorkPreferences.tsx`

The Flutter app has the complete implementation. To run it, you need Flutter SDK installed. The React web simulator needs the code from JobCategoryAndWorkPreferences.tsx to be integrated.
