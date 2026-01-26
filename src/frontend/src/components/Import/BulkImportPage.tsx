import React, { useState } from 'react';
import { Upload, Loader, CheckCircle, XCircle, AlertCircle } from 'lucide-react';
import importService, { BulkImportResult } from '../../services/importService';

const BulkImportPage: React.FC = () => {
  const [file, setFile] = useState<File | null>(null);
  const [importing, setImporting] = useState(false);
  const [result, setResult] = useState<BulkImportResult | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFile = e.target.files?.[0];
    if (selectedFile) {
      if (selectedFile.type !== 'application/json') {
        setError('Please select a JSON file');
        return;
      }
      setFile(selectedFile);
      setError(null);
      setResult(null);
    }
  };

  const handleImport = async () => {
    if (!file) return;

    setImporting(true);
    setError(null);

    try {
      const data = await importService.parseJsonFile(file);

      // Ensure data is an array
      const servicesArray = Array.isArray(data) ? data : [data];

      const importResult = await importService.bulkImportServices(servicesArray);
      setResult(importResult);
    } catch (err: any) {
      setError(err.message || 'Failed to import services');
    } finally {
      setImporting(false);
    }
  };

  const handleReset = () => {
    setFile(null);
    setResult(null);
    setError(null);
  };

  const getStatusColor = (success: boolean) => {
    return success ? 'text-green-600' : 'text-red-600';
  };

  const getStatusIcon = (success: boolean) => {
    return success ? (
      <CheckCircle className="w-5 h-5 text-green-600" />
    ) : (
      <XCircle className="w-5 h-5 text-red-600" />
    );
  };

  return (
    <div className="max-w-6xl mx-auto p-6">
      <div className="bg-white rounded-lg shadow-lg p-8">
        <h1 className="text-3xl font-bold text-gray-800 mb-2">Bulk Import Services</h1>
        <p className="text-gray-600 mb-8">
          Upload a JSON file containing an array of services to import multiple services at once
        </p>

        {/* Error Alert */}
        {error && (
          <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg flex items-start">
            <AlertCircle className="w-5 h-5 text-red-600 mt-0.5 mr-3 flex-shrink-0" />
            <div>
              <p className="text-red-800 font-medium">Error</p>
              <p className="text-red-700 text-sm">{error}</p>
            </div>
          </div>
        )}

        {/* Upload Area */}
        {!result && (
          <div>
            <div
              className={`border-2 border-dashed rounded-lg p-12 text-center transition-colors ${
                file ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:border-gray-400'
              }`}
            >
              <Upload className="w-12 h-12 mx-auto mb-4 text-gray-400" />
              <input
                type="file"
                accept=".json"
                onChange={handleFileChange}
                className="hidden"
                id="bulk-file-upload"
                disabled={importing}
              />
              <label
                htmlFor="bulk-file-upload"
                className="cursor-pointer text-blue-600 hover:text-blue-700 font-medium"
              >
                Choose a JSON file
              </label>
              <p className="text-gray-500 text-sm mt-2">File must contain an array of service objects</p>
              {file && (
                <div className="mt-4 p-3 bg-white rounded border border-blue-200">
                  <p className="text-sm font-medium text-gray-800">{file.name}</p>
                  <p className="text-xs text-gray-500">{(file.size / 1024).toFixed(2)} KB</p>
                </div>
              )}
            </div>

            <div className="mt-6 flex gap-4">
              <button
                onClick={handleImport}
                disabled={!file || importing}
                className="flex-1 bg-blue-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors flex items-center justify-center"
              >
                {importing ? (
                  <>
                    <Loader className="w-5 h-5 mr-2 animate-spin" />
                    Importing Services...
                  </>
                ) : (
                  'Import Services'
                )}
              </button>
            </div>
          </div>
        )}

        {/* Results */}
        {result && (
          <div>
            {/* Summary */}
            <div className="mb-6 p-6 bg-gray-50 rounded-lg border border-gray-200">
              <h2 className="text-xl font-semibold text-gray-800 mb-4">Import Summary</h2>
              <div className="grid grid-cols-3 gap-4">
                <div className="text-center p-4 bg-white rounded border">
                  <p className="text-3xl font-bold text-gray-800">{result.totalCount}</p>
                  <p className="text-sm text-gray-600 mt-1">Total</p>
                </div>
                <div className="text-center p-4 bg-green-50 rounded border border-green-200">
                  <p className="text-3xl font-bold text-green-600">{result.successCount}</p>
                  <p className="text-sm text-gray-600 mt-1">Successful</p>
                </div>
                <div className="text-center p-4 bg-red-50 rounded border border-red-200">
                  <p className="text-3xl font-bold text-red-600">{result.failCount}</p>
                  <p className="text-sm text-gray-600 mt-1">Failed</p>
                </div>
              </div>
            </div>

            {/* Detailed Results */}
            <div className="space-y-3 mb-6">
              <h3 className="text-lg font-semibold text-gray-800">Detailed Results</h3>
              {result.results.map((item, index) => (
                <div
                  key={index}
                  className={`p-4 rounded-lg border ${
                    item.success
                      ? 'bg-green-50 border-green-200'
                      : 'bg-red-50 border-red-200'
                  }`}
                >
                  <div className="flex items-start">
                    <div className="mr-3 mt-0.5">{getStatusIcon(item.success)}</div>
                    <div className="flex-1">
                      <div className="flex items-center justify-between">
                        <p className={`font-medium ${getStatusColor(item.success)}`}>
                          Service {item.serviceCode || `#${index + 1}`}
                        </p>
                        {item.success && item.serviceId && (
                          <a
                            href={`/services/${item.serviceId}`}
                            className="text-sm text-blue-600 hover:text-blue-700"
                          >
                            View →
                          </a>
                        )}
                      </div>
                      {item.success ? (
                        <p className="text-sm text-gray-700 mt-1">
                          Successfully imported as ID: {item.serviceId}
                        </p>
                      ) : (
                        <div className="mt-2">
                          {item.errors && item.errors.length > 0 ? (
                            <ul className="space-y-1">
                              {item.errors.map((error, errorIndex) => (
                                <li key={errorIndex} className="text-sm text-gray-700">
                                  <span className="font-medium">{error.field}:</span> {error.message}
                                </li>
                              ))}
                            </ul>
                          ) : (
                            <p className="text-sm text-gray-700">{item.message}</p>
                          )}
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>

            {/* Actions */}
            <div className="flex gap-4">
              <button
                onClick={handleReset}
                className="flex-1 bg-blue-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-blue-700 transition-colors"
              >
                Import More Services
              </button>
              <a
                href="/services"
                className="flex-1 bg-gray-200 text-gray-800 px-6 py-3 rounded-lg font-medium hover:bg-gray-300 transition-colors text-center"
              >
                View All Services
              </a>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default BulkImportPage;
