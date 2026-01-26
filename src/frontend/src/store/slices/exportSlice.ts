import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { exportApi, ExportRequest, ExportStatusResponse, ExportHistoryItem } from '../../services/api';

export type ExportStatus = 'idle' | 'pending' | 'processing' | 'completed' | 'failed' | 'cancelled';

export interface ExportOperation {
  operationId: string;
  status: ExportStatus;
  format: 'pdf' | 'markdown';
  progress: number;
  message?: string;
  downloadUrl?: string;
  fileName?: string;
  fileSize?: number;
  startedAt: string;
  completedAt?: string;
  error?: string;
}

export interface ExportState {
  currentOperation: ExportOperation | null;
  history: ExportHistoryItem[];
  historyTotalCount: number;
  isLoading: boolean;
  isLoadingHistory: boolean;
  error: string | null;
}

const initialState: ExportState = {
  currentOperation: null,
  history: [],
  historyTotalCount: 0,
  isLoading: false,
  isLoadingHistory: false,
  error: null,
};

// Async thunks
export const startExport = createAsyncThunk(
  'export/start',
  async (request: ExportRequest, { rejectWithValue }) => {
    try {
      const response = await exportApi.export(request);
      return {
        operationId: response.data.operationId,
        status: response.data.status as ExportStatus,
        format: request.format,
        startedAt: response.data.createdAt,
      };
    } catch (error) {
      return rejectWithValue((error as Error).message || 'Failed to start export');
    }
  }
);

export const checkExportStatus = createAsyncThunk(
  'export/checkStatus',
  async ({ operationId, format }: { operationId: string; format: 'pdf' | 'markdown' }, { rejectWithValue }) => {
    try {
      const response = await exportApi.getStatus(operationId, format);
      return response.data;
    } catch (error) {
      return rejectWithValue((error as Error).message || 'Failed to check export status');
    }
  }
);

export const loadExportHistory = createAsyncThunk(
  'export/loadHistory',
  async (params: { page?: number; pageSize?: number } = {}, { rejectWithValue }) => {
    try {
      const response = await exportApi.getHistory(params);
      return response.data;
    } catch (error) {
      return rejectWithValue((error as Error).message || 'Failed to load export history');
    }
  }
);

export const cancelExport = createAsyncThunk(
  'export/cancel',
  async (operationId: string, { rejectWithValue }) => {
    try {
      await exportApi.cancel(operationId);
      return operationId;
    } catch (error) {
      return rejectWithValue((error as Error).message || 'Failed to cancel export');
    }
  }
);

const exportSlice = createSlice({
  name: 'export',
  initialState,
  reducers: {
    clearCurrentOperation: (state) => {
      state.currentOperation = null;
      state.error = null;
    },
    updateProgress: (state, action: PayloadAction<{ progress: number; message?: string }>) => {
      if (state.currentOperation) {
        state.currentOperation.progress = action.payload.progress;
        if (action.payload.message) {
          state.currentOperation.message = action.payload.message;
        }
      }
    },
    clearError: (state) => {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      // Start export
      .addCase(startExport.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(startExport.fulfilled, (state, action) => {
        state.isLoading = false;
        state.currentOperation = {
          operationId: action.payload.operationId,
          status: action.payload.status,
          format: action.payload.format,
          progress: 0,
          startedAt: action.payload.startedAt,
        };
      })
      .addCase(startExport.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      })
      // Check status
      .addCase(checkExportStatus.fulfilled, (state, action) => {
        if (state.currentOperation) {
          const statusData = action.payload as ExportStatusResponse;
          state.currentOperation.status = statusData.status as ExportStatus;
          state.currentOperation.progress = statusData.progress;
          state.currentOperation.message = statusData.message;
          state.currentOperation.downloadUrl = statusData.downloadUrl;
          state.currentOperation.fileName = statusData.fileName;
          state.currentOperation.fileSize = statusData.fileSize;
          state.currentOperation.completedAt = statusData.completedAt;
          state.currentOperation.error = statusData.error;
        }
      })
      // Load history
      .addCase(loadExportHistory.pending, (state) => {
        state.isLoadingHistory = true;
      })
      .addCase(loadExportHistory.fulfilled, (state, action) => {
        state.isLoadingHistory = false;
        state.history = action.payload.items;
        state.historyTotalCount = action.payload.totalCount;
      })
      .addCase(loadExportHistory.rejected, (state, action) => {
        state.isLoadingHistory = false;
        state.error = action.payload as string;
      })
      // Cancel export
      .addCase(cancelExport.fulfilled, (state) => {
        if (state.currentOperation) {
          state.currentOperation.status = 'cancelled';
        }
      });
  },
});

export const { clearCurrentOperation, updateProgress, clearError } = exportSlice.actions;

// Selectors
export const selectCurrentExportOperation = (state: { export: ExportState }) => state.export.currentOperation;
export const selectExportHistory = (state: { export: ExportState }) => state.export.history;
export const selectExportIsLoading = (state: { export: ExportState }) => state.export.isLoading;
export const selectExportError = (state: { export: ExportState }) => state.export.error;

export default exportSlice.reducer;
