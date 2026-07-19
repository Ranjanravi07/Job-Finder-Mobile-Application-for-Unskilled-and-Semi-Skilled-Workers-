import { ArrowUpRight, ArrowDownRight, Users, Briefcase, CheckCircle, Activity } from "lucide-react";

const monthlyStats = [
  { month: "Jan", workers: 120, employers: 18, placements: 58 },
  { month: "Feb", workers: 185, employers: 24, placements: 72 },
  { month: "Mar", workers: 240, employers: 31, placements: 94 },
  { month: "Apr", workers: 198, employers: 27, placements: 86 },
  { month: "May", workers: 310, employers: 42, placements: 118 },
  { month: "Jun", workers: 278, employers: 38, placements: 104 },
  { month: "Jul", workers: 390, employers: 55, placements: 139 },
  { month: "Aug", workers: 425, employers: 61, placements: 152 },
  { month: "Sep", workers: 512, employers: 74, placements: 178 },
  { month: "Oct", workers: 480, employers: 68, placements: 165 },
  { month: "Nov", workers: 560, employers: 82, placements: 201 },
  { month: "Dec", workers: 634, employers: 91, placements: 224 },
];

const summary = [
  { label: "Total Workers", value: "4,218", change: "+12.4%", up: true, icon: Users, color: "text-violet-400" },
  { label: "Total Employers", value: "312", change: "+8.7%", up: true, icon: Briefcase, color: "text-sky-400" },
  { label: "Total Placements", value: "1,591", change: "+16.2%", up: true, icon: CheckCircle, color: "text-emerald-400" },
  { label: "Active Jobs", value: "89", change: "-4.3%", up: false, icon: Activity, color: "text-amber-400" },
];

export default function ReportsPanel({ search }: { search: string }) {
  return (
    <div className="space-y-5">
      <div>
        <h2 className="text-sm font-semibold text-foreground">Reports</h2>
        <p className="text-xs text-muted-foreground mt-0.5">Analytics and performance insights</p>
      </div>

      <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
        {summary.map((card) => {
          const Icon = card.icon;
          return (
            <div
              key={card.label}
              className="bg-card border border-border rounded-xl p-5 flex flex-col gap-3 hover:border-primary/30 transition-colors"
            >
              <div className="flex items-center justify-between">
                <span className="text-xs text-muted-foreground font-medium uppercase tracking-wider">{card.label}</span>
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
                  <span className="text-xs text-muted-foreground">vs last month</span>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      <div className="bg-card border border-border rounded-xl p-5">
        <h3 className="text-sm font-semibold text-foreground mb-4">Monthly Performance</h3>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-border">
                {["Month", "New Workers", "New Employers", "Placements"].map((h) => (
                  <th key={h} className="px-4 py-3 text-left text-xs font-medium text-muted-foreground uppercase tracking-wider">{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {monthlyStats.map((row) => (
                <tr key={row.month} className="border-b border-border last:border-0 hover:bg-muted/40 transition-colors">
                  <td className="px-4 py-3 text-xs font-medium text-foreground">{row.month}</td>
                  <td className="px-4 py-3 text-xs text-muted-foreground">{row.workers.toLocaleString()}</td>
                  <td className="px-4 py-3 text-xs text-muted-foreground">{row.employers.toLocaleString()}</td>
                  <td className="px-4 py-3 text-xs text-muted-foreground">{row.placements.toLocaleString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
