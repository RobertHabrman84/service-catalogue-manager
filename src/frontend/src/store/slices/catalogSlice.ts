import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import type { ServiceCatalogItem, ServiceCatalogListItem } from '@types/models/ServiceCatalogItem';

interface CatalogFilters {
  searchTerm: string;
  categoryId: number | null;
  isActive: boolean | null;
  sortBy: string;
  sortDescending: boolean;
}

interface CatalogState {
  items: ServiceCatalogListItem[];
  selectedItem: ServiceCatalogItem | null;
  filters: CatalogFilters;
  pagination: {
    page: number;
    pageSize: number;
    totalCount: number;
    totalPages: number;
  };
  isLoading: boolean;
  error: string | null;
}

const initialState: CatalogState = {
  items: [],
  selectedItem: null,
  filters: {
    searchTerm: '',
    categoryId: null,
    isActive: true,
    sortBy: 'modified',
    sortDescending: true,
  },
  pagination: {
    page: 1,
    pageSize: 20,
    totalCount: 0,
    totalPages: 0,
  },
  isLoading: false,
  error: null,
};

const catalogSlice = createSlice({
  name: 'catalog',
  initialState,
  reducers: {
    setItems: (state, action: PayloadAction<ServiceCatalogListItem[]>) => {
      state.items = action.payload;
    },
    setSelectedItem: (state, action: PayloadAction<ServiceCatalogItem | null>) => {
      state.selectedItem = action.payload;
    },
    setFilters: (state, action: PayloadAction<Partial<CatalogFilters>>) => {
      state.filters = { ...state.filters, ...action.payload };
      state.pagination.page = 1; // Reset to first page on filter change
    },
    setPagination: (state, action: PayloadAction<Partial<CatalogState['pagination']>>) => {
      state.pagination = { ...state.pagination, ...action.payload };
    },
    setPage: (state, action: PayloadAction<number>) => {
      state.pagination.page = action.payload;
    },
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload;
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload;
      state.isLoading = false;
    },
    clearFilters: (state) => {
      state.filters = initialState.filters;
      state.pagination.page = 1;
    },
  },
});

export const {
  setItems,
  setSelectedItem,
  setFilters,
  setPagination,
  setPage,
  setLoading,
  setError,
  clearFilters,
} = catalogSlice.actions;

export default catalogSlice.reducer;
