import { describe, it, expect } from 'vitest';
import catalogReducer, {
  setServices,
  setSelectedService,
  setLoading,
  setError,
  setPagination,
  setFilters,
} from './catalogSlice';

describe('catalogSlice', () => {
  const initialState = {
    services: [],
    selectedService: null,
    isLoading: false,
    error: null,
    pagination: { page: 1, pageSize: 20, totalCount: 0, totalPages: 0 },
    filters: { searchTerm: '', categoryId: null, isActive: null },
  };

  it('returns initial state', () => {
    expect(catalogReducer(undefined, { type: 'unknown' })).toEqual(initialState);
  });

  it('handles setServices', () => {
    const services = [{ id: 1, name: 'Service 1' }];
    const state = catalogReducer(initialState, setServices(services as any));
    expect(state.services).toEqual(services);
  });

  it('handles setSelectedService', () => {
    const service = { id: 1, name: 'Service 1' };
    const state = catalogReducer(initialState, setSelectedService(service as any));
    expect(state.selectedService).toEqual(service);
  });

  it('handles setFilters', () => {
    const filters = { searchTerm: 'test', categoryId: 1, isActive: true };
    const state = catalogReducer(initialState, setFilters(filters));
    expect(state.filters).toEqual(filters);
  });

  it('handles setPagination', () => {
    const pagination = { page: 2, pageSize: 10, totalCount: 50, totalPages: 5 };
    const state = catalogReducer(initialState, setPagination(pagination));
    expect(state.pagination).toEqual(pagination);
  });
});
