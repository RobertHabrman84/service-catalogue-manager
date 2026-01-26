import { useEffect, useCallback } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { RootState, AppDispatch } from '../store/store';
import { fetchAllLookups, selectLookupState } from '../store/slices/lookupSlice';

export interface LookupItem {
  id: number;
  name: string;
  code?: string;
  description?: string;
  isActive?: boolean;
  sortOrder?: number;
}

export interface ServiceCategory extends LookupItem {
  parentId?: number | null;
  children?: ServiceCategory[];
}

export interface SizeOption extends LookupItem {
  abbreviation: string;
}

export interface CloudProvider extends LookupItem {
  logoUrl?: string;
}

export interface UseLookupDataResult {
  categories: ServiceCategory[];
  sizeOptions: SizeOption[];
  cloudProviders: CloudProvider[];
  dependencyTypes: LookupItem[];
  prerequisiteCategories: LookupItem[];
  licenseTypes: LookupItem[];
  toolCategories: LookupItem[];
  scopeTypes: LookupItem[];
  interactionLevels: LookupItem[];
  requirementLevels: LookupItem[];
  roles: LookupItem[];
  isLoading: boolean;
  isLoaded: boolean;
  error: string | null;
  refresh: () => Promise<void>;
  getCategoryById: (id: number) => ServiceCategory | undefined;
  getSizeOptionById: (id: number) => SizeOption | undefined;
  getRoleById: (id: number) => LookupItem | undefined;
}

export const useLookupData = (): UseLookupDataResult => {
  const dispatch = useDispatch<AppDispatch>();
  const lookupState = useSelector(selectLookupState);

  const {
    categories,
    sizeOptions,
    cloudProviders,
    dependencyTypes,
    prerequisiteCategories,
    licenseTypes,
    toolCategories,
    scopeTypes,
    interactionLevels,
    requirementLevels,
    roles,
    isLoading,
    isLoaded,
    error,
  } = lookupState;

  const refresh = useCallback(async () => {
    await dispatch(fetchAllLookups());
  }, [dispatch]);

  const getCategoryById = useCallback(
    (id: number): ServiceCategory | undefined => {
      const findCategory = (cats: ServiceCategory[]): ServiceCategory | undefined => {
        for (const cat of cats) {
          if (cat.id === id) return cat;
          if (cat.children) {
            const found = findCategory(cat.children);
            if (found) return found;
          }
        }
        return undefined;
      };
      return findCategory(categories);
    },
    [categories]
  );

  const getSizeOptionById = useCallback(
    (id: number): SizeOption | undefined => {
      return sizeOptions.find((s) => s.id === id);
    },
    [sizeOptions]
  );

  const getRoleById = useCallback(
    (id: number): LookupItem | undefined => {
      return roles.find((r) => r.id === id);
    },
    [roles]
  );

  // Load lookups on mount if not already loaded
  useEffect(() => {
    if (!isLoaded && !isLoading) {
      refresh();
    }
  }, [isLoaded, isLoading, refresh]);

  return {
    categories,
    sizeOptions,
    cloudProviders,
    dependencyTypes,
    prerequisiteCategories,
    licenseTypes,
    toolCategories,
    scopeTypes,
    interactionLevels,
    requirementLevels,
    roles,
    isLoading,
    isLoaded,
    error,
    refresh,
    getCategoryById,
    getSizeOptionById,
    getRoleById,
  };
};

export default useLookupData;
