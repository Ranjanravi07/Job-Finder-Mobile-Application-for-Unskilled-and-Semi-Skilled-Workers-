import React, { useState } from "react";
import { HardHat, Sun, Moon, Monitor, Eye, EyeOff, Loader2 } from "lucide-react";
import { useTheme } from "next-themes";
import { signInWithEmailAndPassword } from "firebase/auth";
import { doc, getDoc } from "firebase/firestore";
import { auth, db, isFirebaseConfigured } from "../../firebase";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuLabel,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "../components/ui/dropdown-menu";
import type { User } from "firebase/auth";

interface LoginProps {
  onLogin: (user: User, profile: { username: string; email: string }) => void;
}

const Login: React.FC<LoginProps> = ({ onLogin }) => {
  const [email, setEmail]         = useState("");
  const [password, setPassword]   = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError]         = useState("");
  const [loading, setLoading]     = useState(false);
  const { theme, setTheme }       = useTheme();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (!email.trim() || !password.trim()) {
      setError("Please enter your email and password.");
      return;
    }

    if (!isFirebaseConfigured || !auth) {
      setError("Firebase is not configured. Check your environment variables.");
      return;
    }

    setLoading(true);
    try {
      const cred = await signInWithEmailAndPassword(auth, email.trim(), password);
      const user = cred.user;

      // Use whatever we have immediately — don't block login on Firestore
      const username = user.displayName || user.email?.split("@")[0] || "Admin";
      onLogin(user, { username, email: user.email ?? email.trim() });

      // Fetch the saved name from Firestore in the background and update if found
      if (db) {
        getDoc(doc(db, "users", user.uid))
          .then((snap) => {
            if (snap.exists()) {
              const data = snap.data();
              if (data?.name) {
                onLogin(user, { username: data.name, email: user.email ?? email.trim() });
              }
            }
          })
          .catch(() => {/* silent — auth already succeeded */});
      }
    } catch (err: any) {
      // Map Firebase error codes to friendly messages
      const code: string = err?.code ?? "";
      if (code === "auth/invalid-credential" || code === "auth/wrong-password" || code === "auth/user-not-found") {
        setError("Invalid email or password.");
      } else if (code === "auth/too-many-requests") {
        setError("Too many failed attempts. Please try again later.");
      } else if (code === "auth/network-request-failed") {
        setError("Network error. Check your connection.");
      } else {
        setError(err?.message ?? "Login failed. Please try again.");
      }
    } finally {
      setLoading(false);
    }
  };

  const ThemeIcon = theme === "light" ? Sun : theme === "dark" ? Moon : Monitor;

  return (
    <div className="min-h-screen bg-background flex items-center justify-center">
      <div className="bg-card border border-border rounded-xl p-10 w-80 shadow-2xl flex flex-col items-center gap-6">

        {/* Logo */}
        <div className="flex flex-col items-center gap-2">
          <div className="w-12 h-12 rounded-xl overflow-hidden border border-border shadow-md">
            <img src="/kaamsathi_logo.jpg" alt="KaamSathi Logo" className="w-full h-full object-cover" />
          </div>
          <h2 className="text-lg font-semibold text-foreground tracking-tight">KaamSathi Admin Panel</h2>
          <p className="text-xs text-muted-foreground">Admin Console</p>
        </div>

        {/* Form */}
        <form onSubmit={handleLogin} className="w-full flex flex-col gap-3">
          <input
            type="email"
            placeholder="Email"
            value={email}
            onChange={(e) => { setEmail(e.target.value); setError(""); }}
            disabled={loading}
            className="w-full px-3 py-2 rounded-md bg-muted border border-border text-foreground placeholder:text-muted-foreground text-sm outline-none focus:border-primary transition-colors disabled:opacity-50"
          />

          <div className="relative">
            <input
              type={showPassword ? "text" : "password"}
              placeholder="Password"
              value={password}
              onChange={(e) => { setPassword(e.target.value); setError(""); }}
              disabled={loading}
              className="w-full px-3 py-2 pr-9 rounded-md bg-muted border border-border text-foreground placeholder:text-muted-foreground text-sm outline-none focus:border-primary transition-colors disabled:opacity-50"
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              className="absolute right-2 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
              tabIndex={-1}
            >
              {showPassword ? <EyeOff className="w-3.5 h-3.5" /> : <Eye className="w-3.5 h-3.5" />}
            </button>
          </div>

          {error && (
            <p className="text-xs text-rose-400 bg-rose-500/10 rounded px-2 py-1.5">{error}</p>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full py-2 mt-1 rounded-md bg-primary text-white text-sm font-semibold hover:bg-primary/90 transition-colors flex items-center justify-center gap-2 disabled:opacity-70 disabled:cursor-not-allowed"
          >
            {loading ? (
              <>
                <Loader2 className="w-3.5 h-3.5 animate-spin" />
                Signing in…
              </>
            ) : (
              "Sign In"
            )}
          </button>
        </form>

        {/* Theme picker */}
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <button className="flex items-center gap-2 text-xs text-muted-foreground hover:text-foreground border border-border rounded-md px-3 py-1.5 transition-colors">
              <ThemeIcon className="w-3.5 h-3.5" />
              <span className="capitalize">{theme === "system" ? "System" : theme}</span>
            </button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-40">
            <DropdownMenuLabel>Theme</DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuRadioGroup value={theme} onValueChange={setTheme}>
              <DropdownMenuRadioItem value="light">
                <Sun className="w-3.5 h-3.5" /> Light
              </DropdownMenuRadioItem>
              <DropdownMenuRadioItem value="dark">
                <Moon className="w-3.5 h-3.5" /> Dark
              </DropdownMenuRadioItem>
              <DropdownMenuRadioItem value="system">
                <Monitor className="w-3.5 h-3.5" /> System
              </DropdownMenuRadioItem>
            </DropdownMenuRadioGroup>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </div>
  );
};

export default Login;
