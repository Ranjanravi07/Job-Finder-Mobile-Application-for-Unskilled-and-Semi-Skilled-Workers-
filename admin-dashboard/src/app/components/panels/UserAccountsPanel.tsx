import { useState, useEffect } from "react";
import { Users, Shield, Plus, Trash2, Eye, EyeOff } from "lucide-react";
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
import { createUserWithEmailAndPassword, sendPasswordResetEmail } from "firebase/auth";
import { auth } from "../../../firebase";
import { doc, setDoc, updateDoc } from "firebase/firestore";
import { db } from "../../../firebase";
import { isFirebaseConfigured, initError } from "../../../firebase";

const initialAccounts = [
  { id: 1, name: "Juan Admin", email: "juan@jobfinder.ph", role: "Super Admin", status: "active", lastLogin: "Dec 28, 2024" },
  { id: 2, name: "Ana Manager", email: "ana@jobfinder.ph", role: "Manager", status: "active", lastLogin: "Dec 27, 2024" },
  { id: 3, name: "Carlos Staff", email: "carlos@jobfinder.ph", role: "Staff", status: "active", lastLogin: "Dec 26, 2024" },
  { id: 4, name: "Liza Viewer", email: "liza@jobfinder.ph", role: "Viewer", status: "inactive", lastLogin: "Dec 20, 2024" },
  { id: 5, name: "Marco Editor", email: "marco@jobfinder.ph", role: "Editor", status: "active", lastLogin: "Dec 28, 2024" },
];

const roleOptions = ["Super Admin", "Manager", "Staff", "Editor", "Viewer"];
const statusOptions = ["active", "inactive"];

const roleStyle: Record<string, string> = {
  "Super Admin": "bg-violet-500/10 text-violet-400 border border-violet-500/20",
  Manager: "bg-sky-500/10 text-sky-400 border border-sky-500/20",
  Staff: "bg-emerald-500/10 text-emerald-400 border border-emerald-500/20",
  Editor: "bg-amber-500/10 text-amber-400 border border-amber-500/20",
  Viewer: "bg-slate-500/10 text-slate-400 border border-slate-500/20",
};

const CURRENT_USER_ROLE = "Super Admin";

export default function UserAccountsPanel({ search, adminProfile }: { search: string; adminProfile?: { username: string; email: string } }) {
  const [accounts, setAccounts] = useState(initialAccounts);

  // Sync the Super Admin row (id: 1) whenever settings profile changes
  useEffect(() => {
    if (!adminProfile) return;
    setAccounts((prev) =>
      prev.map((a) =>
        a.id === 1 ? { ...a, name: adminProfile.username, email: adminProfile.email } : a
      )
    );
  }, [adminProfile?.username, adminProfile?.email]);
  const [open, setOpen] = useState(false);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [role, setRole] = useState("Staff");
  const [status, setStatus] = useState("active");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState("");

  const [selectedUser, setSelectedUser] = useState<(typeof initialAccounts)[0] | null>(null);
  const [editName, setEditName] = useState("");
  const [editEmail, setEditEmail] = useState("");
  const [editStatus, setEditStatus] = useState("active");
  const [editRole, setEditRole] = useState("Staff");
  const [editPassword, setEditPassword] = useState("");
  const [showEditPassword, setShowEditPassword] = useState(false);

  const isSuperAdmin = CURRENT_USER_ROLE === "Super Admin";
  const firebaseReady = isFirebaseConfigured && auth && db;

  const filtered = accounts.filter((a) =>
    a.name.toLowerCase().includes(search.toLowerCase()) ||
    a.email.toLowerCase().includes(search.toLowerCase()) ||
    a.role.toLowerCase().includes(search.toLowerCase())
  );

  const resetForm = () => {
    setName("");
    setEmail("");
    setRole("Staff");
    setStatus("active");
    setPassword("");
    setShowPassword(false);
    setError("");
  };

  const handleAdd = async () => {
    setError("");
    if (!name.trim() || !email.trim() || !password.trim()) {
      setError("Please fill in all fields");
      return;
    }
    try {
      if (firebaseReady) {
        const cred = await createUserWithEmailAndPassword(auth!, email.trim(), password);
        const newUser = {
          id: accounts.length ? Math.max(...accounts.map((a) => a.id)) + 1 : 1,
          name: name.trim(),
          email: email.trim(),
          role,
          status,
          lastLogin: "Never",
          uid: cred.user.uid,
        };
        setAccounts((prev) => [newUser, ...prev]);
        await setDoc(doc(db!, "users", cred.user.uid), {
          name: name.trim(),
          email: email.trim(),
          role,
          status,
          lastLogin: "Never",
        });
      } else {
        const newUser = {
          id: accounts.length ? Math.max(...accounts.map((a) => a.id)) + 1 : 1,
          name: name.trim(),
          email: email.trim(),
          role,
          status,
          lastLogin: "Never",
        };
        setAccounts((prev) => [newUser, ...prev]);
      }
      resetForm();
      setOpen(false);
    } catch (err: any) {
      const message = err?.message || "Failed to create user";
      setError(message);
    }
  };

  const openEdit = (user: (typeof initialAccounts)[0]) => {
    if (!isSuperAdmin) return;
    setSelectedUser(user);
    setEditName(user.name);
    setEditEmail(user.email);
    setEditStatus(user.status);
    setEditRole(user.role);
    setEditPassword("");
    setShowEditPassword(false);
  };

  const handleSaveChanges = async () => {
    if (!selectedUser) return;
    try {
      if (firebaseReady && selectedUser.uid) {
        const updates: any = { name: editName, email: editEmail, status: editStatus, role: editRole };
        if (editPassword.trim() && selectedUser.email) {
          await sendPasswordResetEmail(auth!, selectedUser.email);
        }
        await updateDoc(doc(db!, "users", selectedUser.uid), updates);
      }
      setAccounts((prev) =>
        prev.map((u) =>
          u.id === selectedUser.id
            ? { ...u, name: editName, email: editEmail, status: editStatus, role: editRole }
            : u
        )
      );
      setSelectedUser(null);
      setEditPassword("");
    } catch (err) {
      console.error("Failed to update user", err);
    }
  };

  const handleDelete = () => {
    if (!selectedUser) return;
    setAccounts((prev) => prev.filter((u) => u.id !== selectedUser.id));
    setSelectedUser(null);
  };

  return (
    <div className="space-y-5">
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

      {!firebaseReady && (
        <p className="text-xs text-amber-400 bg-amber-500/10 rounded-md px-3 py-2">
          Firebase is not configured. Users will be added locally only. Configure VITE_FIREBASE_* env vars to enable cloud sync.
          {initError && <span className="block mt-1 text-rose-300">Error: {initError}</span>}
        </p>
      )}

      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Add User</DialogTitle>
            <DialogDescription>Create a new admin or staff account.</DialogDescription>
          </DialogHeader>
          {error && (
            <p className="text-xs text-rose-400 bg-rose-500/10 rounded-md px-3 py-2">{error}</p>
          )}
          <div className="space-y-4">
            <div>
              <label className="text-xs font-medium text-foreground block mb-1.5">Full Name</label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="w-full px-3 py-2 rounded-md bg-muted border border-border text-foreground text-sm outline-none focus:border-primary transition-colors"
                placeholder="e.g. Juan Admin"
              />
            </div>
            <div>
              <label className="text-xs font-medium text-foreground block mb-1.5">Email</label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full px-3 py-2 rounded-md bg-muted border border-border text-foreground text-sm outline-none focus:border-primary transition-colors"
                placeholder="e.g. juan@jobfinder.ph"
              />
            </div>
            <div>
              <label className="text-xs font-medium text-foreground block mb-1.5">Role</label>
              <Select value={role} onValueChange={setRole}>
                <SelectTrigger className="w-full">
                  <SelectValue placeholder="Select role" />
                </SelectTrigger>
                <SelectContent>
                  {roleOptions.map((r) => (
                    <SelectItem key={r} value={r}>{r}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div>
              <label className="text-xs font-medium text-foreground block mb-1.5">Status</label>
              <Select value={status} onValueChange={setStatus}>
                <SelectTrigger className="w-full">
                  <SelectValue placeholder="Select status" />
                </SelectTrigger>
                <SelectContent>
                  {statusOptions.map((s) => (
                    <SelectItem key={s} value={s}>{s}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div>
              <label className="text-xs font-medium text-foreground block mb-1.5">Password</label>
              <div className="relative">
                <input
                  type={showPassword ? "text" : "password"}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full px-3 py-2 rounded-md bg-muted border border-border text-foreground text-sm outline-none focus:border-primary transition-colors pr-9"
                  placeholder="Set initial password"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-2 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                >
                  {showPassword ? <EyeOff className="w-3.5 h-3.5" /> : <Eye className="w-3.5 h-3.5" />}
                </button>
              </div>
            </div>
          </div>
          <DialogFooter>
            <DialogClose asChild>
              <button className="px-4 py-2 rounded-md text-xs border border-border hover:bg-muted transition-colors">Cancel</button>
            </DialogClose>
            <button
              onClick={handleAdd}
              className="px-4 py-2 rounded-md text-xs bg-primary text-white hover:bg-primary/90 transition-colors"
            >
              Add User
            </button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

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
                <input
                  type="text"
                  value={editName}
                  onChange={(e) => setEditName(e.target.value)}
                  className="w-full px-3 py-2 rounded-md bg-muted border border-border text-foreground text-sm outline-none focus:border-primary transition-colors"
                />
              </div>
              <div>
                <label className="text-xs font-medium text-foreground block mb-1.5">Email</label>
                <input
                  type="email"
                  value={editEmail}
                  onChange={(e) => setEditEmail(e.target.value)}
                  className="w-full px-3 py-2 rounded-md bg-muted border border-border text-foreground text-sm outline-none focus:border-primary transition-colors"
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-xs font-medium text-muted-foreground block mb-1">Last Login</label>
                  <p className="text-sm text-foreground">{selectedUser.lastLogin}</p>
                </div>
              </div>
              <div>
                <label className="text-xs font-medium text-foreground block mb-1.5">Role</label>
                <Select value={editRole} onValueChange={setEditRole}>
                  <SelectTrigger className="w-full">
                    <SelectValue placeholder="Select role" />
                  </SelectTrigger>
                  <SelectContent>
                    {roleOptions.map((r) => (
                      <SelectItem key={r} value={r}>{r}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div>
                <label className="text-xs font-medium text-foreground block mb-1.5">Status</label>
                <Select value={editStatus} onValueChange={setEditStatus}>
                  <SelectTrigger className="w-full">
                    <SelectValue placeholder="Select status" />
                  </SelectTrigger>
                  <SelectContent>
                    {statusOptions.map((s) => (
                      <SelectItem key={s} value={s}>{s}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div>
                <label className="text-xs font-medium text-foreground block mb-1.5">Reset Password</label>
                <div className="relative">
                  <input
                    type={showEditPassword ? "text" : "password"}
                    value={editPassword}
                    onChange={(e) => setEditPassword(e.target.value)}
                    className="w-full px-3 py-2 rounded-md bg-muted border border-border text-foreground text-sm outline-none focus:border-primary transition-colors pr-9"
                    placeholder="Leave blank to keep current"
                  />
                  <button
                    type="button"
                    onClick={() => setShowEditPassword(!showEditPassword)}
                    className="absolute right-2 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                  >
                    {showEditPassword ? <EyeOff className="w-3.5 h-3.5" /> : <Eye className="w-3.5 h-3.5" />}
                  </button>
                </div>
                <p className="text-[10px] text-muted-foreground mt-1">A password reset email will be sent if changed.</p>
              </div>
            </div>
          )}
          <DialogFooter>
            <button
              onClick={handleDelete}
              className="px-4 py-2 rounded-md text-xs border border-rose-500/40 text-rose-400 hover:bg-rose-500/10 transition-colors flex items-center gap-1.5"
            >
              <Trash2 className="w-3.5 h-3.5" />
              Delete User
            </button>
            <DialogClose asChild>
              <button className="px-4 py-2 rounded-md text-xs border border-border hover:bg-muted transition-colors">Cancel</button>
            </DialogClose>
            <button
              onClick={handleSaveChanges}
              className="px-4 py-2 rounded-md text-xs bg-primary text-white hover:bg-primary/90 transition-colors"
            >
              Save Changes
            </button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <div className="bg-card border border-border rounded-xl overflow-hidden">
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
              {filtered.map((user) => (
                <tr
                  key={user.id}
                  onClick={() => openEdit(user)}
                  className={`border-b border-border last:border-0 hover:bg-muted/40 transition-colors ${isSuperAdmin ? "cursor-pointer" : "cursor-default"}`}
                >
                  <td className="px-4 py-3 text-xs font-medium text-foreground whitespace-nowrap flex items-center gap-2">
                    <div className="w-6 h-6 rounded-full bg-primary/10 flex items-center justify-center text-[10px] font-bold text-primary flex-shrink-0">
                      {user.name.split(" ").map((n) => n[0]).join("")}
                    </div>
                    {user.name}
                  </td>
                  <td className="px-4 py-3 text-xs text-muted-foreground whitespace-nowrap">{user.email}</td>
                  <td className="px-4 py-3 whitespace-nowrap">
                    <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${roleStyle[user.role] || "bg-muted text-muted-foreground"}`}>{user.role}</span>
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
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
