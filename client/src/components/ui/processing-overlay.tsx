import { useEffect, useState } from "react";
import { WandSparkles, Cog } from "lucide-react";

interface ProcessingOverlayProps {
  operation: 'remove_background' | 'remove_text' | 'cleanup' | 'remove_logo';
}

export default function ProcessingOverlay({ operation }: ProcessingOverlayProps) {
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setProgress((prev) => {
        if (prev >= 90) return prev;
        return prev + Math.random() * 10;
      });
    }, 500);

    return () => clearInterval(interval);
  }, []);

  const getProcessingMessage = () => {
    switch (operation) {
      case 'remove_background':
        return {
          title: 'Removing Background...',
          message: 'AI is analyzing and removing the background from your image.',
        };
      case 'remove_text':
        return {
          title: 'Removing Text...',
          message: 'AI is detecting and removing text from your image.',
        };
      case 'cleanup':
        return {
          title: 'Cleaning Up Objects...',
          message: 'AI is removing unwanted objects from your image.',
        };
      case 'remove_logo':
        return {
          title: 'Removing Logo...',
          message: 'AI is detecting and removing logo from your image.',
        };
      default:
        return {
          title: 'Processing Image...',
          message: 'AI is working its magic. Please wait.',
        };
    }
  };

  const { title, message } = getProcessingMessage();

  return (
    <section className="py-6">
      <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-200 mb-6">
        <div className="text-center">
          <div className="w-16 h-16 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-4">
            <div className="animate-spin">
              <WandSparkles className="text-primary text-2xl" size={32} />
            </div>
          </div>
          <h3 className="font-semibold text-slate-800 mb-2">{title}</h3>
          <p className="text-sm text-slate-600 mb-4">{message}</p>
          
          <div className="w-full bg-slate-200 rounded-full h-2 mb-4">
            <div 
              className="bg-gradient-to-r from-primary to-secondary h-2 rounded-full transition-all duration-500"
              style={{ width: `${progress}%` }}
            />
          </div>
          
          <p className="text-xs text-slate-500">Estimated time: 3-5 seconds</p>
        </div>
      </div>

      {/* Loading Overlay */}
      <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
        <div className="bg-white rounded-2xl p-6 mx-4 max-w-sm w-full">
          <div className="text-center">
            <div className="w-16 h-16 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-4">
              <div className="animate-spin">
                <Cog className="text-primary text-2xl" size={32} />
              </div>
            </div>
            <h3 className="font-semibold text-slate-800 mb-2">Processing...</h3>
            <p className="text-sm text-slate-600">Please don't close the app</p>
          </div>
        </div>
      </div>
    </section>
  );
}
