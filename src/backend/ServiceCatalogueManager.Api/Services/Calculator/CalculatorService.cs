using Microsoft.EntityFrameworkCore;
using ServiceCatalogueManager.Api.Data.DbContext;
using ServiceCatalogueManager.Api.Data.Entities;
using System.Text.Json;

namespace ServiceCatalogueManager.Api.Services.Calculator;

/// <summary>
/// Service for calculator configuration operations
/// </summary>
public interface ICalculatorService
{
    Task<CalculatorConfigDto?> GetCalculatorConfigAsync(int serviceId);
    Task<ServiceMapDto> GetServiceMapAsync();
}

/// <summary>
/// Implementation of calculator service
/// </summary>
public class CalculatorService : ICalculatorService
{
    private readonly ServiceCatalogDbContext _context;

    public CalculatorService(ServiceCatalogDbContext context)
    {
        _context = context;
    }

    public async Task<CalculatorConfigDto?> GetCalculatorConfigAsync(int serviceId)
    {
        var service = await _context.ServiceCatalogItems
            .Include(s => s.Category)
            .FirstOrDefaultAsync(s => s.ServiceId == serviceId);

        if (service == null) return null;

        // Load all calculator-related data
        var pricingConfig = await _context.ServicePricingConfigs
            .FirstOrDefaultAsync(p => p.ServiceId == serviceId);

        var roleRates = await _context.ServiceRoleRates
            .Where(r => r.ServiceId == serviceId)
            .OrderBy(r => r.SortOrder)
            .ToListAsync();

        var baseEfforts = await _context.ServiceBaseEfforts
            .Where(e => e.ServiceId == serviceId)
            .OrderBy(e => e.SortOrder)
            .ToListAsync();

        var contextMultipliers = await _context.ServiceContextMultipliers
            .Include(m => m.Values.OrderBy(v => v.SortOrder))
            .Where(m => m.ServiceId == serviceId)
            .OrderBy(m => m.SortOrder)
            .ToListAsync();

        var scopeAreas = await _context.ServiceScopeAreas
            .Where(a => a.ServiceId == serviceId)
            .OrderBy(a => a.SortOrder)
            .ToListAsync();

        var complianceFactors = await _context.ServiceComplianceFactors
            .Where(f => f.ServiceId == serviceId)
            .OrderBy(f => f.SortOrder)
            .ToListAsync();

        var sections = await _context.ServiceCalculatorSections
            .Include(s => s.Groups.OrderBy(g => g.SortOrder))
                .ThenInclude(g => g.Parameters.OrderBy(p => p.SortOrder))
                    .ThenInclude(p => p.Options.OrderBy(o => o.SortOrder))
            .Where(s => s.ServiceId == serviceId)
            .OrderBy(s => s.SortOrder)
            .ToListAsync();

        var scenarios = await _context.ServiceCalculatorScenarios
            .Where(s => s.ServiceId == serviceId)
            .OrderBy(s => s.SortOrder)
            .ToListAsync();

        var phases = await _context.ServiceCalculatorPhases
            .Where(p => p.ServiceId == serviceId)
            .OrderBy(p => p.SortOrder)
            .ToListAsync();

        var teamCompositions = await _context.ServiceTeamCompositions
            .Where(t => t.ServiceId == serviceId)
            .OrderBy(t => t.SizeCode)
            .ThenBy(t => t.SortOrder)
            .ToListAsync();

        var sizingCriteria = await _context.ServiceSizingCriterias
            .Where(c => c.ServiceId == serviceId)
            .ToListAsync();

        // Build the DTO
        return new CalculatorConfigDto
        {
            Metadata = new MetadataDto
            {
                Name = service.ServiceName,
                Id = service.ServiceCode,
                Version = service.Version ?? "v1.0",
                Category = service.Category?.CategoryPath ?? service.Category?.Name
            },
            BaseEffort = BuildBaseEffort(baseEfforts),
            Pricing = BuildPricing(pricingConfig),
            Roles = BuildRoles(roleRates),
            TeamComposition = BuildTeamComposition(teamCompositions, roleRates),
            ContextMultipliers = BuildContextMultipliers(contextMultipliers),
            Sections = BuildSections(sections),
            ScopeAreas = BuildScopeAreas(scopeAreas),
            ComplexityFactors = BuildComplexityFactors(complianceFactors),
            Scenarios = BuildScenarios(scenarios),
            Phases = BuildPhases(phases),
            SizingCriteria = BuildSizingCriteria(sizingCriteria)
        };
    }

    public async Task<ServiceMapDto> GetServiceMapAsync()
    {
        var services = await _context.ServiceCatalogItems
            .Include(s => s.Category)
            .Where(s => s.IsActive)
            .OrderBy(s => s.ServiceCode)
            .Select(s => new ServiceMapItemDto
            {
                Id = s.ServiceCode,
                Name = s.ServiceName,
                ShortName = s.ServiceCode,
                Layer = DetermineLayer(s.Category != null ? s.Category.Name : "other"),
                X = 400, // Default position - would need to be customizable
                Y = 300
            })
            .ToListAsync();

        var dependencies = await _context.ServiceDependencies
            .Include(d => d.Service)
            .Include(d => d.DependencyType)
            .Where(d => d.DependentOnServiceCode != null)
            .Select(d => new ServiceMapDependencyDto
            {
                From = d.Service != null ? d.Service.ServiceCode : "",
                To = d.DependentOnServiceCode ?? "",
                Type = MapDependencyType(d.DependencyType != null ? d.DependencyType.Code : "optional")
            })
            .ToListAsync();

        return new ServiceMapDto
        {
            Services = services,
            Dependencies = dependencies
        };
    }

    private static string DetermineLayer(string categoryName)
    {
        var lower = categoryName.ToLowerInvariant();
        if (lower.Contains("assessment")) return "assessment";
        if (lower.Contains("infra")) return "infra";
        if (lower.Contains("platform")) return "platform";
        if (lower.Contains("entry") || lower.Contains("initial")) return "entry";
        return "other";
    }

    private static string MapDependencyType(string code)
    {
        return code.ToLowerInvariant() switch
        {
            "required" or "mandatory" => "required",
            "recommended" => "recommended",
            _ => "optional"
        };
    }

    private static Dictionary<string, BaseEffortItemDto> BuildBaseEffort(List<ServiceBaseEffort> efforts)
    {
        var result = new Dictionary<string, BaseEffortItemDto>();
        foreach (var effort in efforts)
        {
            result[effort.EffortCode] = new BaseEffortItemDto
            {
                Hours = effort.Hours,
                Label = effort.Label,
                Description = effort.Description
            };
        }
        // Ensure default values exist
        if (!result.ContainsKey("kickoff"))
            result["kickoff"] = new BaseEffortItemDto { Hours = 16, Label = "Project Coordination", Description = "Kickoff, coordination, planning" };
        if (!result.ContainsKey("discovery"))
            result["discovery"] = new BaseEffortItemDto { Hours = 24, Label = "Discovery & Assessment", Description = "Initial assessment, current state analysis" };
        if (!result.ContainsKey("handover"))
            result["handover"] = new BaseEffortItemDto { Hours = 12, Label = "Handover & Training", Description = "Final handover, knowledge transfer" };
        return result;
    }

    private static PricingDto BuildPricing(ServicePricingConfig? config)
    {
        return config != null ? new PricingDto
        {
            Margin = (double)config.Margin,
            RiskPremium = (double)config.RiskPremium,
            Contingency = (double)config.Contingency,
            Discount = (double)config.Discount,
            HoursPerDay = config.HoursPerDay
        } : new PricingDto { Margin = 15, RiskPremium = 5, Contingency = 5, Discount = 0, HoursPerDay = 8 };
    }

    private static List<RoleDto> BuildRoles(List<ServiceRoleRate> rates)
    {
        if (!rates.Any())
        {
            // Return defaults
            return new List<RoleDto>
            {
                new() { Id = "cloudArchitect", Name = "Cloud Architect", DailyRate = 1500, IsPrimary = true },
                new() { Id = "securityArchitect", Name = "Security Architect", DailyRate = 1400 },
                new() { Id = "platformEngineer", Name = "Platform Engineer", DailyRate = 1300 },
                new() { Id = "projectManager", Name = "Project Manager", DailyRate = 1100 }
            };
        }

        return rates.Select(r => new RoleDto
        {
            Id = r.RoleCode,
            Name = r.RoleName,
            DailyRate = (double)r.DailyRate,
            IsPrimary = r.IsPrimary
        }).ToList();
    }

    private static Dictionary<string, Dictionary<string, double>> BuildTeamComposition(
        List<ServiceTeamComposition> compositions, List<ServiceRoleRate> roles)
    {
        var result = new Dictionary<string, Dictionary<string, double>>();

        if (!compositions.Any())
        {
            // Return defaults
            return new Dictionary<string, Dictionary<string, double>>
            {
                ["S"] = new() { ["cloudArchitect"] = 0.8, ["securityArchitect"] = 0.3, ["platformEngineer"] = 0.4, ["projectManager"] = 0.2 },
                ["M"] = new() { ["cloudArchitect"] = 1.0, ["securityArchitect"] = 0.5, ["platformEngineer"] = 0.6, ["projectManager"] = 0.3 },
                ["L"] = new() { ["cloudArchitect"] = 1.0, ["securityArchitect"] = 0.7, ["platformEngineer"] = 0.8, ["projectManager"] = 0.5 }
            };
        }

        foreach (var comp in compositions)
        {
            if (!result.ContainsKey(comp.SizeCode))
                result[comp.SizeCode] = new Dictionary<string, double>();
            result[comp.SizeCode][comp.RoleCode] = (double)comp.FteAllocation;
        }

        return result;
    }

    private static Dictionary<string, Dictionary<string, double>> BuildContextMultipliers(
        List<ServiceContextMultiplier> multipliers)
    {
        var result = new Dictionary<string, Dictionary<string, double>>();

        if (!multipliers.Any())
        {
            // Return defaults
            return new Dictionary<string, Dictionary<string, double>>
            {
                ["documentation"] = new() { ["none"] = 0.15, ["partial"] = 0, ["complete"] = -0.10 },
                ["k8sExperience"] = new() { ["beginner"] = 0.20, ["intermediate"] = 0, ["expert"] = -0.15 },
                ["stakeholders"] = new() { ["low"] = 0, ["medium"] = 0, ["high"] = 0.15 },
                ["timeline"] = new() { ["relaxed"] = -0.05, ["normal"] = 0, ["aggressive"] = 0.10 }
            };
        }

        foreach (var mult in multipliers)
        {
            result[mult.MultiplierCode] = mult.Values
                .ToDictionary(v => v.ValueCode, v => (double)v.MultiplierValue);
        }

        return result;
    }

    private static List<SectionDto> BuildSections(List<ServiceCalculatorSection> sections)
    {
        return sections.Select(s => new SectionDto
        {
            Id = s.SectionCode,
            Label = s.SectionLabel,
            Groups = s.Groups.Select(g => new GroupDto
            {
                Title = g.GroupTitle,
                Parameters = g.Parameters.Select(p => new ParameterDto
                {
                    Id = p.ParameterCode,
                    Label = p.ParameterLabel,
                    Required = p.IsRequired,
                    Default = p.DefaultValue,
                    Options = p.Options.Select(o => new OptionDto
                    {
                        Value = o.OptionValue,
                        Label = o.OptionLabel,
                        SizeImpact = o.SizeImpact,
                        ComplexityHours = o.ComplexityHours
                    }).ToList()
                }).ToList()
            }).ToList()
        }).ToList();
    }

    private static List<ScopeAreaDto> BuildScopeAreas(List<ServiceScopeArea> areas)
    {
        return areas.Select(a => new ScopeAreaDto
        {
            Id = a.AreaCode,
            Name = a.AreaName,
            Hours = a.Hours,
            Description = a.Description,
            Category = a.Category,
            Required = a.IsRequired,
            Requires = string.IsNullOrEmpty(a.RequiresAreaCodes) 
                ? null 
                : a.RequiresAreaCodes.Split(',').Select(x => x.Trim()).ToList()
        }).ToList();
    }

    private static List<ComplexityFactorDto> BuildComplexityFactors(List<ServiceComplianceFactor> factors)
    {
        return factors.Select(f => new ComplexityFactorDto
        {
            Id = f.FactorCode,
            Label = f.FactorLabel,
            Hours = f.Hours
        }).ToList();
    }

    private static List<ScenarioDto> BuildScenarios(List<ServiceCalculatorScenario> scenarios)
    {
        return scenarios.Select(s => new ScenarioDto
        {
            Id = s.ScenarioCode,
            Name = s.ScenarioName,
            Description = s.Description,
            Values = string.IsNullOrEmpty(s.ParameterValuesJson)
                ? new Dictionary<string, string>()
                : JsonSerializer.Deserialize<Dictionary<string, string>>(s.ParameterValuesJson) ?? new Dictionary<string, string>()
        }).ToList();
    }

    private static List<PhaseDto> BuildPhases(List<ServiceCalculatorPhase> phases)
    {
        return phases.Select(p => new PhaseDto
        {
            Id = p.PhaseCode,
            Name = p.PhaseName,
            DurationBySize = new Dictionary<string, string>
            {
                ["S"] = p.DurationSmall ?? "",
                ["M"] = p.DurationMedium ?? "",
                ["L"] = p.DurationLarge ?? ""
            }
        }).ToList();
    }

    private static Dictionary<string, SizingCriteriaDto>? BuildSizingCriteria(List<ServiceSizingCriteria> criteria)
    {
        if (!criteria.Any()) return null;

        return criteria.ToDictionary(
            c => c.SizeCode,
            c => new SizingCriteriaDto
            {
                Duration = c.Duration,
                Effort = c.Effort,
                Description = c.Description
            }
        );
    }
}

#region DTOs

public class CalculatorConfigDto
{
    public MetadataDto Metadata { get; set; } = new();
    public Dictionary<string, BaseEffortItemDto> BaseEffort { get; set; } = new();
    public PricingDto Pricing { get; set; } = new();
    public List<RoleDto> Roles { get; set; } = new();
    public Dictionary<string, Dictionary<string, double>> TeamComposition { get; set; } = new();
    public Dictionary<string, Dictionary<string, double>> ContextMultipliers { get; set; } = new();
    public List<SectionDto> Sections { get; set; } = new();
    public List<ScopeAreaDto> ScopeAreas { get; set; } = new();
    public List<ComplexityFactorDto> ComplexityFactors { get; set; } = new();
    public List<ScenarioDto> Scenarios { get; set; } = new();
    public List<PhaseDto> Phases { get; set; } = new();
    public Dictionary<string, SizingCriteriaDto>? SizingCriteria { get; set; }
}

public class MetadataDto
{
    public string Name { get; set; } = "";
    public string Id { get; set; } = "";
    public string Version { get; set; } = "v1.0";
    public string? Category { get; set; }
}

public class BaseEffortItemDto
{
    public int Hours { get; set; }
    public string Label { get; set; } = "";
    public string? Description { get; set; }
}

public class PricingDto
{
    public double Margin { get; set; } = 15;
    public double RiskPremium { get; set; } = 5;
    public double Contingency { get; set; } = 5;
    public double Discount { get; set; } = 0;
    public int HoursPerDay { get; set; } = 8;
}

public class RoleDto
{
    public string Id { get; set; } = "";
    public string Name { get; set; } = "";
    public double DailyRate { get; set; }
    public bool IsPrimary { get; set; }
}

public class SectionDto
{
    public string Id { get; set; } = "";
    public string Label { get; set; } = "";
    public List<GroupDto> Groups { get; set; } = new();
}

public class GroupDto
{
    public string Title { get; set; } = "";
    public List<ParameterDto> Parameters { get; set; } = new();
}

public class ParameterDto
{
    public string Id { get; set; } = "";
    public string Label { get; set; } = "";
    public bool Required { get; set; }
    public string? Default { get; set; }
    public List<OptionDto> Options { get; set; } = new();
}

public class OptionDto
{
    public string Value { get; set; } = "";
    public string Label { get; set; } = "";
    public string? SizeImpact { get; set; }
    public int? ComplexityHours { get; set; }
}

public class ScopeAreaDto
{
    public string Id { get; set; } = "";
    public string Name { get; set; } = "";
    public int Hours { get; set; }
    public string? Description { get; set; }
    public string? Category { get; set; }
    public bool Required { get; set; }
    public List<string>? Requires { get; set; }
}

public class ComplexityFactorDto
{
    public string Id { get; set; } = "";
    public string Label { get; set; } = "";
    public int Hours { get; set; }
}

public class ScenarioDto
{
    public string Id { get; set; } = "";
    public string Name { get; set; } = "";
    public string? Description { get; set; }
    public Dictionary<string, string> Values { get; set; } = new();
}

public class PhaseDto
{
    public string Id { get; set; } = "";
    public string Name { get; set; } = "";
    public Dictionary<string, string> DurationBySize { get; set; } = new();
}

public class SizingCriteriaDto
{
    public string? Duration { get; set; }
    public string? Effort { get; set; }
    public string? Description { get; set; }
}

// Service Map DTOs
public class ServiceMapDto
{
    public List<ServiceMapItemDto> Services { get; set; } = new();
    public List<ServiceMapDependencyDto> Dependencies { get; set; } = new();
}

public class ServiceMapItemDto
{
    public string Id { get; set; } = "";
    public string Name { get; set; } = "";
    public string ShortName { get; set; } = "";
    public string Layer { get; set; } = "other";
    public int X { get; set; }
    public int Y { get; set; }
}

public class ServiceMapDependencyDto
{
    public string From { get; set; } = "";
    public string To { get; set; } = "";
    public string Type { get; set; } = "optional";
}

#endregion
