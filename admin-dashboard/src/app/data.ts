// ─── Shared source data ────────────────────────────────────────────────────────
// All panels import from here so charts in App.tsx stay in sync with real data.

export type SeekerStatus   = "pending" | "active" | "inactive";
export type EmployerStatus = "pending" | "active" | "inactive";

export interface Seeker {
  id: string;
  name: string;
  skill: string;
  location: string;
  rating: number;
  status: SeekerStatus;
  phone: string;
  govIdNumber: string;
  govIdImage: string;
  profilePhoto: string;
}

export interface Employer {
  id: string;
  name: string;
  industry: string;
  location: string;
  workers: number;
  status: EmployerStatus;
  contactPerson: string;
  phone: string;
  govIdNumber: string;
  govIdImage: string;
  profilePhoto: string;
}

export interface Application {
  id: string;
  worker: string;
  skill: string;
  employer: string;
  location: string;
  status: "hired" | "pending" | "rejected";
  date: string;
}

export interface Job {
  id: string;
  title: string;
  employer: string;
  location: string;
  salary: string;
  type: "Daily" | "Monthly";
  posted: string;
  applicants: number;
  status: "open" | "closed" | "paused";
}

export interface Placement {
  id: string;
  worker: string;
  employer: string;
  role: string;
  location: string;
  date: string;
  salary: string;
}

// ─── Job Seekers ───────────────────────────────────────────────────────────────
export const seekers: Seeker[] = [
  { id: "W-1042", name: "Ramon dela Cruz",   skill: "Construction",   location: "Manila",       rating: 4.8, status: "pending", phone: "+63 912 345 6789", govIdNumber: "PSN-2024-00142", govIdImage: "", profilePhoto: "" },
  { id: "W-1041", name: "Maria Santos",       skill: "Domestic Help",  location: "Quezon City",  rating: 4.6, status: "pending", phone: "+63 917 234 5678", govIdNumber: "PSN-2024-00187", govIdImage: "", profilePhoto: "" },
  { id: "W-1040", name: "Eduardo Bautista",   skill: "Factory Work",   location: "Caloocan",     rating: 4.9, status: "pending", phone: "+63 918 876 5432", govIdNumber: "PSN-2024-00203", govIdImage: "", profilePhoto: "" },
  { id: "W-1039", name: "Josefina Reyes",     skill: "Security Guard", location: "Makati",       rating: 4.3, status: "pending", phone: "+63 919 111 2233", govIdNumber: "PSN-2024-00219", govIdImage: "", profilePhoto: "" },
  { id: "W-1038", name: "Benjamin Lim",       skill: "Delivery Rider", location: "Pasig",        rating: 4.5, status: "pending", phone: "+63 920 444 5566", govIdNumber: "PSN-2024-00231", govIdImage: "", profilePhoto: "" },
  { id: "W-1037", name: "Lourdes Magno",      skill: "Domestic Help",  location: "Marikina",     rating: 4.7, status: "pending", phone: "+63 921 667 8899", govIdNumber: "PSN-2024-00248", govIdImage: "", profilePhoto: "" },
  { id: "W-1036", name: "Arturo Villanueva",  skill: "Construction",   location: "Taguig",       rating: 4.2, status: "pending", phone: "+63 922 321 0987", govIdNumber: "PSN-2024-00261", govIdImage: "", profilePhoto: "" },
  { id: "W-1035", name: "Carina Ocampo",      skill: "Factory Work",   location: "Navotas",      rating: 4.8, status: "pending", phone: "+63 923 555 7744", govIdNumber: "PSN-2024-00275", govIdImage: "", profilePhoto: "" },
];

// ─── Employers ─────────────────────────────────────────────────────────────────
export const employers: Employer[] = [
  { id: "E-201", name: "SunBuild Corp.",      industry: "Construction", location: "Manila",       workers: 124, status: "pending", contactPerson: "Marco Dela Rosa", phone: "+63 912 100 2001", govIdNumber: "BIR-2024-E0201", govIdImage: "", profilePhoto: "" },
  { id: "E-202", name: "Reyes Household",     industry: "Domestic",     location: "Quezon City",  workers: 3,   status: "pending", contactPerson: "Ana Reyes",       phone: "+63 917 200 3002", govIdNumber: "BIR-2024-E0202", govIdImage: "", profilePhoto: "" },
  { id: "E-203", name: "FiliTex Mills",       industry: "Factory",      location: "Caloocan",     workers: 86,  status: "pending", contactPerson: "Roberto Filio",   phone: "+63 918 300 4003", govIdNumber: "BIR-2024-E0203", govIdImage: "", profilePhoto: "" },
  { id: "E-204", name: "Shield Pro Security", industry: "Security",     location: "Makati",       workers: 45,  status: "pending", contactPerson: "Dante Escudo",    phone: "+63 919 400 5004", govIdNumber: "BIR-2024-E0204", govIdImage: "", profilePhoto: "" },
  { id: "E-205", name: "QuickShip PH",        industry: "Logistics",    location: "Pasig",        workers: 32,  status: "pending", contactPerson: "Rina Velasco",    phone: "+63 920 500 6005", govIdNumber: "BIR-2024-E0205", govIdImage: "", profilePhoto: "" },
  { id: "E-206", name: "MetroBuild Inc.",     industry: "Construction", location: "Taguig",       workers: 67,  status: "pending", contactPerson: "Jun Serrano",     phone: "+63 921 600 7006", govIdNumber: "BIR-2024-E0206", govIdImage: "", profilePhoto: "" },
];

// ─── Applications ──────────────────────────────────────────────────────────────
export const applications: Application[] = [
  { id: "APP-1042", worker: "Ramon dela Cruz",   skill: "Construction",   employer: "SunBuild Corp.",      location: "Manila",       status: "hired",    date: "Dec 28, 2024" },
  { id: "APP-1041", worker: "Maria Santos",       skill: "Domestic Help",  employer: "Reyes Household",     location: "Quezon City",  status: "pending",  date: "Dec 28, 2024" },
  { id: "APP-1040", worker: "Eduardo Bautista",   skill: "Factory Work",   employer: "FiliTex Mills",       location: "Caloocan",     status: "hired",    date: "Dec 27, 2024" },
  { id: "APP-1039", worker: "Josefina Reyes",     skill: "Security Guard", employer: "Shield Pro Security", location: "Makati",       status: "rejected", date: "Dec 27, 2024" },
  { id: "APP-1038", worker: "Benjamin Lim",       skill: "Delivery Rider", employer: "QuickShip PH",        location: "Pasig",        status: "hired",    date: "Dec 26, 2024" },
  { id: "APP-1037", worker: "Lourdes Magno",      skill: "Domestic Help",  employer: "Cruz Family",         location: "Marikina",     status: "pending",  date: "Dec 26, 2024" },
  { id: "APP-1036", worker: "Arturo Villanueva",  skill: "Construction",   employer: "MetroBuild Inc.",     location: "Taguig",       status: "hired",    date: "Dec 25, 2024" },
];

export function derivePlacements(apps: Application[]): Placement[] {
  const roleMap: Record<string, string> = {
    "Construction": "Construction Helper",
    "Domestic Help": "Domestic Helper",
    "Factory Work": "Factory Sorter",
    "Security Guard": "Security Guard",
    "Delivery Rider": "Delivery Rider",
  };
  const salaryMap: Record<string, string> = {
    "Construction": "₱450/day",
    "Domestic Help": "₱8,000/mo",
    "Factory Work": "₱420/day",
    "Security Guard": "₱15,000/mo",
    "Delivery Rider": "₱500/day",
  };
  return apps
    .filter((a) => a.status === "hired")
    .map((a) => ({
      id: `PL-${a.id.replace("APP-", "")}`,
      worker: a.worker,
      employer: a.employer,
      role: roleMap[a.skill] || a.skill,
      location: a.location,
      date: a.date,
      salary: salaryMap[a.skill] || "—",
    }));
}

export const placements: Placement[] = derivePlacements(applications);

// ─── Job Listings ──────────────────────────────────────────────────────────────
export const jobs: Job[] = [
  { id: "J-301", title: "Construction Helper", employer: "SunBuild Corp.",      location: "Manila",       salary: "₱450/day",   type: "Daily",   posted: "Dec 28", applicants: 24, status: "open"   },
  { id: "J-302", title: "Domestic Helper",     employer: "Reyes Household",     location: "Quezon City",  salary: "₱8,000/mo",  type: "Monthly", posted: "Dec 27", applicants: 12, status: "open"   },
  { id: "J-303", title: "Factory Sorter",      employer: "FiliTex Mills",       location: "Caloocan",     salary: "₱420/day",   type: "Daily",   posted: "Dec 26", applicants: 56, status: "open"   },
  { id: "J-304", title: "Security Guard",      employer: "Shield Pro Security", location: "Makati",       salary: "₱15,000/mo", type: "Monthly", posted: "Dec 25", applicants: 38, status: "closed" },
  { id: "J-305", title: "Delivery Rider",      employer: "QuickShip PH",        location: "Pasig",        salary: "₱500/day",   type: "Daily",   posted: "Dec 24", applicants: 19, status: "open"   },
  { id: "J-306", title: "Welder",              employer: "MetroBuild Inc.",      location: "Taguig",       salary: "₱550/day",   type: "Daily",   posted: "Dec 23", applicants: 8,  status: "paused" },
];

// ─── Derived chart data ────────────────────────────────────────────────────────

// Skills breakdown from real seeker data → pie chart
const skillCounts = seekers.reduce<Record<string, number>>((acc, s) => {
  acc[s.skill] = (acc[s.skill] || 0) + 1;
  return acc;
}, {});
const totalSeekers = seekers.length;

export const categoryData = [
  { name: "Construction",   value: Math.round((skillCounts["Construction"]   || 0) / totalSeekers * 100), color: "#7c5cfc" },
  { name: "Domestic Help",  value: Math.round((skillCounts["Domestic Help"]  || 0) / totalSeekers * 100), color: "#36d1b7" },
  { name: "Factory Work",   value: Math.round((skillCounts["Factory Work"]   || 0) / totalSeekers * 100), color: "#f7c948" },
  { name: "Security Guard", value: Math.round((skillCounts["Security Guard"] || 0) / totalSeekers * 100), color: "#5ca4fc" },
  { name: "Delivery Rider", value: Math.round((skillCounts["Delivery Rider"] || 0) / totalSeekers * 100), color: "#e8455a" },
];

// Applications by date → registrations tab (workers applied, employers involved)
// Group applications by date for the registrations chart
const appDateMap: Record<string, { workers: number; employers: Set<string> }> = {};
for (const a of applications) {
  // Extract short date label e.g. "Dec 28"
  const label = a.date.replace(", 2024", "");
  if (!appDateMap[label]) appDateMap[label] = { workers: 0, employers: new Set() };
  appDateMap[label].workers += 1;
  appDateMap[label].employers.add(a.employer);
}

export const registrationData = Object.entries(appDateMap)
  .sort((a, b) => {
    // Sort chronologically Dec 25 → Dec 28
    const months: Record<string, number> = { Jan:1,Feb:2,Mar:3,Apr:4,May:5,Jun:6,Jul:7,Aug:8,Sep:9,Oct:10,Nov:11,Dec:12 };
    const parse = (s: string) => { const [m, d] = s.split(" "); return months[m] * 100 + parseInt(d); };
    return parse(a[0]) - parse(b[0]);
  })
  .map(([date, val]) => ({
    date,
    workers:   val.workers,
    employers: val.employers.size,
  }));

// Placements = hired applications by date
const placementDateMap: Record<string, number> = {};
for (const a of applications) {
  if (a.status !== "hired") continue;
  const label = a.date.replace(", 2024", "");
  placementDateMap[label] = (placementDateMap[label] || 0) + 1;
}

export const placementData = Object.entries(placementDateMap)
  .sort((a, b) => {
    const months: Record<string, number> = { Jan:1,Feb:2,Mar:3,Apr:4,May:5,Jun:6,Jul:7,Aug:8,Sep:9,Oct:10,Nov:11,Dec:12 };
    const parse = (s: string) => { const [m, d] = s.split(" "); return months[m] * 100 + parseInt(d); };
    return parse(a[0]) - parse(b[0]);
  })
  .map(([date, placed]) => ({ date, placed }));
