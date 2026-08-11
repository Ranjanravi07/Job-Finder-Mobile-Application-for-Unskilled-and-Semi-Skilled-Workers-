import { useState } from "react";
import React from "react";
import {
  MapPin, MoreVertical, CheckCircle, Ban, Trash2,
  X, Phone, CreditCard, Briefcase, User, FileText, Check
} from "lucide-react";
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
import { type Seeker, type SeekerStatus as Status } from "../../data";
import { StorageImage } from "../../components/ui/StorageImage";
import { StorageDocumentLink } from "../../components/ui/StorageDocumentLink";

const statusStyle: Record<Status, string> = {
  active:   "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20",
  pending:  "bg-amber-500/10  text-amber-400  border border-amber-500/20",
  inactive: "bg-slate-500/10  text-slate-400  border border-slate-500/20",
};

/** Initials avatar fallback */
function Avatar({ name, photo, size = "md" }: { name: string; photo?: string; size?: "sm" | "md" | "lg" }) {
  if (photo && photo.trim().length > 0) {
    const sizeClass = size === "lg" ? "w-16 h-16" : size === "md" ? "w-10 h-10" : "w-6 h-6";
    return (
      <div className={`${sizeClass} rounded-full overflow-hidden flex-shrink-0 border border-border bg-muted`}>
        <StorageImage path={photo} alt={name} className="w-full h-full object-cover" />
      </div>
    );
  }
  const initials = name.split(" ").map((n) => n[0]).join("").slice(0, 2).toUpperCase();
  const sizeClass = size === "lg" ? "w-16 h-16 text-lg" : size === "md" ? "w-10 h-10 text-sm" : "w-6 h-6 text-[10px]";
  return (
    <div className={`${sizeClass} rounded-full bg-primary/15 flex items-center justify-center font-bold text-primary flex-shrink-0`}>
      {initials}
    </div>
  );
}

/** Profile modal displaying complete Worker details & all Government IDs */
function ProfileModal({ seeker, onClose }: { seeker: Seeker; onClose: () => void }) {
  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4"
      style={{ background: "rgba(0,0,0,0.6)", backdropFilter: "blur(4px)" }}
      onClick={onClose}
    >
      <div
        className="bg-card border border-border rounded-2xl w-full max-w-md shadow-2xl overflow-hidden max-h-[90vh] overflow-y-auto"
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
            <Avatar name={seeker.name} photo={seeker.profilePhoto} size="lg" />
            <span className={`text-xs px-2.5 py-1 rounded-full font-medium capitalize ${statusStyle[seeker.status]}`}>
              {seeker.status}
            </span>
          </div>

          {/* Name + ID */}
          <h3 className="text-base font-semibold text-foreground">{seeker.name}</h3>
          <p className="text-xs text-muted-foreground mt-0.5" style={{ fontFamily: "'DM Mono', monospace" }}>{seeker.id}</p>

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
                <p className="text-xs text-muted-foreground">Work Category / Skill</p>
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

            {/* Primary Gov ID number */}
            <div className="flex items-start gap-3">
              <div className="w-7 h-7 rounded-md bg-muted flex items-center justify-center flex-shrink-0">
                <CreditCard className="w-3.5 h-3.5 text-muted-foreground" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Primary Government ID ({seeker.govIdType || 'Citizenship'})</p>
                <p className="text-sm font-medium text-foreground mt-0.5" style={{ fontFamily: "'DM Mono', monospace" }}>
                  {seeker.govIdNumber || "N/A"}
                </p>
              </div>
            </div>
          </div>

          {/* Multi-Selection Government IDs Breakdown */}
          {seeker.governmentIds && Object.keys(seeker.governmentIds).length > 0 && (
            <div className="mt-4 border-t border-border pt-4 space-y-3">
              <p className="text-xs font-semibold text-foreground flex items-center gap-1.5">
                <FileText className="w-3.5 h-3.5 text-primary" /> Submitted Government IDs ({Object.keys(seeker.governmentIds).length})
              </p>
              <div className="space-y-2">
                {Object.entries(seeker.governmentIds).map(([typeKey, idObj]) => (
                  <div key={typeKey} className="bg-muted/40 border border-border rounded-lg p-2.5 text-xs">
                    <div className="flex items-center justify-between">
                      <span className="font-semibold text-foreground capitalize flex items-center gap-1">
                        <Check className="w-3 h-3 text-emerald-400" /> {typeKey}
                      </span>
                      <span className="font-mono text-muted-foreground">{idObj.idNumber}</span>
                    </div>
                    {idObj.documentFiles && idObj.documentFiles.length > 0 && (
                      <div className="grid grid-cols-2 gap-2 mt-2">
                        {idObj.documentFiles.map((docUrl, idx) => (
                          <StorageDocumentLink 
                            key={idx} 
                            path={docUrl} 
                            label={`${typeKey} doc ${idx + 1}`}
                            isImagePreview={true}
                          />
                        ))}
                      </div>
                    )}
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Gov ID image fallback if no governmentIds map */}
          {(!seeker.governmentIds || Object.keys(seeker.governmentIds).length === 0) && (
            <div className="mt-4">
              <p className="text-xs text-muted-foreground mb-2 flex items-center gap-1.5">
                <CreditCard className="w-3 h-3" /> Government ID Image
              </p>
              {seeker.govIdImage ? (
                <div className="w-full h-32 rounded-lg border border-border overflow-hidden bg-muted/40 relative">
                  <StorageImage
                    path={seeker.govIdImage}
                    alt="Government ID"
                    className="w-full h-full object-cover"
                  />
                  <div className="absolute inset-0 flex items-center justify-center opacity-0 hover:opacity-100 bg-black/40 transition-opacity">
                    <StorageDocumentLink path={seeker.govIdImage} label="View Full Image" className="text-white hover:text-primary-foreground" />
                  </div>
                </div>
              ) : (
                <div className="w-full h-28 rounded-lg border border-dashed border-border bg-muted/40 flex flex-col items-center justify-center gap-2">
                  <CreditCard className="w-6 h-6 text-muted-foreground/50" />
                  <p className="text-xs text-muted-foreground">No ID image uploaded</p>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default function JobSeekersPanel({ search, filters, seekers, setSeekers }: {
  search: string;
  filters?: ActiveFilters;
  seekers: Seeker[];
  setSeekers: React.Dispatch<React.SetStateAction<Seeker[]>>;
}) {
  const [selected, setSelected] = useState<Seeker | null>(null);

  const approve = async (id: string) => {
    if (db) {
      try {
        await updateDoc(doc(db, "workers", id), {
          verificationStatus: "verified",
        });
      } catch (err) {
        console.error("Failed to approve worker in Firestore:", err);
      }
    }
    setSeekers((prev) => prev.map((s) => (s.id === id ? { ...s, status: "active", verificationStatus: "verified" } : s)));
  };

  const block = async (id: string) => {
    if (db) {
      try {
        await updateDoc(doc(db, "workers", id), {
          verificationStatus: "inactive",
        });
      } catch (err) {
        console.error("Failed to block worker in Firestore:", err);
      }
    }
    setSeekers((prev) => prev.map((s) => (s.id === id ? { ...s, status: "inactive", verificationStatus: "inactive" } : s)));
  };

  const remove = async (id: string) => {
    if (db) {
      try {
        await deleteDoc(doc(db, "workers", id));
      } catch (err) {
        console.error("Failed to delete worker from Firestore:", err);
      }
    }
    setSeekers((prev) => prev.filter((s) => s.id !== id));
    if (selected?.id === id) setSelected(null);
  };

  const filtered = seekers.filter((s) => {
    const q = search.toLowerCase();
    const matchSearch =
      s.name.toLowerCase().includes(q) ||
      s.skill.toLowerCase().includes(q) ||
      s.location.toLowerCase().includes(q);

    const matchStatus  = !filters?.status.length   || filters.status.includes(s.status);
    const matchSkill   = !filters?.skill.length    || filters.skill.includes(s.skill);

    return matchSearch && matchStatus && matchSkill;
  });

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
          <h2 className="text-sm font-semibold text-foreground">Jobseekers (Workers)</h2>
          <p className="text-xs text-muted-foreground mt-0.5">Manage registered worker accounts — click a row to view profile</p>
        </div>

        <div className="bg-card border border-border rounded-xl overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-border">
                  {["ID", "Name", "Skill", "Location", "Status", "Action"].map((h) => (
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
                    <td colSpan={6} className="px-4 py-8 text-center text-xs text-muted-foreground">
                      No jobseekers registered yet.
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
                          <Avatar name={seeker.name} photo={seeker.profilePhoto} size="sm" />
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
