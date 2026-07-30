import { useState, useEffect } from "react";
import { Users, Plus, Trash2, Eye, EyeOff, Loader2, RefreshCw } from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogClose,
} from "../../components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "../../components/ui/select";
import {
  createUserWithEmailAndPassword,
  sendPasswordResetEmail,
  deleteUser as firebaseDeleteUser,
} from "firebase/auth";
import { auth } from "../../../firebase";
import {
  collection,
  doc,
  setDoc,
  updateDoc,
  deleteDoc,
  onSnapshot,
  serverTimestamp,
  query,
  orderBy,
} from "firebase/firestore";
import { db, isFirebaseConfigured } from "../../../firebase";

// ─── Types ─────────────────────────────────────────────────────────────────────
interface Account {
  uid: string;       // Firestore doc ID = Firebase Auth UID
  name: string;
  email: string;
  role: string;
  status: string;
  lastLogin: string;
}

const roleOptions   = ["Super Admin", "Manager", "Staff", "Editor", "Viewer"];
const statusOptions = ["active", "inactive"];

const roleStyle: Record<string, string> = {
  "Super Admin": "bg-violet-500/10 text-violet-400 border border-violet-500/20",
  Manager:       "bg-sky-500/10 text-sky-400 border border-sky-500/20",
  Staff:         "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20",
  Editor:        "bg-amber-500/10 text-amber-400 border border-amber-500/20",
  Viewer:        "bg-slate-500/10 text-slate-400 border border-slate-500/20",
};

// ─── Component ─────────────────────────────────────────────────────────────────
export default function UserAccountsPanel({
  search,
  adminProfile,
  onProfileChange,
}: {
  search: string;
  adminProfile?: { username: string; email: string };
  onProfileChange?: (username: string, email: string) => void;
}) {
  const [accounts,  setAccounts]  = useState<Account[]>([]);
  const [loading,   setLoading]   = useState(true);
  const [fetchErr,  setFetchErr]  = useState<string | null>(null);

  // ── Add dialog ──
  const [open,         setOpen]        = useState(false);
  const [name,         setName]        = useState("");
  const [email,        setEmail]       = useState("");
  const [role,         setRole]        = useState("Staff");
  const [status,       setStatus]      = useState("active");
  const [password,     setPassword]    = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [addErr,       setAddErr]      = useState("");
  const [adding,       setAdding]      = useState(false);
  const [nameTouched,  setNameTouched] = useState(false);

  // ── Edit dialog ──
  const [selectedUser,     setSelectedUser]     = useState<Account | null>(null);
  const [editName,         setEditName]         = useState("");
  const [editEmail,        setEditEmail]        = useState("");
  const [editStatus,       setEditStatus]       = useState("active");
  const [editRole,         setEditRole]         = useState("Staff");
  const [editPassword,     setEditPassword]     = useState("");
  const [showEditPassword, setShowEditPassword] = useState(false);
  const [saving,           setSaving]           = useState(false);

  const firebaseReady = isFirebaseConfigured && auth && db;

  // ── Real-time listener from Firestore ──────────────────────────────────────
  useEffect(() => {
    console.log("UserAccountsPanel: useEffect fired", { firebaseReady, db: !!db });
    if (!firebaseReady || !db) {
      console.log("UserAccountsPanel: Firebase not ready, setting loading false");
      setLoading(false);
      return;
    }

    setLoading(true);
    setFetchErr(null);

    console.log("UserAccountsPanel: Setting up Firestore listener for users collection");
    const q = query(collection(db, "users"), orderBy("name"));
    const unsub = onSnapshot(
      q,
      (snap) => {
        console.log("UserAccountsPanel: Firestore snapshot received, docs:", snap.docs.length);
        const data: Account[] = snap.docs.map((d) => {
          const raw = d.data();
          return {
            uid:       d.id,
            name:      raw.name      ?? "Unknown",
            email:     raw.email     ?? "",
            role:      raw.role      ?? "Staff",
            status:    raw.status    ?? "active",
            lastLogin: raw.lastLogin ?? "Never",
          };
        });
        console.log("UserAccountsPanel: Setting accounts:", data);
        setAccounts(data);
        setLoading(false);
      },
      (err: any) => {
        console.error("UserAccountsPanel: Firestore error:", err);
        if (err?.code === "unavailable") {
          setFetchErr("Firestore is unavailable. Please enable Firestore Database in your Firebase Console at: https://console.firebase.google.com/project/admin-dashboard-of-job-finder/firestore");
        } else {
          setFetchErr(err.message);
        }
        setLoading(false);
      }
    );

    return unsub; // cleanup on unmount
  }, [firebaseReady, db]);

  // ── Filtered list for search ───────────────────────────────────────────────
  const filtered = accounts.filter((a) =>
    a.name.toLowerCase().includes(search.toLowerCase())  ||
    a.email.toLowerCase().includes(search.toLowerCase()) ||
    a.role.toLowerCase().includes(search.toLowerCase())
  );

  // ── Reset add form ─────────────────────────────────────────────────────────
  const resetForm = () => {
    setName(""); setEmail(""); setRole("Staff"); setStatus("active");
    setPassword(""); setShowPassword(false); setAddErr(""); setNameTouched(false);
  };

  // ── Add user ───────────────────────────────────────────────────────────────
  const handleAdd = async () => {
    setAddErr("");
    if (!name.trim() || !email.trim() || !password.trim()) {
      setAddErr("Please fill in all fields.");
      return;
    }
    if (!firebaseReady) { setAddErr("Firebase is not configured."); return; }

    setAdding(true);
    try {
      const cred = await createUserWithEmailAndPassword(auth!, email.trim(), password);

      // Write to Firestore before closing dialog to ensure data persistence
      await setDoc(doc(db!, "users", cred.user.uid), {
        name:      name.trim(),
        email:     email.trim(),
        role,
        status,
        lastLogin: "Never",
        createdAt: serverTimestamp(),
      });

      // Close dialog after successful write
      resetForm();
      setOpen(false);
      setAdding(false);

    } catch (err: any) {
      const code: string = err?.code ?? "";
      if (code === "auth/email-already-in-use") setAddErr("Email is already in use.");
      else if (code === "auth/weak-password")    setAddErr("Password must be at least 6 characters.");
      else setAddErr(err?.message ?? "Failed to create user.");
      setAdding(false);
    }
  };

  // ── Open edit dialog ───────────────────────────────────────────────────────
  const openEdit = (user: Account) => {
    setSelectedUser(user);
    setEditName(user.name);
    setEditEmail(user.email);
    setEditStatus(user.status);
    setEditRole(user.role);
    setEditPassword("");
    setShowEditPassword(false);
  };

  // ── Save changes ───────────────────────────────────────────────────────────
  const handleSaveChanges = async () => {
    if (!selectedUser || !firebaseReady) return;
    setSaving(true);
    try {
      await updateDoc(doc(db!, "users", selectedUser.uid), {
        name:   editName,
        email:  editEmail,
        status: editStatus,
        role:   editRole,
      });
      if (editPassword.trim()) {
        await sendPasswordResetEmail(auth!, selectedUser.email);
      }
      // If editing the currently logged-in user, propagate to sidebar/header
      if (auth?.currentUser?.uid === selectedUser.uid && onProfileChange) {
        onProfileChange(editName, editEmail);
      }
    } catch (err) {
      console.error("Failed to update user:", err);
    } finally {
      setSaving(false);
      setSelectedUser(null);
      setEditPassword("");
    }
  };

  // ── Delete user ────────────────────────────────────────────────────────────
  const handleDelete = async () => {
    if (!selectedUser || !firebaseReady) return;
    try {
      await deleteDoc(doc(db!, "users", selectedUser.uid));
      // Firestore onSnapshot will remove it from the list automatically
    } catch (err) {
      console.error("Failed to delete user:", err);
    } finally {
      setSelectedUser(null);
    }
  };

  // ── Render ─────────────────────────────────────────────────────────────────
  return (
    <div className="space-y-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-sm font-semibold text-foreground">User Accounts</h2>
          <p className="text-xs text-muted-foreground mt-0.5">Manage admin and staff access</p>
        </div>
        <button
          onClick={() => { resetForm(); setOpen(true); }}
          className="flex items-center gap-1.5 text-xs bg-primary text-white px-3 py-1.5 rounded-md hover:bg-primary/90 transition-colors"
        >
          <Plus className="w-3 h-3" />
          Add User
        </button>
      </div>

      {/* Firebase warning */}
      {!firebaseReady && (
        <p className="text-xs text-amber-400 bg-amber-500/10 rounded-md px-3 py-2">
          Firebase is not configured. Configure VITE_FIREBASE_* env vars to enable cloud sync.
        </p>
      )}

      {/* Fetch error */}
      {fetchErr && (
        <p className="text-xs text-rose-400 bg-rose-500/10 rounded-md px-3 py-2">
          Failed to load users: {fetchErr}
        </p>
      )}

      {/* ── Add User Dialog ── */}
      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Add User</DialogTitle>
            <DialogDescription>Create a new admin or staff account.</DialogDescription>
          </DialogHeader>
          {addErr && (
            <p className="text-xs text-rose-400 bg-rose-500/10 rounded-md px-3 py-2">{addErr}</p>
          )}
          <div className="space-y-4">
            <div>
              <label className="text-xs font-medium text-foreground block mb-1.5">Full Name</label>
              <input type="text" value={name} onChange={(e) => { setName(e.target.value); setNameTouched(true); }}
                className="w-full px-3 py-2 rounded-md bg-muted border border-border text-foreground text-sm outline-none focus:border-primary transition-colors"
                placeholder="e.g. Juan Admin" />
            </div>
            <div>
              <label className="text-xs font-medium text-foreground block mb-1.5">Email</label>
              <input type="email" value={email} onChange={(e) => {
                const val = e.target.value;
                setEmail(val);
                if (!nameTouched) {
                  const localPart = val.split("@")[0];
                  setName(localPart || "");
                }
              }}
                className="w-full px-3 py-2 rounded-md bg-muted border border-border text-foreground text-sm outline-none focus:border-primary transition-colors"
                placeholder="e.g. juan@jobfinder.ph" />
            </div>
            <div>
              <label className="text-xs font-medium text-foreground block mb-1.5">Role</label>
              <Select value={role} onValueChange={setRole}>
                <SelectTrigger className="w-full"><SelectValue placeholder="Select role" /></SelectTrigger>
                <SelectContent>{roleOptions.map((r) => <SelectItem key={r} value={r}>{r}</SelectItem>)}</SelectContent>
              </Select>
            </div>
            <div>
              <label className="text-xs font-medium text-foreground block mb-1.5">Status</label>
              <Select value={status} onValueChange={setStatus}>
                <SelectTrigger className="w-full"><SelectValue placeholder="Select status" /></SelectTrigger>
                <SelectContent>{statusOptions.map((s) => <SelectItem key={s} value={s}>{s}</SelectItem>)}</SelectContent>
              </Select>
            </div>
            <div>
              <label className="text-xs font-medium text-foreground block mb-1.5">Password</label>
              <div className="relative">
                <input type={showPassword ? "text" : "password"} value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full px-3 py-2 rounded-md bg-muted border border-border text-foreground text-sm outline-none focus:border-primary transition-colors pr-9"
                  placeholder="Set initial password" />
                <button type="button" onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-2 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground">
                  {showPassword ? <EyeOff className="w-3.5 h-3.5" /> : <Eye className="w-3.5 h-3.5" />}
                </button>
              </div>
            </div>
          </div>
          <DialogFooter>
            <DialogClose asChild>
              <button className="px-4 py-2 rounded-md text-xs border border-border hover:bg-muted transition-colors">Cancel</button>
            </DialogClose>
            <button onClick={handleAdd} disabled={adding}
              className="px-4 py-2 rounded-md text-xs bg-primary text-white hover:bg-primary/90 transition-colors flex items-center gap-1.5 disabled:opacity-60">
              {adding && <Loader2 className="w-3 h-3 animate-spin" />}
              Add User
            </button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* ── Edit / Manage User Dialog ── */}
      <Dialog open={!!selectedUser} onOpenChange={(val) => !val && setSelectedUser(null)}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Manage User</DialogTitle>
            <DialogDescription>
              {selectedUser ? `Editing profile for ${selectedUser.name}` : ""}
            </DialogDescription>
          </DialogHeader>
          {selectedUser && (
            <div className="space-y-4">
              <div>
                <label className="text-xs font-medium text-foreground block mb-1.5">Full Name</label>
                <input type="text" value={editName} onChange={(e) => setEditName(e.target.value)}
                  className="w-full px-3 py-2 rounded-md bg-muted border border-border text-foreground text-sm outline-none focus:border-primary transition-colors" />
              </div>
              <div>
                <label className="text-xs font-medium text-foreground block mb-1.5">Email</label>
                <input type="email" value={editEmail} onChange={(e) => setEditEmail(e.target.value)}
                  className="w-full px-3 py-2 rounded-md bg-muted border border-border text-foreground text-sm outline-none focus:border-primary transition-colors" />
              </div>
              <div>
                <label className="text-xs font-medium text-muted-foreground block mb-1">Last Login</label>
                <p className="text-sm text-foreground">{selectedUser.lastLogin}</p>
              </div>
              <div>
                <label className="text-xs font-medium text-foreground block mb-1.5">Role</label>
                <Select value={editRole} onValueChange={setEditRole}>
                  <SelectTrigger className="w-full"><SelectValue placeholder="Select role" /></SelectTrigger>
                  <SelectContent>{roleOptions.map((r) => <SelectItem key={r} value={r}>{r}</SelectItem>)}</SelectContent>
                </Select>
              </div>
              <div>
                <label className="text-xs font-medium text-foreground block mb-1.5">Status</label>
                <Select value={editStatus} onValueChange={setEditStatus}>
                  <SelectTrigger className="w-full"><SelectValue placeholder="Select status" /></SelectTrigger>
                  <SelectContent>{statusOptions.map((s) => <SelectItem key={s} value={s}>{s}</SelectItem>)}</SelectContent>
                </Select>
              </div>
              <div>
                <label className="text-xs font-medium text-foreground block mb-1.5">Reset Password</label>
                <div className="relative">
                  <input type={showEditPassword ? "text" : "password"} value={editPassword}
                    onChange={(e) => setEditPassword(e.target.value)}
                    className="w-full px-3 py-2 rounded-md bg-muted border border-border text-foreground text-sm outline-none focus:border-primary transition-colors pr-9"
                    placeholder="Leave blank to keep current" />
                  <button type="button" onClick={() => setShowEditPassword(!showEditPassword)}
                    className="absolute right-2 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground">
                    {showEditPassword ? <EyeOff className="w-3.5 h-3.5" /> : <Eye className="w-3.5 h-3.5" />}
                  </button>
                </div>
                <p className="text-[10px] text-muted-foreground mt-1">A password reset email will be sent if a new password is entered.</p>
              </div>
            </div>
          )}
          <DialogFooter>
            <button onClick={handleDelete}
              className="px-4 py-2 rounded-md text-xs border border-rose-500/40 text-rose-400 hover:bg-rose-500/10 transition-colors flex items-center gap-1.5">
              <Trash2 className="w-3.5 h-3.5" /> Delete User
            </button>
            <DialogClose asChild>
              <button className="px-4 py-2 rounded-md text-xs border border-border hover:bg-muted transition-colors">Cancel</button>
            </DialogClose>
            <button onClick={handleSaveChanges} disabled={saving}
              className="px-4 py-2 rounded-md text-xs bg-primary text-white hover:bg-primary/90 transition-colors flex items-center gap-1.5 disabled:opacity-60">
              {saving && <Loader2 className="w-3 h-3 animate-spin" />}
              Save Changes
            </button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* ── Table ── */}
      <div className="bg-card border border-border rounded-xl overflow-hidden">
        {loading ? (
          <div className="flex items-center justify-center gap-2 py-12 text-muted-foreground text-xs">
            <Loader2 className="w-4 h-4 animate-spin" />
            Loading users from database…
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-border">
                  {["Name", "Email", "Role", "Status", "Last Login"].map((h) => (
                    <th key={h} className="px-4 py-3 text-left text-xs font-medium text-muted-foreground uppercase tracking-wider">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filtered.length === 0 ? (
                  <tr>
                    <td colSpan={5} className="px-4 py-8 text-center text-xs text-muted-foreground">
                      {accounts.length === 0 ? "No users found in database." : "No users match your search."}
                    </td>
                  </tr>
                ) : (
                  filtered.map((user) => (
                    <tr key={user.uid} onClick={() => openEdit(user)}
                      className="border-b border-border last:border-0 hover:bg-muted/40 transition-colors cursor-pointer">
                      <td className="px-4 py-3 text-xs font-medium text-foreground whitespace-nowrap">
                        <div className="flex items-center gap-2">
                          <div className="w-6 h-6 rounded-full bg-primary/10 flex items-center justify-center text-[10px] font-bold text-primary flex-shrink-0">
                            {user.name.split(" ").map((n) => n[0]).join("").slice(0, 2).toUpperCase()}
                          </div>
                          {user.name}
                          {auth?.currentUser?.uid === user.uid && (
                            <span className="text-[10px] bg-primary/10 text-primary px-1.5 py-0.5 rounded font-medium">You</span>
                          )}
                        </div>
                      </td>
                      <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap">{user.email}</td>
                      <td className="px-4 py-3 whitespace-nowrap">
                        <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${roleStyle[user.role] ?? "bg-muted text-muted-foreground"}`}>{user.role}</span>
                      </td>
                      <td className="px-4 py-3">
                        <span className={`text-xs px-2 py-0.5 rounded-full font-medium capitalize ${
                          user.status === "active"
                            ? "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20"
                            : "bg-slate-500/10 text-slate-400 border border-slate-500/20"
                        }`}>{user.status}</span>
                      </td>
                      <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap" style={{ fontFamily: "'DM Mono', monospace" }}>{user.lastLogin}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
