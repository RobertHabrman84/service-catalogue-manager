// pages/Export/index.tsx
// Export page for generating PDF, Markdown exports

import React, { useState, useEffect } from 'react';
import { useSearchParams } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import {
  DocumentArrowDownIcon,
  DocumentTextIcon,
  CodeBracketIcon,
  CloudArrowUpIcon,
  CheckIcon,
  XMarkIcon,
  ArrowDownTrayIcon,
  ClockIcon,
} from '@heroicons/react/24/outline';
import { serviceCatalogApi, exportService } from '../../services/api.ts';
import { useExportToPdf, useExportToMarkdown, useExportHistory } from '../../hooks/useServiceCatalog';
import { ExportFormat, ServiceCatalogItem, ExportResult } from '../../types';
import { 
  Spinner, 
  Badge, 
  Checkbox, 
  SearchInput, 
  EmptyState,
} from '../../components/common';
import { PageHeader } from '../../components/common/Breadcrumb';
import clsx from 'clsx';

// Export format option card
interface FormatOptionProps {
  format: ExportFormat;
  title: string;
  description: string;
  icon: React.ReactNode;
  selected: boolean;
  onSelect: () => void;
}

const FormatOption: React.FC<FormatOptionProps> = ({
  format,
  title,
  description,
  icon,
  selected,
  onSelect,
}) => (
  <button
    type="button"
    onClick={onSelect}
    className={clsx(
      'flex items-start gap-4 p-4 rounded-lg border-2 text-left transition-all w-full',
      selected
        ? 'border-blue-500 bg-blue-50'
        : 'border-gray-200 hover:border-gray-300 bg-white'
    )}
  >
    <div className={clsx(
      'p-3 rounded-lg',
      selected ? 'bg-blue-100 text-blue-600' : 'bg-gray-100 text-gray-600'
    )}>
      {icon}
    </div>
    <div className="flex-1">
      <div className="flex items-center gap-2">
        <h4 className="font-medium text-gray-900">{title}</h4>
        {selected && <CheckIcon className="w-5 h-5 text-blue-600" />}
      </div>
      <p className="text-sm text-gray-500 mt-1">{description}</p>
    </div>
  </button>
);

// Service selection row
interface ServiceRowProps {
  service: ServiceCatalogItem;
  selected: boolean;
  onToggle: () => void;
}

const ServiceRow: React.FC<ServiceRowProps> = ({ service, selected, onToggle }) => (
  <div
    onClick={onToggle}
    className={clsx(
      'flex items-center gap-4 p-4 rounded-lg border cursor-pointer transition-all',
      selected
        ? 'border-blue-500 bg-blue-50'
        : 'border-gray-200 hover:border-gray-300 bg-white'
    )}
  >
    <input
      type="checkbox"
      checked={selected}
      onChange={onToggle}
      className="h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
    />
    <div className="flex-1 min-w-0">
      <div className="flex items-center gap-2">
        <span className="font-medium text-gray-900 truncate">{service.serviceName}</span>
        <Badge variant="blue" size="xs">{service.serviceCode}</Badge>
      </div>
      <p className="text-sm text-gray-500 truncate">{service.category?.categoryName}</p>
    </div>
    <div className="flex gap-1">
      {service.sizeOptions?.slice(0, 3).map((size) => (
        <Badge key={size.sizeOptionId} variant="gray" size="xs">
          {size.sizeOption?.sizeCode}
        </Badge>
      ))}
    </div>
  </div>
);

// Export history item
interface ExportHistoryItemProps {
  export_: ExportResult;
  onDownload: () => void;
}

const ExportHistoryItem: React.FC<ExportHistoryItemProps> = ({ export_, onDownload }) => {
  const isExpired = new Date(export_.expiresAt) < new Date();
  
  return (
    <div className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
      <div className="flex items-center gap-3">
        <div className="p-2 rounded-lg bg-white border border-gray-200">
          {export_.format === 'pdf' ? (
            <DocumentTextIcon className="w-5 h-5 text-red-500" />
          ) : (
            <CodeBracketIcon className="w-5 h-5 text-gray-500" />
          )}
        </div>
        <div>
          <p className="font-medium text-gray-900">{export_.fileName}</p>
          <p className="text-xs text-gray-500 flex items-center gap-1">
            <ClockIcon className="w-3 h-3" />
            Expires: {new Date(export_.expiresAt).toLocaleString()}
          </p>
        </div>
      </div>
      <button
        onClick={onDownload}
        disabled={isExpired}
        className={clsx(
          'inline-flex items-center gap-2 px-3 py-1.5 rounded-md text-sm font-medium transition-colors',
          isExpired
            ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
            : 'bg-blue-600 text-white hover:bg-blue-700'
        )}
      >
        <ArrowDownTrayIcon className="w-4 h-4" />
        {isExpired ? 'Expired' : 'Download'}
      </button>
    </div>
  );
};

// Main Export Page
export const ExportPage: React.FC = () => {
  const [searchParams] = useSearchParams();
  const preselectedIds = searchParams.get('services')?.split(',').map(Number) || [];

  // State
  const [selectedFormat, setSelectedFormat] = useState<ExportFormat>('pdf');
  const [selectedServices, setSelectedServices] = useState<Set<number>>(new Set(preselectedIds));
  const [searchQuery, setSearchQuery] = useState('');
  const [includeAllSections, setIncludeAllSections] = useState(true);

  // Queries
  const { data: servicesData, isLoading: servicesLoading } = useQuery({
    queryKey: ['services', 'export-list'],
    queryFn: () => serviceCatalogApi.getServices({ isPublished: true }, 1, 100),
  });
  const { data: exportHistoryData, isLoading: historyLoading } = useExportHistory();
  
  // Ensure exportHistory is always an array
  const exportHistory = Array.isArray(exportHistoryData) ? exportHistoryData : [];

  // Mutations
  const pdfMutation = useExportToPdf();
  const markdownMutation = useExportToMarkdown();

  const services = servicesData?.items || [];
  const filteredServices = services.filter(s =>
    s.serviceName.toLowerCase().includes(searchQuery.toLowerCase()) ||
    s.serviceCode.toLowerCase().includes(searchQuery.toLowerCase())
  );

  // Update preselected services
  useEffect(() => {
    if (preselectedIds.length > 0) {
      setSelectedServices(new Set(preselectedIds));
    }
  }, []);

  const toggleService = (serviceId: number) => {
    const newSelected = new Set(selectedServices);
    if (newSelected.has(serviceId)) {
      newSelected.delete(serviceId);
    } else {
      newSelected.add(serviceId);
    }
    setSelectedServices(newSelected);
  };

  const selectAll = () => {
    setSelectedServices(new Set(filteredServices.map(s => s.serviceId)));
  };

  const clearSelection = () => {
    setSelectedServices(new Set());
  };

  const handleExport = async () => {
    const options = {
      format: selectedFormat,
      serviceIds: Array.from(selectedServices),
      includeAllSections,
    };

    if (selectedFormat === 'pdf') {
      const result = await pdfMutation.mutateAsync(options);
      // Trigger download
      window.open(result.downloadUrl, '_blank');
    } else if (selectedFormat === 'markdown') {
      const result = await markdownMutation.mutateAsync(options);
      window.open(result.downloadUrl, '_blank');
    }
  };

  const handleDownload = async (exportId: string) => {
    const blob = await exportService.downloadExport(exportId);
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'export';
    a.click();
    URL.revokeObjectURL(url);
  };

  const isExporting = pdfMutation.isPending || markdownMutation.isPending;

  return (
    <div className="space-y-8">
      {/* Page Header */}
      <PageHeader
        title="Export Services"
        subtitle="Generate PDF or Markdown documentation for your services"
        breadcrumbs={[
          { label: 'Dashboard', href: '/' },
          { label: 'Export' },
        ]}
      />

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Main Content */}
        <div className="lg:col-span-2 space-y-6">
          {/* Format Selection */}
          <div className="bg-white rounded-xl border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Export Format</h2>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <FormatOption
                format="pdf"
                title="PDF Document"
                description="Formatted PDF suitable for printing and sharing"
                icon={<DocumentTextIcon className="w-6 h-6" />}
                selected={selectedFormat === 'pdf'}
                onSelect={() => setSelectedFormat('pdf')}
              />
              <FormatOption
                format="markdown"
                title="Markdown"
                description="Plain text format for documentation systems"
                icon={<CodeBracketIcon className="w-6 h-6" />}
                selected={selectedFormat === 'markdown'}
                onSelect={() => setSelectedFormat('markdown')}
              />
              <FormatOption
                format="uubookkit"
                title="uuBookKit"
                description="Publish directly to uuBookKit documentation"
                icon={<CloudArrowUpIcon className="w-6 h-6" />}
                selected={selectedFormat === 'uubookkit'}
                onSelect={() => setSelectedFormat('uubookkit')}
              />
            </div>
          </div>

          {/* Service Selection */}
          <div className="bg-white rounded-xl border border-gray-200 p-6">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-semibold text-gray-900">
                Select Services ({selectedServices.size} selected)
              </h2>
              <div className="flex gap-2">
                <button
                  onClick={selectAll}
                  className="text-sm text-blue-600 hover:text-blue-700"
                >
                  Select All
                </button>
                <span className="text-gray-300">|</span>
                <button
                  onClick={clearSelection}
                  className="text-sm text-gray-500 hover:text-gray-700"
                >
                  Clear
                </button>
              </div>
            </div>

            <SearchInput
              value={searchQuery}
              onChange={setSearchQuery}
              placeholder="Search services..."
              className="mb-4"
            />

            {servicesLoading ? (
              <div className="flex justify-center py-8">
                <Spinner size="lg" />
              </div>
            ) : filteredServices.length === 0 ? (
              <EmptyState
                variant="search"
                title="No services found"
                description="Try a different search term"
                compact
              />
            ) : (
              <div className="space-y-2 max-h-96 overflow-y-auto">
                {filteredServices.map((service) => (
                  <ServiceRow
                    key={service.serviceId}
                    service={service}
                    selected={selectedServices.has(service.serviceId)}
                    onToggle={() => toggleService(service.serviceId)}
                  />
                ))}
              </div>
            )}
          </div>

          {/* Options */}
          <div className="bg-white rounded-xl border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Export Options</h2>
            <div className="space-y-4">
              <label className="flex items-center gap-3">
                <input
                  type="checkbox"
                  checked={includeAllSections}
                  onChange={(e) => setIncludeAllSections(e.target.checked)}
                  className="h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                />
                <span className="text-sm text-gray-700">Include all sections</span>
              </label>
            </div>
          </div>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Export Button */}
          <div className="bg-white rounded-xl border border-gray-200 p-6">
            <h3 className="font-semibold text-gray-900 mb-4">Ready to Export</h3>
            <div className="space-y-3 mb-4 text-sm">
              <div className="flex justify-between">
                <span className="text-gray-500">Format</span>
                <span className="font-medium text-gray-900 capitalize">{selectedFormat}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-500">Services</span>
                <span className="font-medium text-gray-900">{selectedServices.size}</span>
              </div>
            </div>
            <button
              onClick={handleExport}
              disabled={selectedServices.size === 0 || isExporting}
              className={clsx(
                'w-full inline-flex items-center justify-center gap-2 px-4 py-3 rounded-lg font-medium transition-colors',
                selectedServices.size === 0 || isExporting
                  ? 'bg-gray-100 text-gray-400 cursor-not-allowed'
                  : 'bg-blue-600 text-white hover:bg-blue-700'
              )}
            >
              {isExporting ? (
                <>
                  <Spinner size="sm" variant="white" />
                  Generating...
                </>
              ) : (
                <>
                  <DocumentArrowDownIcon className="w-5 h-5" />
                  Generate Export
                </>
              )}
            </button>
          </div>

          {/* Recent Exports */}
          <div className="bg-white rounded-xl border border-gray-200 p-6">
            <h3 className="font-semibold text-gray-900 mb-4">Recent Exports</h3>
            {historyLoading ? (
              <Spinner size="sm" />
            ) : exportHistory.length === 0 ? (
              <p className="text-sm text-gray-500">No recent exports</p>
            ) : (
              <div className="space-y-3">
                {exportHistory.slice(0, 5).map((exp) => (
                  <ExportHistoryItem
                    key={exp.exportId}
                    export_={exp}
                    onDownload={() => handleDownload(exp.exportId)}
                  />
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default ExportPage;
