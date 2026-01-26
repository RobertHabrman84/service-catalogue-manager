import React from 'react';
import { EmptyState } from '../EmptyState/EmptyState';

export const NoSearchResults: React.FC = () => {
  return <EmptyState title="No results found" message="Try adjusting your search criteria" />;
};
