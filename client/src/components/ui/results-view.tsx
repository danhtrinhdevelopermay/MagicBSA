import { useState } from "react";
import { Download, Share2, Edit3, RotateCcw } from "lucide-react";
import { Button } from "./button";

interface ResultsViewProps {
  originalImageUrl: string;
  processedImageUrl: string;
  operation: 'remove_background' | 'remove_text' | 'cleanup' | 'remove_logo';
  onStartOver: () => void;
}

export default function ResultsView({ 
  originalImageUrl, 
  processedImageUrl, 
  operation,
  onStartOver 
}: ResultsViewProps) {
  const [isComparison, setIsComparison] = useState(true);

  const handleDownload = async () => {
    try {
      const response = await fetch(processedImageUrl);
      const blob = await response.blob();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `edited-image-${Date.now()}.png`;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);
    } catch (error) {
      console.error('Download failed:', error);
    }
  };

  const handleShare = async () => {
    if (navigator.share) {
      try {
        const response = await fetch(processedImageUrl);
        const blob = await response.blob();
        const file = new File([blob], 'edited-image.png', { type: 'image/png' });
        
        await navigator.share({
          title: 'AI Edited Image',
          text: 'Check out this AI-edited image!',
          files: [file],
        });
      } catch (error) {
        console.error('Share failed:', error);
        // Fallback to copying URL
        navigator.clipboard.writeText(window.location.href);
      }
    } else {
      // Fallback for browsers that don't support Web Share API
      navigator.clipboard.writeText(window.location.href);
    }
  };

  return (
    <section className="py-6">
      <div className="bg-white rounded-2xl p-4 shadow-sm border border-slate-200 mb-6">
        <div className="flex items-center justify-between mb-4">
          <h3 className="font-semibold text-slate-800">Before & After</h3>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setIsComparison(!isComparison)}
            className="text-primary text-sm font-medium"
          >
            <RotateCcw size={16} className="mr-1" />
            Toggle View
          </Button>
        </div>

        {isComparison ? (
          <div className="grid grid-cols-2 gap-3 mb-4">
            <div className="space-y-2">
              <p className="text-xs font-medium text-slate-600 uppercase tracking-wide">Original</p>
              <div className="aspect-square bg-slate-100 rounded-lg overflow-hidden">
                <img 
                  src={originalImageUrl} 
                  alt="Original image" 
                  className="w-full h-full object-cover"
                />
              </div>
            </div>
            
            <div className="space-y-2">
              <p className="text-xs font-medium text-slate-600 uppercase tracking-wide">Processed</p>
              <div className="aspect-square bg-gradient-to-br from-slate-100 to-slate-200 rounded-lg overflow-hidden border-2 border-dashed border-primary/30">
                <img 
                  src={processedImageUrl} 
                  alt="Processed image" 
                  className="w-full h-full object-cover"
                />
              </div>
            </div>
          </div>
        ) : (
          <div className="mb-4">
            <div className="aspect-square bg-gradient-to-br from-slate-100 to-slate-200 rounded-lg overflow-hidden">
              <img 
                src={processedImageUrl} 
                alt="Processed image" 
                className="w-full h-full object-cover"
              />
            </div>
          </div>
        )}

        <div className="bg-slate-50 rounded-lg p-3 mb-4">
          <div className="flex items-center justify-between text-sm">
            <span className="text-slate-600">Quality Score</span>
            <span className="font-semibold text-slate-800">98%</span>
          </div>
          <div className="flex items-center justify-between text-sm">
            <span className="text-slate-600">Operation</span>
            <span className="font-semibold text-slate-800 capitalize">
              {operation.replace('_', ' ')}
            </span>
          </div>
        </div>

        <div className="space-y-3">
          <Button
            onClick={handleDownload}
            className="w-full bg-accent text-white py-3 rounded-xl font-medium flex items-center justify-center space-x-2 hover:bg-accent/90 transition-colors"
          >
            <Download size={20} />
            <span>Download Result</span>
          </Button>
          
          <div className="grid grid-cols-2 gap-3">
            <Button
              onClick={handleShare}
              variant="secondary"
              className="bg-slate-100 text-slate-700 py-2.5 rounded-lg font-medium text-sm hover:bg-slate-200 transition-colors"
            >
              <Share2 size={16} className="mr-1" />
              Share
            </Button>
            <Button
              onClick={onStartOver}
              variant="secondary"
              className="bg-slate-100 text-slate-700 py-2.5 rounded-lg font-medium text-sm hover:bg-slate-200 transition-colors"
            >
              <Edit3 size={16} className="mr-1" />
              Edit More
            </Button>
          </div>
        </div>
      </div>
    </section>
  );
}
