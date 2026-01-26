using System.Text;
using ServiceCatalogueManager.Api.Models.DTOs.ServiceCatalog;
using ServiceCatalogueManager.Api.Services.Interfaces;

namespace ServiceCatalogueManager.Api.Services.Implementations;

/// <summary>
/// Markdown generation service for service documentation
/// </summary>
public class MarkdownGeneratorService : IMarkdownGeneratorService
{
    private readonly ILogger<MarkdownGeneratorService> _logger;

    public MarkdownGeneratorService(ILogger<MarkdownGeneratorService> logger)
    {
        _logger = logger;
    }

    public Task<string> GenerateServiceMarkdownAsync(ServiceCatalogFullDto service, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Generating Markdown for service: {ServiceCode}", service.ServiceCode);

        var sb = new StringBuilder();

        // Title
        sb.AppendLine($"# {service.ServiceName}");
        sb.AppendLine();

        // Metadata table
        sb.AppendLine("## Overview");
        sb.AppendLine();
        sb.AppendLine("| Property | Value |");
        sb.AppendLine("|----------|-------|");
        sb.AppendLine($"| **Service Code** | `{service.ServiceCode}` |");
        sb.AppendLine($"| **Category** | {service.CategoryName} |");
        sb.AppendLine($"| **Version** | {service.Version} |");
        sb.AppendLine($"| **Status** | {(service.IsActive ? "✅ Active" : "❌ Inactive")} |");
        
        if (service.CreatedDate.HasValue)
        {
            sb.AppendLine($"| **Created** | {service.CreatedDate.Value:yyyy-MM-dd} |");
        }
        
        sb.AppendLine();

        // Description
        if (!string.IsNullOrEmpty(service.Description))
        {
            sb.AppendLine("## Description");
            sb.AppendLine();
            sb.AppendLine(service.Description);
            sb.AppendLine();
        }

        // Usage Scenarios
        if (service.UsageScenarios?.Any() == true)
        {
            sb.AppendLine("## Usage Scenarios");
            sb.AppendLine();
            
            foreach (var scenario in service.UsageScenarios)
            {
                sb.AppendLine($"### {scenario.ScenarioTitle}");
                sb.AppendLine();
                
                if (!string.IsNullOrEmpty(scenario.ScenarioDescription))
                {
                    sb.AppendLine(scenario.ScenarioDescription);
                    sb.AppendLine();
                }
            }
        }

        // Prerequisites
        if (service.Prerequisites?.Any() == true)
        {
            sb.AppendLine("## Prerequisites");
            sb.AppendLine();
            
            foreach (var prereq in service.Prerequisites)
            {
                sb.AppendLine($"- **{prereq.PrerequisiteName}**");
                
                if (!string.IsNullOrEmpty(prereq.PrerequisiteDescription))
                {
                    sb.AppendLine($"  {prereq.PrerequisiteDescription}");
                }
            }
            
            sb.AppendLine();
        }

        // Dependencies
        if (service.Dependencies?.Any() == true)
        {
            sb.AppendLine("## Dependencies");
            sb.AppendLine();
            
            foreach (var dep in service.Dependencies)
            {
                sb.AppendLine($"- **{dep.DependencyName}** ({dep.DependencyTypeName})");
                
                if (!string.IsNullOrEmpty(dep.DependencyDescription))
                {
                    sb.AppendLine($"  {dep.DependencyDescription}");
                }
            }
            
            sb.AppendLine();
        }

        // Scope
        if (service.ScopeCategories?.Any() == true)
        {
            sb.AppendLine("## Scope");
            sb.AppendLine();
            
            foreach (var category in service.ScopeCategories)
            {
                sb.AppendLine($"### {category.CategoryName}");
                sb.AppendLine();
                
                if (category.Items?.Any() == true)
                {
                    foreach (var item in category.Items)
                    {
                        sb.AppendLine($"- {item.ItemDescription}");
                    }
                    sb.AppendLine();
                }
            }
        }

        // Size Options
        if (service.SizeOptions?.Any() == true)
        {
            sb.AppendLine("## Size Options");
            sb.AppendLine();
            sb.AppendLine("| Size | Estimated Days | Description |");
            sb.AppendLine("|------|----------------|-------------|");
            
            foreach (var size in service.SizeOptions)
            {
                var desc = string.IsNullOrEmpty(size.SizeDescription) ? "-" : size.SizeDescription;
                sb.AppendLine($"| {size.SizeName} | {size.EstimatedDays} | {desc} |");
            }
            
            sb.AppendLine();
        }

        // Timeline Phases
        if (service.TimelinePhases?.Any() == true)
        {
            sb.AppendLine("## Timeline");
            sb.AppendLine();
            
            foreach (var phase in service.TimelinePhases.OrderBy(p => p.PhaseOrder))
            {
                sb.AppendLine($"### {phase.PhaseOrder}. {phase.PhaseName}");
                sb.AppendLine();
                
                if (!string.IsNullOrEmpty(phase.PhaseDescription))
                {
                    sb.AppendLine(phase.PhaseDescription);
                    sb.AppendLine();
                }
                
                if (phase.DurationsBySize?.Any() == true)
                {
                    sb.AppendLine("**Duration by size:**");
                    sb.AppendLine();
                    
                    foreach (var duration in phase.DurationsBySize)
                    {
                        sb.AppendLine($"- {duration.SizeName}: {duration.DurationDays} days");
                    }
                    
                    sb.AppendLine();
                }
            }
        }

        // Inputs
        if (service.Inputs?.Any() == true)
        {
            sb.AppendLine("## Required Inputs");
            sb.AppendLine();
            
            foreach (var input in service.Inputs)
            {
                sb.AppendLine($"- **{input.InputName}**{(input.IsRequired ? " *(required)*" : "")}");
                
                if (!string.IsNullOrEmpty(input.InputDescription))
                {
                    sb.AppendLine($"  {input.InputDescription}");
                }
            }
            
            sb.AppendLine();
        }

        // Outputs/Deliverables
        if (service.OutputCategories?.Any() == true)
        {
            sb.AppendLine("## Deliverables");
            sb.AppendLine();
            
            foreach (var category in service.OutputCategories)
            {
                sb.AppendLine($"### {category.CategoryName}");
                sb.AppendLine();
                
                if (category.Items?.Any() == true)
                {
                    foreach (var item in category.Items)
                    {
                        sb.AppendLine($"- {item.ItemDescription}");
                    }
                    sb.AppendLine();
                }
            }
        }

        // Team & Roles
        if (service.ResponsibleRoles?.Any() == true)
        {
            sb.AppendLine("## Team & Roles");
            sb.AppendLine();
            
            foreach (var role in service.ResponsibleRoles)
            {
                sb.AppendLine($"- **{role.RoleName}**: {role.ResponsibilityDescription}");
            }
            
            sb.AppendLine();
        }

        // Footer
        sb.AppendLine("---");
        sb.AppendLine();
        sb.AppendLine($"*Generated: {DateTime.UtcNow:yyyy-MM-dd HH:mm} UTC*");

        return Task.FromResult(sb.ToString());
    }

    public Task<string> GenerateCatalogMarkdownAsync(IEnumerable<ServiceCatalogFullDto> services, CancellationToken cancellationToken = default)
    {
        _logger.LogInformation("Generating catalog Markdown for {Count} services", services.Count());

        var sb = new StringBuilder();

        // Title
        sb.AppendLine("# Service Catalog");
        sb.AppendLine();
        sb.AppendLine($"**Total Services:** {services.Count()}");
        sb.AppendLine();
        sb.AppendLine("---");
        sb.AppendLine();

        // Table of Contents
        sb.AppendLine("## Table of Contents");
        sb.AppendLine();
        
        foreach (var service in services.OrderBy(s => s.CategoryName).ThenBy(s => s.ServiceName))
        {
            var anchor = service.ServiceCode.ToLowerInvariant().Replace(" ", "-");
            sb.AppendLine($"- [{service.ServiceName}](#{anchor}) - {service.CategoryName}");
        }
        
        sb.AppendLine();
        sb.AppendLine("---");
        sb.AppendLine();

        // Service Details
        foreach (var service in services.OrderBy(s => s.CategoryName).ThenBy(s => s.ServiceName))
        {
            sb.AppendLine($"## {service.ServiceName}");
            sb.AppendLine();
            sb.AppendLine($"**Code:** `{service.ServiceCode}`");
            sb.AppendLine($"**Category:** {service.CategoryName}");
            sb.AppendLine($"**Version:** {service.Version}");
            sb.AppendLine($"**Status:** {(service.IsActive ? "✅ Active" : "❌ Inactive")}");
            sb.AppendLine();
            
            if (!string.IsNullOrEmpty(service.Description))
            {
                sb.AppendLine("### Description");
                sb.AppendLine();
                sb.AppendLine(service.Description);
                sb.AppendLine();
            }
            
            if (service.SizeOptions?.Any() == true)
            {
                sb.AppendLine("### Size Options");
                sb.AppendLine();
                
                foreach (var size in service.SizeOptions)
                {
                    sb.AppendLine($"- **{size.SizeName}**: {size.EstimatedDays} days");
                }
                
                sb.AppendLine();
            }
            
            sb.AppendLine("---");
            sb.AppendLine();
        }

        // Footer
        sb.AppendLine($"*Generated: {DateTime.UtcNow:yyyy-MM-dd HH:mm} UTC*");

        return Task.FromResult(sb.ToString());
    }
}
