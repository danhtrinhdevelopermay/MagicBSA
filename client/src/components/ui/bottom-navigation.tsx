import { Home, History, Star, User } from "lucide-react";

export default function BottomNavigation() {
  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-slate-200 shadow-lg">
      <div className="max-w-md mx-auto px-4 py-2">
        <div className="flex items-center justify-around">
          <button className="flex flex-col items-center py-2 px-3 text-primary">
            <Home size={20} className="mb-1" />
            <span className="text-xs font-medium">Home</span>
          </button>
          
          <button className="flex flex-col items-center py-2 px-3 text-slate-400">
            <History size={20} className="mb-1" />
            <span className="text-xs">History</span>
          </button>
          
          <button className="flex flex-col items-center py-2 px-3 text-slate-400">
            <Star size={20} className="mb-1" />
            <span className="text-xs">Premium</span>
          </button>
          
          <button className="flex flex-col items-center py-2 px-3 text-slate-400">
            <User size={20} className="mb-1" />
            <span className="text-xs">Profile</span>
          </button>
        </div>
      </div>
    </nav>
  );
}
