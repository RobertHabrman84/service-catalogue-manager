import React, { useState, useEffect, useMemo, useRef, useCallback } from 'react';
import { CalculatorConfigDto, RoleDto } from '../../services/api/calculatorApi';

// Icons component
const Icon: React.FC<{ name: string; size?: number; className?: string }> = ({ name, size = 16, className = "" }) => {
  const icons: Record<string, React.ReactNode> = {
    settings: <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className={className}><circle cx="12" cy="12" r="3"/><path d="M12 1v2m0 18v2M4.22 4.22l1.42 1.42m12.72 12.72l1.42 1.42M1 12h2m18 0h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>,
    fileText: <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className={className}><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>,
    download: <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className={className}><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>,
    upload: <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className={className}><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>,
    chevronDown: <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className={className}><polyline points="6 9 12 15 18 9"/></svg>,
    check: <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className={className}><polyline points="20 6 9 17 4 12"/></svg>,
    x: <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className={className}><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>,
    building: <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className={className}><rect x="4" y="2" width="16" height="20" rx="2" ry="2"/><path d="M9 22v-4h6v4M8 6h.01M16 6h.01M12 6h.01M12 10h.01M12 14h.01M16 10h.01M16 14h.01M8 10h.01M8 14h.01"/></svg>,
    server: <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className={className}><rect x="2" y="2" width="20" height="8" rx="2" ry="2"/><rect x="2" y="14" width="20" height="8" rx="2" ry="2"/><line x1="6" y1="6" x2="6.01" y2="6"/><line x1="6" y1="18" x2="6.01" y2="18"/></svg>,
    checkSquare: <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className={className}><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>,
    shield: <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className={className}><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>,
    barChart: <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className={className}><line x1="12" y1="20" x2="12" y2="10"/><line x1="18" y1="20" x2="18" y2="4"/><line x1="6" y1="20" x2="6" y2="16"/></svg>,
    fileCode: <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className={className}><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><path d="M10 12l-2 2 2 2"/><path d="M14 12l2 2-2 2"/></svg>,
    alertTriangle: <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className={className}><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>,
    folderOpen: <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className={className}><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/><path d="M2 10h20"/></svg>,
    refreshCw: <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className={className}><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/></svg>,
    percent: <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className={className}><line x1="19" y1="5" x2="5" y2="19"/><circle cx="6.5" cy="6.5" r="2.5"/><circle cx="17.5" cy="17.5" r="2.5"/></svg>,
  };
  return <>{icons[name] || null}</>;
};

// Default config
const DEFAULT_CONFIG: Partial<CalculatorConfigDto> = {
  metadata: { name: "Universal Service Calculator", id: "ID0XX", version: "v1.0" },
  baseEffort: {
    kickoff: { hours: 16, label: "Project Coordination", description: "Kickoff, coordination, planning" },
    discovery: { hours: 24, label: "Discovery & Assessment", description: "Initial assessment, current state analysis" },
    handover: { hours: 12, label: "Handover & Training", description: "Final handover, knowledge transfer" }
  },
  pricing: { margin: 15, riskPremium: 5, contingency: 5, discount: 0, hoursPerDay: 8 },
  roles: [
    { id: 'cloudArchitect', name: 'Cloud Architect', dailyRate: 1500, isPrimary: true },
    { id: 'securityArchitect', name: 'Security Architect', dailyRate: 1400 },
    { id: 'platformEngineer', name: 'Platform Engineer', dailyRate: 1300 },
    { id: 'projectManager', name: 'Project Manager', dailyRate: 1100 }
  ],
  contextMultipliers: {
    documentation: { none: 0.15, partial: 0, complete: -0.10 },
    k8sExperience: { beginner: 0.20, intermediate: 0, expert: -0.15 },
    stakeholders: { low: 0, medium: 0, high: 0.15 },
    timeline: { relaxed: -0.05, normal: 0, aggressive: 0.10 }
  },
  teamComposition: {
    S: { cloudArchitect: 0.8, securityArchitect: 0.3, platformEngineer: 0.4, projectManager: 0.2 },
    M: { cloudArchitect: 1.0, securityArchitect: 0.5, platformEngineer: 0.6, projectManager: 0.3 },
    L: { cloudArchitect: 1.0, securityArchitect: 0.7, platformEngineer: 0.8, projectManager: 0.5 }
  },
  sections: [],
  scopeAreas: [],
  complexityFactors: [],
  scenarios: [],
  phases: []
};

interface ServiceCalculatorProps {
  config?: CalculatorConfigDto | null;
  logoUrl?: string;
}

interface CalculationResults {
  size: string;
  totalEffort: number;
  manDays: number;
  durationWeeks: number;
  baseCost: number;
  marginAmount: number;
  riskAmount: number;
  contingencyAmount: number;
  discountAmount: number;
  finalPrice: number;
  blendedRate: number;
  contextMultiplier: number;
  baseHours: number;
  scopeHours: number;
  complexityHours: number;
  rawEffort: number;
  teamComp: Record<string, number>;
  roles: RoleDto[];
  selectedScopes: string[];
}

const ServiceCalculator: React.FC<ServiceCalculatorProps> = ({ config: externalConfig, logoUrl }) => {
  const [config, setConfig] = useState<CalculatorConfigDto>({ ...DEFAULT_CONFIG, ...externalConfig } as CalculatorConfigDto);
  const [activeTab, setActiveTab] = useState('organization');
  const [resultTab, setResultTab] = useState('summary');
  const [showScenarios, setShowScenarios] = useState(false);
  const [showConfig, setShowConfig] = useState(false);
  const [showDocs, setShowDocs] = useState(false);
  const [showExport, setShowExport] = useState(false);
  const [configTab, setConfigTab] = useState('pricing');
  const [loadMessage, setLoadMessage] = useState<{ type: string; text: string } | null>(null);
  
  const [pricingSettings, setPricingSettings] = useState({
    margin: config.pricing?.margin || 15,
    riskPremium: config.pricing?.riskPremium || 5,
    contingency: config.pricing?.contingency || 5
  });
  
  const fileInputRef = useRef<HTMLInputElement>(null);
  
  const [paramValues, setParamValues] = useState<Record<string, string>>({});
  const [scopeSelection, setScopeSelection] = useState<Record<string, boolean>>({});
  const [complianceSelection, setComplianceSelection] = useState<Record<string, boolean>>({});
  const [contextValues, setContextValues] = useState<Record<string, string>>({});
  const [requirementsValues, setRequirementsValues] = useState<Record<string, string>>({
    securityPosture: 'standard',
    availability: 'standard',
    drRequirement: 'none'
  });

  // Update config when external config changes
  useEffect(() => {
    if (externalConfig) {
      setConfig({ ...DEFAULT_CONFIG, ...externalConfig } as CalculatorConfigDto);
      
      // Initialize param values with defaults
      const defaults: Record<string, string> = {};
      externalConfig.sections?.forEach(section => {
        section.groups?.forEach(group => {
          group.parameters?.forEach(param => {
            if (param.default) {
              defaults[param.id] = param.default;
            }
          });
        });
      });
      setParamValues(defaults);
      
      // Initialize required scope areas
      const reqScopes: Record<string, boolean> = {};
      externalConfig.scopeAreas?.forEach(area => {
        if (area.required) {
          reqScopes[area.id] = true;
        }
      });
      setScopeSelection(reqScopes);
      
      // Initialize context values with first option
      const ctxDefaults: Record<string, string> = {};
      Object.keys(externalConfig.contextMultipliers || {}).forEach(key => {
        const values = externalConfig.contextMultipliers?.[key];
        if (values) {
          const firstKey = Object.keys(values)[0];
          if (firstKey) {
            ctxDefaults[key] = firstKey;
          }
        }
      });
      setContextValues(ctxDefaults);
      
      // Update pricing settings
      if (externalConfig.pricing) {
        setPricingSettings({
          margin: externalConfig.pricing.margin || 15,
          riskPremium: externalConfig.pricing.riskPremium || 5,
          contingency: externalConfig.pricing.contingency || 5
        });
      }
    }
  }, [externalConfig]);

  const handleScopeChange = useCallback((scopeId: string) => {
    const area = config.scopeAreas?.find(a => a.id === scopeId);
    if (area?.required) return;
    
    const newValue = !scopeSelection[scopeId];
    if (newValue && area?.requires) {
      const missingDeps = area.requires.filter(reqId => !scopeSelection[reqId]);
      if (missingDeps.length > 0) return;
    }
    
    setScopeSelection(prev => {
      const updated = { ...prev, [scopeId]: newValue };
      if (!newValue) {
        config.scopeAreas?.forEach(a => {
          if (a.requires?.includes(scopeId)) updated[a.id] = false;
        });
      }
      return updated;
    });
  }, [config.scopeAreas, scopeSelection]);

  const calculateResults = useCallback((): CalculationResults => {
    const baseEffort = config.baseEffort || DEFAULT_CONFIG.baseEffort!;
    let baseHours = Object.values(baseEffort).reduce((sum, item) => sum + (item.hours || 0), 0);
    
    let scopeHours = 0;
    config.scopeAreas?.forEach(area => {
      if (scopeSelection[area.id]) scopeHours += area.hours || 0;
    });
    
    let complexityHours = 0;
    config.sections?.forEach(section => {
      section.groups?.forEach(group => {
        group.parameters?.forEach(param => {
          const option = param.options?.find(o => o.value === paramValues[param.id]);
          if (option?.complexityHours) complexityHours += option.complexityHours;
        });
      });
    });
    
    Object.entries(complianceSelection).forEach(([key, selected]) => {
      if (selected) {
        const factor = config.complexityFactors?.find(f => f.id === key);
        if (factor) complexityHours += factor.hours || 16;
      }
    });
    
    if (requirementsValues.securityPosture === 'zeroTrust') complexityHours += 24;
    if (requirementsValues.availability === 'critical') complexityHours += 16;
    if (requirementsValues.drRequirement === 'full') complexityHours += 24;
    
    const multipliers = config.contextMultipliers || DEFAULT_CONFIG.contextMultipliers!;
    let contextMultiplier = 1;
    Object.entries(contextValues).forEach(([key, value]) => {
      if (multipliers[key]?.[value]) contextMultiplier *= (1 + multipliers[key][value]);
    });
    
    const rawEffort = baseHours + scopeHours + complexityHours;
    const totalEffort = Math.round(rawEffort * contextMultiplier);
    
    let size = 'S';
    if (totalEffort > 300) size = 'L';
    else if (totalEffort > 150) size = 'M';
    
    const durationWeeks = size === 'S' ? 4 : size === 'M' ? 7 : 12;
    
    const pricing = config.pricing || DEFAULT_CONFIG.pricing!;
    const roles = config.roles || DEFAULT_CONFIG.roles!;
    const manDays = totalEffort / pricing.hoursPerDay;
    
    const teamComp = (config.teamComposition || DEFAULT_CONFIG.teamComposition!)?.[size] || { cloudArchitect: 1 };
    let totalFte = 0, weightedRate = 0;
    roles.forEach(role => {
      const fte = teamComp[role.id] || 0;
      totalFte += fte;
      weightedRate += role.dailyRate * fte;
    });
    const blendedRate = totalFte > 0 ? Math.round(weightedRate / totalFte) : 1400;
    
    const baseCost = manDays * blendedRate;
    const marginAmount = baseCost * (pricingSettings.margin / 100);
    const riskAmount = baseCost * (pricingSettings.riskPremium / 100);
    const contingencyAmount = baseCost * (pricingSettings.contingency / 100);
    const discountAmount = baseCost * (pricing.discount / 100);
    const finalPrice = baseCost + marginAmount + riskAmount + contingencyAmount - discountAmount;
    
    return {
      size,
      totalEffort,
      manDays: Math.round(manDays * 10) / 10,
      durationWeeks,
      baseCost: Math.round(baseCost),
      marginAmount: Math.round(marginAmount),
      riskAmount: Math.round(riskAmount),
      contingencyAmount: Math.round(contingencyAmount),
      discountAmount: Math.round(discountAmount),
      finalPrice: Math.round(finalPrice),
      blendedRate,
      contextMultiplier,
      baseHours,
      scopeHours,
      complexityHours,
      rawEffort,
      teamComp,
      roles,
      selectedScopes: Object.entries(scopeSelection).filter(([, v]) => v).map(([k]) => k)
    };
  }, [config, paramValues, scopeSelection, complianceSelection, contextValues, requirementsValues, pricingSettings]);
  
  const results = useMemo(() => calculateResults(), [calculateResults]);

  const applyScenario = useCallback((scenario: { values: Record<string, string> }) => {
    setParamValues(prev => ({ ...prev, ...scenario.values }));
    setShowScenarios(false);
  }, []);

  const exportResults = useCallback((format: string) => {
    const data = { 
      service: config.metadata, 
      results, 
      parameters: paramValues, 
      scope: scopeSelection, 
      context: contextValues, 
      pricingSettings 
    };
    if (format === 'json') {
      const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
      const a = document.createElement('a');
      a.href = URL.createObjectURL(blob);
      a.download = `${config.metadata?.name?.replace(/\s+/g, '-') || 'estimate'}.json`;
      a.click();
    }
  }, [config.metadata, results, paramValues, scopeSelection, contextValues, pricingSettings]);

  const tabs = [
    { id: 'organization', label: 'Organization', icon: 'building' },
    { id: 'technical', label: 'Technical', icon: 'server' },
    { id: 'scope', label: 'Scope', icon: 'checkSquare' },
    { id: 'requirements', label: 'Requirements', icon: 'shield' },
    { id: 'context', label: 'Context', icon: 'barChart' }
  ];

  const resultTabs = ['Summary', 'Costs', 'Team', 'Phases', 'Deliverables'];
  const getSizeColor = (s: string) => s === 'S' ? 'bg-emerald-600' : s === 'M' ? 'bg-amber-500' : 'bg-rose-600';
  const formatCurrency = (v: number) => `€${v.toLocaleString()}`;

  const scopeCategories = useMemo(() => [...new Set(config.scopeAreas?.map(a => a.category) || [])], [config.scopeAreas]);

  const activeSection = useMemo(() => config.sections?.find(s => s.id === activeTab), [config.sections, activeTab]);

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 via-blue-50 to-gray-100">
      {loadMessage && (
        <div className={`fixed top-4 right-4 z-50 px-4 py-3 rounded-lg shadow-lg flex items-center gap-2 ${
          loadMessage.type === 'success' ? 'bg-emerald-500 text-white' : 'bg-rose-500 text-white'
        }`}>
          <Icon name={loadMessage.type === 'success' ? 'check' : 'alertTriangle'} size={18} />
          {loadMessage.text}
        </div>
      )}

      {/* Header */}
      <header className="bg-blue-900 border-b border-blue-800 shadow-lg sticky top-0 z-40">
        <div className="max-w-7xl mx-auto px-4 py-3">
          <div className="flex items-center justify-between flex-wrap gap-4">
            <div className="flex items-center gap-4">
              {logoUrl && (
                <img src={logoUrl} alt="Logo" className="h-10 brightness-0 invert" style={{ height: '40px' }} />
              )}
              <div className={logoUrl ? "border-l-2 border-blue-700 pl-4" : ""}>
                <h1 className="text-lg font-bold text-white">{config.metadata?.name}</h1>
                <p className="text-xs text-blue-200">Sizing & Effort Calculator {config.metadata?.version} | ID: {config.metadata?.id}</p>
              </div>
            </div>
            
            <div className="flex items-center gap-2">
              {config.scenarios && config.scenarios.length > 0 && (
                <div className="relative">
                  <button 
                    onClick={() => setShowScenarios(!showScenarios)} 
                    className="flex items-center gap-2 px-4 py-2 bg-blue-700 rounded-lg text-sm hover:bg-blue-600 text-white font-medium"
                  >
                    <Icon name="fileCode" size={16} />
                    <span className="hidden sm:inline">Scenarios</span>
                    <Icon name="chevronDown" size={14} />
                  </button>
                  {showScenarios && (
                    <div className="absolute right-0 top-full mt-2 w-72 bg-white rounded-xl shadow-2xl border border-gray-200 z-50 overflow-hidden">
                      <div className="px-4 py-3 bg-blue-50 border-b border-blue-100">
                        <span className="text-sm font-semibold text-blue-900">Quick-Start Scenarios</span>
                      </div>
                      <div className="max-h-64 overflow-y-auto">
                        {config.scenarios.map(s => (
                          <button
                            key={s.id}
                            onClick={() => applyScenario(s)}
                            className="w-full text-left px-4 py-3 hover:bg-blue-50 border-b border-gray-100 last:border-b-0"
                          >
                            <div className="font-medium text-sm text-gray-900">{s.name}</div>
                            {s.description && <div className="text-xs text-gray-500 mt-0.5">{s.description}</div>}
                          </button>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              )}
              <button 
                onClick={() => setShowConfig(true)} 
                className="flex items-center gap-2 px-4 py-2 bg-blue-700 rounded-lg text-sm hover:bg-blue-600 text-white font-medium"
              >
                <Icon name="settings" size={16} />
                <span className="hidden sm:inline">Config</span>
              </button>
              <button 
                onClick={() => setShowExport(true)} 
                className="flex items-center gap-2 px-4 py-2 bg-blue-700 rounded-lg text-sm hover:bg-blue-600 text-white font-medium"
              >
                <Icon name="download" size={16} />
                <span className="hidden sm:inline">Export</span>
              </button>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 py-6">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Left Panel - Configuration */}
          <div className="lg:col-span-2 space-y-4">
            {/* Tabs */}
            <div className="bg-white rounded-2xl shadow-md overflow-hidden border border-gray-200">
              <div className="flex overflow-x-auto border-b border-gray-200 bg-gray-50">
                {tabs.map(tab => (
                  <button
                    key={tab.id}
                    onClick={() => setActiveTab(tab.id)}
                    className={`flex items-center gap-2 px-5 py-3.5 text-sm font-medium whitespace-nowrap transition ${
                      activeTab === tab.id
                        ? 'bg-white text-blue-900 border-b-2 border-blue-900 -mb-px'
                        : 'text-gray-500 hover:text-gray-700 hover:bg-gray-100'
                    }`}
                  >
                    <Icon name={tab.icon} size={16} />
                    {tab.label}
                  </button>
                ))}
              </div>

              <div className="p-5">
                {/* Parameter Sections */}
                {activeSection && (
                  <div className="space-y-6">
                    {activeSection.groups?.map((group, gi) => (
                      <div key={gi} className="space-y-4">
                        <h3 className="text-sm font-semibold text-blue-900 uppercase tracking-wide">{group.title}</h3>
                        <div className="space-y-4">
                          {group.parameters?.map(param => (
                            <div key={param.id} className="space-y-2">
                              <label className="text-sm font-medium text-gray-700 flex items-center gap-1">
                                {param.label}
                                {param.required && <span className="text-rose-500">*</span>}
                              </label>
                              <div className="grid grid-cols-2 gap-2">
                                {param.options?.map(option => (
                                  <button
                                    key={option.value}
                                    onClick={() => setParamValues(prev => ({ ...prev, [param.id]: option.value }))}
                                    className={`px-3 py-2.5 rounded-lg text-sm text-left border transition ${
                                      paramValues[param.id] === option.value
                                        ? 'bg-blue-900 text-white border-blue-900'
                                        : 'bg-white text-gray-700 border-gray-200 hover:border-blue-300'
                                    }`}
                                  >
                                    <div className="flex items-center justify-between">
                                      <span>{option.label}</span>
                                      {option.sizeImpact && (
                                        <span className={`ml-2 px-1.5 py-0.5 text-xs rounded ${
                                          option.sizeImpact === 'L' ? 'bg-rose-100 text-rose-700' : 
                                          option.sizeImpact === 'M' ? 'bg-amber-100 text-amber-700' : 
                                          'bg-emerald-100 text-emerald-700'
                                        }`}>
                                          {option.sizeImpact}
                                        </span>
                                      )}
                                    </div>
                                    {option.complexityHours && (
                                      <div className="text-xs mt-0.5 opacity-75">+{option.complexityHours}h</div>
                                    )}
                                  </button>
                                ))}
                              </div>
                            </div>
                          ))}
                        </div>
                      </div>
                    ))}
                  </div>
                )}

                {/* Scope Tab */}
                {activeTab === 'scope' && (
                  <div className="space-y-6">
                    {config.scopeAreas && config.scopeAreas.length > 0 ? (
                      <>
                        <p className="text-sm text-gray-600 bg-blue-50 p-3 rounded-lg border border-blue-100">
                          💡 Select design areas to include. Each adds specific deliverables and effort.
                        </p>
                        {scopeCategories.map(cat => (
                          <div key={cat || 'default'}>
                            <h3 className="text-sm font-semibold text-blue-900 mb-3 uppercase tracking-wide">{cat || 'General'}</h3>
                            <div className="space-y-2">
                              {config.scopeAreas?.filter(a => a.category === cat).map(area => {
                                const hasMissingDeps = area.requires?.some(r => !scopeSelection[r]);
                                return (
                                  <div
                                    key={area.id}
                                    onClick={() => !hasMissingDeps && handleScopeChange(area.id)}
                                    className={`flex items-start gap-3 p-4 rounded-xl border-2 transition cursor-pointer ${
                                      scopeSelection[area.id]
                                        ? 'bg-blue-50 border-blue-300'
                                        : hasMissingDeps
                                        ? 'bg-gray-50 border-gray-100 opacity-50 cursor-not-allowed'
                                        : 'bg-white border-gray-100 hover:border-blue-200'
                                    }`}
                                  >
                                    <div className={`w-6 h-6 rounded-md flex items-center justify-center flex-shrink-0 ${
                                      scopeSelection[area.id] ? 'bg-blue-900' : 'bg-gray-200'
                                    }`}>
                                      {scopeSelection[area.id] && <Icon name="check" size={14} className="text-white" />}
                                    </div>
                                    <div className="flex-1">
                                      <div className="flex items-center gap-2">
                                        <span className="text-sm font-semibold text-gray-900">{area.name}</span>
                                        {area.required && (
                                          <span className="text-xs bg-amber-100 text-amber-700 px-2 py-0.5 rounded-full">Required</span>
                                        )}
                                      </div>
                                      {area.requires && hasMissingDeps && (
                                        <div className="flex items-center gap-1 mt-1 text-xs text-amber-600">
                                          <Icon name="alertTriangle" size={12} />
                                          Requires: {area.requires.map(r => config.scopeAreas?.find(a => a.id === r)?.name).join(', ')}
                                        </div>
                                      )}
                                      {area.description && <p className="text-xs text-gray-500 mt-1">{area.description}</p>}
                                    </div>
                                    <span className="text-sm font-bold text-blue-900 bg-blue-100 px-2 py-1 rounded">{area.hours}h</span>
                                  </div>
                                );
                              })}
                            </div>
                          </div>
                        ))}
                        {config.complexityFactors && config.complexityFactors.length > 0 && (
                          <div>
                            <h3 className="text-sm font-semibold text-blue-900 mb-3 uppercase tracking-wide">Compliance Frameworks</h3>
                            <div className="flex flex-wrap gap-2">
                              {config.complexityFactors.map(f => (
                                <button
                                  key={f.id}
                                  onClick={() => setComplianceSelection(p => ({ ...p, [f.id]: !p[f.id] }))}
                                  className={`px-4 py-2 rounded-lg text-sm border-2 font-medium transition ${
                                    complianceSelection[f.id]
                                      ? 'bg-blue-900 text-white border-blue-900'
                                      : 'bg-white text-gray-700 border-gray-200 hover:border-blue-300'
                                  }`}
                                >
                                  {f.label}
                                </button>
                              ))}
                            </div>
                          </div>
                        )}
                      </>
                    ) : (
                      <div className="text-center py-12 text-gray-500">
                        <Icon name="folderOpen" size={48} className="mx-auto mb-4 opacity-50" />
                        <p>No scope areas configured.</p>
                      </div>
                    )}
                  </div>
                )}

                {/* Requirements Tab */}
                {activeTab === 'requirements' && (
                  <div className="space-y-5">
                    {[
                      {
                        id: 'securityPosture',
                        label: 'Security Posture',
                        options: [
                          { value: 'standard', label: 'Standard' },
                          { value: 'enhanced', label: 'Enhanced' },
                          { value: 'zeroTrust', label: 'Full Zero Trust' }
                        ]
                      },
                      {
                        id: 'availability',
                        label: 'Availability Target',
                        options: [
                          { value: 'standard', label: 'Standard (99.9%)' },
                          { value: 'high', label: 'High (99.95%)' },
                          { value: 'critical', label: 'Critical (99.99%)' }
                        ]
                      },
                      {
                        id: 'drRequirement',
                        label: 'Disaster Recovery',
                        options: [
                          { value: 'none', label: 'None' },
                          { value: 'basic', label: 'Basic (Backup)' },
                          { value: 'standard', label: 'Active-Passive' },
                          { value: 'full', label: 'Active-Active' }
                        ]
                      }
                    ].map(p => (
                      <div key={p.id} className="space-y-2">
                        <label className="text-sm font-medium text-gray-700">{p.label}</label>
                        <div className="grid grid-cols-2 gap-2">
                          {p.options.map(o => (
                            <button
                              key={o.value}
                              onClick={() => setRequirementsValues(prev => ({ ...prev, [p.id]: o.value }))}
                              className={`px-3 py-2.5 rounded-lg text-sm text-left border transition ${
                                requirementsValues[p.id] === o.value
                                  ? 'bg-blue-900 text-white border-blue-900'
                                  : 'bg-white text-gray-700 border-gray-200 hover:border-blue-300'
                              }`}
                            >
                              {o.label}
                            </button>
                          ))}
                        </div>
                      </div>
                    ))}
                  </div>
                )}

                {/* Context Tab */}
                {activeTab === 'context' && (
                  <div className="space-y-5">
                    {Object.entries(config.contextMultipliers || {}).map(([key, values]) => (
                      <div key={key} className="space-y-2">
                        <label className="text-sm font-medium text-gray-700 capitalize">
                          {key.replace(/([A-Z])/g, ' $1').trim()}
                        </label>
                        <div className="grid grid-cols-3 gap-2">
                          {Object.entries(values).map(([vKey, vVal]) => (
                            <button
                              key={vKey}
                              onClick={() => setContextValues(prev => ({ ...prev, [key]: vKey }))}
                              className={`px-3 py-2.5 rounded-lg text-sm text-left border transition ${
                                contextValues[key] === vKey
                                  ? 'bg-blue-900 text-white border-blue-900'
                                  : 'bg-white text-gray-700 border-gray-200 hover:border-blue-300'
                              }`}
                            >
                              <div className="capitalize">{vKey}</div>
                              <div className="text-xs opacity-75">
                                {vVal > 0 ? `+${(vVal * 100).toFixed(0)}%` : vVal < 0 ? `${(vVal * 100).toFixed(0)}%` : '0%'}
                              </div>
                            </button>
                          ))}
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Right Panel - Results */}
          <div className="space-y-4">
            {/* Size Badge */}
            <div className="bg-white rounded-2xl shadow-md p-5 border border-gray-200">
              <div className="flex items-center justify-between mb-4">
                <span className="text-sm font-medium text-gray-600">Project Size</span>
                <div className={`${getSizeColor(results.size)} text-white w-12 h-12 rounded-xl flex items-center justify-center text-2xl font-bold shadow-lg`}>
                  {results.size}
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4 text-center">
                <div className="bg-gray-50 rounded-xl p-3">
                  <div className="text-2xl font-bold text-blue-900">{results.totalEffort}</div>
                  <div className="text-xs text-gray-500">Total Hours</div>
                </div>
                <div className="bg-gray-50 rounded-xl p-3">
                  <div className="text-2xl font-bold text-blue-900">{results.durationWeeks}</div>
                  <div className="text-xs text-gray-500">Weeks</div>
                </div>
              </div>
              <div className="mt-4 pt-4 border-t border-gray-200">
                <div className="flex items-center justify-between">
                  <span className="text-sm text-gray-600">Total Price</span>
                  <span className="text-2xl font-bold text-blue-900">{formatCurrency(results.finalPrice)}</span>
                </div>
              </div>
            </div>

            {/* Result Tabs */}
            <div className="bg-white rounded-2xl shadow-md overflow-hidden border border-gray-200">
              <div className="flex overflow-x-auto border-b border-gray-200 bg-gray-50">
                {resultTabs.map(tab => (
                  <button
                    key={tab}
                    onClick={() => setResultTab(tab.toLowerCase())}
                    className={`px-4 py-2.5 text-xs font-medium whitespace-nowrap transition ${
                      resultTab === tab.toLowerCase()
                        ? 'bg-white text-blue-900 border-b-2 border-blue-900 -mb-px'
                        : 'text-gray-500 hover:text-gray-700'
                    }`}
                  >
                    {tab}
                  </button>
                ))}
              </div>

              <div className="p-4">
                {resultTab === 'summary' && (
                  <div className="space-y-3">
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600">Base Effort</span>
                      <span className="font-medium">{results.baseHours}h</span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600">Scope Areas</span>
                      <span className="font-medium">{results.scopeHours}h</span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600">Complexity</span>
                      <span className="font-medium">{results.complexityHours}h</span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600">Context Multiplier</span>
                      <span className="font-medium">×{results.contextMultiplier.toFixed(2)}</span>
                    </div>
                    <div className="border-t pt-3 flex justify-between text-sm font-semibold">
                      <span>Total Effort</span>
                      <span className="text-blue-900">{results.totalEffort}h</span>
                    </div>
                  </div>
                )}

                {resultTab === 'costs' && (
                  <div className="space-y-3">
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600">Man-Days</span>
                      <span className="font-medium">{results.manDays}</span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600">Blended Rate</span>
                      <span className="font-medium">{formatCurrency(results.blendedRate)}/day</span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600">Base Cost</span>
                      <span className="font-medium">{formatCurrency(results.baseCost)}</span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600">Margin ({pricingSettings.margin}%)</span>
                      <span className="font-medium">+{formatCurrency(results.marginAmount)}</span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600">Risk ({pricingSettings.riskPremium}%)</span>
                      <span className="font-medium">+{formatCurrency(results.riskAmount)}</span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600">Contingency ({pricingSettings.contingency}%)</span>
                      <span className="font-medium">+{formatCurrency(results.contingencyAmount)}</span>
                    </div>
                    <div className="border-t pt-3 flex justify-between text-sm font-semibold">
                      <span>Final Price</span>
                      <span className="text-blue-900">{formatCurrency(results.finalPrice)}</span>
                    </div>
                  </div>
                )}

                {resultTab === 'team' && (
                  <div className="space-y-3">
                    {results.roles.map(role => {
                      const fte = results.teamComp[role.id] || 0;
                      return (
                        <div key={role.id} className="flex justify-between text-sm">
                          <span className="text-gray-600">{role.name}</span>
                          <span className="font-medium">{(fte * 100).toFixed(0)}% FTE</span>
                        </div>
                      );
                    })}
                  </div>
                )}

                {resultTab === 'phases' && (
                  <div className="space-y-3">
                    {config.phases?.map(phase => (
                      <div key={phase.id} className="flex justify-between text-sm">
                        <span className="text-gray-600">{phase.name}</span>
                        <span className="font-medium">{phase.durationBySize?.[results.size] || '-'}</span>
                      </div>
                    ))}
                  </div>
                )}

                {resultTab === 'deliverables' && (
                  <div className="space-y-2">
                    {results.selectedScopes.map(scopeId => {
                      const area = config.scopeAreas?.find(a => a.id === scopeId);
                      return area ? (
                        <div key={scopeId} className="flex justify-between text-sm">
                          <span className="text-gray-600">{area.name}</span>
                          <span className="font-medium">{area.hours}h</span>
                        </div>
                      ) : null;
                    })}
                  </div>
                )}
              </div>
            </div>

            {/* Size Reference */}
            <div className="bg-white rounded-2xl shadow-md p-4 border border-gray-200">
              <h3 className="text-sm font-semibold text-gray-700 mb-3">Size Reference</h3>
              <div className="grid grid-cols-3 gap-2">
                <div className="text-center p-2 bg-emerald-50 border border-emerald-200 rounded-lg">
                  <div className="w-8 h-8 bg-emerald-600 text-white rounded-full flex items-center justify-center font-bold mx-auto mb-1">S</div>
                  <div className="text-xs text-emerald-700">≤150h</div>
                </div>
                <div className="text-center p-2 bg-amber-50 border border-amber-200 rounded-lg">
                  <div className="w-8 h-8 bg-amber-500 text-white rounded-full flex items-center justify-center font-bold mx-auto mb-1">M</div>
                  <div className="text-xs text-amber-700">151-300h</div>
                </div>
                <div className="text-center p-2 bg-rose-50 border border-rose-200 rounded-lg">
                  <div className="w-8 h-8 bg-rose-600 text-white rounded-full flex items-center justify-center font-bold mx-auto mb-1">L</div>
                  <div className="text-xs text-rose-700">&gt;300h</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Config Modal */}
      {showConfig && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl w-full max-w-lg overflow-hidden shadow-2xl">
            <div className="flex items-center justify-between p-5 border-b bg-gradient-to-r from-blue-900 to-blue-800">
              <h2 className="font-bold text-white text-lg">Pricing Configuration</h2>
              <button onClick={() => setShowConfig(false)} className="text-white/80 hover:text-white">
                <Icon name="x" size={24} />
              </button>
            </div>
            <div className="p-5 space-y-4">
              <div>
                <label className="text-sm font-medium text-gray-700 block mb-2">Margin (%)</label>
                <input
                  type="number"
                  value={pricingSettings.margin}
                  onChange={(e) => setPricingSettings(p => ({ ...p, margin: Number(e.target.value) }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                />
              </div>
              <div>
                <label className="text-sm font-medium text-gray-700 block mb-2">Risk Premium (%)</label>
                <input
                  type="number"
                  value={pricingSettings.riskPremium}
                  onChange={(e) => setPricingSettings(p => ({ ...p, riskPremium: Number(e.target.value) }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                />
              </div>
              <div>
                <label className="text-sm font-medium text-gray-700 block mb-2">Contingency (%)</label>
                <input
                  type="number"
                  value={pricingSettings.contingency}
                  onChange={(e) => setPricingSettings(p => ({ ...p, contingency: Number(e.target.value) }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                />
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Export Modal */}
      {showExport && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl w-full max-w-md overflow-hidden shadow-2xl">
            <div className="flex items-center justify-between p-5 border-b bg-gradient-to-r from-blue-900 to-blue-800">
              <h2 className="font-bold text-white text-lg">Export Results</h2>
              <button onClick={() => setShowExport(false)} className="text-white/80 hover:text-white">
                <Icon name="x" size={24} />
              </button>
            </div>
            <div className="p-5 space-y-3">
              <button
                onClick={() => window.print()}
                className="w-full flex items-center gap-4 px-5 py-4 bg-gray-50 border border-gray-200 rounded-xl hover:bg-blue-50 transition"
              >
                <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                  <Icon name="fileText" size={20} className="text-blue-900" />
                </div>
                <div className="text-left">
                  <div className="font-semibold text-gray-900">Print</div>
                  <div className="text-xs text-gray-500">Print or save as PDF</div>
                </div>
              </button>
              <button
                onClick={() => exportResults('json')}
                className="w-full flex items-center gap-4 px-5 py-4 bg-gray-50 border border-gray-200 rounded-xl hover:bg-blue-50 transition"
              >
                <div className="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                  <Icon name="download" size={20} className="text-blue-900" />
                </div>
                <div className="text-left">
                  <div className="font-semibold text-gray-900">Download JSON</div>
                  <div className="text-xs text-gray-500">Full calculation data</div>
                </div>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Footer */}
      <footer className="max-w-7xl mx-auto px-4 py-4 text-center text-xs text-gray-400 border-t border-gray-200 mt-8">
        {config.metadata?.name} — Calculator {config.metadata?.version} | ID: {config.metadata?.id} | Estimates are indicative
      </footer>
    </div>
  );
};

export default ServiceCalculator;
