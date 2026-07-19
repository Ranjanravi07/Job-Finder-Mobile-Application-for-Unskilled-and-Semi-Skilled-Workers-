import { useState } from "react";
import {
  MapPin, Star, MoreVertical, CheckCircle, Ban, Trash2,
  X, Phone, CreditCard, Briefcase, User,
} from "lucide-react";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "../../components/ui/dropdown-menu";

type Status = "pending" | "active" | "inactive";

interface Seeker {
  id: string;
  name: string;
  skill: string;
  location: string;
  rating: number;
  status: Status;
  // profile details
  phone: string;
  govIdNumber: string;
  govIdImage: string;   // URL or placeholder
  profilePhoto: string; // URL or placeholder
}

const initialSeekers: Seeker[] = [
  {
    id: "W-1042", name: "Ramon dela Cruz",  skill: "Construction",   location: "Manila",
    rating: 4.8, status: "pending",
    phone: "+63 912 345 6789", govIdNumber: "PSN-2024-00142",
    govIdImage: "", profilePhoto: "",
  },
  {
    id: "W-1041", name: "Maria Santos",     skill: "Domestic Help",  location: "Quezon City",
    rating: 4.6, status: "pending",
    phone: "+63 917 234 5678", govIdNumber: "PSN-2024-00187",
    govIdImage: "", profilePhoto: "",
  },
  {
    id: "W-1040", name: "Eduardo Bautista", skill: "Factory Work",   location: "Caloocan",
    rating: 4.9, status: "pending",
    phone: "+63 918 876 5432", govIdNumber: "PSN-2024-00203",
    govIdImage: "", profilePhoto: "",
  },
  {
    id: "W-1039", name: "Josefina Reyes",   skill: "Security Guard", location: "Makati",
    rating: 4.3, status: "pending",
    phone: "+63 919 111 2233", govIdNumber: "PSN-2024-00219",
    govIdImage: "", profilePhoto: "",
  },
  {
    id: "W-1038", name: "Benjamin Lim",     skill: "Delivery Rider", location: "Pasig",
    rating: 4.5, status: "pending",
    phone: "+63 920 444 5566", govIdNumber: "PSN-2024-00231",
    govIdImage: "", profilePhoto: "",
  },
  {
    id: "W-1037", name: "Lourdes Magno",    skill: "Domestic Help",  location: "Marikina",
    rating: 4.7, status: "pending",
    phone: "+63 921 667 8899", govIdNumber: "PSN-2024-00248",
    govIdImage: "", profilePhoto: "",
  },
  {
    id: "W-1036", name: "Arturo Villanueva",skill: "Construction",   location: "Taguig",
    rating: 4.2, status: "pending",
    phone: "+63 922 321 0987", govIdNumber: "PSN-2024-00261",
    govIdImage: "", profilePhoto: "",
  },
  {
    id: "W-1035", name: "Carina Ocampo",    skill: "Factory Work",   location: "Navotas",
    rating: 4.8, status: "pending",
    phone: "+63 923 555 7744", govIdNumber: "PSN-2024-00275",
    govIdImage: "", profilePhoto: "",
  },
];

const statusStyle: Record<Status, string> = {
  active:   "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20",
  pending:  "bg-amber-500/10  text-amber-400  border border-amber-500/20",
  inactive: "bg-slate-500/10  text-slate-400  border border-slate-500/20",
};

/** Initials avatar */
function Avatar({ name, size = "md" }: { name: string; size?: "sm" | "md" | "lg" }) {
  const initials = name.split(" ").map((n) => n[0]).join("").slice(0, 2).toUpperCase();
  const sizeClass = size === "lg" ? "w-16 h-16 text-lg" : size === "md" ? "w-10 h-10 text-sm" : "w-6 h-6 text-[10px]";
  return (
    <div className={`${sizeClass} rounded-full bg-primary/15 flex items-center justify-center font-bold text-primary flex-shrink-0`}>
      {initials}
    </div>
  );
}

/** Profile modal */
function ProfileModal({ seeker, onClose }: { seeker: Seeker; onClose: () => void }) {
  return (
    /* Backdrop */
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4"
      style={{ background: "rgba(0,0,0,0.6)", backdropFilter: "blur(4px)" }}
      onClick={onClose}
    >
      {/* Card — stop propagation so clicking inside doesn't close */}
      <div
        className="bg-card border border-border rounded-2xl w-full max-w-md shadow-2xl overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header band */}
        <div className="relative h-24 bg-gradient-to-br from-primary/30 to-primary/5">
          <button
            onClick={onClose}
            className="absolute top-3 right-3 w-7 h-7 flex items-center justify-center rounded-full bg-black/30 text-white hover:bg-black/50 transition-colors"
          >
            <X className="w-3.5 h-3.5" />
          </button>
        </div>

        {/* Avatar overlapping header */}
        <div className="px-6 pb-6">
          <div className="-mt-8 mb-4 flex items-end justify-between">
            <div className="w-16 h-16 rounded-full bg-primary/15 flex items-center justify-center font-bold text-primary text-xl ring-4 ring-card flex-shrink-0">
              {seeker.name.split(" ").map((n) => n[0]).join("").slice(0, 2).toUpperCase()}
            </div>
            <span className={`text-xs px-2.5 py-1 rounded-full font-medium capitalize ${statusStyle[seeker.status]}`}>
              {seeker.status}
            </span>
          </div>

          {/* Name + ID */}
          <h3 className="text-base font-semibold text-foreground">{seeker.name}</h3>
          <p className="text-xs text-muted-foreground mt-0.5" style={{ fontFamily: "'DM Mono', monospace" }}>{seeker.id}</p>

          {/* Rating */}
          <div className="flex items-center gap-1 mt-2">
            <Star className="w-3.5 h-3.5 text-amber-400 fill-amber-400" />
            <span className="text-xs font-medium text-foreground">{seeker.rating}</span>
            <span className="text-xs text-muted-foreground ml-1">rating</span>
          </div>

          <hr className="border-border my-4" />

          {/* Detail rows */}
          <div className="space-y-3">
            {/* Phone */}
            <div className="flex items-start gap-3">
              <div className="w-7 h-7 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
                <Phone className="w-3.5 h-3.5 text-muted-foreground" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Phone Number</p>
                <p className="text-sm font-medium text-foreground mt-0.5">{seeker.phone}</p>
              </div>
            </div>

            {/* Primary skill */}
            <div className="flex items-start gap-3">
              <div className="w-7 h-7 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
                <Briefcase className="w-3.5 h-3.5 text-muted-foreground" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Primary Skill / Role</p>
                <p className="text-sm font-medium text-foreground mt-0.5">{seeker.skill}</p>
              </div>
            </div>

            {/* Location */}
            <div className="flex items-start gap-3">
              <div className="w-7 h-7 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
                <MapPin className="w-3.5 h-3.5 text-muted-foreground" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Location</p>
                <p className="text-sm font-medium text-foreground mt-0.5">{seeker.location}</p>
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
                  {seeker.govIdNumber}
                </p>
              </div>
            </div>
          </div>

          {/* Gov ID image */}
          <div className="mt-4">
            <p className="text-xs text-muted-foreground mb-2 flex items-center gap-1.5">
              <CreditCard className="w-3 h-3" /> Government ID Image
            </p>
            {seeker.govIdImage ? (
              <img
                src={seeker.govIdImage}
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

export default function JobSeekersPanel({ search }: { search: string }) {
  const [seekers, setSeekers] = useState<Seeker[]>(initialSeekers);
  const [selected, setSelected] = useState<Seeker | null>(null);

  const approve = (id: string) =>
    setSeekers((prev) => prev.map((s) => (s.id === id ? { ...s, status: "active" } : s)));

  const block = (id: string) =>
    setSeekers((prev) => prev.map((s) => (s.id === id ? { ...s, status: "inactive" } : s)));

  const remove = (id: string) => {
    setSeekers((prev) => prev.filter((s) => s.id !== id));
    if (selected?.id === id) setSelected(null);
  };

  const filtered = seekers.filter(
    (s) =>
      s.name.toLowerCase().includes(search.toLowerCase()) ||
      s.skill.toLowerCase().includes(search.toLowerCase()) ||
      s.location.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <>
      {/* Profile modal */}
      {selected && (
        <ProfileModal
          seeker={selected}
          onClose={() => setSelected(null)}
        />
      )}

      <div className="space-y-5">
        <div>
          <h2 className="text-sm font-semibold text-foreground">Workers</h2>
          <p className="text-xs text-muted-foreground mt-0.5">Manage registered workers — click a row to view profile</p>
        </div>

        <div className="bg-card border border-border rounded-xl overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-border">
                  {["ID", "Name", "Skill", "Location", "Rating", "Status", "Action"].map((h) => (
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
                      No workers found.
                    </td>
                  </tr>
                ) : (
                  filtered.map((seeker) => (
                    <tr
                      key={seeker.id}
                      className="border-b border-border last:border-0 hover:bg-muted/40 transition-colors cursor-pointer"
                      onClick={() => setSelected(seeker)}
                    >
                      {/* ID */}
                      <td
                        className="px-4 py-3 text-xs text-muted-foreground"
                        style={{ fontFamily: "'DM Mono', monospace" }}
                      >
                        {seeker.id}
                      </td>

                      {/* Name */}
                      <td className="px-4 py-3 text-xs font-medium text-foreground whitespace-nowrap">
                        <div className="flex items-center gap-2">
                          <div className="w-6 h-6 rounded-full bg-primary/10 flex items-center justify-center text-[10px] font-bold text-primary flex-shrink-0">
                            {seeker.name.split(" ").map((n) => n[0]).join("").slice(0, 2)}
                          </div>
                          {seeker.name}
                        </div>
                      </td>

                      {/* Skill */}
                      <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap">
                        {seeker.skill}
                      </td>

                      {/* Location */}
                      <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap">
                        <span className="flex items-center gap-1">
                          <MapPin className="w-3 h-3" />
                          {seeker.location}
                        </span>
                      </td>

                      {/* Rating */}
                      <td className="px-4 py-3 text-xs text-foreground whitespace-nowrap">
                        <span className="flex items-center gap-1">
                          <Star className="w-3 h-3 text-amber-400 fill-amber-400" />
                          {seeker.rating}
                        </span>
                      </td>

                      {/* Status */}
                      <td className="px-4 py-3">
                        <span className={`text-xs px-2 py-0.5 rounded-full font-medium capitalize ${statusStyle[seeker.status]}`}>
                          {seeker.status}
                        </span>
                      </td>

                      {/* Action — stop row click propagation so dropdown doesn't open modal */}
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
                              onClick={() => approve(seeker.id)}
                              disabled={seeker.status === "active"}
                              className="gap-2"
                            >
                              <CheckCircle className="w-3.5 h-3.5 text-emerald-400" />
                              Approve
                            </DropdownMenuItem>
                            <DropdownMenuItem
                              onClick={() => block(seeker.id)}
                              disabled={seeker.status === "inactive"}
                              className="gap-2"
                            >
                              <Ban className="w-3.5 h-3.5 text-amber-400" />
                              Block
                            </DropdownMenuItem>
                            <DropdownMenuSeparator />
                            <DropdownMenuItem
                              variant="destructive"
                              onClick={() => remove(seeker.id)}
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
