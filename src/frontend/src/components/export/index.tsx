import React, { useState } from 'react';

// ============================================
// Types
// ============================================
type ExportFormat = 'pdf' | 'markdown' | 'uubookkit';

interface ExportOptionsState {
  format: ExportFormat;
  includeUsageScenarios: boolean;
  includeDependencies: boolean;
  includeScope: boolean;
  includePrerequisites: boolean;
  includeInputsOutputs: boolean;
  includeTimeline: boolean;
  includeSizing: boolean;
  includeEffort: boolean;
  includeTeam: boolean;
  includeMultiCloud: boolean;
  includeExamples: boolean;
  includeNotes: boolean;
}

// ============================================
// ExportDialog Component
// ============================================
interface ExportDialogProps {
  isOpen: boolean;
  onClose: () => void;
  onExport: (options: ExportOptionsState) => void;
  selectedServices: number[];
  isExporting?: boolean;
}

export const ExportDialog: React.FC<ExportDialogProps> = ({
  isOpen,
  onClose,
  onExport,
  selectedServices,
  isExporting = false,
}) => {
  const [options, setOptions] = useState<ExportOptionsState>({
    format: 'pdf',
    includeUsageScenarios: true,
    includeDependencies: true,
    includeScope: true,
    includePrerequisites: true,
    includeInputsOutputs: true,
    includeTimeline: true,
    includeSizing: true,
    includeEffort: true,
    includeTeam: true,
    includeMultiCloud: true,
    includeExamples: true,
    includeNotes: true,
  });

  if (!isOpen) return null;

  const handleExport = () => {
    onExport(options);
  };

  const toggleOption = (key: keyof ExportOptionsState) => {
    if (key === 'format') return;
    setOptions(prev => ({ ...prev, [key]: !prev[key] }));
  };

  const selectAll = () => {
    setOptions(prev => ({
      ...prev,
      includeUsageScenarios: true,
      includeDependencies: true,
      includeScope: true,
      includePrerequisites: true,
      includeInputsOutputs: true,
      includeTimeline: true,
      includeSizing: true,
      includeEffort: true,
      includeTeam: true,
      includeMultiCloud: true,
      includeExamples: true,
      includeNotes: true,
    }));
  };

  const selectNone = () => {
    setOptions(prev => ({
      ...prev,
      includeUsageScenarios: false,
      includeDependencies: false,
      includeScope: false,
      includePrerequisites: false,
      includeInputsOutputs: false,
      includeTimeline: false,
      includeSizing: false,
      includeEffort: false,
      includeTeam: false,
      includeMultiCloud: false,
      includeExamples: false,
      includeNotes: false,
    }));
  };

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto">
      <div className="flex items-center justify-center min-h-screen px-4">
        <div className="fixed inset-0 bg-black bg-opacity-50" onClick={onClose} />
        
        <div className="relative bg-white rounded-lg shadow-xl max-w-lg w-full p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900">Export Services</h3>
            <button onClick={onClose} className="text-gray-400 hover:text-gray-600">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          <p className="text-sm text-gray-600 mb-4">
            Exporting {selectedServices.length} service{selectedServices.length !== 1 ? 's' : ''}
          </p>

          {/* Format Selection */}
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">Export Format</label>
            <div className="grid grid-cols-3 gap-2">
              {(['pdf', 'markdown', 'uubookkit'] as ExportFormat[]).map((format) => (
                <button
                  key={format}
                  onClick={() => setOptions(prev => ({ ...prev, format }))}
                  className={`px-4 py-2 text-sm rounded-md border ${
                    options.format === format
                      ? 'bg-blue-50 border-blue-500 text-blue-700'
                      : 'border-gray-300 text-gray-700 hover:bg-gray-50'
                  }`}
                >
                  {format === 'pdf' && 'PDF'}
                  {format === 'markdown' && 'Markdown'}
                  {format === 'uubookkit' && 'UuBookKit'}
                </button>
              ))}
            </div>
          </div>

          {/* Include Options */}
          <div className="mb-6">
            <div className="flex items-center justify-between mb-2">
              <label className="block text-sm font-medium text-gray-700">Include Sections</label>
              <div className="space-x-2">
                <button onClick={selectAll} className="text-xs text-blue-600 hover:text-blue-800">Select All</button>
                <button onClick={selectNone} className="text-xs text-gray-600 hover:text-gray-800">Select None</button>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-2 max-h-48 overflow-y-auto">
              {[
                { key: 'includeUsageScenarios', label: 'Usage Scenarios' },
                { key: 'includeDependencies', label: 'Dependencies' },
                { key: 'includeScope', label: 'Scope' },
                { key: 'includePrerequisites', label: 'Prerequisites' },
                { key: 'includeInputsOutputs', label: 'Inputs/Outputs' },
                { key: 'includeTimeline', label: 'Timeline' },
                { key: 'includeSizing', label: 'Sizing' },
                { key: 'includeEffort', label: 'Effort' },
                { key: 'includeTeam', label: 'Team' },
                { key: 'includeMultiCloud', label: 'Multi-Cloud' },
                { key: 'includeExamples', label: 'Examples' },
                { key: 'includeNotes', label: 'Notes' },
              ].map(({ key, label }) => (
                <label key={key} className="flex items-center space-x-2 text-sm">
                  <input
                    type="checkbox"
                    checked={options[key as keyof ExportOptionsState] as boolean}
                    onChange={() => toggleOption(key as keyof ExportOptionsState)}
                    className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                  <span>{label}</span>
                </label>
              ))}
            </div>
          </div>

          {/* Actions */}
          <div className="flex justify-end space-x-3">
            <button
              onClick={onClose}
              className="px-4 py-2 text-sm text-gray-700 border border-gray-300 rounded-md hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              onClick={handleExport}
              disabled={isExporting}
              className="px-4 py-2 text-sm text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:opacity-50"
            >
              {isExporting ? 'Exporting...' : 'Export'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

// ============================================
// ExportProgress Component
// ============================================
interface ExportProgressProps {
  isOpen: boolean;
  progress: number;
  message?: string;
  onCancel?: () => void;
}

export const ExportProgress: React.FC<ExportProgressProps> = ({
  isOpen,
  progress,
  message = 'Generating export...',
  onCancel,
}) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      <div className="fixed inset-0 bg-black bg-opacity-50" />
      <div className="relative bg-white rounded-lg shadow-xl p-6 w-80">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Exporting</h3>
        <p className="text-sm text-gray-600 mb-4">{message}</p>
        
        <div className="w-full bg-gray-200 rounded-full h-2 mb-4">
          <div
            className="bg-blue-600 h-2 rounded-full transition-all duration-300"
            style={{ width: `${progress}%` }}
          />
        </div>
        
        <p className="text-sm text-gray-500 text-center mb-4">{progress}%</p>
        
        {onCancel && (
          <button
            onClick={onCancel}
            className="w-full px-4 py-2 text-sm text-gray-700 border border-gray-300 rounded-md hover:bg-gray-50"
          >
            Cancel
          </button>
        )}
      </div>
    </div>
  );
};

export default { ExportDialog, ExportProgress };
