import { useState, useEffect } from "react";
import { Scissors, Type, Eraser, Shield } from "lucide-react";
import { Button } from "./button";

interface ImageEditorProps {
  file: File;
  onProcessImage: (operation: 'remove_background' | 'remove_text' | 'cleanup' | 'remove_logo') => void;
  isProcessing: boolean;
}

export default function ImageEditor({ file, onProcessImage, isProcessing }: ImageEditorProps) {
  const [imagePreview, setImagePreview] = useState<string>("");

  useEffect(() => {
    const reader = new FileReader();
    reader.onload = (e) => {
      setImagePreview(e.target?.result as string);
    };
    reader.readAsDataURL(file);
  }, [file]);

  return (
    <section className="py-6">
      <div className="bg-white rounded-2xl p-4 shadow-sm border border-slate-200 mb-6">
        <div className="aspect-square bg-slate-100 rounded-xl overflow-hidden mb-4">
          {imagePreview && (
            <img 
              src={imagePreview} 
              alt="Uploaded image preview" 
              className="w-full h-full object-cover"
            />
          )}
        </div>
        
        <div className="grid grid-cols-2 gap-3">
          <Button
            onClick={() => onProcessImage('remove_background')}
            disabled={isProcessing}
            className="w-full bg-gradient-to-r from-blue-500 to-blue-600 text-white py-3 rounded-xl font-medium flex items-center justify-center space-x-2 hover:shadow-lg transition-all"
          >
            <Scissors size={18} />
            <span>Remove BG</span>
          </Button>
          
          <Button
            onClick={() => onProcessImage('remove_text')}
            disabled={isProcessing}
            className="w-full bg-gradient-to-r from-green-500 to-green-600 text-white py-3 rounded-xl font-medium flex items-center justify-center space-x-2 hover:shadow-lg transition-all"
          >
            <Type size={18} />
            <span>Remove Text</span>
          </Button>
          
          <Button
            onClick={() => onProcessImage('cleanup')}
            disabled={isProcessing}
            className="w-full bg-gradient-to-r from-purple-500 to-purple-600 text-white py-3 rounded-xl font-medium flex items-center justify-center space-x-2 hover:shadow-lg transition-all"
          >
            <Eraser size={18} />
            <span>Cleanup</span>
          </Button>
          
          <Button
            onClick={() => onProcessImage('remove_logo')}
            disabled={isProcessing}
            className="w-full bg-gradient-to-r from-red-500 to-red-600 text-white py-3 rounded-xl font-medium flex items-center justify-center space-x-2 hover:shadow-lg transition-all"
          >
            <Shield size={18} />
            <span>Remove Logo</span>
          </Button>
        </div>
      </div>
    </section>
  );
}
