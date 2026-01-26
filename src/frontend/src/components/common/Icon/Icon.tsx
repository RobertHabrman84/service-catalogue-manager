import { FC, SVGProps } from 'react';
import { icons, IconName } from './icons';

interface IconProps extends SVGProps<SVGSVGElement> { name: IconName; size?: number; }
export const Icon: FC<IconProps> = ({ name, size = 24, ...props }) => {
  const IconComponent = icons[name];
  return IconComponent ? <IconComponent width={size} height={size} {...props} /> : null;
};
