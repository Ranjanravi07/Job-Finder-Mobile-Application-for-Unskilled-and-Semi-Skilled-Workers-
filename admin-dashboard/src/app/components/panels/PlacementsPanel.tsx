import { CheckCircle, MapPin, Clock } from "lucide-react";

const placements = [
  { id: "PL-501", worker: "Ramon dela Cruz", employer: "SunBuild Corp.", role: "Construction Helper", location: "Manila", date: "Dec 28, 2024", salary: "₱450/day" },
  { id: "PL-500", worker: "Eduardo Bautista", employer: "FiliTex Mills", role: "Factory Sorter", location: "Caloocan", date: "Dec 27, 2024", salary: "₱420/day" },
  { id: "PL-499", worker: "Benjamin Lim", employer: "QuickShip PH", role: "Delivery Rider", location: "Pasig", date: "Dec 26, 2024", salary: "₱500/day" },
  { id: "PL-498", worker: "Arturo Villanueva", employer: "MetroBuild Inc.", role: "Construction Helper", location: "Taguig", date: "Dec 25, 2024", salary: "₱550/day" },
  { id: "PL-497", worker: "Maria Santos", employer: "Reyes Household", role: "Domestic Helper", location: "Quezon City", date: "Dec 24, 2024", salary: "₱8,000/mo" },
];

export default function PlacementsPanel({ search }: { search: string }) {
  const filtered = placements.filter((p) =>
    p.worker.toLowerCase().includes(search.toLowerCase()) ||
    p.employer.toLowerCase().includes(search.toLowerCase()) ||
    p.role.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-5">
      <div>
        <h2 className="text-sm font-semibold text-foreground">Placements</h2>
        <p className="text-xs text-muted-foreground mt-0.5">Successful job placements history</p>
      </div>

      <div className="bg-card border border-border rounded-xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border">
                {["ID", "Worker", "Employer", "Role", "Location", "Salary", "Date"].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-medium text-muted-foreground uppercase tracking-wider">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.map((pl) => (
                <tr key={pl.id} className="border-b border-border last:border-0 hover:bg-muted/40 transition-colors">
                  <td className="px-4 py-3 text-xs text-muted-foreground" style={{ fontFamily: "'DM Mono', monospace" }}>{pl.id}</td>
                  <td className="px-4 py-3 text-xs font-medium text-foreground whitespace-nowrap flex items-center gap-2">
                    <div className="w-6 h-6 rounded-full bg-emerald-500/10 flex items-center justify-center text-[10px] font-bold text-emerald-400 flex-shrink-0">
                      <CheckCircle className="w-3 h-3" />
                    </div>
                    {pl.worker}
                  </td>
                  <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap">{pl.employer}</td>
                  <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap">{pl.role}</td>
                  <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap flex items-center gap-1">
                    <MapPin className="w-2.5 h-2.5" />
                    {pl.location}
                  </td>
                  <td className="px-4 py-3 text-xs text-foreground whitespace-nowrap">{pl.salary}</td>
                  <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap flex items-center gap-1" style={{ fontFamily: "'DM Mono', monospace" }}>
                    <Clock className="w-2.5 h-2.5" />
                    {pl.date}
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
