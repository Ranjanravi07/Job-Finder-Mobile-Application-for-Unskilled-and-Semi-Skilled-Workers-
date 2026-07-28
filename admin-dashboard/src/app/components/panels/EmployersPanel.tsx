import { useState } from "react";
import React from "react";
import {
  Building2, MapPin, Users, MoreVertical, CheckCircle, Ban, Trash2,
  X, Phone, CreditCard, Briefcase,
} from "lucide-react";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "../../components/ui/dropdown-menu";
import type { ActiveFilters } from "../App";
import { type Employer, type EmployerStatus as Status } from "../../data";

const statusStyle: Record<Status, string> = {
  active:   "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20",
  pending:  "bg-amber-500/10  text-amber-400  border border-amber-500/20",
  inactive: "bg-slate-500/10  text-slate-400  border border-slate-500/20",
};

/** Profile modal */
function ProfileModal({ employer, onClose }: { employer: Employer; onClose: () => void }) {
  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4"
      style={{ background: "rgba(0,0,0,0.6)", backdropFilter: "blur(4px)" }}
      onClick={onClose}
    >
      <div
        className="bg-card border border-border rounded-2xl w-full max-w-md shadow-2xl overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header band */}
        <div className="relative h-24 bg-gradient-to-br from-sky-500/25 to-primary/5">
          <button
            onClick={onClose}
            className="absolute top-3 right-3 w-7 h-7 flex items-center justify-center rounded-full bg-black/30 text-white hover:bg-black/50 transition-colors"
          >
            <X className="w-3.5 h-3.5" />
          </button>
        </div>

        <div className="px-6 pb-6">
          {/* Avatar overlapping header */}
          <div className="-mt-8 mb-4 flex items-end justify-between">
            <div className="w-16 h-16 rounded-xl bg-primary/15 flex items-center justify-center ring-4 ring-card flex-shrink-0">
              <Building2 className="w-7 h-7 text-primary" />
            </div>
            <span className={`text-xs px-2.5 py-1 rounded-full font-medium capitalize ${statusStyle[employer.status]}`}>
              {employer.status}
            </span>
          </div>

          {/* Company name + ID */}
          <h3 className="text-base font-semibold text-foreground">{employer.name}</h3>
          <p className="text-xs text-muted-foreground mt-0.5" style={{ fontFamily: "'DM Mono', monospace" }}>{employer.id}</p>

          {/* Workers count badge */}
          <div className="flex items-center gap-1 mt-2">
            <Users className="w-3.5 h-3.5 text-muted-foreground" />
            <span className="text-xs font-medium text-foreground">{employer.workers}</span>
            <span className="text-xs text-muted-foreground ml-1">workers hired</span>
          </div>

          <hr className="border-border my-4" />

          {/* Detail rows */}
          <div className="space-y-3">
            {/* Contact person */}
            <div className="flex items-start gap-3">
              <div className="w-7 h-7 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
                <Users className="w-3.5 h-3.5 text-muted-foreground" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Contact Person</p>
                <p className="text-sm font-medium text-foreground mt-0.5">{employer.contactPerson}</p>
              </div>
            </div>

            {/* Phone */}
            <div className="flex items-start gap-3">
              <div className="w-7 h-7 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
                <Phone className="w-3.5 h-3.5 text-muted-foreground" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Phone Number</p>
                <p className="text-sm font-medium text-foreground mt-0.5">{employer.phone}</p>
              </div>
            </div>

            {/* Primary role / industry */}
            <div className="flex items-start gap-3">
              <div className="w-7 h-7 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
                <Briefcase className="w-3.5 h-3.5 text-muted-foreground" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Primary Role / Industry</p>
                <p className="text-sm font-medium text-foreground mt-0.5">{employer.industry}</p>
              </div>
            </div>

            {/* Location */}
            <div className="flex items-start gap-3">
              <div className="w-7 h-7 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
                <MapPin className="w-3.5 h-3.5 text-muted-foreground" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Location</p>
                <p className="text-sm font-medium text-foreground mt-0.5">{employer.location}</p>
              </div>
            </div>

            {/* Gov ID number */}
            <div className="flex items-start gap-3">
              <div className="w-7 h-7 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
                <CreditCard className="w-3.5 h-3.5 text-muted-foreground" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Government ID Number</p>
                <p className="text-sm font-medium text-foreground mt-0.5" style={{ fontFamily: "'DM Mono', monospace" }}>
                  {employer.govIdNumber}
                </p>
              </div>
            </div>
          </div>

          {/* Gov ID image */}
          <div className="mt-4">
            <p className="text-xs text-muted-foreground mb-2 flex items-center gap-1.5">
              <CreditCard className="w-3 h-3" /> Government ID Image
            </p>
            {employer.govIdImage ? (
              <img
                src={employer.govIdImage}
                alt="Government ID"
                className="w-full rounded-lg border border-border object-cover max-h-40"
              />
            ) : (
              <div className="w-full h-28 rounded-lg border border-dashed border-border bg-muted/40 flex flex-col items-center justify-center gap-2">
                <CreditCard className="w-6 h-6 text-muted-foreground/50" />
                <p className="text-xs text-muted-foreground">No ID image uploaded</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

export default function EmployersPanel({ search, filters, employers, setEmployers }: {
  search: string;
  filters?: ActiveFilters;
  employers: Employer[];
  setEmployers: React.Dispatch<React.SetStateAction<Employer[]>>;
}) {
  const [selected, setSelected] = useState<Employer | null>(null);

  const approve = (id: string) =>
    setEmployers((prev) => prev.map((e) => (e.id === id ? { ...e, status: "active" } : e)));

  const block = (id: string) =>
    setEmployers((prev) => prev.map((e) => (e.id === id ? { ...e, status: "inactive" } : e)));

  const remove = (id: string) => {
    setEmployers((prev) => prev.filter((e) => e.id !== id));
    if (selected?.id === id) setSelected(null);
  };

  const filtered = employers.filter((e) => {
    const q = search.toLowerCase();
    const matchSearch =
      e.name.toLowerCase().includes(q) ||
      e.industry.toLowerCase().includes(q) ||
      e.location.toLowerCase().includes(q);
    const matchStatus   = !filters?.status.length   || filters.status.includes(e.status);
    const matchIndustry = !filters?.industry.length || filters.industry.includes(e.industry);
    return matchSearch && matchStatus && matchIndustry;
  });

  return (
    <>
      {/* Profile modal */}
      {selected && (
        <ProfileModal
          employer={selected}
          onClose={() => setSelected(null)}
        />
      )}

      <div className="space-y-5">
        <div>
          <h2 className="text-sm font-semibold text-foreground">Employers</h2>
          <p className="text-xs text-muted-foreground mt-0.5">Registered employer accounts — click a row to view profile</p>
        </div>

        <div className="bg-card border border-border rounded-xl overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-border">
                  {["ID", "Company", "Industry", "Location", "Workers", "Status", "Action"].map((h) => (
                    <th
                      key={h}
                      className="px-4 py-3 text-left text-xs font-medium text-muted-foreground uppercase tracking-wider"
                    >
                      {h}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filtered.length === 0 ? (
                  <tr>
                    <td colSpan={7} className="px-4 py-8 text-center text-xs text-muted-foreground">
                      No employers found.
                    </td>
                  </tr>
                ) : (
                  filtered.map((employer) => (
                    <tr
                      key={employer.id}
                      className="border-b border-border last:border-0 hover:bg-muted/40 transition-colors cursor-pointer"
                      onClick={() => setSelected(employer)}
                    >
                      {/* ID */}
                      <td
                        className="px-4 py-3 text-xs text-muted-foreground"
                        style={{ fontFamily: "'DM Mono', monospace" }}
                      >
                        {employer.id}
                      </td>

                      {/* Company */}
                      <td className="px-4 py-3 text-xs font-medium text-foreground whitespace-nowrap">
                        <div className="flex items-center gap-2">
                          <div className="w-6 h-6 rounded bg-primary/10 flex items-center justify-center flex-shrink-0">
                            <Building2 className="w-3 h-3 text-primary" />
                          </div>
                          {employer.name}
                        </div>
                      </td>

                      {/* Industry */}
                      <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap">
                        {employer.industry}
                      </td>

                      {/* Location */}
                      <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap">
                        <span className="flex items-center gap-1">
                          <MapPin className="w-3 h-3" />
                          {employer.location}
                        </span>
                      </td>

                      {/* Workers */}
                      <td className="px-4 py-3 text-xs text-foreground whitespace-nowrap">
                        <span className="flex items-center gap-1">
                          <Users className="w-3 h-3 text-muted-foreground" />
                          {employer.workers}
                        </span>
                      </td>

                      {/* Status */}
                      <td className="px-4 py-3">
                        <span className={`text-xs px-2 py-0.5 rounded-full font-medium capitalize ${statusStyle[employer.status]}`}>
                          {employer.status}
                        </span>
                      </td>

                      {/* Action — stop propagation so dropdown doesn't open modal */}
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
                            <DropdownMenuItem
                              onClick={() => approve(employer.id)}
                              disabled={employer.status === "active"}
                              className="gap-2"
                            >
                              <CheckCircle className="w-3.5 h-3.5 text-emerald-400" />
                              Approve
                            </DropdownMenuItem>
                            <DropdownMenuItem
                              onClick={() => block(employer.id)}
                              disabled={employer.status === "inactive"}
                              className="gap-2"
                            >
                              <Ban className="w-3.5 h-3.5 text-amber-400" />
                              Block
                            </DropdownMenuItem>
                            <DropdownMenuSeparator />
                            <DropdownMenuItem
                              variant="destructive"
                              onClick={() => remove(employer.id)}
                              className="gap-2"
                            >
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
