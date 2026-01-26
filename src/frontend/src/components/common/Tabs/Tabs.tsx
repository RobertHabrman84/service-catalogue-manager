import React, { createContext, useContext, useState } from 'react';

const TabsContext = createContext<{ activeTab: number; setActiveTab: (index: number) => void } | null>(null);

export const Tabs: React.FC<{ children: React.ReactNode; defaultTab?: number }> = ({ children, defaultTab = 0 }) => {
  const [activeTab, setActiveTab] = useState(defaultTab);

  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="w-full">{children}</div>
    </TabsContext.Provider>
  );
};
