// Tabs/index.tsx
// Tabs component with different styles

import React, { createContext, useContext, useState, useCallback, useMemo } from 'react';
import clsx from 'clsx';

// Context
interface TabsContextType {
  activeTab: string;
  setActiveTab: (id: string) => void;
  variant: TabsVariant;
}

const TabsContext = createContext<TabsContextType | null>(null);

const useTabsContext = () => {
  const context = useContext(TabsContext);
  if (!context) {
    throw new Error('Tab components must be used within a Tabs component');
  }
  return context;
};

// Types
type TabsVariant = 'underline' | 'pills' | 'boxed' | 'buttons';
type TabsSize = 'sm' | 'md' | 'lg';

interface TabItem {
  id: string;
  label: string;
  icon?: React.ReactNode;
  badge?: string | number;
  disabled?: boolean;
}

// Main Tabs Component
interface TabsProps {
  defaultTab?: string;
  activeTab?: string;
  onChange?: (tabId: string) => void;
  variant?: TabsVariant;
  children: React.ReactNode;
}

export const Tabs: React.FC<TabsProps> = ({
  defaultTab,
  activeTab: controlledActiveTab,
  onChange,
  variant = 'underline',
  children,
}) => {
  const [internalActiveTab, setInternalActiveTab] = useState(defaultTab || '');
  const isControlled = controlledActiveTab !== undefined;
  const activeTab = isControlled ? controlledActiveTab : internalActiveTab;

  const setActiveTab = useCallback((tabId: string) => {
    if (!isControlled) setInternalActiveTab(tabId);
    onChange?.(tabId);
  }, [isControlled, onChange]);

  const contextValue = useMemo(() => ({ activeTab, setActiveTab, variant }), [activeTab, setActiveTab, variant]);

  return (
    <TabsContext.Provider value={contextValue}>
      <div className="w-full">{children}</div>
    </TabsContext.Provider>
  );
};

// Tab List
interface TabListProps {
  tabs: TabItem[];
  size?: TabsSize;
  fullWidth?: boolean;
  className?: string;
}

const SIZE_CLASSES: Record<TabsSize, string> = {
  sm: 'text-sm px-3 py-1.5',
  md: 'text-sm px-4 py-2',
  lg: 'text-base px-5 py-2.5',
};

export const TabList: React.FC<TabListProps> = ({ tabs, size = 'md', fullWidth = false, className }) => {
  const { activeTab, setActiveTab, variant } = useTabsContext();

  const getTabStyles = (isActive: boolean, isDisabled: boolean) => {
    const base = clsx('inline-flex items-center gap-2 font-medium transition-colors', SIZE_CLASSES[size], isDisabled && 'opacity-50 cursor-not-allowed');
    switch (variant) {
      case 'underline': return clsx(base, 'border-b-2', isActive ? 'border-blue-500 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700');
      case 'pills': return clsx(base, 'rounded-full', isActive ? 'bg-blue-100 text-blue-700' : 'text-gray-500 hover:bg-gray-100');
      case 'boxed': return clsx(base, 'rounded-md', isActive ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-500');
      case 'buttons': return clsx(base, 'rounded-md border', isActive ? 'bg-blue-600 text-white border-blue-600' : 'bg-white text-gray-700 border-gray-300');
      default: return base;
    }
  };

  return (
    <nav className={clsx('flex', variant === 'underline' && 'border-b border-gray-200', variant === 'boxed' && 'bg-gray-100 p-1 rounded-lg', className)} aria-label="Tabs">
      {tabs.map((tab) => (
        <button
          key={tab.id}
          type="button"
          role="tab"
          aria-selected={activeTab === tab.id}
          disabled={tab.disabled}
          onClick={() => !tab.disabled && setActiveTab(tab.id)}
          className={clsx(getTabStyles(activeTab === tab.id, !!tab.disabled), fullWidth && 'flex-1 justify-center')}
        >
          {tab.icon}
          <span>{tab.label}</span>
          {tab.badge !== undefined && (
            <span className={clsx('ml-2 rounded-full px-2 py-0.5 text-xs font-medium', activeTab === tab.id ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-600')}>
              {tab.badge}
            </span>
          )}
        </button>
      ))}
    </nav>
  );
};

// Tab Panel
interface TabPanelProps {
  id: string;
  children: React.ReactNode;
  className?: string;
}

export const TabPanel: React.FC<TabPanelProps> = ({ id, children, className }) => {
  const { activeTab } = useTabsContext();
  if (activeTab !== id) return null;
  return <div id={`tabpanel-${id}`} role="tabpanel" className={clsx('mt-4', className)}>{children}</div>;
};

// Tab Panels Container
export const TabPanels: React.FC<{ children: React.ReactNode; className?: string }> = ({ children, className }) => (
  <div className={className}>{children}</div>
);

// Simple Tabs (all-in-one)
interface SimpleTabsProps {
  tabs: Array<TabItem & { content: React.ReactNode }>;
  defaultTab?: string;
  variant?: TabsVariant;
  size?: TabsSize;
  fullWidth?: boolean;
  className?: string;
}

export const SimpleTabs: React.FC<SimpleTabsProps> = ({ tabs, defaultTab, variant = 'underline', size = 'md', fullWidth = false, className }) => {
  const [activeTab, setActiveTab] = useState(defaultTab || tabs[0]?.id || '');
  return (
    <Tabs activeTab={activeTab} onChange={setActiveTab} variant={variant}>
      <TabList tabs={tabs} size={size} fullWidth={fullWidth} className={className} />
      <TabPanels>
        {tabs.map((tab) => <TabPanel key={tab.id} id={tab.id}>{tab.content}</TabPanel>)}
      </TabPanels>
    </Tabs>
  );
};

export default Tabs;
