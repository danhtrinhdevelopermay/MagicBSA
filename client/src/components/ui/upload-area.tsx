import { useRef } from "react";
import { CloudUpload } from "lucide-react";
import { Button } from "./button";

interface UploadAreaProps {
  onFileSelect: (file: File) => void;
}

export default function UploadArea({ onFileSelect }: UploadAreaProps) {
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      // Validate file type
      const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
      if (!allowedTypes.includes(file.type)) {
        alert('Please select a valid image file (JPG, PNG, or WEBP)');
        return;
      }

      // Validate file size (10MB)
      if (file.size > 10 * 1024 * 1024) {
        alert('File size must be less than 10MB');
        return;
      }

      onFileSelect(file);
    }
  };

  const handleUploadClick = () => {
    fileInputRef.current?.click();
  };

  return (
    <section className="py-6">
      <div className="text-center mb-6">
        <h2 className="text-2xl font-bold text-slate-800 mb-2">Remove Backgrounds & Objects</h2>
        <p className="text-slate-600 text-sm">Upload your image and let AI do the magic</p>
      </div>

      <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200 mb-6">
        <div 
          className="border-2 border-dashed border-slate-300 rounded-xl p-8 text-center bg-slate-50 cursor-pointer hover:border-primary/50 transition-colors"
          onClick={handleUploadClick}
        >
          <div className="w-16 h-16 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-4">
            <CloudUpload className="text-primary text-2xl" size={32} />
          </div>
          <h3 className="font-semibold text-slate-800 mb-2">Upload Your Image</h3>
          <p className="text-sm text-slate-600 mb-4">Support JPG, PNG, WEBP up to 10MB</p>
          <Button 
            className="bg-primary text-white px-6 py-2.5 rounded-lg font-medium text-sm hover:bg-primary/90 transition-colors"
            onClick={handleUploadClick}
          >
            Choose File
          </Button>
          <input
            ref={fileInputRef}
            type="file"
            accept="image/jpeg,image/png,image/webp"
            className="hidden"
            onChange={handleFileChange}
          />
        </div>
      </div>
    </section>
  );
}
