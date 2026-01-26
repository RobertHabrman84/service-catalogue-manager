import { NavLink } from "react-router-dom";
import { LayoutDashboard, FileText, Upload, Download, Settings, PlusCircle } from "lucide-react";
import { useAppSelector } from "@store/store";

const navItems = [
  { to: "/dashboard", icon: LayoutDashboard, label: "Dashboard" },
  { to: "/catalog", icon: FileText, label: "Catalog" },
  { to: "/services/new", icon: PlusCircle, label: "Create Service" },
  { to: "/import", icon: Upload, label: "Import" },
  { to: "/export", icon: Download, label: "Export" },
  { to: "/settings", icon: Settings, label: "Settings" },
];

export const Sidebar = () => {
  const { sidebarOpen } = useAppSelector((state) => state.ui);
  
  return (
    <aside className={`fixed left-0 top-16 h-[calc(100vh-4rem)] bg-white border-r border-gray-200 transition-all duration-300 ${sidebarOpen ? "w-64" : "w-16"}`}>
      <nav className="p-4 space-y-2">
        {navItems.map(({ to, icon: Icon, label }) => (
          <NavLink 
            key={to} 
            to={to} 
            className={({ isActive }) => 
              `flex items-center gap-3 px-3 py-2 rounded-lg transition-colors ${
                isActive 
                  ? "bg-primary-100 text-primary-700" 
                  : "text-gray-600 hover:bg-gray-100"
              }`
            }
          >
            <Icon className="w-5 h-5 flex-shrink-0" />
            {sidebarOpen && <span>{label}</span>}
          </NavLink>
        ))}
      </nav>
    </aside>
  );
};

export default Sidebar;
