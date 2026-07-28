import { MapPin, Clock } from "lucide-react";
import type { ActiveFilters } from "../App";
import { applications } from "../../data";

const statusStyle: Record<string, string> = {
  hired:    "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20",
  pending:  "bg-amber-500/10  text-amber-400  border border-amber-500/20",
  rejected: "bg-rose-500/10   text-rose-400   border border-rose-500/20",
};

export default function ApplicationsPanel({ search, filters }: { search: string; filters?: ActiveFilters }) {
  const filtered = applications.filter((a) => {
    const q = search.toLowerCase();
    const matchSearch =
      a.worker.toLowerCase().includes(q) ||
      a.employer.toLowerCase().includes(q) ||
      a.skill.toLowerCase().includes(q);
    const matchStatus = !filters?.status.length || filters.status.includes(a.status);
    const matchSkill  = !filters?.skill.length  || filters.skill.includes(a.skill);
    return matchSearch && matchStatus && matchSkill;
  });

  return (
    <div className="space-y-5">
      <div>
        <h2 className="text-sm font-semibold text-foreground">Applications</h2>
        <p className="text-xs text-muted-foreground mt-0.5">Track job applications and approvals</p>
      </div>

      <div className="bg-card border border-border rounded-xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border">
                {["ID", "Worker", "Skill", "Employer", "Location", "Status", "Date"].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-medium text-muted-foreground uppercase tracking-wider">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-4 py-8 text-center text-xs text-muted-foreground">
                    No applications match the current filters.
                  </td>
                </tr>
              ) : (
                filtered.map((app) => (
                  <tr key={app.id} className="border-b border-border last:border-0 hover:bg-muted/40 transition-colors">
                    <td className="px-4 py-3 text-xs text-muted-foreground" style={{ fontFamily: "'DM Mono', monospace" }}>{app.id}</td>
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
                      <span className={`text-xs px-2 py-0.5 rounded-full font-medium capitalize ${statusStyle[app.status]}`}>{app.status}</span>
                    </td>
                    <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap" style={{ fontFamily: "'DM Mono', monospace" }}>
                      <span className="flex items-center gap-1">
                        <Clock className="w-2.5 h-2.5" />
                        {app.date}
                      </span>
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
