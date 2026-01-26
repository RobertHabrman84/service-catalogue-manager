import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { serviceApi, ServiceListParams } from '../../services/api';
import { ServiceCatalogItem, ServiceCatalogListItem, CreateServiceRequest, UpdateServiceRequest } from '../../types';

export interface ServiceState {
  list: ServiceCatalogListItem[];
  totalCount: number;
  page: number;
  pageSize: number;
  totalPages: number;
  currentService: ServiceCatalogItem | null;
  isLoading: boolean;
  isLoadingDetail: boolean;
  isSaving: boolean;
  error: string | null;
  filters: ServiceListParams;
}

const initialState: ServiceState = {
  list: [],
  totalCount: 0,
  page: 1,
  pageSize: 20,
  totalPages: 0,
  currentService: null,
  isLoading: false,
  isLoadingDetail: false,
  isSaving: false,
  error: null,
  filters: {},
};

// Async thunks
export const fetchServices = createAsyncThunk(
  'services/fetchList',
  async (params: ServiceListParams = {}, { rejectWithValue }) => {
    try {
      const response = await serviceApi.getList(params);
      return response.data;
    } catch (error) {
      return rejectWithValue((error as Error).message || 'Failed to fetch services');
    }
  }
);

export const fetchServiceById = createAsyncThunk(
  'services/fetchById',
  async (id: number, { rejectWithValue }) => {
    try {
      const response = await serviceApi.getById(id);
      return response.data;
    } catch (error) {
      return rejectWithValue((error as Error).message || 'Failed to fetch service');
    }
  }
);

export const createService = createAsyncThunk(
  'services/create',
  async (data: CreateServiceRequest, { rejectWithValue }) => {
    try {
      const response = await serviceApi.create(data);
      return response.data;
    } catch (error) {
      return rejectWithValue((error as Error).message || 'Failed to create service');
    }
  }
);

export const updateService = createAsyncThunk(
  'services/update',
  async ({ id, data }: { id: number; data: UpdateServiceRequest }, { rejectWithValue }) => {
    try {
      const response = await serviceApi.update(id, data);
      return response.data;
    } catch (error) {
      return rejectWithValue((error as Error).message || 'Failed to update service');
    }
  }
);

export const deleteService = createAsyncThunk(
  'services/delete',
  async (id: number, { rejectWithValue }) => {
    try {
      await serviceApi.delete(id);
      return id;
    } catch (error) {
      return rejectWithValue((error as Error).message || 'Failed to delete service');
    }
  }
);

export const duplicateService = createAsyncThunk(
  'services/duplicate',
  async (id: number, { rejectWithValue }) => {
    try {
      const response = await serviceApi.duplicate(id);
      return response.data;
    } catch (error) {
      return rejectWithValue((error as Error).message || 'Failed to duplicate service');
    }
  }
);

export const bulkDeleteServices = createAsyncThunk(
  'services/bulkDelete',
  async (serviceIds: number[], { rejectWithValue }) => {
    try {
      const response = await serviceApi.bulkDelete(serviceIds);
      return response.data;
    } catch (error) {
      return rejectWithValue((error as Error).message || 'Failed to delete services');
    }
  }
);

const serviceSlice = createSlice({
  name: 'services',
  initialState,
  reducers: {
    setFilters: (state, action: PayloadAction<ServiceListParams>) => {
      state.filters = { ...state.filters, ...action.payload };
    },
    clearFilters: (state) => {
      state.filters = {};
    },
    setPage: (state, action: PayloadAction<number>) => {
      state.page = action.payload;
    },
    setPageSize: (state, action: PayloadAction<number>) => {
      state.pageSize = action.payload;
      state.page = 1;
    },
    clearCurrentService: (state) => {
      state.currentService = null;
    },
    clearError: (state) => {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      // Fetch list
      .addCase(fetchServices.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(fetchServices.fulfilled, (state, action) => {
        state.isLoading = false;
        state.list = action.payload.items as unknown as ServiceCatalogListItem[];
        state.totalCount = action.payload.totalCount;
        state.page = action.payload.page;
        state.pageSize = action.payload.pageSize;
        state.totalPages = action.payload.totalPages;
      })
      .addCase(fetchServices.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      })
      // Fetch by ID
      .addCase(fetchServiceById.pending, (state) => {
        state.isLoadingDetail = true;
        state.error = null;
      })
      .addCase(fetchServiceById.fulfilled, (state, action) => {
        state.isLoadingDetail = false;
        state.currentService = action.payload;
      })
      .addCase(fetchServiceById.rejected, (state, action) => {
        state.isLoadingDetail = false;
        state.error = action.payload as string;
      })
      // Create
      .addCase(createService.pending, (state) => {
        state.isSaving = true;
        state.error = null;
      })
      .addCase(createService.fulfilled, (state, action) => {
        state.isSaving = false;
        state.currentService = action.payload;
      })
      .addCase(createService.rejected, (state, action) => {
        state.isSaving = false;
        state.error = action.payload as string;
      })
      // Update
      .addCase(updateService.pending, (state) => {
        state.isSaving = true;
        state.error = null;
      })
      .addCase(updateService.fulfilled, (state, action) => {
        state.isSaving = false;
        state.currentService = action.payload;
        // Update item in list if present
        const index = state.list.findIndex(s => s.serviceId === action.payload.serviceId);
        if (index !== -1) {
          state.list[index] = {
            ...state.list[index],
            serviceName: action.payload.serviceName,
            description: action.payload.description,
            isActive: action.payload.isActive,
            isPublished: action.payload.isPublished,
          };
        }
      })
      .addCase(updateService.rejected, (state, action) => {
        state.isSaving = false;
        state.error = action.payload as string;
      })
      // Delete
      .addCase(deleteService.fulfilled, (state, action) => {
        state.list = state.list.filter(s => s.serviceId !== action.payload);
        state.totalCount -= 1;
        if (state.currentService?.serviceId === action.payload) {
          state.currentService = null;
        }
      })
      // Duplicate
      .addCase(duplicateService.fulfilled, (state, action) => {
        state.currentService = action.payload;
      })
      // Bulk delete
      .addCase(bulkDeleteServices.fulfilled, (state, action) => {
        const deletedIds = action.meta.arg;
        state.list = state.list.filter(s => !deletedIds.includes(s.serviceId));
        state.totalCount -= action.payload.deletedCount;
      });
  },
});

export const {
  setFilters,
  clearFilters,
  setPage,
  setPageSize,
  clearCurrentService,
  clearError,
} = serviceSlice.actions;

// Selectors
export const selectServiceList = (state: { services: ServiceState }) => state.services.list;
export const selectCurrentService = (state: { services: ServiceState }) => state.services.currentService;
export const selectServicePagination = (state: { services: ServiceState }) => ({
  page: state.services.page,
  pageSize: state.services.pageSize,
  totalCount: state.services.totalCount,
  totalPages: state.services.totalPages,
});
export const selectServiceFilters = (state: { services: ServiceState }) => state.services.filters;
export const selectServiceIsLoading = (state: { services: ServiceState }) => state.services.isLoading;
export const selectServiceIsSaving = (state: { services: ServiceState }) => state.services.isSaving;
export const selectServiceError = (state: { services: ServiceState }) => state.services.error;

export default serviceSlice.reducer;
