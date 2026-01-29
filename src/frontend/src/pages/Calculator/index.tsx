import React, { useEffect, useState } from 'react';
import { useParams, useSearchParams, useNavigate } from 'react-router-dom';
import { ServiceCalculator } from '../../components/Calculator';
import { useCalculator } from '../../hooks/useCalculator';
import { LoadingSpinner } from '../../components/common/LoadingSpinner';

const CalculatorPage: React.FC = () => {
  const { serviceId } = useParams<{ serviceId?: string }>();
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const { config, loading, error, loadConfig } = useCalculator();
  const [availableServices, setAvailableServices] = useState<Array<{ id: string; name: string }>>([]);
  const [loadingServices, setLoadingServices] = useState(true);

  // Load available services for selector
  useEffect(() => {
    const fetchServices = async () => {
      try {
        const response = await fetch('/api/services');
        if (response.ok) {
          const data = await response.json();
          setAvailableServices(data.map((s: any) => ({ id: s.id, name: s.name })));
        }
      } catch (err) {
        console.error('Failed to load services:', err);
      } finally {
        setLoadingServices(false);
      }
    };
    fetchServices();
  }, []);

  // Load calculator config when serviceId changes
  useEffect(() => {
    const id = serviceId || searchParams.get('serviceId');
    if (id) {
      loadConfig(id);
    }
  }, [serviceId, searchParams, loadConfig]);

  const handleServiceChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const newServiceId = e.target.value;
    if (newServiceId) {
      navigate(`/calculator/${newServiceId}`);
    }
  };

  const currentServiceId = serviceId || searchParams.get('serviceId');

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200 px-6 py-4">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Service Calculator</h1>
            <p className="text-sm text-gray-500 mt-1">
              Calculate effort, duration, and pricing for services
            </p>
          </div>
          
          {/* Service Selector */}
          <div className="flex items-center gap-4">
            <label htmlFor="service-select" className="text-sm font-medium text-gray-700">
              Select Service:
            </label>
            {loadingServices ? (
              <LoadingSpinner size="sm" />
            ) : (
              <select
                id="service-select"
                value={currentServiceId || ''}
                onChange={handleServiceChange}
                className="block w-64 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm"
              >
                <option value="">-- Select a service --</option>
                {availableServices.map((service) => (
                  <option key={service.id} value={service.id}>
                    {service.name}
                  </option>
                ))}
              </select>
            )}
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="p-6">
        {loading && (
          <div className="flex items-center justify-center py-20">
            <LoadingSpinner size="lg" />
            <span className="ml-3 text-gray-600">Loading calculator configuration...</span>
          </div>
        )}

        {error && (
          <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
            <div className="flex items-center">
              <svg className="w-5 h-5 text-red-400 mr-2" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
              </svg>
              <span className="text-red-800">{error}</span>
            </div>
          </div>
        )}

        {!loading && !error && !currentServiceId && (
          <div className="text-center py-20">
            <svg className="mx-auto h-16 w-16 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
            </svg>
            <h3 className="mt-4 text-lg font-medium text-gray-900">No Service Selected</h3>
            <p className="mt-2 text-gray-500">
              Select a service from the dropdown above to load the calculator configuration.
            </p>
          </div>
        )}

        {!loading && !error && config && (
          <ServiceCalculator 
            config={config} 
            logoUrl="/logo.png"
          />
        )}
      </div>
    </div>
  );
};

export default CalculatorPage;
