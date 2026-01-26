import React from 'react';
import { CheckCircle, XCircle, ExternalLink } from 'lucide-react';
import { ImportResult } from '../../services/importService';

interface ImportResultsProps {
  result: ImportResult;
}

const ImportResults: React.FC<ImportResultsProps> = ({ result }) => {
  if (result.success) {
    return (
      <div className="bg-green-50 border border-green-200 rounded-lg p-6">
        <div className="flex items-start">
          <CheckCircle className="w-8 h-8 text-green-600 mt-0.5 mr-4 flex-shrink-0" />
          <div className="flex-1">
            <h3 className="text-xl font-semibold text-green-800 mb-2">Import Successful!</h3>
            <p className="text-green-700 mb-4">
              Service has been successfully imported into the catalog.
            </p>

            <div className="bg-white rounded-lg p-4 border border-green-200">
              <dl className="grid grid-cols-2 gap-4 text-sm">
                <div>
                  <dt className="text-gray-600 mb-1">Service ID</dt>
                  <dd className="font-mono text-lg font-semibold text-gray-800">
                    {result.serviceId}
                  </dd>
                </div>
                <div>
                  <dt className="text-gray-600 mb-1">Service Code</dt>
                  <dd className="font-mono text-lg font-semibold text-gray-800">
                    {result.serviceCode}
                  </dd>
                </div>
              </dl>
            </div>

            {result.serviceId && (
              <div className="mt-4 flex gap-3">
                <a
                  href={`/services/${result.serviceId}`}
                  className="inline-flex items-center text-sm text-green-700 hover:text-green-800 font-medium"
                >
                  View Service Details
                  <ExternalLink className="w-4 h-4 ml-1" />
                </a>
                <a
                  href="/services"
                  className="inline-flex items-center text-sm text-green-700 hover:text-green-800 font-medium"
                >
                  Browse All Services
                  <ExternalLink className="w-4 h-4 ml-1" />
                </a>
              </div>
            )}
          </div>
        </div>
      </div>
    );
  }

  // Import failed
  return (
    <div className="bg-red-50 border border-red-200 rounded-lg p-6">
      <div className="flex items-start">
        <XCircle className="w-8 h-8 text-red-600 mt-0.5 mr-4 flex-shrink-0" />
        <div className="flex-1">
          <h3 className="text-xl font-semibold text-red-800 mb-2">Import Failed</h3>
          <p className="text-red-700 mb-4">
            {result.message || 'An error occurred during import.'}
          </p>

          {result.errors && result.errors.length > 0 && (
            <div className="space-y-3">
              {result.errors.map((error, index) => (
                <div key={index} className="bg-white rounded-lg p-4 border border-red-200">
                  <div className="flex items-start">
                    <div className="flex-1">
                      <p className="font-medium text-gray-800">{error.field}</p>
                      <p className="text-sm text-gray-700 mt-1">{error.message}</p>
                      {error.code && (
                        <span className="inline-block mt-2 text-xs text-gray-500 font-mono bg-gray-100 px-2 py-1 rounded">
                          {error.code}
                        </span>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}

          <div className="mt-4 p-4 bg-blue-50 border border-blue-200 rounded">
            <p className="text-sm text-blue-800">
              <strong>Need help?</strong> Check the{' '}
              <a href="/docs/troubleshooting" className="underline hover:text-blue-900">
                troubleshooting guide
              </a>{' '}
              or contact support.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ImportResults;
