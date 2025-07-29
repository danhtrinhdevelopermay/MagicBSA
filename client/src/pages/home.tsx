import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { ImageJob } from "@shared/schema";
import UploadArea from "@/components/ui/upload-area";
import ImageEditor from "@/components/ui/image-editor";
import ProcessingOverlay from "@/components/ui/processing-overlay";
import ResultsView from "@/components/ui/results-view";
import BottomNavigation from "@/components/ui/bottom-navigation";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { WandSparkles, Menu } from "lucide-react";

export default function Home() {
  const [currentJob, setCurrentJob] = useState<ImageJob | null>(null);
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const { toast } = useToast();
  const queryClient = useQueryClient();

  // Mutation for creating a new job
  const createJobMutation = useMutation({
    mutationFn: async ({ file, operation }: { file: File; operation: string }) => {
      const formData = new FormData();
      formData.append('image', file);
      formData.append('operation', operation);
      
      const response = await apiRequest('POST', '/api/jobs', formData);
      return await response.json();
    },
    onSuccess: (job: ImageJob) => {
      setCurrentJob(job);
      queryClient.invalidateQueries({ queryKey: ['/api/jobs'] });
    },
    onError: (error) => {
      toast({
        title: "Upload Failed",
        description: error instanceof Error ? error.message : "Failed to upload image",
        variant: "destructive",
      });
    },
  });

  // Mutation for processing a job
  const processJobMutation = useMutation({
    mutationFn: async (jobId: string) => {
      const response = await apiRequest('POST', `/api/jobs/${jobId}/process`);
      return await response.json();
    },
    onSuccess: (job: ImageJob) => {
      setCurrentJob(job);
      queryClient.invalidateQueries({ queryKey: ['/api/jobs'] });
      
      if (job.status === 'completed') {
        toast({
          title: "Processing Complete",
          description: "Your image has been processed successfully!",
        });
      } else if (job.status === 'failed') {
        toast({
          title: "Processing Failed",
          description: job.errorMessage || "Failed to process image",
          variant: "destructive",
        });
      }
    },
    onError: (error) => {
      toast({
        title: "Processing Failed",
        description: error instanceof Error ? error.message : "Failed to process image",
        variant: "destructive",
      });
    },
  });

  // Query to poll job status when processing
  const { data: jobStatus } = useQuery<ImageJob>({
    queryKey: ['/api/jobs', currentJob?.id],
    enabled: !!currentJob && currentJob.status === 'processing',
    refetchInterval: 1000,
  });

  // Update current job when status changes
  if (jobStatus && currentJob && jobStatus.id === currentJob.id) {
    if (jobStatus.status !== currentJob.status) {
      setCurrentJob(jobStatus);
    }
  }

  const handleFileSelect = (file: File) => {
    setSelectedFile(file);
    setCurrentJob(null);
  };

  const handleProcessImage = (operation: 'remove_background' | 'remove_text' | 'cleanup' | 'remove_logo') => {
    if (!selectedFile) return;
    
    createJobMutation.mutate({ file: selectedFile, operation }, {
      onSuccess: (job) => {
        // Automatically start processing
        processJobMutation.mutate(job.id);
      }
    });
  };

  const handleStartOver = () => {
    setCurrentJob(null);
    setSelectedFile(null);
  };

  const renderMainContent = () => {
    if (currentJob?.status === 'completed' && currentJob.processedImageUrl) {
      return (
        <ResultsView
          originalImageUrl={currentJob.originalImageUrl}
          processedImageUrl={currentJob.processedImageUrl}
          operation={currentJob.operation}
          onStartOver={handleStartOver}
        />
      );
    }

    if (currentJob?.status === 'processing' || processJobMutation.isPending) {
      return <ProcessingOverlay operation={currentJob?.operation || 'remove_background'} />;
    }

    if (selectedFile) {
      return (
        <ImageEditor
          file={selectedFile}
          onProcessImage={handleProcessImage}
          isProcessing={createJobMutation.isPending}
        />
      );
    }

    return <UploadArea onFileSelect={handleFileSelect} />;
  };

  return (
    <div className="bg-slate-50 min-h-screen font-sans">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-slate-200">
        <div className="max-w-md mx-auto px-4 py-3 flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <div className="w-8 h-8 bg-gradient-to-br from-primary to-secondary rounded-lg flex items-center justify-center">
              <WandSparkles className="text-white text-sm" size={16} />
            </div>
            <h1 className="text-lg font-semibold text-slate-800">AI Image Editor</h1>
          </div>
          <button className="w-8 h-8 flex items-center justify-center text-slate-600">
            <Menu size={16} />
          </button>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-md mx-auto px-4 pb-20">
        {renderMainContent()}

        {/* Features Section */}
        <section className="py-6">
          <h3 className="font-semibold text-slate-800 mb-4">Features</h3>
          <div className="grid grid-cols-2 gap-3">
            <div className="bg-white rounded-xl p-4 shadow-sm border border-slate-200">
              <div className="w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center mb-3">
                <i className="fas fa-cut text-primary"></i>
              </div>
              <h4 className="font-medium text-slate-800 mb-1">Auto Background</h4>
              <p className="text-xs text-slate-600">Remove backgrounds instantly with AI</p>
            </div>
            
            <div className="bg-white rounded-xl p-4 shadow-sm border border-slate-200">
              <div className="w-10 h-10 bg-secondary/10 rounded-lg flex items-center justify-center mb-3">
                <i className="fas fa-magic text-secondary"></i>
              </div>
              <h4 className="font-medium text-slate-800 mb-1">AI Processing</h4>
              <p className="text-xs text-slate-600">Fast and accurate AI processing</p>
            </div>
            
            <div className="bg-white rounded-xl p-4 shadow-sm border border-slate-200">
              <div className="w-10 h-10 bg-accent/10 rounded-lg flex items-center justify-center mb-3">
                <i className="fas fa-lightning-bolt text-accent"></i>
              </div>
              <h4 className="font-medium text-slate-800 mb-1">Fast Processing</h4>
              <p className="text-xs text-slate-600">Get results in seconds</p>
            </div>
            
            <div className="bg-white rounded-xl p-4 shadow-sm border border-slate-200">
              <div className="w-10 h-10 bg-green-500/10 rounded-lg flex items-center justify-center mb-3">
                <i className="fas fa-shield-alt text-green-500"></i>
              </div>
              <h4 className="font-medium text-slate-800 mb-1">High Quality</h4>
              <p className="text-xs text-slate-600">Professional-grade results</p>
            </div>
          </div>
        </section>
      </main>

      <BottomNavigation />
    </div>
  );
}
