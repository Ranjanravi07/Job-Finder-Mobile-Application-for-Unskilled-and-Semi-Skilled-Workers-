import { useState, useEffect } from "react";
import { useTheme } from "next-themes";
import { onAuthStateChanged } from "firebase/auth";
import { auth } from "../firebase";
import Login from "./components/Login";
import UserLogin from "./components/UserLogin";
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

const registrationData = [
  { month: "Jan", workers: 120, employers: 18 },
  { month: "Feb", workers: 185, employers: 24 },
  { month: "Mar", workers: 240, employers: 31 },
  { month: "Apr", workers: 198, employers: 27 },
  { month: "May", workers: 310, employers: 42 },
  { month: "Jun", workers: 278, employers: 38 },
  { month: "Jul", workers: 390, employers: 55 },
  { month: "Aug", workers: 425, employers: 61 },
  { month: "Sep", workers: 512, employers: 74 },
  { month: "Oct", workers: 480, employers: 68 },
  { month: "Nov", workers: 560, employers: 82 },
  { month: "Dec", workers: 634, employers: 91 },
];

const placementData = [
  { month: "Jan", placed: 58 },
  { month: "Feb", placed: 72 },
  { month: "Mar", placed: 94 },
  { month: "Apr", placed: 86 },
  { month: "May", placed: 118 },
  { month: "Jun", placed: 104 },
  { month: "Jul", placed: 139 },
  { month: "Aug", placed: 152 },
  { month: "Sep", placed: 178 },
  { month: "Oct", placed: 165 },
  { month: "Nov", placed: 201 },
  { month: "Dec", placed: 224 },
];

const categoryData = [
  { name: "Construction", value: 32, color: "#7c5cfc" },
  { name: "Domestic Help", value: 22, color: "#36d1b7" },
  { name: "Factory Work", value: 18, color: "#f7c948" },
  { name: "Security Guard", value: 13, color: "#5ca4fc" },
  { name: "Delivery", value: 10, color: "#e8455a" },
  { name: "Others", value: 5, color: "#a78bfa" },
];

const recentApplications = [
  { id: "APP-1042", worker: "Ramon dela Cruz", skill: "Construction", employer: "SunBuild Corp.", location: "Manila", status: "hired", date: "Dec 28, 2024" },
  { id: "APP-1041", worker: "Maria Santos", skill: "Domestic Help", employer: "Reyes Household", location: "Quezon City", status: "pending", date: "Dec 28, 2024" },
  { id: "APP-1040", worker: "Eduardo Bautista", skill: "Factory Work", employer: "FiliTex Mills", location: "Caloocan", status: "hired", date: "Dec 27, 2024" },
  { id: "APP-1039", worker: "Josefina Reyes", skill: "Security Guard", employer: "Shield Pro Security", location: "Makati", status: "rejected", date: "Dec 27, 2024" },
  { id: "APP-1038", worker: "Benjamin Lim", skill: "Delivery Rider", employer: "QuickShip PH", location: "Pasig", status: "hired", date: "Dec 26, 2024" },
  { id: "APP-1037", worker: "Lourdes Magno", skill: "Domestic Help", employer: "Cruz Family", location: "Marikina", status: "pending", date: "Dec 26, 2024" },
  { id: "APP-1036", worker: "Arturo Villanueva", skill: "Construction", employer: "MetroBuild Inc.", location: "Taguig", status: "hired", date: "Dec 25, 2024" },
];

const recentWorkers = [
  { name: "Carina Ocampo", skill: "Factory Work", location: "Navotas", rating: 4.8, joined: "Dec 28" },
  { name: "Rolando Tupas", skill: "Construction", location: "Malabon", rating: 4.5, joined: "Dec 27" },
  { name: "Nena Escuadro", skill: "Domestic Help", location: "Valenzuela", rating: 4.9, joined: "Dec 27" },
  { name: "Felix Domingo", skill: "Delivery Rider", location: "San Juan", rating: 4.3, joined: "Dec 26" },
];

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

const navItems = [
  { icon: LayoutDashboard, label: "Dashboard", id: "dashboard" },
  { icon: HardHat, label: "Job Seekers", id: "seekers", badge: "4.2k" },
  { icon: Building2, label: "Employers", id: "employers", badge: "312" },
  { icon: Briefcase, label: "Job Listings", id: "jobs", badge: "89" },
  { icon: FileText, label: "Applications", id: "applications" },
  { icon: CheckCircle, label: "Placements", id: "placements" },
  { icon: Users, label: "User Accounts", id: "accounts" },
  { icon: Activity, label: "Reports", id: "reports" },
  { icon: Settings, label: "Settings", id: "settings" },
];

const kpiCards = [
  { label: "Registered Workers", value: "4,218", change: "+12.4%", up: true, sub: "vs last month", icon: HardHat, color: "text-violet-400" },
  { label: "Active Employers", value: "312", change: "+8.7%", up: true, sub: "vs last month", icon: Building2, color: "text-sky-400" },
  { label: "Successful Placements", value: "1,591", change: "+16.2%", up: true, sub: "this year", icon: CheckCircle, color: "text-emerald-400" },
  { label: "Open Job Listings", value: "89", change: "-4.3%", up: false, sub: "vs last week", icon: Briefcase, color: "text-amber-400" },
];

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
  const [userMode, setUserMode] = useState(false);
  const [firebaseUser, setFirebaseUser] = useState<ReturnType<typeof onAuthStateChanged> extends (cb: (u: infer U) => any) => any ? U : never>(null as any);
  const [adminProfile, setAdminProfile] = useState({ username: "Juan Admin", email: "juan@jobfinder.ph" });
  const [loginDate] = useState(() => new Date());

  const handleProfileSave = (username: string, email: string) => {
    setAdminProfile({ username, email });
  };

  // Derive initials from username (up to 2 letters)
  const adminInitials = adminProfile.username
    .split(" ")
    .map((n) => n[0])
    .join("")
    .slice(0, 2)
    .toUpperCase();

  const handleLogin = () => {
    localStorage.setItem("jobfinder-auth", "true");
    setIsAuthenticated(true);
  };

  const handleLogout = () => {
    localStorage.removeItem("jobfinder-auth");
    setIsAuthenticated(false);
  };

  const handleUserLogin = () => {
    setUserMode(true);
  };

  useEffect(() => {
    if (!auth) return;
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      setFirebaseUser(user);
    });
    return unsubscribe;
  }, []);

  const handleUserLogout = async () => {
    if (auth) await auth.signOut();
    setUserMode(false);
    setFirebaseUser(null);
  };

  const toggleTheme = () => {
    setTheme(theme === "light" ? "dark" : theme === "dark" ? "system" : "light");
  };

  if (!isAuthenticated && !userMode) {
    return <Login onLogin={handleLogin} onSwitchToUser={() => setUserMode(true)} />;
  }

  if (userMode && !firebaseUser) {
    return <UserLogin onLogin={handleUserLogin} />;
  }

  if (userMode && firebaseUser) {
    return (
      <div className="size-full flex bg-background text-foreground overflow-hidden" style={{ fontFamily: "'Geist', system-ui, sans-serif" }}>
        <div className="flex-1 flex flex-col items-center justify-center gap-4">
          <HardHat className="w-12 h-12 text-primary" />
          <h1 className="text-xl font-semibold">Welcome, {firebaseUser.email}</h1>
          <p className="text-xs text-muted-foreground">User Dashboard</p>
          <button onClick={handleUserLogout} className="mt-4 px-4 py-2 rounded-md bg-primary text-white text-sm">Logout</button>
        </div>
      </div>
    );
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
                onClick={() => setActiveNav(item.id)}
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
            <button className="flex items-center gap-1.5 text-xs text-muted-foreground hover:text-foreground border border-border rounded-md px-3 py-1.5 transition-colors">
              <Filter className="w-3 h-3" /> Filter
            </button>
            <button className="relative w-8 h-8 flex items-center justify-center rounded-md text-muted-foreground hover:text-foreground hover:bg-muted transition-colors">
              <Bell className="w-4 h-4" />
              <span className="absolute top-1.5 right-1.5 w-1.5 h-1.5 bg-rose-500 rounded-full" />
            </button>
            <div className="flex items-center gap-2 px-2 py-1.5 rounded-md hover:bg-muted cursor-pointer transition-colors">
              <div className="w-6 h-6 rounded-full bg-primary/20 flex items-center justify-center text-xs font-bold text-primary">
                {adminInitials}
              </div>
              <span className="text-sm text-foreground font-medium">{adminProfile.username.split(" ")[0]}</span>
              <ChevronDown className="w-3 h-3 text-muted-foreground" />
            </div>
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
                    <XAxis dataKey="month" tick={{ fill: "#7a7a9a", fontSize: 11, fontFamily: "DM Mono, monospace" }} axisLine={false} tickLine={false} />
                    <YAxis tick={{ fill: "#7a7a9a", fontSize: 11, fontFamily: "DM Mono, monospace" }} axisLine={false} tickLine={false} />
                    <Tooltip content={<ChartTooltip />} />
                    <Area key="workers" type="monotone" dataKey="workers" name="Workers" stroke="#7c5cfc" strokeWidth={2} fill="url(#gWorker)" dot={false} activeDot={{ r: 4, fill: "#7c5cfc", strokeWidth: 0 }} />
                    <Area key="employers" type="monotone" dataKey="employers" name="Employers" stroke="#36d1b7" strokeWidth={2} fill="url(#gEmployer)" dot={false} activeDot={{ r: 4, fill: "#36d1b7", strokeWidth: 0 }} />
                  </AreaChart>
                ) : (
                  <BarChart data={placementData} margin={{ top: 0, right: 0, left: -20, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(128,128,128,0.1)" />
                    <XAxis dataKey="month" tick={{ fill: "#7a7a9a", fontSize: 11, fontFamily: "DM Mono, monospace" }} axisLine={false} tickLine={false} />
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
                <button className="text-xs text-primary hover:text-primary/80 font-medium transition-colors">
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
                  <button className="text-xs text-primary hover:text-primary/80 font-medium">View all →</button>
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
          {activeNav === "seekers" && <JobSeekersPanel search={globalSearch} />}
          {activeNav === "employers" && <EmployersPanel search={globalSearch} />}
          {activeNav === "jobs" && <JobListingsPanel search={globalSearch} />}
          {activeNav === "applications" && <ApplicationsPanel search={globalSearch} />}
          {activeNav === "placements" && <PlacementsPanel search={globalSearch} />}
          {activeNav === "accounts" && <UserAccountsPanel search={globalSearch} adminProfile={adminProfile} />}
          {activeNav === "reports" && <ReportsPanel search={globalSearch} />}
          {activeNav === "settings" && <SettingsPanel search={globalSearch} username={adminProfile.username} email={adminProfile.email} onSave={handleProfileSave} />}
        </main>
      </div>
    </div>
  );
}
