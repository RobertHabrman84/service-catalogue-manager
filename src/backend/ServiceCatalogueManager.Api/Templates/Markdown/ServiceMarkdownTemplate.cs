using System.Text;

namespace ServiceCatalogueManager.Api.Templates.Markdown;

public class ServiceMarkdownTemplate
{
    public static string Generate(ServiceMarkdownData data)
    {
        var sb = new StringBuilder();

        // Header
        sb.AppendLine($"# {data.ServiceName}");
        sb.AppendLine();
        sb.AppendLine($"**Service Code:** `{data.ServiceCode}`  ");
        sb.AppendLine($"**Version:** {data.Version ?? "1.0.0"}  ");
        sb.AppendLine($"**Status:** {(data.IsActive ? "✅ Active" : "❌ Inactive")}  ");
        sb.AppendLine($"**Category:** {data.CategoryName ?? "N/A"}  ");
        sb.AppendLine($"**Last Updated:** {data.ModifiedDate?.ToString("yyyy-MM-dd") ?? "N/A"}");
        sb.AppendLine();

        // Description
        if (!string.IsNullOrEmpty(data.Description))
        {
            sb.AppendLine("## Overview");
            sb.AppendLine();
            sb.AppendLine(data.Description);
            sb.AppendLine();
        }

        // Table of Contents
        sb.AppendLine("## Table of Contents");
        sb.AppendLine();
        sb.AppendLine("- [Usage Scenarios](#usage-scenarios)");
        sb.AppendLine("- [Dependencies](#dependencies)");
        sb.AppendLine("- [Scope](#scope)");
        sb.AppendLine("- [Prerequisites](#prerequisites)");
        sb.AppendLine("- [Tools](#tools)");
        sb.AppendLine("- [Inputs & Outputs](#inputs--outputs)");
        sb.AppendLine("- [Timeline](#timeline)");
        sb.AppendLine("- [Sizing](#sizing)");
        sb.AppendLine("- [Effort](#effort)");
        sb.AppendLine("- [Team](#team)");
        sb.AppendLine();

        // Usage Scenarios
        sb.AppendLine("## Usage Scenarios");
        sb.AppendLine();
        if (data.UsageScenarios?.Any() == true)
        {
            int num = 1;
            foreach (var scenario in data.UsageScenarios.OrderBy(s => s.SortOrder))
            {
                sb.AppendLine($"### {num}. {scenario.ScenarioName}");
                sb.AppendLine();
                if (!string.IsNullOrEmpty(scenario.Description))
                    sb.AppendLine(scenario.Description);
                if (!string.IsNullOrEmpty(scenario.Actors))
                    sb.AppendLine($"- **Actors:** {scenario.Actors}");
                if (!string.IsNullOrEmpty(scenario.Trigger))
                    sb.AppendLine($"- **Trigger:** {scenario.Trigger}");
                sb.AppendLine();
                num++;
            }
        }
        else
        {
            sb.AppendLine("_No usage scenarios defined._");
            sb.AppendLine();
        }

        // Dependencies
        sb.AppendLine("## Dependencies");
        sb.AppendLine();
        if (data.Dependencies?.Any() == true)
        {
            sb.AppendLine("| Dependency | Type | Criticality | Description |");
            sb.AppendLine("|------------|------|-------------|-------------|");
            foreach (var dep in data.Dependencies.OrderBy(d => d.SortOrder))
            {
                sb.AppendLine($"| {dep.DependencyName} | {dep.DependencyTypeName ?? "-"} | {dep.CriticalityLevel ?? "-"} | {dep.Description ?? "-"} |");
            }
            sb.AppendLine();
        }
        else
        {
            sb.AppendLine("_No dependencies defined._");
            sb.AppendLine();
        }

        // Scope
        sb.AppendLine("## Scope");
        sb.AppendLine();
        sb.AppendLine("### In Scope");
        sb.AppendLine();
        if (data.InScopeItems?.Any() == true)
        {
            foreach (var item in data.InScopeItems)
                sb.AppendLine($"- ✅ {item}");
        }
        else
        {
            sb.AppendLine("_Not defined._");
        }
        sb.AppendLine();
        sb.AppendLine("### Out of Scope");
        sb.AppendLine();
        if (data.OutOfScopeItems?.Any() == true)
        {
            foreach (var item in data.OutOfScopeItems)
                sb.AppendLine($"- ❌ {item}");
        }
        else
        {
            sb.AppendLine("_Not defined._");
        }
        sb.AppendLine();

        // Prerequisites
        sb.AppendLine("## Prerequisites");
        sb.AppendLine();
        if (data.Prerequisites?.Any() == true)
        {
            foreach (var prereq in data.Prerequisites.OrderBy(p => p.SortOrder))
            {
                var required = prereq.IsMandatory ? "🔴 Required" : "🟢 Optional";
                sb.AppendLine($"- **{prereq.PrerequisiteName}** ({required})");
                if (!string.IsNullOrEmpty(prereq.Description))
                    sb.AppendLine($"  - {prereq.Description}");
            }
            sb.AppendLine();
        }
        else
        {
            sb.AppendLine("_No prerequisites defined._");
            sb.AppendLine();
        }

        // Tools
        sb.AppendLine("## Tools");
        sb.AppendLine();
        if (data.Tools?.Any() == true)
        {
            sb.AppendLine("| Tool | Category | Version | Description |");
            sb.AppendLine("|------|----------|---------|-------------|");
            foreach (var tool in data.Tools.OrderBy(t => t.SortOrder))
            {
                sb.AppendLine($"| {tool.ToolName} | {tool.CategoryName ?? "-"} | {tool.Version ?? "-"} | {tool.Description ?? "-"} |");
            }
            sb.AppendLine();
        }
        else
        {
            sb.AppendLine("_No tools defined._");
            sb.AppendLine();
        }

        // Inputs & Outputs
        sb.AppendLine("## Inputs & Outputs");
        sb.AppendLine();
        sb.AppendLine("### Inputs");
        sb.AppendLine();
        if (data.Inputs?.Any() == true)
        {
            sb.AppendLine("| Input | Type | Required | Description |");
            sb.AppendLine("|-------|------|----------|-------------|");
            foreach (var input in data.Inputs.OrderBy(i => i.SortOrder))
            {
                var required = input.IsRequired ? "Yes" : "No";
                sb.AppendLine($"| {input.InputName} | {input.DataType ?? "-"} | {required} | {input.Description ?? "-"} |");
            }
            sb.AppendLine();
        }
        else
        {
            sb.AppendLine("_No inputs defined._");
            sb.AppendLine();
        }

        sb.AppendLine("### Outputs");
        sb.AppendLine();
        if (data.Outputs?.Any() == true)
        {
            sb.AppendLine("| Output | Type | Format | Description |");
            sb.AppendLine("|--------|------|--------|-------------|");
            foreach (var output in data.Outputs.OrderBy(o => o.SortOrder))
            {
                sb.AppendLine($"| {output.OutputName} | {output.DataType ?? "-"} | {output.Format ?? "-"} | {output.Description ?? "-"} |");
            }
            sb.AppendLine();
        }
        else
        {
            sb.AppendLine("_No outputs defined._");
            sb.AppendLine();
        }

        // Timeline
        sb.AppendLine("## Timeline");
        sb.AppendLine();
        if (data.TimelinePhases?.Any() == true)
        {
            var totalDays = data.TimelinePhases.Sum(p => p.DurationDays);
            sb.AppendLine($"**Total Duration:** {totalDays} days");
            sb.AppendLine();
            sb.AppendLine("| Phase | Duration | Description |");
            sb.AppendLine("|-------|----------|-------------|");
            foreach (var phase in data.TimelinePhases.OrderBy(p => p.SortOrder))
            {
                sb.AppendLine($"| {phase.PhaseName} | {phase.DurationDays} days | {phase.Description ?? "-"} |");
            }
            sb.AppendLine();
        }
        else
        {
            sb.AppendLine("_No timeline defined._");
            sb.AppendLine();
        }

        // Sizing
        sb.AppendLine("## Sizing");
        sb.AppendLine();
        if (data.SizingOptions?.Any() == true)
        {
            foreach (var size in data.SizingOptions.OrderBy(s => s.SortOrder))
            {
                var recommended = size.IsRecommended ? " ⭐ **Recommended**" : "";
                sb.AppendLine($"### {size.SizeName}{recommended}");
                sb.AppendLine();
                if (!string.IsNullOrEmpty(size.Description))
                    sb.AppendLine(size.Description);
                if (!string.IsNullOrEmpty(size.Users))
                    sb.AppendLine($"- **Users:** {size.Users}");
                if (!string.IsNullOrEmpty(size.Storage))
                    sb.AppendLine($"- **Storage:** {size.Storage}");
                if (size.MonthlyCost.HasValue)
                    sb.AppendLine($"- **Cost:** ${size.MonthlyCost:N0}/month");
                sb.AppendLine();
            }
        }
        else
        {
            sb.AppendLine("_No sizing options defined._");
            sb.AppendLine();
        }

        // Effort
        sb.AppendLine("## Effort");
        sb.AppendLine();
        if (data.EffortItems?.Any() == true)
        {
            var totalHours = data.EffortItems.Sum(e => e.EstimatedHours);
            sb.AppendLine($"**Total Effort:** {totalHours} hours ({totalHours / 8.0:N1} days)");
            sb.AppendLine();
            sb.AppendLine("| Activity | Role | Hours | Notes |");
            sb.AppendLine("|----------|------|-------|-------|");
            foreach (var item in data.EffortItems.OrderBy(e => e.SortOrder))
            {
                sb.AppendLine($"| {item.ActivityName} | {item.RoleName ?? "-"} | {item.EstimatedHours}h | {item.Notes ?? "-"} |");
            }
            sb.AppendLine();
        }
        else
        {
            sb.AppendLine("_No effort estimation defined._");
            sb.AppendLine();
        }

        // Team
        sb.AppendLine("## Team");
        sb.AppendLine();
        if (data.TeamMembers?.Any() == true)
        {
            var totalFte = data.TeamMembers.Sum(t => t.FteAllocation);
            sb.AppendLine($"**Total FTE:** {totalFte:N1}");
            sb.AppendLine();
            sb.AppendLine("| Role | FTE | Responsibilities |");
            sb.AppendLine("|------|-----|------------------|");
            foreach (var member in data.TeamMembers.OrderBy(t => t.SortOrder))
            {
                sb.AppendLine($"| {member.RoleName} | {member.FteAllocation:N1} | {member.Responsibilities ?? "-"} |");
            }
            sb.AppendLine();
        }
        else
        {
            sb.AppendLine("_No team allocation defined._");
            sb.AppendLine();
        }

        // Footer
        sb.AppendLine("---");
        sb.AppendLine();
        sb.AppendLine($"_Generated by Service Catalogue Manager on {DateTime.UtcNow:yyyy-MM-dd HH:mm} UTC_");

        return sb.ToString();
    }
}

public class ServiceMarkdownData
{
    public string ServiceName { get; set; } = string.Empty;
    public string ServiceCode { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? Version { get; set; }
    public bool IsActive { get; set; }
    public string? CategoryName { get; set; }
    public DateTime? ModifiedDate { get; set; }
    
    public IEnumerable<UsageScenarioMdData>? UsageScenarios { get; set; }
    public IEnumerable<DependencyMdData>? Dependencies { get; set; }
    public IEnumerable<string>? InScopeItems { get; set; }
    public IEnumerable<string>? OutOfScopeItems { get; set; }
    public IEnumerable<PrerequisiteMdData>? Prerequisites { get; set; }
    public IEnumerable<ToolMdData>? Tools { get; set; }
    public IEnumerable<InputMdData>? Inputs { get; set; }
    public IEnumerable<OutputMdData>? Outputs { get; set; }
    public IEnumerable<TimelinePhaseMdData>? TimelinePhases { get; set; }
    public IEnumerable<SizingOptionMdData>? SizingOptions { get; set; }
    public IEnumerable<EffortItemMdData>? EffortItems { get; set; }
    public IEnumerable<TeamMemberMdData>? TeamMembers { get; set; }
}

// Simplified data models for Markdown
public record UsageScenarioMdData(string ScenarioName, string? Description, string? Actors, string? Trigger, int SortOrder);
public record DependencyMdData(string DependencyName, string? DependencyTypeName, string? CriticalityLevel, string? Description, int SortOrder);
public record PrerequisiteMdData(string PrerequisiteName, bool IsMandatory, string? Description, int SortOrder);
public record ToolMdData(string ToolName, string? CategoryName, string? Version, string? Description, int SortOrder);
public record InputMdData(string InputName, string? DataType, bool IsRequired, string? Description, int SortOrder);
public record OutputMdData(string OutputName, string? DataType, string? Format, string? Description, int SortOrder);
public record TimelinePhaseMdData(string PhaseName, int DurationDays, string? Description, int SortOrder);
public record SizingOptionMdData(string SizeName, string? Description, string? Users, string? Storage, decimal? MonthlyCost, bool IsRecommended, int SortOrder);
public record EffortItemMdData(string ActivityName, string? RoleName, int EstimatedHours, string? Notes, int SortOrder);
public record TeamMemberMdData(string RoleName, decimal FteAllocation, string? Responsibilities, int SortOrder);
