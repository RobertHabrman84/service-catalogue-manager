import React from 'react';

export const TabList: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  return <div className="flex border-b border-gray-200 mb-4">{children}</div>;
};
