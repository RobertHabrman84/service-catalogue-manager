import React, { useState } from 'react';
import { Upload, CheckCircle, XCircle, AlertCircle, Loader } from 'lucide-react';
import importService, { ImportResult, ValidationError } from '../../services/importService';
import ValidationResults from './ValidationResults';
import ImportResults from './ImportResults';

type ImportStep = 'upload' | 'validating' | 'validated' | 'importing' | 'complete';

const ImportPage: React.FC = () => {
  const [step, setStep] = useState<ImportStep>('upload');
  const [file, setFile] = useState<File | null>(null);
  const [serviceData, setServiceData] = useState<any>(null);
  const [validationErrors, setValidationErrors] = useState<ValidationError[]>([]);
  const [importResult, setImportResult] = useState<ImportResult | null>(null);
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
    }
  };

  const handleValidate = async () => {
    if (!file) return;

    setStep('validating');
    setError(null);

    try {
      // Parse JSON file
      const data = await importService.parseJsonFile(file);
      setServiceData(data);

      // Validate
      const result = await importService.validateImport(data);

      if (result.isValid) {
        setStep('validated');
        setValidationErrors([]);
      } else {
        setStep('upload');
        setValidationErrors(result.errors || []);
        setError('Validation failed. Please fix the errors below.');
      }
    } catch (err: any) {
      setStep('upload');
      setError(err.message || 'Failed to validate service');
    }
  };

  const handleImport = async () => {
    if (!serviceData) return;

    setStep('importing');
    setError(null);

    try {
      const result = await importService.importService(serviceData);
      setImportResult(result);
      setStep('complete');

      if (!result.success) {
        setError('Import failed. See details below.');
      }
    } catch (err: any) {
      setStep('validated');
      setError(err.message || 'Failed to import service');
    }
  };

  const handleReset = () => {
    setStep('upload');
    setFile(null);
    setServiceData(null);
    setValidationErrors([]);
    setImportResult(null);
    setError(null);
  };

  return (
    <div className="max-w-4xl mx-auto p-6">
      <div className="bg-white rounded-lg shadow-lg p-8">
        <h1 className="text-3xl font-bold text-gray-800 mb-2">Import Service</h1>
        <p className="text-gray-600 mb-8">
          Upload a JSON file to import a service into the catalog
        </p>

        {/* Progress Steps */}
        <div className="mb-8">
          <div className="flex items-center justify-between">
            <StepIndicator
              number={1}
              label="Upload"
              active={step === 'upload' || step === 'validating'}
              complete={step !== 'upload' && step !== 'validating'}
            />
            <div className="flex-1 h-1 bg-gray-200 mx-2">
              <div
                className={`h-full transition-all duration-500 ${
                  step !== 'upload' && step !== 'validating' ? 'bg-blue-600' : 'bg-gray-200'
                }`}
              />
            </div>
            <StepIndicator
              number={2}
              label="Validate"
              active={step === 'validating' || step === 'validated'}
              complete={step === 'importing' || step === 'complete'}
            />
            <div className="flex-1 h-1 bg-gray-200 mx-2">
              <div
                className={`h-full transition-all duration-500 ${
                  step === 'complete' ? 'bg-blue-600' : 'bg-gray-200'
                }`}
              />
            </div>
            <StepIndicator
              number={3}
              label="Import"
              active={step === 'importing' || step === 'complete'}
              complete={step === 'complete'}
            />
          </div>
        </div>

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

        {/* Upload Step */}
        {(step === 'upload' || step === 'validating') && (
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
                id="file-upload"
                disabled={step === 'validating'}
              />
              <label
                htmlFor="file-upload"
                className="cursor-pointer text-blue-600 hover:text-blue-700 font-medium"
              >
                Choose a JSON file
              </label>
              <p className="text-gray-500 text-sm mt-2">or drag and drop</p>
              {file && (
                <div className="mt-4 p-3 bg-white rounded border border-blue-200">
                  <p className="text-sm font-medium text-gray-800">{file.name}</p>
                  <p className="text-xs text-gray-500">{(file.size / 1024).toFixed(2)} KB</p>
                </div>
              )}
            </div>

            {/* Validation Errors */}
            {validationErrors.length > 0 && (
              <ValidationResults errors={validationErrors} />
            )}

            <div className="mt-6 flex gap-4">
              <button
                onClick={handleValidate}
                disabled={!file || step === 'validating'}
                className="flex-1 bg-blue-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors flex items-center justify-center"
              >
                {step === 'validating' ? (
                  <>
                    <Loader className="w-5 h-5 mr-2 animate-spin" />
                    Validating...
                  </>
                ) : (
                  'Validate Service'
                )}
              </button>
            </div>
          </div>
        )}

        {/* Validated Step */}
        {step === 'validated' && (
          <div>
            <div className="mb-6 p-4 bg-green-50 border border-green-200 rounded-lg flex items-start">
              <CheckCircle className="w-5 h-5 text-green-600 mt-0.5 mr-3 flex-shrink-0" />
              <div>
                <p className="text-green-800 font-medium">Validation Passed</p>
                <p className="text-green-700 text-sm">
                  Service is ready to import: {serviceData?.serviceCode} - {serviceData?.serviceName}
                </p>
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 mb-6">
              <h3 className="font-medium text-gray-800 mb-2">Service Details</h3>
              <dl className="grid grid-cols-2 gap-4 text-sm">
                <div>
                  <dt className="text-gray-600">Service Code:</dt>
                  <dd className="font-medium">{serviceData?.serviceCode}</dd>
                </div>
                <div>
                  <dt className="text-gray-600">Version:</dt>
                  <dd className="font-medium">{serviceData?.version}</dd>
                </div>
                <div className="col-span-2">
                  <dt className="text-gray-600">Service Name:</dt>
                  <dd className="font-medium">{serviceData?.serviceName}</dd>
                </div>
                <div className="col-span-2">
                  <dt className="text-gray-600">Category:</dt>
                  <dd className="font-medium">{serviceData?.category}</dd>
                </div>
              </dl>
            </div>

            <div className="flex gap-4">
              <button
                onClick={handleReset}
                className="flex-1 bg-gray-200 text-gray-800 px-6 py-3 rounded-lg font-medium hover:bg-gray-300 transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={handleImport}
                className="flex-1 bg-blue-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-blue-700 transition-colors"
              >
                Import Service
              </button>
            </div>
          </div>
        )}

        {/* Importing Step */}
        {step === 'importing' && (
          <div className="text-center py-12">
            <Loader className="w-16 h-16 mx-auto mb-4 text-blue-600 animate-spin" />
            <p className="text-xl font-medium text-gray-800">Importing service...</p>
            <p className="text-gray-600 mt-2">Please wait while we save your service to the catalog</p>
          </div>
        )}

        {/* Complete Step */}
        {step === 'complete' && importResult && (
          <div>
            <ImportResults result={importResult} />

            <div className="mt-6 flex gap-4">
              <button
                onClick={handleReset}
                className="flex-1 bg-blue-600 text-white px-6 py-3 rounded-lg font-medium hover:bg-blue-700 transition-colors"
              >
                Import Another Service
              </button>
              {importResult.success && importResult.serviceId && (
                <a
                  href={`/services/${importResult.serviceId}`}
                  className="flex-1 bg-gray-200 text-gray-800 px-6 py-3 rounded-lg font-medium hover:bg-gray-300 transition-colors text-center"
                >
                  View Service
                </a>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

// Step Indicator Component
const StepIndicator: React.FC<{
  number: number;
  label: string;
  active: boolean;
  complete: boolean;
}> = ({ number, label, active, complete }) => {
  return (
    <div className="flex flex-col items-center">
      <div
        className={`w-10 h-10 rounded-full flex items-center justify-center font-medium transition-colors ${
          complete
            ? 'bg-blue-600 text-white'
            : active
            ? 'bg-blue-100 text-blue-600 border-2 border-blue-600'
            : 'bg-gray-200 text-gray-600'
        }`}
      >
        {complete ? <CheckCircle className="w-6 h-6" /> : number}
      </div>
      <span className={`text-sm mt-2 ${active || complete ? 'text-gray-800 font-medium' : 'text-gray-500'}`}>
        {label}
      </span>
    </div>
  );
};

export default ImportPage;
