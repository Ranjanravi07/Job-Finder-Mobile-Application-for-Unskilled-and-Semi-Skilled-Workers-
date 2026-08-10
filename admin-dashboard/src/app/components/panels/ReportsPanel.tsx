import { useState, useMemo } from "react";
import React from "react";
import {
  Users, Briefcase, CheckCircle, Activity, Download, Calendar, Filter, FileText, ShieldCheck, MapPin, Tag, Building2
} from "lucide-react";
import { type Seeker, type Employer, type Job, type Application } from "../../data";

interface ReportsPanelProps {
  search: string;
  totalWorkers: number;
  totalEmployers: number;
  totalPlacements: number;
  openJobs: number;
  seekerList: Seeker[];
  employerList: Employer[];
  jobList: Job[];
  appData: Application[];
}

type DateFilterOption = "all" | "today" | "week" | "month" | "year";
type ReportCategory = "overview" | "jobs" | "applications" | "kyc";

export default function ReportsPanel({
  search,
  totalWorkers,
  totalEmployers,
  totalPlacements,
  openJobs,
  seekerList,
  employerList,
  jobList,
  appData,
}: ReportsPanelProps) {
  const [dateFilter, setDateFilter] = useState<DateFilterOption>("all");
  const [activeCategory, setActiveCategory] = useState<ReportCategory>("overview");

  // Helper to check if a date falls within dateFilter range
  const isWithinDateFilter = (rawDate?: string) => {
    if (dateFilter === "all") return true;
    if (!rawDate) return false;
    try {
      const itemDate = new Date(rawDate);
      if (isNaN(itemDate.getTime())) return false;
      const now = Date.now();
      const msInDay = 24 * 60 * 60 * 1000;
      const diffMs = now - itemDate.getTime();

      if (dateFilter === "today") return diffMs <= msInDay;
      if (dateFilter === "week")  return diffMs <= 7 * msInDay;
      if (dateFilter === "month") return diffMs <= 30 * msInDay;
      if (dateFilter === "year")  return diffMs <= 365 * msInDay;
      return true;
    } catch (_) {
      return false;
    }
  };

  // Filtered datasets based on Date Range and Search
  const filteredWorkers = useMemo(() => {
    return seekerList.filter((s) => {
      const matchDate = isWithinDateFilter((s as any).createdAt || (s as any).submissionDate);
      const q = search.toLowerCase();
      const matchSearch = s.name.toLowerCase().includes(q) || s.skill.toLowerCase().includes(q) || s.location.toLowerCase().includes(q);
      return matchDate && matchSearch;
    });
  }, [seekerList, dateFilter, search]);

  const filteredEmployers = useMemo(() => {
    return employerList.filter((e) => {
      const matchDate = isWithinDateFilter((e as any).createdAt || (e as any).submissionDate);
      const q = search.toLowerCase();
      const matchSearch = e.name.toLowerCase().includes(q) || e.industry.toLowerCase().includes(q) || e.location.toLowerCase().includes(q);
      return matchDate && matchSearch;
    });
  }, [employerList, dateFilter, search]);

  const filteredJobs = useMemo(() => {
    return jobList.filter((j) => {
      const matchDate = isWithinDateFilter((j as any).datePosted || (j as any).createdAt);
      const q = search.toLowerCase();
      const matchSearch = j.title.toLowerCase().includes(q) || j.employer.toLowerCase().includes(q) || j.location.toLowerCase().includes(q);
      return matchDate && matchSearch;
    });
  }, [jobList, dateFilter, search]);

  const filteredApps = useMemo(() => {
    return appData.filter((a) => {
      const matchDate = isWithinDateFilter((a as any).appliedAt || (a as any).date);
      const q = search.toLowerCase();
      const matchSearch = a.worker.toLowerCase().includes(q) || a.employer.toLowerCase().includes(q) || a.skill.toLowerCase().includes(q);
      return matchDate && matchSearch;
    });
  }, [appData, dateFilter, search]);

  // Derived KPI metrics for selected period
  const periodWorkers = filteredWorkers.length;
  const periodEmployers = filteredEmployers.length;
  const periodJobs = filteredJobs.length;
  const periodApplications = filteredApps.length;
  const periodPlacements = filteredApps.filter((a) => a.status === "hired" || (a.status as any) === "accepted").length;
  const periodPendingKYC = filteredWorkers.filter((w) => w.verificationStatus === "pending").length +
                           filteredEmployers.filter((e) => e.verificationStatus === "pending").length;

  // Export CSV Handler
  const exportCSV = () => {
    let headers: string[] = [];
    let rows: string[][] = [];
    let filename = `report_${activeCategory}_${dateFilter}.csv`;

    if (activeCategory === "jobs") {
      headers = ["Job ID", "Title", "Employer", "Category", "Location", "Salary", "Type", "Applicants", "Status"];
      rows = filteredJobs.map((j) => [
        j.id, j.title, j.employer, j.category || "General", j.location, j.salary, j.type, String(j.applicants), j.status
      ]);
    } else if (activeCategory === "applications") {
      headers = ["Application ID", "Worker", "Skill", "Employer", "Location", "Applied Date", "Status"];
      rows = filteredApps.map((a) => [
        a.id, a.worker, a.skill, a.employer, a.location, a.date, a.status
      ]);
    } else if (activeCategory === "kyc") {
      headers = ["User ID", "Name", "Role", "Phone", "Gov ID Type", "Verification Status"];
      const workerRows = filteredWorkers.map((w) => [w.id, w.name, "Worker", w.phone, w.govIdType || "Citizenship", w.verificationStatus]);
      const employerRows = filteredEmployers.map((e) => [e.id, e.name, "Employer", e.phone, e.govIdNumber ? "Registered ID" : "Citizenship", e.verificationStatus]);
      rows = [...workerRows, ...employerRows];
    } else {
      headers = ["Metric", "Period Count", "Total Current Count"];
      rows = [
        ["Jobseekers", String(periodWorkers), String(totalWorkers)],
        ["Employers", String(periodEmployers), String(totalEmployers)],
        ["Job Listings", String(periodJobs), String(openJobs)],
        ["Applications", String(periodApplications), String(appData.length)],
        ["Placements", String(periodPlacements), String(totalPlacements)],
        ["Pending KYC", String(periodPendingKYC), String(seekerList.filter(s=>s.verificationStatus==='pending').length + employerList.filter(e=>e.verificationStatus==='pending').length)]
      ];
    }

    const csvContent = [headers.join(","), ...rows.map((r) => r.map((cell) => `"${cell.replace(/"/g, '""')}"`).join(","))].join("\n");
    const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.setAttribute("download", filename);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <div className="space-y-5">
      {/* Header & Filter Controls */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-sm font-semibold text-foreground">Analytics & System Reports</h2>
          <p className="text-xs text-muted-foreground mt-0.5">Real-time performance reporting directly from Firestore database</p>
        </div>

        <div className="flex items-center gap-2">
          {/* Date Filter Dropdown */}
          <div className="flex items-center gap-1.5 bg-card border border-border px-3 py-1.5 rounded-lg text-xs font-medium text-foreground">
            <Calendar className="w-3.5 h-3.5 text-muted-foreground" />
            <select
              value={dateFilter}
              onChange={(e) => setDateFilter(e.target.value as DateFilterOption)}
              className="bg-transparent text-foreground outline-none cursor-pointer text-xs"
            >
              <option value="all">All Time</option>
              <option value="today">Today</option>
              <option value="week">This Week</option>
              <option value="month">This Month</option>
              <option value="year">This Year</option>
            </select>
          </div>

          {/* Export CSV Button */}
          <button
            onClick={exportCSV}
            className="flex items-center gap-1.5 bg-primary text-white text-xs font-medium px-3 py-1.5 rounded-lg hover:bg-primary/90 transition-colors shadow-sm"
          >
            <Download className="w-3.5 h-3.5" />
            Export CSV
          </button>
        </div>
      </div>

      {/* Report Category Sub-Tabs */}
      <div className="flex items-center gap-2 border-b border-border pb-2">
        {[
          { id: "overview", label: "Overview Summary", icon: Activity },
          { id: "jobs", label: "Job Reports", icon: Briefcase },
          { id: "applications", label: "Application & Placement Reports", icon: CheckCircle },
          { id: "kyc", label: "KYC & Verification Reports", icon: ShieldCheck },
        ].map((tab) => {
          const Icon = tab.icon;
          const active = activeCategory === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => setActiveCategory(tab.id as ReportCategory)}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition-colors ${
                active ? "bg-muted text-foreground border border-border" : "text-muted-foreground hover:text-foreground"
              }`}
            >
              <Icon className="w-3.5 h-3.5" />
              {tab.label}
            </button>
          );
        })}
      </div>

      {/* Dynamic Summary Cards for Selected Date Filter */}
      <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
        <div className="bg-card border border-border rounded-xl p-4 flex flex-col gap-2">
          <div className="flex items-center justify-between">
            <span className="text-xs text-muted-foreground font-medium uppercase">Jobseekers (Period)</span>
            <Users className="w-4 h-4 text-violet-400" />
          </div>
          <p className="text-2xl font-bold text-foreground">{periodWorkers.toLocaleString()}</p>
          <p className="text-[11px] text-muted-foreground">{totalWorkers.toLocaleString()} total in database</p>
        </div>

        <div className="bg-card border border-border rounded-xl p-4 flex flex-col gap-2">
          <div className="flex items-center justify-between">
            <span className="text-xs text-muted-foreground font-medium uppercase">Employers (Period)</span>
            <Building2 className="w-4 h-4 text-sky-400" />
          </div>
          <p className="text-2xl font-bold text-foreground">{periodEmployers.toLocaleString()}</p>
          <p className="text-[11px] text-muted-foreground">{totalEmployers.toLocaleString()} total in database</p>
        </div>

        <div className="bg-card border border-border rounded-xl p-4 flex flex-col gap-2">
          <div className="flex items-center justify-between">
            <span className="text-xs text-muted-foreground font-medium uppercase">Jobs (Period)</span>
            <Briefcase className="w-4 h-4 text-amber-400" />
          </div>
          <p className="text-2xl font-bold text-foreground">{periodJobs.toLocaleString()}</p>
          <p className="text-[11px] text-muted-foreground">{openJobs.toLocaleString()} open listings</p>
        </div>

        <div className="bg-card border border-border rounded-xl p-4 flex flex-col gap-2">
          <div className="flex items-center justify-between">
            <span className="text-xs text-muted-foreground font-medium uppercase">Placements (Period)</span>
            <CheckCircle className="w-4 h-4 text-emerald-400" />
          </div>
          <p className="text-2xl font-bold text-foreground">{periodPlacements.toLocaleString()}</p>
          <p className="text-[11px] text-muted-foreground">{totalPlacements.toLocaleString()} total placements</p>
        </div>
      </div>

      {/* Main Report Table Container */}
      <div className="bg-card border border-border rounded-xl overflow-hidden">
        {/* Overview Tab Table */}
        {activeCategory === "overview" && (
          <div className="p-5 space-y-4">
            <h3 className="text-sm font-semibold text-foreground flex items-center gap-2">
              <FileText className="w-4 h-4 text-primary" /> Comprehensive System Metrics
            </h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
              <div className="border border-border rounded-lg p-4 space-y-2 bg-muted/20">
                <p className="font-semibold text-foreground">User & Registration Summary</p>
                <div className="flex justify-between py-1 border-b border-border">
                  <span className="text-muted-foreground">Period Worker Registrations</span>
                  <span className="font-mono text-foreground">{periodWorkers}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-border">
                  <span className="text-muted-foreground">Period Employer Registrations</span>
                  <span className="font-mono text-foreground">{periodEmployers}</span>
                </div>
                <div className="flex justify-between py-1">
                  <span className="text-muted-foreground">Pending KYC Audits</span>
                  <span className="font-mono text-amber-400">{periodPendingKYC}</span>
                </div>
              </div>

              <div className="border border-border rounded-lg p-4 space-y-2 bg-muted/20">
                <p className="font-semibold text-foreground">Jobs & Applications Summary</p>
                <div className="flex justify-between py-1 border-b border-border">
                  <span className="text-muted-foreground">Period Jobs Posted</span>
                  <span className="font-mono text-foreground">{periodJobs}</span>
                </div>
                <div className="flex justify-between py-1 border-b border-border">
                  <span className="text-muted-foreground">Period Applications Submitted</span>
                  <span className="font-mono text-foreground">{periodApplications}</span>
                </div>
                <div className="flex justify-between py-1">
                  <span className="text-muted-foreground">Period Placements</span>
                  <span className="font-mono text-emerald-400">{periodPlacements}</span>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Jobs Tab Table */}
        {activeCategory === "jobs" && (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-border">
                  {["Job ID", "Title", "Employer", "Category", "Location", "Salary", "Type", "Applicants", "Status"].map((h) => (
                    <th key={h} className="px-4 py-3 text-left text-xs font-medium text-muted-foreground uppercase tracking-wider">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filteredJobs.length === 0 ? (
                  <tr>
                    <td colSpan={9} className="px-4 py-8 text-center text-xs text-muted-foreground">
                      No jobs found for selected period.
                    </td>
                  </tr>
                ) : (
                  filteredJobs.map((job) => (
                    <tr key={job.id} className="border-b border-border last:border-0 hover:bg-muted/40 transition-colors">
                      <td className="px-4 py-3 text-xs font-mono text-muted-foreground">{job.id}</td>
                      <td className="px-4 py-3 text-xs font-medium text-foreground">{job.title}</td>
                      <td className="px-4 py-3 text-xs text-muted-foreground">{job.employer}</td>
                      <td className="px-4 py-3 text-xs text-muted-foreground">{job.category || "General"}</td>
                      <td className="px-4 py-3 text-xs text-muted-foreground">{job.location}</td>
                      <td className="px-4 py-3 text-xs text-foreground">{job.salary}</td>
                      <td className="px-4 py-3 text-xs text-muted-foreground">{job.type}</td>
                      <td className="px-4 py-3 text-xs font-mono text-foreground">{job.applicants}</td>
                      <td className="px-4 py-3 text-xs capitalize">{job.status}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}

        {/* Applications Tab Table */}
        {activeCategory === "applications" && (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-border">
                  {["Application ID", "Worker", "Skill / Category", "Employer", "Location", "Applied Date", "Status"].map((h) => (
                    <th key={h} className="px-4 py-3 text-left text-xs font-medium text-muted-foreground uppercase tracking-wider">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filteredApps.length === 0 ? (
                  <tr>
                    <td colSpan={7} className="px-4 py-8 text-center text-xs text-muted-foreground">
                      No applications found for selected period.
                    </td>
                  </tr>
                ) : (
                  filteredApps.map((app) => (
                    <tr key={app.id} className="border-b border-border last:border-0 hover:bg-muted/40 transition-colors">
                      <td className="px-4 py-3 text-xs font-mono text-muted-foreground">{app.id}</td>
                      <td className="px-4 py-3 text-xs font-medium text-foreground">{app.worker}</td>
                      <td className="px-4 py-3 text-xs text-muted-foreground">{app.skill}</td>
                      <td className="px-4 py-3 text-xs text-muted-foreground">{app.employer}</td>
                      <td className="px-4 py-3 text-xs text-muted-foreground">{app.location}</td>
                      <td className="px-4 py-3 text-xs text-muted-foreground">{app.date}</td>
                      <td className="px-4 py-3 text-xs font-medium capitalize">
                        <span className={`px-2 py-0.5 rounded-full ${
                          app.status === "hired" || (app.status as any) === "accepted" ? "bg-emerald-500/10 text-emerald-400" :
                          app.status === "rejected" ? "bg-rose-500/10 text-rose-400" : "bg-amber-500/10 text-amber-400"
                        }`}>
                          {app.status}
                        </span>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}

        {/* KYC Tab Table */}
        {activeCategory === "kyc" && (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-border">
                  {["ID", "Name", "Role", "Phone", "Gov ID Type", "Verification Status"].map((h) => (
                    <th key={h} className="px-4 py-3 text-left text-xs font-medium text-muted-foreground uppercase tracking-wider">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filteredWorkers.length === 0 && filteredEmployers.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="px-4 py-8 text-center text-xs text-muted-foreground">
                      No KYC records found for selected period.
                    </td>
                  </tr>
                ) : (
                  [
                    ...filteredWorkers.map((w) => ({ ...w, userType: "Worker" })),
                    ...filteredEmployers.map((e) => ({ ...e, userType: "Employer" }))
                  ].map((user) => (
                    <tr key={user.id} className="border-b border-border last:border-0 hover:bg-muted/40 transition-colors">
                      <td className="px-4 py-3 text-xs font-mono text-muted-foreground">{user.id}</td>
                      <td className="px-4 py-3 text-xs font-medium text-foreground">{user.name}</td>
                      <td className="px-4 py-3 text-xs text-muted-foreground">{user.userType}</td>
                      <td className="px-4 py-3 text-xs text-muted-foreground">{user.phone}</td>
                      <td className="px-4 py-3 text-xs text-muted-foreground capitalize">{(user as any).govIdType || "Citizenship"}</td>
                      <td className="px-4 py-3 text-xs font-medium capitalize">
                        <span className={`px-2 py-0.5 rounded-full ${
                          user.verificationStatus === "verified" ? "bg-emerald-500/10 text-emerald-400" :
                          user.verificationStatus === "rejected" || user.verificationStatus === "blocked" ? "bg-rose-500/10 text-rose-400" : "bg-amber-500/10 text-amber-400"
                        }`}>
                          {user.verificationStatus}
                        </span>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
