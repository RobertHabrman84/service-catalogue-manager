import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { ServiceMap } from '../../components/ServiceMap';
import { useServiceMap } from '../../hooks/useCalculator';
import { LoadingSpinner } from '../../components/common/LoadingSpinner';

const ServiceMapPage: React.FC = () => {
  const navigate = useNavigate();
  const { serviceMap, loading, error, loadServiceMap } = useServiceMap();

  useEffect(() => {
    loadServiceMap();
  }, [loadServiceMap]);

  const handleServiceClick = (serviceId: string) => {
    // Navigate to calculator with selected service
    navigate(`/calculator/${serviceId}`);
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200 px-6 py-4">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Service Map</h1>
            <p className="text-sm text-gray-500 mt-1">
              Interactive visualization of service dependencies and relationships
            </p>
          </div>
          
          {/* Actions */}
          <div className="flex items-center gap-3">
            <button
              onClick={() => loadServiceMap()}
              className="inline-flex items-center px-3 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
              Refresh
            </button>
            <button
              onClick={() => navigate('/calculator')}
              className="inline-flex items-center px-3 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
              </svg>
              Open Calculator
            </button>
          </div>
        </div>
      </div>

      {/* Legend Info */}
      <div className="bg-blue-50 border-b border-blue-100 px-6 py-3">
        <div className="flex items-center justify-center gap-8 text-sm">
          <div className="flex items-center gap-2">
            <span className="font-medium text-gray-700">Layers:</span>
            <span className="inline-flex items-center gap-1">
              <span className="w-3 h-3 rounded-full bg-amber-500"></span>
              <span className="text-gray-600">Entry</span>
            </span>
            <span className="inline-flex items-center gap-1">
              <span className="w-3 h-3 rounded-full bg-green-500"></span>
              <span className="text-gray-600">Assessment</span>
            </span>
            <span className="inline-flex items-center gap-1">
              <span className="w-3 h-3 rounded-full bg-blue-500"></span>
              <span className="text-gray-600">Infrastructure</span>
            </span>
            <span className="inline-flex items-center gap-1">
              <span className="w-3 h-3 rounded-full bg-purple-500"></span>
              <span className="text-gray-600">Platform</span>
            </span>
          </div>
          <div className="border-l border-blue-200 pl-8 flex items-center gap-2">
            <span className="font-medium text-gray-700">Dependencies:</span>
            <span className="inline-flex items-center gap-1">
              <span className="w-4 h-0.5 bg-red-500"></span>
              <span className="text-gray-600">Required</span>
            </span>
            <span className="inline-flex items-center gap-1">
              <span className="w-4 h-0.5 bg-blue-500 border-dashed border-t-2 border-blue-500"></span>
              <span className="text-gray-600">Recommended</span>
            </span>
            <span className="inline-flex items-center gap-1">
              <span className="w-4 h-0.5 bg-gray-400 border-dotted border-t-2 border-gray-400"></span>
              <span className="text-gray-600">Optional</span>
            </span>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="p-6">
        {loading && (
          <div className="flex items-center justify-center py-20">
            <LoadingSpinner size="lg" />
            <span className="ml-3 text-gray-600">Loading service map...</span>
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
            <button
              onClick={() => loadServiceMap()}
              className="mt-3 text-sm text-red-600 hover:text-red-800 underline"
            >
              Try again
            </button>
          </div>
        )}

        {!loading && !error && serviceMap && (
          <div className="bg-white rounded-lg shadow-lg overflow-hidden">
            <ServiceMap 
              data={serviceMap}
              onServiceClick={handleServiceClick}
            />
          </div>
        )}

        {!loading && !error && !serviceMap && (
          <div className="text-center py-20">
            <svg className="mx-auto h-16 w-16 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" />
            </svg>
            <h3 className="mt-4 text-lg font-medium text-gray-900">No Service Map Data</h3>
            <p className="mt-2 text-gray-500">
              Unable to load service map. Click refresh to try again.
            </p>
          </div>
        )}
      </div>

      {/* Help Text */}
      <div className="px-6 pb-6">
        <div className="bg-gray-100 rounded-lg p-4 text-sm text-gray-600">
          <h4 className="font-medium text-gray-900 mb-2">How to use the Service Map</h4>
          <ul className="list-disc list-inside space-y-1">
            <li>Click on any service node to view its details and dependencies</li>
            <li>Hover over services to highlight their connections</li>
            <li>Use the zoom controls to adjust the view</li>
            <li>Click a service to open its calculator configuration</li>
            <li>Toggle the legend for layer and dependency type reference</li>
          </ul>
        </div>
      </div>
    </div>
  );
};

export default ServiceMapPage;
