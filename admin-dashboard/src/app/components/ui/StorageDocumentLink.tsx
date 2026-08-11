import React, { useState, useEffect } from "react";
import { getDownloadURL, ref } from "firebase/storage";
import { storage } from "../../../firebase";
import { FileText, Loader2, ExternalLink, Image as ImageIcon } from "lucide-react";

interface StorageDocumentLinkProps {
  path: string;
  label?: string;
  className?: string;
  isImagePreview?: boolean;
}

export function StorageDocumentLink({ path, label, className, isImagePreview }: StorageDocumentLinkProps) {
  const [url, setUrl] = useState<string | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<boolean>(false);

  useEffect(() => {
    if (!path || path.trim() === "") {
      setLoading(false);
      setError(true);
      return;
    }

    if (path.startsWith("http://") || path.startsWith("https://") || path.startsWith("data:")) {
      setUrl(path);
      setLoading(false);
      return;
    }

    if (!storage) {
      setError(true);
      setLoading(false);
      return;
    }

    const fetchUrl = async () => {
      try {
        const docRef = ref(storage, path);
        const downloadUrl = await getDownloadURL(docRef);
        setUrl(downloadUrl);
        setError(false);
      } catch (err) {
        console.error("Failed to load document from storage:", err, path);
        setError(true);
      } finally {
        setLoading(false);
      }
    };

    fetchUrl();
  }, [path]);

  if (loading) {
    if (isImagePreview) {
      return (
        <div className="w-full h-16 flex items-center justify-center bg-muted/40 animate-pulse rounded border border-border">
          <Loader2 className="w-4 h-4 text-muted-foreground animate-spin" />
        </div>
      );
    }
    return (
      <div className={`flex items-center gap-2 text-muted-foreground ${className || ""}`}>
        <Loader2 className="w-3.5 h-3.5 animate-spin" />
        <span className="text-xs">Loading document...</span>
      </div>
    );
  }

  if (error || !url) {
    if (isImagePreview) {
      return (
        <div className="w-full h-16 flex items-center justify-center bg-muted/40 border border-dashed border-border rounded">
          <ImageIcon className="w-4 h-4 text-muted-foreground/50" />
        </div>
      );
    }
    return (
      <div className={`text-xs text-rose-400 ${className || ""}`}>
        Failed to load document.
      </div>
    );
  }

  const isProbablyImage = path.toLowerCase().match(/\.(jpeg|jpg|gif|png|webp)$/) || url.toLowerCase().includes("alt=media");

  if (isImagePreview && isProbablyImage) {
    return (
      <a href={url} target="_blank" rel="noreferrer" className="block">
        <img 
          src={url} 
          alt={label || "Document preview"} 
          className="w-full h-16 object-cover rounded border border-border hover:opacity-80 transition-opacity" 
        />
      </a>
    );
  }

  return (
    <a
      href={url}
      target="_blank"
      rel="noreferrer"
      className={`inline-flex items-center gap-1.5 text-primary hover:underline text-xs font-medium ${className || ""}`}
    >
      <FileText className="w-3.5 h-3.5" />
      {label || "View Document"}
      <ExternalLink className="w-3 h-3 ml-0.5" />
    </a>
  );
}
