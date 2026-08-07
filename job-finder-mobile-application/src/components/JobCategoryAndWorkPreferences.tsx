// Add these state variables at the top of MobileSimulator component (around line 125):

  // Job Category and Work Preferences (NEW)
  const [selectedJobCategory, setSelectedJobCategory] = useState<string>('');
  const [preferredLocation, setPreferredLocation] = useState<string>('');
  const [selectedWorkType, setSelectedWorkType] = useState<string>('');
  const [selectedShift, setSelectedShift] = useState<string>('');
  const [expectedSalary, setExpectedSalary] = useState<string>('');

// Add these constants after SKILL_CATEGORIES (around line 50 in data.ts or define here):

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

// Add this JSX after the "Main Skill Dropdown" section (around line 1050):

              {/* ==================== JOB CATEGORY SECTION (NEW) ==================== */}
              <div className="space-y-2 mt-6">
                <label className="text-sm font-black text-slate-900 flex items-center gap-1">
                  <span className="text-base">👨‍🔧</span>
                  <span>{lang === 'ne' ? 'तपाईं के काम गर्नुहुन्छ?' : 'What work do you do?'}</span>
                </label>
                <p className="text-[10px] text-slate-500 font-medium">
                  {lang === 'ne' ? 'एउटा छान्नुहोस्' : 'Select one category'}
                </p>
                
                <div className="grid grid-cols-2 gap-2 mt-3">
                  {JOB_CATEGORIES.map((category) => {
                    const isSelected = selectedJobCategory === category.id;
                    return (
                      <button
                        key={category.id}
                        type="button"
                        onClick={() => {
                          setSelectedJobCategory(category.id);
                          // Haptic feedback simulation
                          if (navigator.vibrate) navigator.vibrate(10);
                          // Voice feedback (optional)
                          if (voiceFeedbackEnabled) {
                            speakAloud(
                              lang === 'ne' ? category.nameNe : category.nameEn,
                              lang
                            );
                          }
                        }}
                        className={`
                          p-3 rounded-xl border-2 transition-all duration-200 flex flex-col items-center gap-1
                          ${isSelected 
                            ? 'bg-emerald-50 border-emerald-500 shadow-md scale-105' 
                            : 'bg-white border-slate-200 hover:border-slate-300 hover:bg-slate-50'}
                        `}
                      >
                        <span className="text-2xl">{category.icon}</span>
                        <span className={`text-[11px] font-bold ${isSelected ? 'text-emerald-700' : 'text-slate-700'}`}>
                          {lang === 'ne' ? category.nameNe : category.nameEn}
                        </span>
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* ==================== WORK PREFERENCES SECTION (NEW) ==================== */}
              <div className="space-y-3 mt-6 pt-4 border-t border-slate-200">
                <label className="text-sm font-black text-slate-900 flex items-center gap-1">
                  <span className="text-base">📍</span>
                  <span>{lang === 'ne' ? 'कहाँ र कसरी काम गर्न चाहनुहुन्छ?' : 'Where and how do you want to work?'}</span>
                </label>

                {/* Preferred Location */}
                <div className="space-y-1.5">
                  <label className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block flex items-center gap-1">
                    <span>🟢</span>
                    <span>{lang === 'ne' ? 'रुचाइएको स्थान' : 'Preferred Location'}</span>
                  </label>
                  
                  <div className="flex flex-wrap gap-1.5">
                    {POPULAR_LOCATIONS.map((location) => {
                      const isSelected = preferredLocation === location;
                      return (
                        <button
                          key={location}
                          type="button"
                          onClick={() => {
                            setPreferredLocation(location);
                            if (navigator.vibrate) navigator.vibrate(5);
                          }}
                          className={`
                            px-3 py-1.5 rounded-lg text-[10px] font-bold transition-all
                            ${isSelected 
                              ? 'bg-emerald-500 text-white shadow-md' 
                              : 'bg-slate-100 text-slate-700 hover:bg-slate-200'}
                          `}
                        >
                          {location}
                        </button>
                      );
                    })}
                  </div>
                  
                  <input
                    type="text"
                    value={preferredLocation}
                    onChange={(e) => setPreferredLocation(e.target.value)}
                    placeholder={lang === 'ne' ? 'वा अन्य स्थान लेख्नुहोस्' : 'Or type custom location'}
                    className="w-full bg-white px-3 py-2 rounded-lg border border-slate-200 text-xs font-medium focus:outline-none focus:border-emerald-500 mt-2"
                  />
                </div>

                {/* Work Type */}
                <div className="space-y-1.5 mt-3">
                  <label className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block flex items-center gap-1">
                    <span>🟢</span>
                    <span>{lang === 'ne' ? 'कामको प्रकार' : 'Work Type'}</span>
                  </label>
                  
                  <div className="grid grid-cols-2 gap-2">
                    {WORK_TYPES.map((workType) => {
                      const isSelected = selectedWorkType === workType.id;
                      return (
                        <button
                          key={workType.id}
                          type="button"
                          onClick={() => {
                            setSelectedWorkType(workType.id);
                            if (navigator.vibrate) navigator.vibrate(5);
                          }}
                          className={`
                            py-2.5 rounded-lg text-[11px] font-bold transition-all border-2
                            ${isSelected 
                              ? 'bg-emerald-500 text-white border-emerald-500 shadow-md' 
                              : 'bg-white text-slate-700 border-slate-200 hover:border-slate-300'}
                          `}
                        >
                          {lang === 'ne' ? workType.nameNe : workType.nameEn}
                        </button>
                      );
                    })}
                  </div>
                </div>

                {/* Shift Preference */}
                <div className="space-y-1.5 mt-3">
                  <label className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block flex items-center gap-1">
                    <span>🟢</span>
                    <span>{lang === 'ne' ? 'पाला प्राथमिकता' : 'Shift Preference'}</span>
                  </label>
                  
                  <div className="grid grid-cols-3 gap-2">
                    {SHIFT_OPTIONS.map((shift) => {
                      const isSelected = selectedShift === shift.id;
                      return (
                        <button
                          key={shift.id}
                          type="button"
                          onClick={() => {
                            setSelectedShift(shift.id);
                            if (navigator.vibrate) navigator.vibrate(5);
                          }}
                          className={`
                            py-2 rounded-lg text-[10px] font-bold transition-all border-2
                            ${isSelected 
                              ? 'bg-emerald-500 text-white border-emerald-500 shadow-md' 
                              : 'bg-white text-slate-700 border-slate-200 hover:border-slate-300'}
                          `}
                        >
                          {lang === 'ne' ? shift.nameNe : shift.nameEn}
                        </button>
                      );
                    })}
                  </div>
                </div>

                {/* Expected Salary */}
                <div className="space-y-1.5 mt-3">
                  <label className="text-[10px] font-bold text-slate-500 uppercase tracking-wider block flex items-center gap-1">
                    <span>🟢</span>
                    <span>{lang === 'ne' ? 'अपेक्षित तलब (न्यूनतम)' : 'Expected Salary (Minimum)'}</span>
                  </label>
                  
                  <div className="relative">
                    <span className="absolute left-3 top-1/2 -translate-y-1/2 text-xs font-bold text-slate-500">NPR</span>
                    <input
                      type="number"
                      value={expectedSalary}
                      onChange={(e) => setExpectedSalary(e.target.value)}
                      placeholder={lang === 'ne' ? 'उदा: २५०००' : 'e.g., 25000'}
                      className="w-full bg-white pl-14 pr-3 py-2.5 rounded-lg border border-slate-200 text-xs font-medium focus:outline-none focus:border-emerald-500"
                    />
                  </div>
                  <p className="text-[9px] text-slate-400">
                    {lang === 'ne' ? 'प्रति महिना' : 'per month'}
                  </p>
                </div>
              </div>

// Update the handleCreateWorkerProfile function to include the new fields:

              handleCreateWorkerProfile({
                name: nameInput,
                mainSkill: skillInput,
                experience: expInput,
                location: locInput,
                profilePhoto: workerSetupPhoto,
                govId: `${workerSetupGovIdType.toUpperCase()} - ${workerSetupGovIdNum}`,
                govIdFiles: workerSetupGovIdFiles,
                // NEW: Add these fields
                jobCategory: selectedJobCategory,
                preferredLocation: preferredLocation,
                workType: selectedWorkType,
                expectedSalary: expectedSalary,
                shiftPreference: selectedShift,
              });
