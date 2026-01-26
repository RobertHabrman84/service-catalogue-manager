import { FC, ReactNode } from 'react';
import { NavLink } from 'react-router-dom';

interface SidebarItemProps {
  to: string;
  icon?: ReactNode;
  children: ReactNode;
}

export const SidebarItem: FC<SidebarItemProps> = ({ to, icon, children }) => {
  return (
    <NavLink 
      to={to} 
      className={({ isActive }) => `sidebar-item ${isActive ? 'active' : ''}`}
    >
      {icon && <span className="icon">{icon}</span>}
      <span className="label">{children}</span>
    </NavLink>
  );
};
