import { useState, useEffect } from "react";
import { useTheme } from "next-themes";
import { auth, db } from "../firebase";
import { doc, setDoc, getDoc } from "firebase/firestore";
import { onAuthStateChanged } from "firebase/auth";
import Login from "./components/Login";
import {
  LayoutDashboard,
  Users,
  Briefcase,
  FileText,
  CheckCircle,
  Settings,
  Bell,
  Search,
  ArrowUpRight,
  ArrowDownRight,
  ChevronDown,
  Building2,
  Activity,
  Menu,
  X,
  MapPin,
  Star,
  Clock,
  HardHat,
  LogOut,
  Filter,
  Sun,
  Moon,
  Monitor,
  SlidersHorizontal,
} from "lucide-react";
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  BarChart,
  Bar,
} from "recharts";
import JobSeekersPanel from "./components/panels/JobSeekersPanel";
import EmployersPanel from "./components/panels/EmployersPanel";
import JobListingsPanel from "./components/panels/JobListingsPanel";
import ApplicationsPanel from "./components/panels/ApplicationsPanel";
import PlacementsPanel from "./components/panels/PlacementsPanel";
import UserAccountsPanel from "./components/panels/UserAccountsPanel";
import ReportsPanel from "./components/panels/ReportsPanel";
import SettingsPanel from "./components/panels/SettingsPanel";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
  DropdownMenuCheckboxItem,
} from "./components/ui/dropdown-menu";

// ─── Filter types ──────────────────────────────────────────────────────────────
export interface ActiveFilters {
  status: string[];      // multi-select
  skill: string[];       // multi-select
  industry: string[];    // multi-select (employers)
  jobType: string[];     // multi-select (job listings)
  minRating: number;     // seekers
}

const defaultFilters: ActiveFilters = {
  status: [], skill: [], industry: [], jobType: [], minRating: 0,
};

// Options per section
const FILTER_CONFIG: Record<string, { label: string; key: keyof ActiveFilters; options: string[] }[]> = {
  seekers: [
    { label: "Status",      key: "status",    options: ["pending", "active", "inactive"] },
    { label: "Skill",       key: "skill",     options: ["Construction", "Domestic Help", "Factory Work", "Security Guard", "Delivery Rider"] },
    { label: "Min Rating",  key: "minRating", options: ["4.0", "4.5", "4.8"] },
  ],
  employers: [
    { label: "Status",   key: "status",   options: ["pending", "active", "inactive"] },
    { label: "Industry", key: "industry", options: ["Construction", "Domestic", "Factory", "Security", "Logistics"] },
  ],
  applications: [
    { label: "Status", key: "status", options: ["hired", "pending", "rejected"] },
    { label: "Skill",  key: "skill",  options: ["Construction", "Domestic Help", "Factory Work", "Security Guard", "Delivery Rider"] },
  ],
  jobs: [
    { label: "Status", key: "status",  options: ["open", "closed", "paused"] },
    { label: "Type",   key: "jobType", options: ["Daily", "Monthly"] },
  ],
};

// Panels that support filtering
const FILTERABLE = new Set(["seekers", "employers", "applications", "jobs"]);

import {
  registrationData,
  placementData,
  categoryData,
  applications as appData,
  seekers as seekerData,
  employers as employerData,
  jobs as jobData,
  type Seeker,
  type Employer,
  type Job,
} from "./data";

const recentApplications = appData;

const activityItems = [
  { text: "New employer SunBuild Corp. registered", time: "5 min ago", type: "employer" },
  { text: "Ramon dela Cruz was successfully hired", time: "18 min ago", type: "placement" },
  { text: "12 new worker profiles approved", time: "1 hr ago", type: "worker" },
  { text: "Job post 'Factory Sorter' flagged for review", time: "2 hr ago", type: "flag" },
  { text: "Batch verification completed — 34 IDs", time: "3 hr ago", type: "system" },
];

const statusStyle: Record<string, string> = {
  hired: "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20",
  pending: "bg-amber-500/10 text-amber-400 border border-amber-500/20",
  rejected: "bg-rose-500/10 text-rose-400 border border-rose-500/20",
};

const activityDot: Record<string, string> = {
  employer: "bg-violet-400",
  placement: "bg-emerald-400",
  worker: "bg-sky-400",
  flag: "bg-rose-400",
  system: "bg-slate-400",
};

function ChartTooltip({ active, payload, label }: any) {
  if (!active || !payload?.length) return null;
  return (
    <div className="bg-card border border-border rounded-lg px-4 py-3 shadow-2xl">
      <p className="text-muted-foreground text-xs font-mono mb-1">{label}</p>
      {payload.map((entry: any) => (
        <p key={entry.dataKey} className="text-foreground text-sm font-medium">
          <span className="text-muted-foreground text-xs mr-1">{entry.name ?? entry.dataKey}:</span>
          {entry.value.toLocaleString()}
        </p>
      ))}
    </div>
  );
}

export default function App() {
  const { theme, setTheme } = useTheme();
  const [isAuthenticated, setIsAuthenticated] = useState(() => localStorage.getItem("jobfinder-auth") === "true");
  const [activeNav, setActiveNav] = useState("dashboard");
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [activeTab, setActiveTab] = useState<"registrations" | "placements">("registrations");
  const [globalSearch, setGlobalSearch] = useState("");
  const [adminProfile, setAdminProfile] = useState({ username: "Admin", email: "" });
  const [loginDate, setLoginDate] = useState(() => new Date());
  const [currentUid, setCurrentUid] = useState<string | null>(null);
  const [activeFilters, setActiveFilters] = useState<ActiveFilters>(defaultFilters);
  const [authLoading, setAuthLoading] = useState(true);
  const [notifications, setNotifications] = useState<Array<{ id: string; message: string; time: Date; type: 'worker' | 'employer' | 'job' | 'placement' }>>([]);
  const [showNotifications, setShowNotifications] = useState(false);

  // ─── Firebase auth state listener ─────────────────────────────────────────────
  useEffect(() => {
    if (!auth) {
      setAuthLoading(false);
      return;
    }

    // Add timeout to force authLoading to false if Firebase takes too long
    const timeoutId = setTimeout(() => {
      console.warn("Auth state check timeout - forcing loading to false");
      setAuthLoading(false);
    }, 5000); // 5 second timeout

    const unsubscribe = onAuthStateChanged(auth, (user) => {
      clearTimeout(timeoutId);
      
      if (user) {
        // User is signed in
        setCurrentUid(user.uid);
        localStorage.setItem("jobfinder-auth", "true");
        
        // Set basic profile from auth data immediately
        setAdminProfile({
          username: user.displayName || user.email?.split("@")[0] || "Admin",
          email: user.email || ""
        });
        setIsAuthenticated(true);
        
        // Fetch user profile from Firestore in background (non-blocking)
        if (db) {
          getDoc(doc(db, "users", user.uid))
            .then((docSnap) => {
              if (docSnap.exists()) {
                const data = docSnap.data();
                setAdminProfile({
                  username: data.name || user.displayName || user.email?.split("@")[0] || "Admin",
                  email: data.email || user.email || ""
                });
              }
            })
            .catch((err: any) => {
              // Silent fail - profile already set from auth data
              if (err?.code !== "unavailable") {
                console.error("Failed to fetch user profile from Firestore:", err);
              }
            });
        }
      } else {
        // User is signed out
        setCurrentUid(null);
        localStorage.removeItem("jobfinder-auth");
        setAdminProfile({ username: "Admin", email: "" });
        setIsAuthenticated(false);
      }
      setAuthLoading(false);
    });

    return () => {
      clearTimeout(timeoutId);
      unsubscribe();
    };
  }, [auth, db]);

  // ─── Lifted data state ───────────────────────────────────────────────────────
  const [seekerList,   setSeekerList]   = useState<Seeker[]>(seekerData);
  const [employerList, setEmployerList] = useState<Employer[]>(employerData);
  const [jobList,      setJobList]      = useState<Job[]>(jobData);

  // Derived counts — recomputed on every render when lists change
  const totalWorkers    = seekerList.length;
  const totalEmployers  = employerList.length;
  const openJobs        = jobList.filter((j) => j.status === "open").length;
  const totalPlacements = appData.filter((a) => a.status === "hired").length;

  // ─── Notification logic based on activity ─────────────────────────────────────
  useEffect(() => {
    const newNotifications: Array<{ id: string; message: string; time: Date; type: 'worker' | 'employer' | 'job' | 'placement' }> = [];
    
    // Check for new workers (last 5)
    const recentWorkers = seekerList.slice(-5);
    recentWorkers.forEach((worker, index) => {
      if (worker.id && !notifications.find(n => n.id === `worker-${worker.id}`)) {
        newNotifications.push({
          id: `worker-${worker.id}`,
          message: `New worker registered: ${worker.name}`,
          time: new Date(),
          type: 'worker'
        });
      }
    });

    // Check for new employers (last 3)
    const recentEmployers = employerList.slice(-3);
    recentEmployers.forEach((employer, index) => {
      if (employer.id && !notifications.find(n => n.id === `employer-${employer.id}`)) {
        newNotifications.push({
          id: `employer-${employer.id}`,
          message: `New employer joined: ${employer.company}`,
          time: new Date(),
          type: 'employer'
        });
      }
    });

    // Check for new jobs (last 3)
    const recentJobs = jobList.slice(-3);
    recentJobs.forEach((job, index) => {
      if (job.id && !notifications.find(n => n.id === `job-${job.id}`)) {
        newNotifications.push({
          id: `job-${job.id}`,
          message: `New job posted: ${job.title}`,
          time: new Date(),
          type: 'job'
        });
      }
    });

    // Check for new placements (last 2)
    const recentPlacements = appData.filter((a) => a.status === "hired").slice(-2);
    recentPlacements.forEach((placement, index) => {
      if (placement.id && !notifications.find(n => n.id === `placement-${placement.id}`)) {
        newNotifications.push({
          id: `placement-${placement.id}`,
          message: `New placement: ${placement.seekerName} hired`,
          time: new Date(),
          type: 'placement'
        });
      }
    });

    if (newNotifications.length > 0) {
      setNotifications(prev => [...newNotifications.reverse(), ...prev].slice(0, 20));
    }
  }, [seekerList, employerList, jobList, appData]);

  const navItems = [
    { icon: LayoutDashboard, label: "Dashboard",    id: "dashboard" },
    { icon: HardHat,         label: "Job Seekers",  id: "seekers",      badge: totalWorkers.toString() },
    { icon: Building2,       label: "Employers",    id: "employers",    badge: totalEmployers.toString() },
    { icon: Briefcase,       label: "Job Listings", id: "jobs",         badge: openJobs.toString() },
    { icon: FileText,        label: "Applications", id: "applications" },
    { icon: CheckCircle,     label: "Placements",   id: "placements" },
    { icon: Users,           label: "User Accounts",id: "accounts" },
    { icon: Activity,        label: "Reports",      id: "reports" },
    { icon: Settings,        label: "Settings",     id: "settings" },
  ];

  const kpiCards = [
    { label: "Registered Workers",    value: totalWorkers.toLocaleString(),    change: "+12.4%", up: true,  sub: "vs last month", icon: HardHat,     color: "text-violet-400" },
    { label: "Active Employers",      value: totalEmployers.toLocaleString(),  change: "+8.7%",  up: true,  sub: "vs last month", icon: Building2,   color: "text-sky-400" },
    { label: "Successful Placements", value: totalPlacements.toLocaleString(), change: "+16.2%", up: true,  sub: "this year",     icon: CheckCircle, color: "text-emerald-400" },
    { label: "Open Job Listings",     value: openJobs.toLocaleString(),        change: "-4.3%",  up: false, sub: "vs last week",  icon: Briefcase,   color: "text-amber-400" },
  ];

  const recentWorkers = seekerList.slice(0, 4).map((s, i) => ({
    name: s.name, skill: s.skill, location: s.location, rating: s.rating,
    joined: "Dec " + (28 - i),
  }));

  // Reset filters whenever the user navigates to a new section
  const handleNavChange = (id: string) => {
    setActiveNav(id);
    setActiveFilters(defaultFilters);
  };

  const toggleArrayFilter = (key: "status" | "skill" | "industry" | "jobType", value: string) => {
    setActiveFilters((prev) => {
      const arr = prev[key] as string[];
      return {
        ...prev,
        [key]: arr.includes(value) ? arr.filter((v) => v !== value) : [...arr, value],
      };
    });
  };

  const setRatingFilter = (value: number) => {
    setActiveFilters((prev) => ({ ...prev, minRating: prev.minRating === value ? 0 : value }));
  };

  const activeFilterCount = activeFilters.status.length + activeFilters.skill.length +
    activeFilters.industry.length + activeFilters.jobType.length + (activeFilters.minRating > 0 ? 1 : 0);

  const handleProfileSave = async (username: string, email: string) => {
    setAdminProfile({ username, email });
    // Persist back to Firestore so the name survives re-login
    if (db && currentUid) {
      try {
        await setDoc(doc(db, "users", currentUid), { name: username, email }, { merge: true });
      } catch (err) {
        console.error("Failed to persist profile to Firestore", err);
      }
    }
  };

  // Derive initials from username (up to 2 letters)
  const adminInitials = adminProfile.username
    .split(" ")
    .map((n) => n[0])
    .join("")
    .slice(0, 2)
    .toUpperCase();

  const handleLogin = (_user: import("firebase/auth").User, profile: { username: string; email: string }) => {
    // The auth state listener will handle profile fetching and state updates
    // Just update the login date for display purposes
    setLoginDate(new Date());
  };

  const handleLogout = async () => {
    if (auth) await auth.signOut();
    localStorage.removeItem("jobfinder-auth");
    setAdminProfile({ username: "Admin", email: "" });
    setCurrentUid(null);
    setIsAuthenticated(false);
  };

  const toggleTheme = () => {
    setTheme(theme === "light" ? "dark" : theme === "dark" ? "system" : "light");
  };

  if (!isAuthenticated) {
    if (authLoading) {
      return (
        <div className="min-h-screen bg-background flex items-center justify-center">
          <div className="flex items-center gap-2 text-muted-foreground text-sm">
            <div className="w-4 h-4 border-2 border-primary border-t-transparent rounded-full animate-spin" />
            Loading...
          </div>
        </div>
      );
    }
    return <Login onLogin={handleLogin} />;
  }

  return (
    <div
      className="size-full flex bg-background text-foreground overflow-hidden"
      style={{ fontFamily: "'Geist', system-ui, sans-serif" }}
    >
      {/* Sidebar */}
      <aside
        className={`flex-shrink-0 flex flex-col bg-sidebar border-r border-sidebar-border transition-all duration-300 ${
          sidebarOpen ? "w-60" : "w-16"
        }`}
      >
        <div className="h-14 flex items-center px-4 border-b border-sidebar-border gap-3">
          <div className="w-7 h-7 rounded-lg bg-primary flex items-center justify-center flex-shrink-0">
            <HardHat className="w-4 h-4 text-white" />
          </div>
          {sidebarOpen && (
            <div className="flex-1 min-w-0">
              <p className="text-xs font-bold text-foreground leading-tight tracking-tight">Job Finder </p>
              <p className="text-xs text-muted-foreground leading-tight">Admin Console</p>
            </div>
          )}
          <button
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="text-muted-foreground hover:text-foreground transition-colors ml-auto"
          >
            {sidebarOpen ? <X className="w-4 h-4" /> : <Menu className="w-4 h-4" />}
          </button>
        </div>

        <nav className="flex-1 py-4 px-2 flex flex-col gap-0.5 overflow-y-auto">
          {navItems.map((item) => {
            const Icon = item.icon;
            const active = activeNav === item.id;
            return (
              <button
                key={item.id}
                onClick={() => handleNavChange(item.id)}
                className={`flex items-center gap-3 px-3 py-2.5 rounded-md text-sm transition-all duration-150 w-full text-left relative ${
                  active
                    ? "bg-primary/10 text-primary"
                    : "text-muted-foreground hover:text-foreground hover:bg-sidebar-accent"
                }`}
              >
                <Icon className="w-4 h-4 flex-shrink-0" />
                {sidebarOpen && (
                  <>
                    <span className="flex-1 font-medium text-sm">{item.label}</span>
                    {item.badge && (
                      <span
                        className={`text-xs font-mono px-1.5 py-0.5 rounded ${
                          active ? "bg-primary/20 text-primary" : "bg-muted text-muted-foreground"
                        }`}
                      >
                        {item.badge}
                      </span>
                    )}
                  </>
                )}
                {active && (
                  <div className="absolute left-0 top-1/2 -translate-y-1/2 w-0.5 h-5 bg-primary rounded-full" />
                )}
              </button>
            );
          })}
        </nav>

        <div className="border-t border-sidebar-border px-3 py-3">
          <div className={`flex items-center gap-3 px-2 py-2 rounded-md ${sidebarOpen ? "" : "justify-center"}`}>
            <div className="w-7 h-7 rounded-full bg-primary/20 flex items-center justify-center flex-shrink-0 text-xs font-bold text-primary">
              {adminInitials}
            </div>
            {sidebarOpen && (
              <div className="flex-1 min-w-0">
                <p className="text-xs font-semibold text-foreground truncate">{adminProfile.username}</p>
                <p className="text-xs text-muted-foreground truncate">{adminProfile.email}</p>
              </div>
            )}
            {sidebarOpen && (
              <button
                onClick={handleLogout}
                className="text-muted-foreground hover:text-foreground transition-colors"
                title="Logout"
              >
                <LogOut className="w-3.5 h-3.5 flex-shrink-0" />
              </button>
            )}
          </div>
        </div>
      </aside>

      {/* Main */}
      <div className="flex-1 flex flex-col overflow-hidden min-w-0">
        {/* Header */}
        <header className="h-14 flex items-center px-6 border-b border-border gap-4 flex-shrink-0">
          <div>
            <h1 className="text-sm font-semibold text-foreground">Dashboard</h1>
            <p className="text-xs text-muted-foreground" style={{ fontFamily: "'DM Mono', monospace" }}>
              {loginDate.toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" })}
              {" · "}
              {loginDate.toLocaleTimeString("en-US", { hour: "numeric", minute: "2-digit", hour12: true })}
            </p>
          </div>
          <div className="flex items-center gap-2 bg-muted rounded-md px-3 py-2 border border-border ml-6 flex-1 max-w-xs">
            <Search className="w-3.5 h-3.5 text-muted-foreground flex-shrink-0" />
            <input
              className="bg-transparent text-sm text-foreground placeholder:text-muted-foreground outline-none w-full"
              placeholder="Search workers, employers, applications..."
              value={globalSearch}
              onChange={(e) => setGlobalSearch(e.target.value)}
              autoComplete="off"
              style={{ fontFamily: "'Geist', system-ui, sans-serif" }}
            />
          </div>
          <div className="ml-auto flex items-center gap-2">
            <button
              onClick={toggleTheme}
              className="w-8 h-8 flex items-center justify-center rounded-md text-muted-foreground hover:text-foreground border border-border hover:bg-muted transition-colors"
              title={
                theme === "light"
                  ? "Switch to dark mode"
                  : theme === "dark"
                    ? "Switch to system mode"
                    : "Switch to light mode"
              }
            >
              {theme === "light" ? (
                <Sun className="w-3.5 h-3.5" />
              ) : theme === "dark" ? (
                <Moon className="w-3.5 h-3.5" />
              ) : (
                <Monitor className="w-3.5 h-3.5" />
              )}
            </button>
            {FILTERABLE.has(activeNav) && (
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <button className={`flex items-center gap-1.5 text-xs border rounded-md px-3 py-1.5 transition-colors ${
                    activeFilterCount > 0
                      ? "bg-primary/10 text-primary border-primary/30"
                      : "text-muted-foreground hover:text-foreground border-border"
                  }`}>
                    <SlidersHorizontal className="w-3 h-3" />
                    Filter
                    {activeFilterCount > 0 && (
                      <span className="ml-0.5 bg-primary text-white text-[10px] font-bold rounded-full w-4 h-4 flex items-center justify-center">
                        {activeFilterCount}
                      </span>
                    )}
                  </button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end" className="w-52">
                  {(FILTER_CONFIG[activeNav] ?? []).map((group) => (
                    <div key={group.key}>
                      <DropdownMenuLabel className="text-xs text-muted-foreground uppercase tracking-wider pt-2">
                        {group.label}
                      </DropdownMenuLabel>
                      {group.options.map((opt) => {
                        if (group.key === "minRating") {
                          const val = parseFloat(opt);
                          return (
                            <DropdownMenuCheckboxItem
                              key={opt}
                              checked={activeFilters.minRating === val}
                              onCheckedChange={() => setRatingFilter(val)}
                            >
                              ≥ {opt} ★
                            </DropdownMenuCheckboxItem>
                          );
                        }
                        const arr = activeFilters[group.key] as string[];
                        return (
                          <DropdownMenuCheckboxItem
                            key={opt}
                            checked={arr.includes(opt)}
                            onCheckedChange={() =>
                              toggleArrayFilter(group.key as "status" | "skill" | "industry" | "jobType", opt)
                            }
                            className="capitalize"
                          >
                            {opt}
                          </DropdownMenuCheckboxItem>
                        );
                      })}
                      <DropdownMenuSeparator />
                    </div>
                  ))}
                  <DropdownMenuItem
                    onClick={() => setActiveFilters(defaultFilters)}
                    className="text-xs text-muted-foreground justify-center"
                    disabled={activeFilterCount === 0}
                  >
                    Clear all filters
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            )}
            <button className="relative w-8 h-8 flex items-center justify-center rounded-md text-muted-foreground hover:text-foreground hover:bg-muted transition-colors">
              <Bell className="w-4 h-4" />
              <span className="absolute top-1.5 right-1.5 w-1.5 h-1.5 bg-rose-500 rounded-full" />
            </button>
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <div className="flex items-center gap-2 px-2 py-1.5 rounded-md hover:bg-muted cursor-pointer transition-colors select-none">
                  <div className="w-6 h-6 rounded-full bg-primary/20 flex items-center justify-center text-xs font-bold text-primary">
                    {adminInitials}
                  </div>
                  <span className="text-sm text-foreground font-medium">{adminProfile.username.split(" ")[0]}</span>
                  <ChevronDown className="w-3 h-3 text-muted-foreground" />
                </div>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-48">
                <DropdownMenuLabel className="text-xs text-muted-foreground font-normal">
                  <p className="font-semibold text-foreground truncate">{adminProfile.username}</p>
                  <p className="truncate">{adminProfile.email}</p>
                </DropdownMenuLabel>
                <DropdownMenuSeparator />
                <DropdownMenuItem
                  className="gap-2 cursor-pointer"
                  onClick={() => handleNavChange("accounts")}
                >
                  <Users className="w-3.5 h-3.5" />
                  User Accounts
                </DropdownMenuItem>
                <DropdownMenuItem
                  className="gap-2 cursor-pointer"
                  onClick={() => handleNavChange("settings")}
                >
                  <Settings className="w-3.5 h-3.5" />
                  Settings
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem
                  variant="destructive"
                  className="gap-2 cursor-pointer"
                  onClick={handleLogout}
                >
                  <LogOut className="w-3.5 h-3.5" />
                  Logout
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </header>

        {/* Content */}
        <main className="flex-1 overflow-y-auto p-6 space-y-5">
          {activeNav === "dashboard" && (
            <div className="space-y-5">
              {/* KPI Cards */}
              <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
            {kpiCards.map((card) => {
              const Icon = card.icon;
              return (
                <div
                  key={card.label}
                  className="bg-card border border-border rounded-xl p-5 flex flex-col gap-3 hover:border-primary/30 transition-colors"
                >
                  <div className="flex items-center justify-between">
                    <span className="text-xs text-muted-foreground font-medium uppercase tracking-wider">
                      {card.label}
                    </span>
                    <Icon className={`w-4 h-4 ${card.color}`} />
                  </div>
                  <div>
                    <p className="text-2xl font-semibold text-foreground tracking-tight">{card.value}</p>
                    <div className="flex items-center gap-1.5 mt-1.5">
                      {card.up ? (
                        <ArrowUpRight className="w-3 h-3 text-emerald-400" />
                      ) : (
                        <ArrowDownRight className="w-3 h-3 text-rose-400" />
                      )}
                      <span className={`text-xs font-mono font-medium ${card.up ? "text-emerald-400" : "text-rose-400"}`}>
                        {card.change}
                      </span>
                      <span className="text-xs text-muted-foreground">{card.sub}</span>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>

          {/* Charts */}
          <div className="grid grid-cols-1 gap-4 lg:grid-cols-3">
            <div className="lg:col-span-2 bg-card border border-border rounded-xl p-5">
              <div className="flex items-center justify-between mb-5">
                <div>
                  <h2 className="text-sm font-semibold text-foreground">Growth Trends</h2>
                  <p className="text-xs text-muted-foreground mt-0.5">FY2024 — monthly breakdown</p>
                </div>
                <div className="flex items-center gap-1 bg-muted rounded-md p-1">
                  {(["registrations", "placements"] as const).map((tab) => (
                    <button
                      key={tab}
                      onClick={() => setActiveTab(tab)}
                      className={`px-3 py-1 rounded text-xs font-medium transition-colors capitalize ${
                        activeTab === tab ? "bg-primary text-white" : "text-muted-foreground hover:text-foreground"
                      }`}
                    >
                      {tab}
                    </button>
                  ))}
                </div>
              </div>
              <ResponsiveContainer width="100%" height={200}>
                {activeTab === "registrations" ? (
                  <AreaChart data={registrationData} margin={{ top: 0, right: 0, left: -20, bottom: 0 }}>
                    <defs>
                      <linearGradient id="gWorker" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#7c5cfc" stopOpacity={0.3} />
                        <stop offset="95%" stopColor="#7c5cfc" stopOpacity={0} />
                      </linearGradient>
                      <linearGradient id="gEmployer" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#36d1b7" stopOpacity={0.3} />
                        <stop offset="95%" stopColor="#36d1b7" stopOpacity={0} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(128,128,128,0.1)" />
                    <XAxis dataKey="date" tick={{ fill: "#7a7a9a", fontSize: 11, fontFamily: "DM Mono, monospace" }} axisLine={false} tickLine={false} />
                    <YAxis tick={{ fill: "#7a7a9a", fontSize: 11, fontFamily: "DM Mono, monospace" }} axisLine={false} tickLine={false} />
                    <Tooltip content={<ChartTooltip />} />
                    <Area key="workers" type="monotone" dataKey="workers" name="Workers" stroke="#7c5cfc" strokeWidth={2} fill="url(#gWorker)" dot={false} activeDot={{ r: 4, fill: "#7c5cfc", strokeWidth: 0 }} />
                    <Area key="employers" type="monotone" dataKey="employers" name="Employers" stroke="#36d1b7" strokeWidth={2} fill="url(#gEmployer)" dot={false} activeDot={{ r: 4, fill: "#36d1b7", strokeWidth: 0 }} />
                  </AreaChart>
                ) : (
                  <BarChart data={placementData} margin={{ top: 0, right: 0, left: -20, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(128,128,128,0.1)" />
                    <XAxis dataKey="date" tick={{ fill: "#7a7a9a", fontSize: 11, fontFamily: "DM Mono, monospace" }} axisLine={false} tickLine={false} />
                    <YAxis tick={{ fill: "#7a7a9a", fontSize: 11, fontFamily: "DM Mono, monospace" }} axisLine={false} tickLine={false} />
                    <Tooltip content={<ChartTooltip />} />
                    <Bar key="placed" dataKey="placed" name="Placements" fill="#7c5cfc" fillOpacity={0.85} radius={[3, 3, 0, 0]} />
                  </BarChart>
                )}
              </ResponsiveContainer>
              {activeTab === "registrations" && (
                <div className="flex items-center gap-4 mt-3">
                  <div className="flex items-center gap-1.5">
                    <span className="w-2.5 h-2.5 rounded-full" style={{ background: "#7c5cfc" }} />
                    <span className="text-xs text-muted-foreground">Workers</span>
                  </div>
                  <div className="flex items-center gap-1.5">
                    <span className="w-2.5 h-2.5 rounded-full" style={{ background: "#36d1b7" }} />
                    <span className="text-xs text-muted-foreground">Employers</span>
                  </div>
                </div>
              )}
            </div>

            <div className="bg-card border border-border rounded-xl p-5">
              <div className="mb-4">
                <h2 className="text-sm font-semibold text-foreground">Job Categories</h2>
                <p className="text-xs text-muted-foreground mt-0.5">Distribution by sector</p>
              </div>
              <ResponsiveContainer width="100%" height={150}>
                <PieChart>
                  <Pie data={categoryData} cx="50%" cy="50%" innerRadius={42} outerRadius={65} paddingAngle={2} dataKey="value">
                    {categoryData.map((entry, i) => (
                      <Cell key={`cell-${i}`} fill={entry.color} strokeWidth={0} />
                    ))}
                  </Pie>
                  <Tooltip
                    formatter={(val) => [`${val}%`, ""]}
                    contentStyle={{ background: "#13131c", border: "1px solid rgba(255,255,255,0.07)", borderRadius: 8, fontSize: 12 }}
                  />
                </PieChart>
              </ResponsiveContainer>
              <div className="mt-3 space-y-1.5">
                {categoryData.map((cat) => (
                  <div key={cat.name} className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <span className="w-2 h-2 rounded-full flex-shrink-0" style={{ backgroundColor: cat.color }} />
                      <span className="text-xs text-muted-foreground">{cat.name}</span>
                    </div>
                    <span className="text-xs font-mono text-foreground">{cat.value}%</span>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Bottom row */}
          <div className="grid grid-cols-1 gap-4 lg:grid-cols-3">
            <div className="lg:col-span-2 bg-card border border-border rounded-xl overflow-hidden">
              <div className="flex items-center justify-between px-5 py-4 border-b border-border">
                <div>
                  <h2 className="text-sm font-semibold text-foreground">Recent Applications</h2>
                  <p className="text-xs text-muted-foreground mt-0.5">Latest job application activity</p>
                </div>
                <button
                  onClick={() => handleNavChange("applications")}
                  className="text-xs text-primary hover:text-primary/80 font-medium transition-colors">
                  View all →
                </button>
              </div>
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b border-border">
                      {["ID", "Worker", "Skill", "Employer", "Location", "Status", "Date"].map((h) => (
                        <th
                          key={h}
                          className="px-4 py-3 text-left text-xs font-medium text-muted-foreground uppercase tracking-wider"
                          style={{ fontFamily: "'DM Mono', monospace" }}
                        >
                          {h}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {recentApplications.map((app, i) => (
                      <tr
                        key={app.id}
                        className={`hover:bg-muted/40 transition-colors ${
                          i < recentApplications.length - 1 ? "border-b border-border" : ""
                        }`}
                      >
                        <td className="px-4 py-3 text-xs text-muted-foreground" style={{ fontFamily: "'DM Mono', monospace" }}>
                          {app.id}
                        </td>
                        <td className="px-4 py-3 text-xs font-medium text-foreground whitespace-nowrap">{app.worker}</td>
                        <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap">{app.skill}</td>
                        <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap">{app.employer}</td>
                        <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap">
                          <span className="flex items-center gap-1">
                            <MapPin className="w-2.5 h-2.5" />
                            {app.location}
                          </span>
                        </td>
                        <td className="px-4 py-3">
                          <span className={`text-xs px-2 py-0.5 rounded-full font-medium capitalize ${statusStyle[app.status]}`}>
                            {app.status}
                          </span>
                        </td>
                        <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap" style={{ fontFamily: "'DM Mono', monospace" }}>
                          {app.date}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

            <div className="flex flex-col gap-4">
              <div className="bg-card border border-border rounded-xl p-5">
                <div className="flex items-center justify-between mb-4">
                  <h2 className="text-sm font-semibold text-foreground">New Job Seekers</h2>
                  <button onClick={() => handleNavChange("seekers")} className="text-xs text-primary hover:text-primary/80 font-medium">View all →</button>
                </div>
                <div className="space-y-3">
                  {recentWorkers.map((w) => (
                    <div key={w.name} className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-full bg-muted flex items-center justify-center text-xs font-bold text-muted-foreground flex-shrink-0">
                        {w.name.split(" ").map((n) => n[0]).join("")}
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="text-xs font-semibold text-foreground truncate">{w.name}</p>
                        <p className="text-xs text-muted-foreground flex items-center gap-1 mt-0.5">
                          <MapPin className="w-2.5 h-2.5" />
                          {w.skill} · {w.location}
                        </p>
                      </div>
                      <div className="text-right flex-shrink-0">
                        <div className="flex items-center gap-0.5 justify-end">
                          <Star className="w-3 h-3 text-amber-400 fill-amber-400" />
                          <span className="text-xs font-mono text-foreground">{w.rating}</span>
                        </div>
                        <p className="text-xs text-muted-foreground mt-0.5" style={{ fontFamily: "'DM Mono', monospace" }}>
                          {w.joined}
                        </p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              <div className="bg-card border border-border rounded-xl p-5 flex-1">
                <div className="flex items-center justify-between mb-4">
                  <h2 className="text-sm font-semibold text-foreground">Activity Log</h2>
                  <div className="flex items-center gap-1.5">
                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                    <span className="text-xs text-emerald-400 font-medium">Live</span>
                  </div>
                </div>
                <div className="space-y-3">
                  {activityItems.map((item, i) => (
                    <div key={i} className="flex gap-3 items-start">
                      <div className={`w-1.5 h-1.5 rounded-full flex-shrink-0 mt-1.5 ${activityDot[item.type]}`} />
                      <div className="flex-1 min-w-0">
                        <p className="text-xs text-foreground leading-relaxed">{item.text}</p>
                        <p
                          className="text-xs text-muted-foreground mt-0.5 flex items-center gap-1"
                          style={{ fontFamily: "'DM Mono', monospace" }}
                        >
                          <Clock className="w-2.5 h-2.5" />
                          {item.time}
                        </p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
            </div>
            </div>
          )}
          {activeNav === "seekers" && <JobSeekersPanel search={globalSearch} filters={activeFilters} seekers={seekerList} setSeekers={setSeekerList} />}
          {activeNav === "employers" && <EmployersPanel search={globalSearch} filters={activeFilters} employers={employerList} setEmployers={setEmployerList} />}
          {activeNav === "jobs" && <JobListingsPanel search={globalSearch} filters={activeFilters} jobs={jobList} setJobs={setJobList} />}
          {activeNav === "applications" && <ApplicationsPanel search={globalSearch} filters={activeFilters} />}
          {activeNav === "placements" && <PlacementsPanel search={globalSearch} />}
          {activeNav === "accounts" && <UserAccountsPanel search={globalSearch} adminProfile={adminProfile} onProfileChange={handleProfileSave} />}
          {activeNav === "reports" && <ReportsPanel search={globalSearch} totalWorkers={totalWorkers} totalEmployers={totalEmployers} totalPlacements={totalPlacements} openJobs={openJobs} seekerList={seekerList} employerList={employerList} jobList={jobList} appData={appData} />}
          {activeNav === "settings" && <SettingsPanel search={globalSearch} username={adminProfile.username} email={adminProfile.email} onSave={handleProfileSave} />}
        </main>
      </div>
    </div>
  );
}
