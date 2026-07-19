import { useState, useEffect } from "react";
import { Save, CheckCircle2 } from "lucide-react";

interface SettingsPanelProps {
  search: string;
  username: string;
  email: string;
  onSave: (username: string, email: string) => void;
}

export default function SettingsPanel({ search, username, email, onSave }: SettingsPanelProps) {
  const [draftUsername, setDraftUsername] = useState(username);
  const [draftEmail, setDraftEmail]       = useState(email);
  const [notifications, setNotifications] = useState(true);
  const [autoApprove, setAutoApprove]     = useState(false);
  const [saved, setSaved]                 = useState(false);

  // Keep draft in sync if parent state changes from outside
  useEffect(() => { setDraftUsername(username); }, [username]);
  useEffect(() => { setDraftEmail(email); },     [email]);

  const handleSave = () => {
    if (!draftUsername.trim() || !draftEmail.trim()) return;
    onSave(draftUsername.trim(), draftEmail.trim());
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  const isDirty = draftUsername.trim() !== username || draftEmail.trim() !== email;

  return (
    <div className="space-y-5">
      <div>
        <h2 className="text-sm font-semibold text-foreground">Settings</h2>
        <p className="text-xs text-muted-foreground mt-0.5">Manage application preferences</p>
      </div>

      <div className="bg-card border border-border rounded-xl p-6 space-y-6 max-w-2xl">

        {/* Profile fields */}
        <div className="space-y-4">
          <div>
            <label className="text-xs font-medium text-foreground block mb-1.5">
              Username
            </label>
            <input
              type="text"
              value={draftUsername}
              onChange={(e) => { setDraftUsername(e.target.value); setSaved(false); }}
              placeholder="Enter username"
              className="w-full px-3 py-2 rounded-md bg-muted border border-border text-foreground text-sm outline-none focus:border-primary transition-colors placeholder:text-muted-foreground"
            />
          </div>

          <div>
            <label className="text-xs font-medium text-foreground block mb-1.5">
              Email
            </label>
            <input
              type="email"
              value={draftEmail}
              onChange={(e) => { setDraftEmail(e.target.value); setSaved(false); }}
              placeholder="Enter email"
              className="w-full px-3 py-2 rounded-md bg-muted border border-border text-foreground text-sm outline-none focus:border-primary transition-colors placeholder:text-muted-foreground"
            />
          </div>

          {/* Email notifications toggle */}
          <div className="flex items-center justify-between py-2">
            <div>
              <p className="text-xs font-medium text-foreground">Email Notifications</p>
              <p className="text-xs text-muted-foreground mt-0.5">Receive alerts for new applications</p>
            </div>
            <button
              onClick={() => setNotifications(!notifications)}
              className={`w-10 h-5 rounded-full transition-colors relative flex-shrink-0 ${notifications ? "bg-primary" : "bg-muted border border-border"}`}
            >
              <div className={`w-3.5 h-3.5 rounded-full bg-white absolute top-0.5 transition-all ${notifications ? "left-5" : "left-0.5"}`} />
            </button>
          </div>

          {/* Auto-approve toggle */}
          <div className="flex items-center justify-between py-2">
            <div>
              <p className="text-xs font-medium text-foreground">Auto-approve Workers</p>
              <p className="text-xs text-muted-foreground mt-0.5">Automatically approve new worker profiles</p>
            </div>
            <button
              onClick={() => setAutoApprove(!autoApprove)}
              className={`w-10 h-5 rounded-full transition-colors relative flex-shrink-0 ${autoApprove ? "bg-primary" : "bg-muted border border-border"}`}
            >
              <div className={`w-3.5 h-3.5 rounded-full bg-white absolute top-0.5 transition-all ${autoApprove ? "left-5" : "left-0.5"}`} />
            </button>
          </div>
        </div>

        {/* Footer */}
        <div className="pt-4 border-t border-border flex items-center gap-3">
          <button
            onClick={handleSave}
            disabled={!isDirty && !saved}
            className={`flex items-center gap-1.5 text-xs px-4 py-2 rounded-md font-medium transition-colors ${
              isDirty
                ? "bg-primary text-white hover:bg-primary/90"
                : "bg-muted text-muted-foreground cursor-not-allowed"
            }`}
          >
            <Save className="w-3.5 h-3.5" />
            Save Changes
          </button>

          {/* Success toast inline */}
          {saved && (
            <span className="flex items-center gap-1.5 text-xs text-emerald-400 animate-in fade-in duration-300">
              <CheckCircle2 className="w-3.5 h-3.5" />
              Profile updated successfully
            </span>
          )}
        </div>
      </div>
    </div>
  );
}
