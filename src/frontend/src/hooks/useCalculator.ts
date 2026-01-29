import { useState, useCallback } from 'react';
import calculatorApi, { CalculatorConfigDto, ServiceMapDto } from '../services/api/calculatorApi';

export interface UseCalculatorResult {
  config: CalculatorConfigDto | null;
  loading: boolean;
  error: string | null;
  loadConfig: (serviceId: string | number) => Promise<void>;
}

export interface UseServiceMapResult {
  serviceMap: ServiceMapDto | null;
  loading: boolean;
  error: string | null;
  loadServiceMap: () => Promise<void>;
}

export const useCalculator = (): UseCalculatorResult => {
  const [config, setConfig] = useState<CalculatorConfigDto | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadConfig = useCallback(async (serviceId: string | number) => {
    setLoading(true);
    setError(null);
    try {
      const data = await calculatorApi.getCalculatorConfig(serviceId);
      setConfig(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load calculator config');
    } finally {
      setLoading(false);
    }
  }, []);

  return { config, loading, error, loadConfig };
};

export const useServiceMap = (): UseServiceMapResult => {
  const [serviceMap, setServiceMap] = useState<ServiceMapDto | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadServiceMap = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await calculatorApi.getServiceMap();
      setServiceMap(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load service map');
    } finally {
      setLoading(false);
    }
  }, []);

  return { serviceMap, loading, error, loadServiceMap };
};
