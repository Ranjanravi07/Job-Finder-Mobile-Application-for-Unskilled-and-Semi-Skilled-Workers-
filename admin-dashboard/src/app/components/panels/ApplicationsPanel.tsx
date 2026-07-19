import { FileText, MapPin, Clock } from "lucide-react";

const applications = [
  { id: "APP-1042", worker: "Ramon dela Cruz", skill: "Construction", employer: "SunBuild Corp.", location: "Manila", status: "hired", date: "Dec 28, 2024" },
  { id: "APP-1041", worker: "Maria Santos", skill: "Domestic Help", employer: "Reyes Household", location: "Quezon City", status: "pending", date: "Dec 28, 2024" },
  { id: "APP-1040", worker: "Eduardo Bautista", skill: "Factory Work", employer: "FiliTex Mills", location: "Caloocan", status: "hired", date: "Dec 27, 2024" },
  { id: "APP-1039", worker: "Josefina Reyes", skill: "Security Guard", employer: "Shield Pro Security", location: "Makati", status: "rejected", date: "Dec 27, 2024" },
  { id: "APP-1038", worker: "Benjamin Lim", skill: "Delivery Rider", employer: "QuickShip PH", location: "Pasig", status: "hired", date: "Dec 26, 2024" },
  { id: "APP-1037", worker: "Lourdes Magno", skill: "Domestic Help", employer: "Cruz Family", location: "Marikina", status: "pending", date: "Dec 26, 2024" },
  { id: "APP-1036", worker: "Arturo Villanueva", skill: "Construction", employer: "MetroBuild Inc.", location: "Taguig", status: "hired", date: "Dec 25, 2024" },
];

const statusStyle: Record<string, string> = {
  hired: "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20",
  pending: "bg-amber-500/10 text-amber-400 border border-amber-500/20",
  rejected: "bg-rose-500/10 text-rose-400 border border-rose-500/20",
};

export default function ApplicationsPanel({ search }: { search: string }) {
  const filtered = applications.filter((a) =>
    a.worker.toLowerCase().includes(search.toLowerCase()) ||
    a.employer.toLowerCase().includes(search.toLowerCase()) ||
    a.skill.toLowerCase().includes(search.toLowerCase())
  );

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
              {filtered.map((app) => (
                <tr key={app.id} className="border-b border-border last:border-0 hover:bg-muted/40 transition-colors">
                  <td className="px-4 py-3 text-xs text-muted-foreground" style={{ fontFamily: "'DM Mono', monospace" }}>{app.id}</td>
                  <td className="px-4 py-3 text-xs font-medium text-foreground whitespace-nowrap">{app.worker}</td>
                  <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap">{app.skill}</td>
                  <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap">{app.employer}</td>
                  <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap flex items-center gap-1">
                    <MapPin className="w-2.5 h-2.5" />
                    {app.location}
                  </td>
                  <td className="px-4 py-3">
                    <span className={`text-xs px-2 py-0.5 rounded-full font-medium capitalize ${statusStyle[app.status]}`}>{app.status}</span>
                  </td>
                  <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap flex items-center gap-1" style={{ fontFamily: "'DM Mono', monospace" }}>
                    <Clock className="w-2.5 h-2.5" />
                    {app.date}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
