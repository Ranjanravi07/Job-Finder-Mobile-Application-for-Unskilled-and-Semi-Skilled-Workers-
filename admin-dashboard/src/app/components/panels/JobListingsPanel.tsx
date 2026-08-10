import { useState } from "react";
import React from "react";
import { Briefcase, MapPin, X, Building2, Users, DollarSign, Calendar, Tag, MoreVertical, CheckCircle, Ban, Trash2 } from "lucide-react";
import { doc, updateDoc, deleteDoc } from "firebase/firestore";
import { db } from "../../../firebase";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "../../components/ui/dropdown-menu";
import type { ActiveFilters } from "../App";
import { type Job } from "../../data";

const statusStyle: Record<string, string> = {
  open:   "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20",
  closed: "bg-rose-500/10   text-rose-400   border border-rose-500/20",
  paused: "bg-amber-500/10  text-amber-400  border border-amber-500/20",
};

/** Job Detail Modal */
function JobDetailModal({ job, onClose, onCloseJob, onPauseJob, onOpenJob, onDeleteJob }: {
  job: Job;
  onClose: () => void;
  onCloseJob: (id: string) => void;
  onPauseJob: (id: string) => void;
  onOpenJob: (id: string) => void;
  onDeleteJob: (id: string) => void;
}) {
  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4"
      style={{ background: "rgba(0,0,0,0.6)", backdropFilter: "blur(4px)" }}
      onClick={onClose}
    >
      <div
        className="bg-card border border-border rounded-2xl w-full max-w-lg shadow-2xl overflow-hidden max-h-[90vh] overflow-y-auto"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header band */}
        <div className="relative h-24 bg-gradient-to-br from-emerald-500/25 to-primary/5 p-6 flex items-end">
          <button
            onClick={onClose}
            className="absolute top-3 right-3 w-7 h-7 flex items-center justify-center rounded-full bg-black/30 text-white hover:bg-black/50 transition-colors"
          >
            <X className="w-3.5 h-3.5" />
          </button>
        </div>

        <div className="px-6 pb-6">
          {/* Badge & Title */}
          <div className="-mt-6 mb-4 flex items-end justify-between">
            <div className="w-14 h-14 rounded-xl bg-primary/15 flex items-center justify-center ring-4 ring-card flex-shrink-0">
              <Briefcase className="w-6 h-6 text-primary" />
            </div>
            <span className={`text-xs px-2.5 py-1 rounded-full font-medium capitalize ${statusStyle[job.status]}`}>
              {job.status}
            </span>
          </div>

          <h3 className="text-lg font-bold text-foreground">{job.title}</h3>
          <p className="text-xs text-muted-foreground mt-0.5" style={{ fontFamily: "'DM Mono', monospace" }}>{job.id}</p>

          <hr className="border-border my-4" />

          {/* Details Grid */}
          <div className="space-y-3">
            <div className="flex items-start gap-3">
              <div className="w-7 h-7 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
                <Building2 className="w-3.5 h-3.5 text-muted-foreground" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Employer</p>
                <p className="text-sm font-medium text-foreground mt-0.5">{job.employer}</p>
              </div>
            </div>

            <div className="flex items-start gap-3">
              <div className="w-7 h-7 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
                <Tag className="w-3.5 h-3.5 text-muted-foreground" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Category</p>
                <p className="text-sm font-medium text-foreground mt-0.5">{job.category || 'General'}</p>
              </div>
            </div>

            <div className="flex items-start gap-3">
              <div className="w-7 h-7 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
                <MapPin className="w-3.5 h-3.5 text-muted-foreground" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Location</p>
                <p className="text-sm font-medium text-foreground mt-0.5">{job.location}</p>
              </div>
            </div>

            <div className="flex items-start gap-3">
              <div className="w-7 h-7 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
                <DollarSign className="w-3.5 h-3.5 text-muted-foreground" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Wage / Salary</p>
                <p className="text-sm font-medium text-foreground mt-0.5">{job.salary}</p>
              </div>
            </div>

            <div className="flex items-start gap-3">
              <div className="w-7 h-7 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
                <Users className="w-3.5 h-3.5 text-muted-foreground" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Applicants</p>
                <p className="text-sm font-medium text-foreground mt-0.5">{job.applicants} applicant(s)</p>
              </div>
            </div>

            <div className="flex items-start gap-3">
              <div className="w-7 h-7 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
                <Calendar className="w-3.5 h-3.5 text-muted-foreground" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Date Posted</p>
                <p className="text-sm font-medium text-foreground mt-0.5">{job.posted}</p>
              </div>
            </div>
          </div>

          {/* Description */}
          {job.description && (
            <div className="mt-4 border-t border-border pt-3">
              <p className="text-xs font-semibold text-muted-foreground mb-1">Job Description</p>
              <p className="text-xs text-foreground bg-muted/30 p-3 rounded-lg border border-border leading-relaxed">
                {job.description}
              </p>
            </div>
          )}

          {/* Action Buttons */}
          <div className="mt-6 flex items-center justify-end gap-2 border-t border-border pt-4">
            {job.status === "open" ? (
              <button
                onClick={() => { onCloseJob(job.id); onClose(); }}
                className="px-3 py-1.5 text-xs font-medium bg-rose-500/10 text-rose-400 border border-rose-500/20 rounded-lg hover:bg-rose-500/20 transition-colors"
              >
                Close Job
              </button>
            ) : (
              <button
                onClick={() => { onOpenJob(job.id); onClose(); }}
                className="px-3 py-1.5 text-xs font-medium bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 rounded-lg hover:bg-emerald-500/20 transition-colors"
              >
                Re-open Job
              </button>
            )}
            <button
              onClick={() => { onDeleteJob(job.id); onClose(); }}
              className="px-3 py-1.5 text-xs font-medium bg-muted text-muted-foreground hover:text-foreground rounded-lg transition-colors"
            >
              Delete
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

export default function JobListingsPanel({ search, filters, jobs, setJobs }: {
  search: string;
  filters?: ActiveFilters;
  jobs: Job[];
  setJobs: React.Dispatch<React.SetStateAction<Job[]>>;
}) {
  const [selectedJob, setSelectedJob] = useState<Job | null>(null);

  const closeJob = async (id: string) => {
    if (db) {
      try {
        await updateDoc(doc(db, "jobs", id), { status: "closed" });
      } catch (err) {
        console.error("Failed to close job in Firestore:", err);
      }
    }
    setJobs((prev) => prev.map((j) => (j.id === id ? { ...j, status: "closed" } : j)));
  };

  const openJob = async (id: string) => {
    if (db) {
      try {
        await updateDoc(doc(db, "jobs", id), { status: "open" });
      } catch (err) {
        console.error("Failed to open job in Firestore:", err);
      }
    }
    setJobs((prev) => prev.map((j) => (j.id === id ? { ...j, status: "open" } : j)));
  };

  const pauseJob = async (id: string) => {
    if (db) {
      try {
        await updateDoc(doc(db, "jobs", id), { status: "paused" });
      } catch (err) {
        console.error("Failed to pause job in Firestore:", err);
      }
    }
    setJobs((prev) => prev.map((j) => (j.id === id ? { ...j, status: "paused" } : j)));
  };

  const remove = async (id: string) => {
    if (db) {
      try {
        await deleteDoc(doc(db, "jobs", id));
      } catch (err) {
        console.error("Failed to delete job from Firestore:", err);
      }
    }
    setJobs((prev) => prev.filter((j) => j.id !== id));
    if (selectedJob?.id === id) setSelectedJob(null);
  };

  const filtered = jobs.filter((j) => {
    const q = search.toLowerCase();
    const matchSearch =
      j.title.toLowerCase().includes(q) ||
      j.employer.toLowerCase().includes(q) ||
      j.location.toLowerCase().includes(q) ||
      (j.category && j.category.toLowerCase().includes(q));
    const matchStatus  = !filters?.status.length  || filters.status.includes(j.status);
    const matchJobType = !filters?.jobType.length || filters.jobType.includes(j.type);
    return matchSearch && matchStatus && matchJobType;
  });

  return (
    <>
      {selectedJob && (
        <JobDetailModal
          job={selectedJob}
          onClose={() => setSelectedJob(null)}
          onCloseJob={closeJob}
          onPauseJob={pauseJob}
          onOpenJob={openJob}
          onDeleteJob={remove}
        />
      )}

      <div className="space-y-5">
        <div>
          <h2 className="text-sm font-semibold text-foreground">Job Listings</h2>
          <p className="text-xs text-muted-foreground mt-0.5">Manage active and past job postings — click a row to view details</p>
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
                      No jobs posted yet.
                    </td>
                  </tr>
                ) : (
                  filtered.map((job) => (
                    <tr
                      key={job.id}
                      className="border-b border-border last:border-0 hover:bg-muted/40 transition-colors cursor-pointer"
                      onClick={() => setSelectedJob(job)}
                    >
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
                      <td
                        className="px-4 py-3"
                        onClick={(e) => e.stopPropagation()}
                      >
                        <DropdownMenu>
                          <DropdownMenuTrigger asChild>
                            <button className="w-7 h-7 flex items-center justify-center rounded-md text-muted-foreground hover:text-foreground hover:bg-muted transition-colors">
                              <MoreVertical className="w-3.5 h-3.5" />
                            </button>
                          </DropdownMenuTrigger>
                          <DropdownMenuContent align="end" className="w-40">
                            {job.status === "open" ? (
                              <DropdownMenuItem onClick={() => closeJob(job.id)} className="gap-2">
                                <Ban className="w-3.5 h-3.5 text-rose-400" />
                                Close Job
                              </DropdownMenuItem>
                            ) : (
                              <DropdownMenuItem onClick={() => openJob(job.id)} className="gap-2">
                                <CheckCircle className="w-3.5 h-3.5 text-emerald-400" />
                                Open Job
                              </DropdownMenuItem>
                            )}
                            <DropdownMenuSeparator />
                            <DropdownMenuItem variant="destructive" onClick={() => remove(job.id)} className="gap-2">
                              <Trash2 className="w-3.5 h-3.5" />
                              Delete
                            </DropdownMenuItem>
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </>
  );
}
