import { FC, ReactNode } from 'react';

interface TabPanelProps { children: ReactNode; active?: boolean; }
export const TabPanel: FC<TabPanelProps> = ({ children, active }) => 
  active ? <div>{children}</div> : null;
