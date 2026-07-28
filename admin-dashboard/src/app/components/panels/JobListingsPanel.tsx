import React from "react";
import { Briefcase, MapPin } from "lucide-react";
import type { ActiveFilters } from "../App";
import { type Job } from "../../data";

const statusStyle: Record<string, string> = {
  open:   "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20",
  closed: "bg-rose-500/10   text-rose-400   border border-rose-500/20",
  paused: "bg-amber-500/10  text-amber-400  border border-amber-500/20",
};

export default function JobListingsPanel({ search, filters, jobs, setJobs }: {
  search: string;
  filters?: ActiveFilters;
  jobs: Job[];
  setJobs: React.Dispatch<React.SetStateAction<Job[]>>;
}) {
  const remove = (id: string) => setJobs((prev) => prev.filter((j) => j.id !== id));

  const filtered = jobs.filter((j) => {
    const q = search.toLowerCase();
    const matchSearch =
      j.title.toLowerCase().includes(q) ||
      j.employer.toLowerCase().includes(q) ||
      j.location.toLowerCase().includes(q);
    const matchStatus  = !filters?.status.length  || filters.status.includes(j.status);
    const matchJobType = !filters?.jobType.length || filters.jobType.includes(j.type);
    return matchSearch && matchStatus && matchJobType;
  });

  return (
    <div className="space-y-5">
      <div>
        <h2 className="text-sm font-semibold text-foreground">Job Listings</h2>
        <p className="text-xs text-muted-foreground mt-0.5">Manage active and past job postings</p>
      </div>

      <div className="bg-card border border-border rounded-xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border">
                {["ID", "Title", "Employer", "Location", "Salary", "Type", "Applicants", "Status", "Action"].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-medium text-muted-foreground uppercase tracking-wider">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={9} className="px-4 py-8 text-center text-xs text-muted-foreground">
                    No job listings match the current filters.
                  </td>
                </tr>
              ) : (
                filtered.map((job) => (
                  <tr key={job.id} className="border-b border-border last:border-0 hover:bg-muted/40 transition-colors">
                    <td className="px-4 py-3 text-xs text-muted-foreground" style={{ fontFamily: "'DM Mono', monospace" }}>{job.id}</td>
                    <td className="px-4 py-3 text-xs font-medium text-foreground whitespace-nowrap">
                      <div className="flex items-center gap-2">
                        <div className="w-6 h-6 rounded bg-primary/10 flex items-center justify-center flex-shrink-0">
                          <Briefcase className="w-3 h-3 text-primary" />
                        </div>
                        {job.title}
                      </div>
                    </td>
                    <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap">{job.employer}</td>
                    <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap">
                      <span className="flex items-center gap-1">
                        <MapPin className="w-3 h-3" />
                        {job.location}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-xs text-foreground whitespace-nowrap">{job.salary}</td>
                    <td className="px-4 py-3">
                      <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${
                        job.type === "Daily"
                          ? "bg-sky-500/10 text-sky-400 border border-sky-500/20"
                          : "bg-violet-500/10 text-violet-400 border border-violet-500/20"
                      }`}>
                        {job.type}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-xs text-foreground whitespace-nowrap">{job.applicants}</td>
                    <td className="px-4 py-3">
                      <span className={`text-xs px-2 py-0.5 rounded-full font-medium capitalize ${statusStyle[job.status]}`}>{job.status}</span>
                    </td>
                    <td className="px-4 py-3">
                      <button
                        onClick={() => remove(job.id)}
                        className="text-xs text-rose-400 hover:text-rose-300 hover:bg-rose-500/10 px-2 py-1 rounded transition-colors"
                      >
                        Delete
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
