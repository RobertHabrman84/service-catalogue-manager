import { FC, SVGProps } from 'react';

export type IconName = 'home' | 'settings' | 'user' | 'search' | 'plus' | 'edit' | 'trash' | 'download' | 'upload' | 'check' | 'x' | 'chevronDown' | 'chevronUp' | 'chevronLeft' | 'chevronRight';

const createIcon = (path: string): FC<SVGProps<SVGSVGElement>> => (props) => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" {...props}>
    <path d={path} />
  </svg>
);

export const icons: Record<IconName, FC<SVGProps<SVGSVGElement>>> = {
  home: createIcon('M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z'),
  settings: createIcon('M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z'),
  user: createIcon('M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2'),
  search: createIcon('M21 21l-6-6m2-5a7 7 0 1 1-14 0 7 7 0 0 1 14 0z'),
  plus: createIcon('M12 5v14M5 12h14'),
  edit: createIcon('M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7'),
  trash: createIcon('M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2'),
  download: createIcon('M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3'),
  upload: createIcon('M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M17 8l-5-5-5 5M12 3v12'),
  check: createIcon('M20 6L9 17l-5-5'),
  x: createIcon('M18 6L6 18M6 6l12 12'),
  chevronDown: createIcon('M6 9l6 6 6-6'),
  chevronUp: createIcon('M18 15l-6-6-6 6'),
  chevronLeft: createIcon('M15 18l-6-6 6-6'),
  chevronRight: createIcon('M9 18l6-6-6-6'),
};
