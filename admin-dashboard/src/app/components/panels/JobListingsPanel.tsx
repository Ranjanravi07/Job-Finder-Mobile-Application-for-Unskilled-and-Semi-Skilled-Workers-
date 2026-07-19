import { Briefcase, MapPin, Clock } from "lucide-react";

const jobs = [
  { id: "J-301", title: "Construction Helper", employer: "SunBuild Corp.", location: "Manila", salary: "₱450/day", type: "Daily", posted: "Dec 28", applicants: 24, status: "open" },
  { id: "J-302", title: "Domestic Helper", employer: "Reyes Household", location: "Quezon City", salary: "₱8,000/mo", type: "Monthly", posted: "Dec 27", applicants: 12, status: "open" },
  { id: "J-303", title: "Factory Sorter", employer: "FiliTex Mills", location: "Caloocan", salary: "₱420/day", type: "Daily", posted: "Dec 26", applicants: 56, status: "open" },
  { id: "J-304", title: "Security Guard", employer: "Shield Pro Security", location: "Makati", salary: "₱15,000/mo", type: "Monthly", posted: "Dec 25", applicants: 38, status: "closed" },
  { id: "J-305", title: "Delivery Rider", employer: "QuickShip PH", location: "Pasig", salary: "₱500/day", type: "Daily", posted: "Dec 24", applicants: 19, status: "open" },
  { id: "J-306", title: "Welder", employer: "MetroBuild Inc.", location: "Taguig", salary: "₱550/day", type: "Daily", posted: "Dec 23", applicants: 8, status: "paused" },
];

const statusStyle: Record<string, string> = {
  open: "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20",
  closed: "bg-rose-500/10 text-rose-400 border border-rose-500/20",
  paused: "bg-amber-500/10 text-amber-400 border border-amber-500/20",
};

export default function JobListingsPanel({ search }: { search: string }) {
  const filtered = jobs.filter((j) =>
    j.title.toLowerCase().includes(search.toLowerCase()) ||
    j.employer.toLowerCase().includes(search.toLowerCase()) ||
    j.location.toLowerCase().includes(search.toLowerCase())
  );

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
                {["ID", "Title", "Employer", "Location", "Salary", "Type", "Applicants", "Status"].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-medium text-muted-foreground uppercase tracking-wider">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.map((job) => (
                <tr key={job.id} className="border-b border-border last:border-0 hover:bg-muted/40 transition-colors">
                  <td className="px-4 py-3 text-xs text-muted-foreground" style={{ fontFamily: "'DM Mono', monospace" }}>{job.id}</td>
                  <td className="px-4 py-3 text-xs font-medium text-foreground whitespace-nowrap flex items-center gap-2">
                    <div className="w-6 h-6 rounded bg-primary/10 flex items-center justify-center text-[10px] font-bold text-primary flex-shrink-0">
                      <Briefcase className="w-3 h-3" />
                    </div>
                    {job.title}
                  </td>
                  <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap">{job.employer}</td>
                  <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap flex items-center gap-1">
                    <MapPin className="w-3 h-3" />
                    {job.location}
                  </td>
                  <td className="px-4 py-3 text-xs text-foreground whitespace-nowrap">{job.salary}</td>
                  <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap">{job.type}</td>
                  <td className="px-4 py-3 text-xs text-foreground whitespace-nowrap">{job.applicants}</td>
                  <td className="px-4 py-3">
                    <span className={`text-xs px-2 py-0.5 rounded-full font-medium capitalize ${statusStyle[job.status]}`}>{job.status}</span>
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
