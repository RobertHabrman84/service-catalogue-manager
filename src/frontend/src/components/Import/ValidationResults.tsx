import React from 'react';
import { XCircle, AlertTriangle } from 'lucide-react';
import { ValidationError } from '../../services/importService';

interface ValidationResultsProps {
  errors: ValidationError[];
}

const ValidationResults: React.FC<ValidationResultsProps> = ({ errors }) => {
  if (errors.length === 0) return null;

  // Group errors by field
  const groupedErrors = errors.reduce((acc, error) => {
    if (!acc[error.field]) {
      acc[error.field] = [];
    }
    acc[error.field].push(error);
    return acc;
  }, {} as Record<string, ValidationError[]>);

  return (
    <div className="mt-6 bg-red-50 border border-red-200 rounded-lg p-6">
      <div className="flex items-start mb-4">
        <XCircle className="w-6 h-6 text-red-600 mt-0.5 mr-3 flex-shrink-0" />
        <div>
          <h3 className="text-lg font-semibold text-red-800">Validation Failed</h3>
          <p className="text-red-700 text-sm mt-1">
            {errors.length} {errors.length === 1 ? 'error' : 'errors'} found. Please fix the issues below and try again.
          </p>
        </div>
      </div>

      <div className="space-y-4 mt-4">
        {Object.entries(groupedErrors).map(([field, fieldErrors]) => (
          <div key={field} className="bg-white rounded-lg p-4 border border-red-200">
            <div className="flex items-start">
              <AlertTriangle className="w-5 h-5 text-orange-600 mt-0.5 mr-2 flex-shrink-0" />
              <div className="flex-1">
                <p className="font-medium text-gray-800">{field}</p>
                <ul className="mt-2 space-y-1">
                  {fieldErrors.map((error, index) => (
                    <li key={index} className="text-sm text-gray-700 flex items-start">
                      <span className="inline-block w-1.5 h-1.5 bg-red-500 rounded-full mt-1.5 mr-2 flex-shrink-0" />
                      <span className="flex-1">
                        {error.message}
                        {error.code && (
                          <span className="ml-2 text-xs text-gray-500 font-mono bg-gray-100 px-2 py-0.5 rounded">
                            {error.code}
                          </span>
                        )}
                      </span>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="mt-4 p-4 bg-blue-50 border border-blue-200 rounded">
        <p className="text-sm text-blue-800">
          <strong>Tip:</strong> Check the{' '}
          <a href="/docs/validation-errors" className="underline hover:text-blue-900">
            validation error reference
          </a>{' '}
          for detailed information about each error code.
        </p>
      </div>
    </div>
  );
};

export default ValidationResults;
