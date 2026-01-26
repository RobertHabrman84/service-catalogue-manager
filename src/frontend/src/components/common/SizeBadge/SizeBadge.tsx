import React from 'react';
import { Badge } from '../Badge/Badge';

export interface SizeBadgeProps {
  size: string;
}

export const SizeBadge: React.FC<SizeBadgeProps> = ({ size }) => {
  return <Badge variant="info">{size}</Badge>;
};
