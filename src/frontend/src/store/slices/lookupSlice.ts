import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import type { AllLookups } from '@types/lookups';

interface LookupState {
  data: AllLookups | null;
  isLoading: boolean;
  error: string | null;
  lastFetched: number | null;
}

const initialState: LookupState = {
  data: null,
  isLoading: false,
  error: null,
  lastFetched: null,
};

const lookupSlice = createSlice({
  name: 'lookup',
  initialState,
  reducers: {
    setLookups: (state, action: PayloadAction<AllLookups>) => {
      state.data = action.payload;
      state.lastFetched = Date.now();
      state.isLoading = false;
      state.error = null;
    },
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload;
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload;
      state.isLoading = false;
    },
  },
});

export const { setLookups, setLoading, setError } = lookupSlice.actions;
export default lookupSlice.reducer;
