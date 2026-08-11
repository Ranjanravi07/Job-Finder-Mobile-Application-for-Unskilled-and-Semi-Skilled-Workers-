import { useEffect, useState } from "react";
import { collection, getDocs } from "firebase/firestore";
import { db } from "../../firebase";

export function DuplicateChecker() {
  const [duplicates, setDuplicates] = useState<any[]>([]);

  useEffect(() => {
    const checkDuplicates = async () => {
      if (!db) return;
      
      const workersSnap = await getDocs(collection(db, "workers"));
      const employersSnap = await getDocs(collection(db, "employers"));
      
      const phoneMap = new Map<string, any[]>();
      
      workersSnap.docs.forEach(doc => {
        const data = doc.data();
        const phone = data.phone || "Unknown";
        const norm = phone.replace("+977", "");
        if (!phoneMap.has(norm)) phoneMap.set(norm, []);
        phoneMap.get(norm)!.push({ id: doc.id, role: "worker", rawPhone: phone, name: data.name });
      });
      
      employersSnap.docs.forEach(doc => {
        const data = doc.data();
        const phone = data.phone || "Unknown";
        const norm = phone.replace("+977", "");
        if (!phoneMap.has(norm)) phoneMap.set(norm, []);
        phoneMap.get(norm)!.push({ id: doc.id, role: "employer", rawPhone: phone, name: data.name });
      });
      
      const dups: any[] = [];
      phoneMap.forEach((accounts, phone) => {
        if (accounts.length > 1) {
          dups.push({ phone, accounts });
        }
      });
      
      setDuplicates(dups);
      console.log("Duplicate Check Results:", dups);
    };
    
    checkDuplicates();
  }, []);

  if (duplicates.length === 0) return null;

  return (
    <div className="p-4 m-4 bg-red-100 border border-red-400 rounded relative z-50">
      <h3 className="font-bold text-red-800">Duplicate Accounts Detected!</h3>
      <p className="text-sm text-red-700">These accounts share the same phone number.</p>
      <pre className="text-xs mt-2 overflow-auto max-h-40 bg-white p-2 border border-red-200">{JSON.stringify(duplicates, null, 2)}</pre>
    </div>
  );
}
