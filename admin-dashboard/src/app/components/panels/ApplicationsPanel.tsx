import { MapPin, Clock, CheckCircle, XCircle } from "lucide-react";
import type { ActiveFilters } from "../App";
import type { Application } from "../../data";

const statusStyle: Record<string, string> = {
  hired:    "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20",
  pending:  "bg-amber-500/10  text-amber-400  border border-amber-500/20",
  rejected: "bg-rose-500/10   text-rose-400   border border-rose-500/20",
};

export default function ApplicationsPanel({ search, filters, appData, setAppData }: {
  search: string;
  filters?: ActiveFilters;
  appData: Application[];
  setAppData: React.Dispatch<React.SetStateAction<Application[]>>;
}) {
  const filtered = appData.filter((a) => {
    const q = search.toLowerCase();
    const matchSearch =
      a.worker.toLowerCase().includes(q) ||
      a.employer.toLowerCase().includes(q) ||
      a.skill.toLowerCase().includes(q);
    const matchStatus = !filters?.status.length || filters.status.includes(a.status);
    const matchSkill  = !filters?.skill.length  || filters.skill.includes(a.skill);
    return matchSearch && matchStatus && matchSkill;
  });

  const hire = (id: string) => {
    setAppData((prev) =>
      prev.map((a) => (a.id === id ? { ...a, status: "hired" as const } : a))
    );
  };

  const reject = (id: string) => {
    setAppData((prev) =>
      prev.map((a) => (a.id === id ? { ...a, status: "rejected" as const } : a))
    );
  };

  const pendingCount = appData.filter((a) => a.status === "pending").length;

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-sm font-semibold text-foreground">Applications</h2>
          <p className="text-xs text-muted-foreground mt-0.5">Track job applications and approvals</p>
        </div>
        {pendingCount > 0 && (
          <span className="text-xs bg-amber-500/10 text-amber-400 border border-amber-500/20 px-2 py-1 rounded-full font-medium">
            {pendingCount} pending
          </span>
        )}
      </div>

      <div className="bg-card border border-border rounded-xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border">
                {["ID", "Worker", "Skill", "Employer", "Location", "Status", "Date", "Actions"].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-medium text-muted-foreground uppercase tracking-wider">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr>
                  <td colSpan={8} className="px-4 py-8 text-center text-xs text-muted-foreground">
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
                    <td className="px-4 py-3">
                      {app.status === "pending" && (
                        <div className="flex items-center gap-1.5">
                          <button
                            onClick={() => hire(app.id)}
                            className="w-6 h-6 flex items-center justify-center rounded-md text-emerald-400 hover:bg-emerald-500/10 transition-colors"
                            title="Approve & hire"
                          >
                            <CheckCircle className="w-3.5 h-3.5" />
                          </button>
                          <button
                            onClick={() => reject(app.id)}
                            className="w-6 h-6 flex items-center justify-center rounded-md text-rose-400 hover:bg-rose-500/10 transition-colors"
                            title="Reject"
                          >
                            <XCircle className="w-3.5 h-3.5" />
                          </button>
                        </div>
                      )}
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
