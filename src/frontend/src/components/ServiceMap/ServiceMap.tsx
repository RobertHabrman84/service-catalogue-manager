import React, { useState, useMemo } from 'react';
import { ServiceMapDto, ServiceMapItemDto, ServiceMapDependencyDto } from '../../services/api/calculatorApi';

interface ServiceMapProps {
  data?: ServiceMapDto | null;
  onServiceClick?: (serviceId: string) => void;
}

const layerColors: Record<string, { fill: string; stroke: string; text: string }> = {
  entry: { fill: '#fbbf24', stroke: '#d97706', text: '#78350f' },
  assessment: { fill: '#10b981', stroke: '#059669', text: '#ffffff' },
  infra: { fill: '#3b82f6', stroke: '#2563eb', text: '#ffffff' },
  platform: { fill: '#8b5cf6', stroke: '#7c3aed', text: '#ffffff' },
  other: { fill: '#f97316', stroke: '#ea580c', text: '#ffffff' },
};

const dependencyStyles: Record<string, { stroke: string; strokeWidth: number; dashArray: string }> = {
  required: { stroke: '#ef4444', strokeWidth: 2.5, dashArray: '' },
  recommended: { stroke: '#3b82f6', strokeWidth: 2, dashArray: '8,4' },
  optional: { stroke: '#9ca3af', strokeWidth: 1.5, dashArray: '4,4' },
};

// Default services if none provided
const defaultServices: ServiceMapItemDto[] = [
  { id: 'IA', name: 'Initial Assessment', shortName: 'Initial', layer: 'entry', x: 400, y: 300 },
  { id: 'ESLZA', name: 'ESLZ Assessment', shortName: 'ESLZ Assess', layer: 'assessment', x: 250, y: 180 },
  { id: 'INFRA', name: 'Infrastructure Assessment', shortName: 'Infra Assess', layer: 'assessment', x: 400, y: 120 },
  { id: 'PLAT', name: 'Platform Assessment', shortName: 'Platform Assess', layer: 'assessment', x: 550, y: 180 },
  { id: 'APP', name: 'Application Assessment', shortName: 'App Assess', layer: 'assessment', x: 580, y: 320 },
  { id: 'DEVOPS', name: 'DevOps Assessment', shortName: 'DevOps Assess', layer: 'assessment', x: 500, y: 440 },
  { id: 'FINOPS', name: 'FinOps Assessment', shortName: 'FinOps Assess', layer: 'assessment', x: 300, y: 440 },
  { id: 'ESLZD', name: 'ESLZ Design', shortName: 'ESLZ Design', layer: 'infra', x: 120, y: 120 },
  { id: 'ALZD', name: 'ALZ Design', shortName: 'ALZ Design', layer: 'infra', x: 280, y: 50 },
  { id: 'CNA', name: 'Cloud Network Arch', shortName: 'Cloud Net', layer: 'infra', x: 120, y: 250 },
  { id: 'HIA', name: 'Hybrid Infra Arch', shortName: 'Hybrid', layer: 'infra', x: 50, y: 380 },
  { id: 'CPA', name: 'Container Platform', shortName: 'Container', layer: 'platform', x: 520, y: 50 },
  { id: 'DOA', name: 'DevOps Architecture', shortName: 'DevOps Arch', layer: 'platform', x: 680, y: 120 },
  { id: 'IAM', name: 'IAM Architecture', shortName: 'IAM', layer: 'platform', x: 700, y: 250 },
  { id: 'APIM', name: 'APIM Architecture', shortName: 'APIM', layer: 'platform', x: 720, y: 380 },
  { id: 'VDI', name: 'VDI Architecture', shortName: 'VDI', layer: 'platform', x: 650, y: 480 },
  { id: 'M365', name: 'M365 Architecture', shortName: 'M365', layer: 'platform', x: 750, y: 320 },
  { id: 'APPA', name: 'Application Architecture', shortName: 'App Arch', layer: 'other', x: 680, y: 400 },
  { id: 'FA', name: 'FinOps Architecture', shortName: 'FinOps Arch', layer: 'other', x: 150, y: 480 },
];

const defaultDependencies: ServiceMapDependencyDto[] = [
  { from: 'IA', to: 'ESLZA', type: 'recommended' },
  { from: 'IA', to: 'INFRA', type: 'recommended' },
  { from: 'IA', to: 'PLAT', type: 'recommended' },
  { from: 'IA', to: 'APP', type: 'recommended' },
  { from: 'IA', to: 'DEVOPS', type: 'recommended' },
  { from: 'IA', to: 'FINOPS', type: 'recommended' },
  { from: 'ESLZA', to: 'ESLZD', type: 'required' },
  { from: 'ESLZA', to: 'FA', type: 'optional' },
  { from: 'INFRA', to: 'ESLZD', type: 'optional' },
  { from: 'INFRA', to: 'ALZD', type: 'recommended' },
  { from: 'INFRA', to: 'CNA', type: 'recommended' },
  { from: 'INFRA', to: 'HIA', type: 'optional' },
  { from: 'PLAT', to: 'CPA', type: 'recommended' },
  { from: 'PLAT', to: 'IAM', type: 'recommended' },
  { from: 'PLAT', to: 'VDI', type: 'optional' },
  { from: 'PLAT', to: 'M365', type: 'optional' },
  { from: 'PLAT', to: 'APIM', type: 'optional' },
  { from: 'PLAT', to: 'DOA', type: 'optional' },
  { from: 'APP', to: 'ALZD', type: 'recommended' },
  { from: 'APP', to: 'APPA', type: 'required' },
  { from: 'APP', to: 'CPA', type: 'optional' },
  { from: 'APP', to: 'APIM', type: 'optional' },
  { from: 'DEVOPS', to: 'DOA', type: 'required' },
  { from: 'FINOPS', to: 'FA', type: 'required' },
  { from: 'FINOPS', to: 'ESLZD', type: 'optional' },
  { from: 'ESLZD', to: 'ALZD', type: 'required' },
  { from: 'ESLZD', to: 'CNA', type: 'required' },
  { from: 'ESLZD', to: 'IAM', type: 'recommended' },
  { from: 'ESLZD', to: 'FA', type: 'recommended' },
  { from: 'ESLZD', to: 'HIA', type: 'optional' },
  { from: 'ESLZD', to: 'CPA', type: 'optional' },
  { from: 'ESLZD', to: 'DOA', type: 'optional' },
  { from: 'ESLZD', to: 'APIM', type: 'optional' },
  { from: 'ESLZD', to: 'VDI', type: 'optional' },
  { from: 'CNA', to: 'HIA', type: 'required' },
  { from: 'CNA', to: 'ALZD', type: 'required' },
  { from: 'CNA', to: 'CPA', type: 'recommended' },
  { from: 'CNA', to: 'APIM', type: 'recommended' },
  { from: 'CNA', to: 'VDI', type: 'recommended' },
  { from: 'IAM', to: 'M365', type: 'recommended' },
  { from: 'IAM', to: 'VDI', type: 'recommended' },
  { from: 'IAM', to: 'APIM', type: 'recommended' },
  { from: 'IAM', to: 'CPA', type: 'optional' },
  { from: 'CPA', to: 'DOA', type: 'recommended' },
  { from: 'ALZD', to: 'CPA', type: 'recommended' },
];

const ServiceMap: React.FC<ServiceMapProps> = ({ data, onServiceClick }) => {
  const [selectedService, setSelectedService] = useState<string | null>(null);
  const [hoveredService, setHoveredService] = useState<string | null>(null);
  const [zoom, setZoom] = useState(1);
  const [showLegend, setShowLegend] = useState(true);

  const services = data?.services?.length ? data.services : defaultServices;
  const dependencies = data?.dependencies?.length ? data.dependencies : defaultDependencies;

  const getServiceById = (id: string) => services.find(s => s.id === id);
  const activeServiceId = hoveredService || selectedService;

  const relevantDependencies = useMemo(() => {
    if (!activeServiceId) return dependencies;
    return dependencies.filter(d => d.from === activeServiceId || d.to === activeServiceId);
  }, [activeServiceId, dependencies]);

  const connectedServiceIds = useMemo(() => {
    if (!activeServiceId) return new Set<string>();
    const connected = new Set<string>();
    connected.add(activeServiceId);
    dependencies.forEach(d => {
      if (d.from === activeServiceId) connected.add(d.to);
      if (d.to === activeServiceId) connected.add(d.from);
    });
    return connected;
  }, [activeServiceId, dependencies]);

  const handleServiceClick = (serviceId: string) => {
    setSelectedService(selectedService === serviceId ? null : serviceId);
    if (onServiceClick) {
      onServiceClick(serviceId);
    }
  };

  const DependencyLine: React.FC<{ dep: ServiceMapDependencyDto; isHighlighted: boolean }> = ({ dep, isHighlighted }) => {
    const fromService = getServiceById(dep.from);
    const toService = getServiceById(dep.to);
    if (!fromService || !toService) return null;

    const style = dependencyStyles[dep.type] || dependencyStyles.optional;
    const opacity = activeServiceId && !isHighlighted ? 0.1 : isHighlighted ? 1 : 0.4;

    const dx = toService.x - fromService.x;
    const dy = toService.y - fromService.y;
    const dist = Math.sqrt(dx * dx + dy * dy);
    const offsetX = (dx / dist) * 30;
    const offsetY = (dy / dist) * 30;

    return (
      <line
        x1={fromService.x + offsetX}
        y1={fromService.y + offsetY}
        x2={toService.x - offsetX}
        y2={toService.y - offsetY}
        stroke={style.stroke}
        strokeWidth={style.strokeWidth}
        strokeDasharray={style.dashArray}
        opacity={opacity}
        markerEnd={`url(#arrow-${dep.type})`}
        className="transition-opacity duration-200"
      />
    );
  };

  const ServiceNode: React.FC<{ service: ServiceMapItemDto }> = ({ service }) => {
    const colors = layerColors[service.layer] || layerColors.other;
    const isActive = activeServiceId === service.id;
    const isConnected = connectedServiceIds.has(service.id);
    const opacity = activeServiceId && !isConnected ? 0.3 : 1;

    return (
      <g
        className="cursor-pointer transition-all duration-200"
        transform={`translate(${service.x}, ${service.y})`}
        onMouseEnter={() => setHoveredService(service.id)}
        onMouseLeave={() => setHoveredService(null)}
        onClick={() => handleServiceClick(service.id)}
        style={{ opacity }}
      >
        <circle
          r={isActive ? 35 : 30}
          fill={colors.fill}
          stroke={isActive ? '#ffffff' : colors.stroke}
          strokeWidth={isActive ? 4 : 2}
          filter="url(#shadow)"
          className="transition-all duration-200"
        />
        <text
          y="0"
          textAnchor="middle"
          dominantBaseline="middle"
          fill={colors.text}
          fontSize="10"
          fontWeight="bold"
        >
          {service.shortName.length > 10 ? service.id : service.shortName}
        </text>
      </g>
    );
  };

  const ServiceDetail = () => {
    if (!selectedService) return null;
    const service = getServiceById(selectedService);
    if (!service) return null;

    const outgoing = dependencies.filter(d => d.from === selectedService);
    const incoming = dependencies.filter(d => d.to === selectedService);

    return (
      <div className="absolute top-4 right-4 w-80 bg-slate-800/95 backdrop-blur rounded-xl border border-slate-600 shadow-xl p-4">
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-3">
            <div
              className="w-10 h-10 rounded-lg flex items-center justify-center text-white font-bold"
              style={{ backgroundColor: layerColors[service.layer]?.fill }}
            >
              {service.id}
            </div>
            <div>
              <h3 className="text-white font-bold">{service.name}</h3>
              <span className="text-slate-400 text-xs capitalize">{service.layer} Layer</span>
            </div>
          </div>
          <button
            onClick={() => setSelectedService(null)}
            className="text-slate-400 hover:text-white"
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <line x1="18" y1="6" x2="6" y2="18" />
              <line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>
        </div>

        {outgoing.length > 0 && (
          <div className="mb-3">
            <h4 className="text-slate-400 text-xs font-semibold mb-2 uppercase">Leads to</h4>
            <div className="space-y-1">
              {outgoing.map((dep, i) => {
                const target = getServiceById(dep.to);
                return target ? (
                  <div key={i} className="flex items-center gap-2 text-sm">
                    <span
                      className="w-2 h-2 rounded-full"
                      style={{ backgroundColor: dependencyStyles[dep.type]?.stroke }}
                    />
                    <span className="text-white">{target.name}</span>
                    <span className="text-slate-500 text-xs">({dep.type})</span>
                  </div>
                ) : null;
              })}
            </div>
          </div>
        )}

        {incoming.length > 0 && (
          <div>
            <h4 className="text-slate-400 text-xs font-semibold mb-2 uppercase">Comes from</h4>
            <div className="space-y-1">
              {incoming.map((dep, i) => {
                const source = getServiceById(dep.from);
                return source ? (
                  <div key={i} className="flex items-center gap-2 text-sm">
                    <span
                      className="w-2 h-2 rounded-full"
                      style={{ backgroundColor: dependencyStyles[dep.type]?.stroke }}
                    />
                    <span className="text-white">{source.name}</span>
                    <span className="text-slate-500 text-xs">({dep.type})</span>
                  </div>
                ) : null;
              })}
            </div>
          </div>
        )}
      </div>
    );
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900 p-6">
      <div className="max-w-7xl mx-auto space-y-4">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-white">Service Architecture Map</h1>
            <p className="text-slate-400 text-sm">Interactive visualization of service dependencies</p>
          </div>

          <div className="flex items-center gap-4">
            {/* Zoom controls */}
            <div className="flex items-center gap-2 bg-slate-700/50 rounded-lg p-1">
              <button
                onClick={() => setZoom(z => Math.max(0.5, z - 0.1))}
                className="w-8 h-8 flex items-center justify-center text-slate-300 hover:text-white hover:bg-slate-600 rounded"
              >
                -
              </button>
              <span className="text-slate-300 text-sm w-12 text-center">{Math.round(zoom * 100)}%</span>
              <button
                onClick={() => setZoom(z => Math.min(2, z + 0.1))}
                className="w-8 h-8 flex items-center justify-center text-slate-300 hover:text-white hover:bg-slate-600 rounded"
              >
                +
              </button>
            </div>

            <button
              onClick={() => setShowLegend(!showLegend)}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition ${
                showLegend ? 'bg-blue-600 text-white' : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
              }`}
            >
              Legend
            </button>
          </div>
        </div>

        {/* Legend */}
        {showLegend && (
          <div className="flex flex-wrap items-center gap-6 bg-slate-800/50 backdrop-blur rounded-xl p-4 border border-slate-700">
            <div className="flex flex-wrap gap-4">
              <span className="text-slate-400">Layers:</span>
              {Object.entries(layerColors).map(([key, colors]) => (
                <div key={key} className="flex items-center gap-2">
                  <div className="w-4 h-4 rounded-full" style={{ backgroundColor: colors.fill }} />
                  <span className="text-white capitalize">{key}</span>
                </div>
              ))}
            </div>
            <div className="border-l border-slate-600 pl-4 flex flex-wrap gap-4">
              <span className="text-slate-400">Dependencies:</span>
              <div className="flex items-center gap-2">
                <div className="w-8 h-0.5 bg-red-500" />
                <span className="text-white">Required</span>
              </div>
              <div className="flex items-center gap-2">
                <div
                  className="w-8 h-0.5 bg-blue-500"
                  style={{ backgroundImage: 'repeating-linear-gradient(90deg, #3b82f6 0, #3b82f6 8px, transparent 8px, transparent 12px)' }}
                />
                <span className="text-white">Recommended</span>
              </div>
              <div className="flex items-center gap-2">
                <div
                  className="w-8 h-0.5"
                  style={{ backgroundImage: 'repeating-linear-gradient(90deg, #9ca3af 0, #9ca3af 4px, transparent 4px, transparent 8px)' }}
                />
                <span className="text-white">Optional</span>
              </div>
            </div>
          </div>
        )}

        {/* Spider Map */}
        <div className="relative bg-slate-800/50 backdrop-blur rounded-2xl border border-slate-700 overflow-hidden">
          <svg
            viewBox="0 0 800 550"
            className="w-full h-auto"
            style={{ transform: `scale(${zoom})`, transformOrigin: 'center', transition: 'transform 0.3s ease' }}
          >
            <defs>
              {/* Shadow filter */}
              <filter id="shadow" x="-50%" y="-50%" width="200%" height="200%">
                <feDropShadow dx="0" dy="4" stdDeviation="8" floodOpacity="0.3" />
              </filter>

              {/* Gradient background */}
              <radialGradient id="bgGradient" cx="50%" cy="50%" r="60%">
                <stop offset="0%" stopColor="#1e293b" stopOpacity="0.3" />
                <stop offset="100%" stopColor="#0f172a" stopOpacity="0.8" />
              </radialGradient>

              {/* Arrow markers */}
              <marker id="arrow-required" markerWidth="10" markerHeight="10" refX="9" refY="3" orient="auto">
                <path d="M0,0 L0,6 L9,3 z" fill="#ef4444" />
              </marker>
              <marker id="arrow-recommended" markerWidth="10" markerHeight="10" refX="9" refY="3" orient="auto">
                <path d="M0,0 L0,6 L9,3 z" fill="#3b82f6" />
              </marker>
              <marker id="arrow-optional" markerWidth="10" markerHeight="10" refX="9" refY="3" orient="auto">
                <path d="M0,0 L0,6 L9,3 z" fill="#9ca3af" />
              </marker>
            </defs>

            {/* Background */}
            <rect width="100%" height="100%" fill="url(#bgGradient)" />

            {/* Concentric circles for visual guidance */}
            <circle cx="400" cy="300" r="100" fill="none" stroke="#334155" strokeWidth="1" strokeDasharray="4,4" opacity="0.5" />
            <circle cx="400" cy="300" r="200" fill="none" stroke="#334155" strokeWidth="1" strokeDasharray="4,4" opacity="0.3" />
            <circle cx="400" cy="300" r="300" fill="none" stroke="#334155" strokeWidth="1" strokeDasharray="4,4" opacity="0.2" />

            {/* Dependency lines (drawn first, behind nodes) */}
            <g>
              {dependencies.map((dep, i) => (
                <DependencyLine
                  key={i}
                  dep={dep}
                  isHighlighted={!!activeServiceId && (dep.from === activeServiceId || dep.to === activeServiceId)}
                />
              ))}
            </g>

            {/* Service nodes */}
            <g>
              {services.map(service => (
                <ServiceNode key={service.id} service={service} />
              ))}
            </g>
          </svg>

          {/* Service Detail Panel */}
          <ServiceDetail />
        </div>

        {/* Instructions */}
        <div className="mt-4 text-center text-slate-400 text-sm flex items-center justify-center gap-2">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <circle cx="12" cy="12" r="10" />
            <line x1="12" y1="16" x2="12" y2="12" />
            <line x1="12" y1="8" x2="12.01" y2="8" />
          </svg>
          Hover over a service to highlight dependencies • Click for details
        </div>
      </div>
    </div>
  );
};

export default ServiceMap;
