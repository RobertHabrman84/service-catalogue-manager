import React from 'react';
import { Badge } from '../Badge/Badge';

export interface StatusBadgeProps {
  status: string;
}

export const StatusBadge: React.FC<StatusBadgeProps> = ({ status }) => {
  const variant = status.toLowerCase() === 'active' ? 'success' : 'default';
  return <Badge variant={variant}>{status}</Badge>;
};
