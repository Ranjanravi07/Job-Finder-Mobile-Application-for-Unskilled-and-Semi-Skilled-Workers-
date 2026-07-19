import React, { useState } from "react";
import { HardHat, Sun, Moon, Monitor } from "lucide-react";
import { useTheme } from "next-themes";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuLabel,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "../components/ui/dropdown-menu";
import { signInWithEmailAndPassword } from "firebase/auth";
import { auth } from "../../firebase";

interface UserLoginProps {
  onLogin: () => void;
}

const UserLogin: React.FC<UserLoginProps> = ({ onLogin }) => {
  const [email, setEmail] = useState<string>("");
  const [password, setPassword] = useState<string>("");
  const [error, setError] = useState<string>("");
  const [loading, setLoading] = useState(false);
  const { theme, setTheme } = useTheme();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);
    try {
      if (!auth) {
        setError("Firebase is not configured. Please set up Firebase credentials.");
        return;
      }
      await signInWithEmailAndPassword(auth, email, password);
      onLogin();
    } catch (err: any) {
      setError(err.message || "Invalid email or password");
    } finally {
      setLoading(false);
    }
  };

  const ThemeIcon = theme === "light" ? Sun : theme === "dark" ? Moon : Monitor;

  return (
    <div className="min-h-screen bg-background flex items-center justify-center">
      <div className="bg-card border border-border rounded-xl p-10 w-80 shadow-2xl flex flex-col items-center gap-6">
        <div className="flex flex-col items-center gap-2">
          <div className="w-10 h-10 rounded-xl bg-primary flex items-center justify-center">
            <HardHat className="w-5 h-5 text-white" />
          </div>
          <h2 className="text-lg font-semibold text-foreground tracking-tight">JobFinder PH</h2>
          <p className="text-xs text-muted-foreground">Worker / Employer Login</p>
        </div>

        <form onSubmit={handleLogin} className="w-full flex flex-col gap-3">
          <input
            type="email"
            placeholder="Email"
            value={email}
            onChange={(e) => { setEmail(e.target.value); setError(""); }}
            className="w-full px-3 py-2 rounded-md bg-muted border border-border text-foreground placeholder:text-muted-foreground text-sm outline-none focus:border-primary transition-colors"
          />
          <input
            type="password"
            placeholder="Password"
            value={password}
            onChange={(e) => { setPassword(e.target.value); setError(""); }}
            className="w-full px-3 py-2 rounded-md bg-muted border border-border text-foreground placeholder:text-muted-foreground text-sm outline-none focus:border-primary transition-colors"
          />
          {error && (
            <p className="text-xs text-rose-400">{error}</p>
          )}
          <button
            type="submit"
            disabled={loading}
            className="w-full py-2 mt-1 rounded-md bg-primary text-white text-sm font-semibold hover:bg-primary/90 transition-colors disabled:opacity-50"
          >
            {loading ? "Signing in..." : "Sign In"}
          </button>
        </form>

        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <button
              className="flex items-center gap-2 text-xs text-muted-foreground hover:text-foreground border border-border rounded-md px-3 py-1.5 transition-colors"
              title="Change theme"
            >
              <ThemeIcon className="w-3.5 h-3.5" />
              <span className="capitalize">{theme === "system" ? "System" : theme}</span>
            </button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-40">
            <DropdownMenuLabel>Theme</DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuRadioGroup value={theme} onValueChange={setTheme}>
              <DropdownMenuRadioItem value="light">
                <Sun className="w-3.5 h-3.5" />
                Light
              </DropdownMenuRadioItem>
              <DropdownMenuRadioItem value="dark">
                <Moon className="w-3.5 h-3.5" />
                Dark
              </DropdownMenuRadioItem>
              <DropdownMenuRadioItem value="system">
                <Monitor className="w-3.5 h-3.5" />
                System
              </DropdownMenuRadioItem>
            </DropdownMenuRadioGroup>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </div>
  );
};

export default UserLogin;
