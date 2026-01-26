import { Menu, Bell, Search, User } from "lucide-react";
import { useAppDispatch } from "@store/store";
import { toggleSidebar } from "@store/slices/uiSlice";
export const Header = () => {
  const dispatch = useAppDispatch();
  return (
    <header className="bg-white border-b border-gray-200 sticky top-0 z-40">
      <div className="flex items-center justify-between px-4 py-3">
        <div className="flex items-center gap-4">
          <button onClick={() => dispatch(toggleSidebar())} className="p-2 hover:bg-gray-100 rounded-lg">
            <Menu className="w-5 h-5" />
          </button>
          <h1 className="text-xl font-semibold text-primary-600">Service Catalogue Manager</h1>
        </div>
        <div className="flex items-center gap-4">
          <button className="p-2 hover:bg-gray-100 rounded-lg"><Search className="w-5 h-5" /></button>
          <button className="p-2 hover:bg-gray-100 rounded-lg"><Bell className="w-5 h-5" /></button>
          <button className="p-2 hover:bg-gray-100 rounded-lg"><User className="w-5 h-5" /></button>
        </div>
      </div>
    </header>
  );
};
export default Header;
