// pages/Settings/index.tsx
// Application settings page

import React, { useState } from 'react';
import {
  UserCircleIcon,
  BellIcon,
  PaintBrushIcon,
  CloudIcon,
  ShieldCheckIcon,
} from '@heroicons/react/24/outline';
import { Badge } from '../../components/common';
import { PageHeader } from '../../components/common/Breadcrumb';
import { authService } from '../../services/auth';
import clsx from 'clsx';

// Settings section wrapper
interface SettingsSectionProps {
  title: string;
  description?: string;
  children: React.ReactNode;
}

const SettingsSection: React.FC<SettingsSectionProps> = ({ title, description, children }) => (
  <div className="bg-white rounded-xl border border-gray-200 p-6">
    <div className="mb-6">
      <h3 className="text-lg font-semibold text-gray-900">{title}</h3>
      {description && <p className="text-sm text-gray-500 mt-1">{description}</p>}
    </div>
    {children}
  </div>
);

// Setting row component
interface SettingRowProps {
  label: string;
  description?: string;
  children: React.ReactNode;
}

const SettingRow: React.FC<SettingRowProps> = ({ label, description, children }) => (
  <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between py-4 border-b border-gray-100 last:border-0">
    <div className="mb-2 sm:mb-0">
      <p className="font-medium text-gray-900">{label}</p>
      {description && <p className="text-sm text-gray-500">{description}</p>}
    </div>
    <div className="flex-shrink-0">{children}</div>
  </div>
);

// Toggle switch component
interface ToggleSwitchProps {
  enabled: boolean;
  onChange: (enabled: boolean) => void;
}

const ToggleSwitch: React.FC<ToggleSwitchProps> = ({ enabled, onChange }) => (
  <button
    type="button"
    onClick={() => onChange(!enabled)}
    className={clsx(
      'relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors',
      enabled ? 'bg-blue-600' : 'bg-gray-200'
    )}
  >
    <span className={clsx(
      'pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow transition',
      enabled ? 'translate-x-5' : 'translate-x-0'
    )} />
  </button>
);

// Profile Tab
const ProfileTab: React.FC = () => {
  const user = authService.getCurrentUser();
  return (
    <SettingsSection title="Profile Information" description="Your account information from Azure AD">
      <div className="flex items-center gap-4 p-4 bg-gray-50 rounded-lg mb-4">
        <div className="w-16 h-16 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 text-2xl font-bold">
          {user?.displayName?.charAt(0) || 'U'}
        </div>
        <div>
          <h4 className="font-semibold text-gray-900">{user?.displayName || 'User'}</h4>
          <p className="text-sm text-gray-500">{user?.email}</p>
        </div>
      </div>
      <SettingRow label="Display Name">{user?.displayName || '-'}</SettingRow>
      <SettingRow label="Email Address">{user?.email || '-'}</SettingRow>
      <SettingRow label="User ID"><code className="text-xs bg-gray-100 px-2 py-1 rounded">{user?.id || '-'}</code></SettingRow>
    </SettingsSection>
  );
};

// Notifications Tab
const NotificationsTab: React.FC = () => {
  const [emailNotifications, setEmailNotifications] = useState(true);
  const [publishNotifications, setPublishNotifications] = useState(true);
  return (
    <SettingsSection title="Notification Preferences" description="Configure how you receive notifications">
      <SettingRow label="Email Notifications" description="Receive email notifications for important updates">
        <ToggleSwitch enabled={emailNotifications} onChange={setEmailNotifications} />
      </SettingRow>
      <SettingRow label="Publish Notifications" description="Get notified when services are published">
        <ToggleSwitch enabled={publishNotifications} onChange={setPublishNotifications} />
      </SettingRow>
    </SettingsSection>
  );
};

// Appearance Tab
const AppearanceTab: React.FC = () => {
  const [theme, setTheme] = useState<'light' | 'dark' | 'system'>('system');
  return (
    <SettingsSection title="Appearance" description="Customize the look and feel">
      <SettingRow label="Theme" description="Choose your preferred color scheme">
        <select value={theme} onChange={(e) => setTheme(e.target.value as any)} className="rounded-md border-gray-300 text-sm">
          <option value="light">Light</option>
          <option value="dark">Dark</option>
          <option value="system">System</option>
        </select>
      </SettingRow>
    </SettingsSection>
  );
};

// Integrations Tab
const IntegrationsTab: React.FC = () => {
  const [uuBookKitConnected, setUuBookKitConnected] = useState(false);
  return (
    <SettingsSection title="uuBookKit Integration" description="Connect to uuBookKit for documentation publishing">
      <div className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
        <div className="flex items-center gap-4">
          <div className="p-3 bg-white rounded-lg border border-gray-200">
            <CloudIcon className="w-6 h-6 text-blue-600" />
          </div>
          <div>
            <h4 className="font-medium text-gray-900">uuBookKit</h4>
            <p className="text-sm text-gray-500">{uuBookKitConnected ? 'Connected' : 'Not connected'}</p>
          </div>
        </div>
        <button
          onClick={() => setUuBookKitConnected(!uuBookKitConnected)}
          className={clsx(
            'px-4 py-2 rounded-lg text-sm font-medium',
            uuBookKitConnected ? 'bg-red-100 text-red-700' : 'bg-blue-600 text-white'
          )}
        >
          {uuBookKitConnected ? 'Disconnect' : 'Connect'}
        </button>
      </div>
    </SettingsSection>
  );
};

// Security Tab
const SecurityTab: React.FC = () => (
  <SettingsSection title="Security" description="Security settings and audit information">
    <SettingRow label="Authentication"><Badge variant="green">Azure AD</Badge></SettingRow>
    <SettingRow label="MFA Status"><Badge variant="green">Enabled</Badge></SettingRow>
    <SettingRow label="Last Login">{new Date().toLocaleString()}</SettingRow>
  </SettingsSection>
);

// Main Settings Page
export const SettingsPage: React.FC = () => {
  const [activeTab, setActiveTab] = useState('profile');

  const tabs = [
    { id: 'profile', label: 'Profile', icon: <UserCircleIcon className="w-4 h-4" /> },
    { id: 'notifications', label: 'Notifications', icon: <BellIcon className="w-4 h-4" /> },
    { id: 'appearance', label: 'Appearance', icon: <PaintBrushIcon className="w-4 h-4" /> },
    { id: 'integrations', label: 'Integrations', icon: <CloudIcon className="w-4 h-4" /> },
    { id: 'security', label: 'Security', icon: <ShieldCheckIcon className="w-4 h-4" /> },
  ];

  return (
    <div className="space-y-6">
      <PageHeader title="Settings" subtitle="Manage your account and application preferences" breadcrumbs={[{ label: 'Dashboard', href: '/' }, { label: 'Settings' }]} />
      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        <div className="lg:col-span-1">
          <nav className="bg-white rounded-xl border border-gray-200 p-2 space-y-1">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={clsx(
                  'w-full flex items-center gap-3 px-4 py-2.5 rounded-lg text-sm font-medium text-left',
                  activeTab === tab.id ? 'bg-blue-50 text-blue-700' : 'text-gray-600 hover:bg-gray-50'
                )}
              >
                {tab.icon}
                {tab.label}
              </button>
            ))}
          </nav>
        </div>
        <div className="lg:col-span-3">
          {activeTab === 'profile' && <ProfileTab />}
          {activeTab === 'notifications' && <NotificationsTab />}
          {activeTab === 'appearance' && <AppearanceTab />}
          {activeTab === 'integrations' && <IntegrationsTab />}
          {activeTab === 'security' && <SecurityTab />}
        </div>
      </div>
    </div>
  );
};

export default SettingsPage;
