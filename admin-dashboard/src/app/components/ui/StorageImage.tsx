import React, { useState, useEffect } from "react";
import { getDownloadURL, ref } from "firebase/storage";
import { storage } from "../../../firebase";
import { Image as ImageIcon, Loader2 } from "lucide-react";

interface StorageImageProps extends React.ImgHTMLAttributes<HTMLImageElement> {
  path: string | undefined | null;
  fallbackIcon?: React.ReactNode;
}

export function StorageImage({ path, fallbackIcon, className, ...props }: StorageImageProps) {
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

    // It's a storage path or gs:// url
    const fetchUrl = async () => {
      try {
        const imageRef = ref(storage, path);
        const downloadUrl = await getDownloadURL(imageRef);
        setUrl(downloadUrl);
        setError(false);
      } catch (err) {
        console.error("Failed to load image from storage:", err, path);
        setError(true);
      } finally {
        setLoading(false);
      }
    };

    fetchUrl();
  }, [path]);

  if (loading) {
    return (
      <div className={`flex items-center justify-center bg-muted/40 animate-pulse ${className || ""}`}>
        <Loader2 className="w-5 h-5 text-muted-foreground animate-spin" />
      </div>
    );
  }

  if (error || !url) {
    return (
      <div className={`flex items-center justify-center bg-muted/40 border border-dashed border-border ${className || ""}`}>
        {fallbackIcon || <ImageIcon className="w-5 h-5 text-muted-foreground/50" />}
      </div>
    );
  }

  return <img src={url} className={className} {...props} />;
}
