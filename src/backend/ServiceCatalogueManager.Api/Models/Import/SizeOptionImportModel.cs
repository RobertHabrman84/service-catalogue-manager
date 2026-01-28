using System.Text.Json.Serialization;
using System.Globalization;

namespace ServiceCatalogueManager.Api.Models.Import;

public class SizeOptionImportModel
{
    // ===== PŮVODNÍ POLE (pro zpětnou kompatibilitu) =====
    public string? SizeName { get; set; }
    public string? Duration { get; set; }
    public string? EffortRange { get; set; }
    public List<TeamAllocationImportModel>? TeamAllocations { get; set; }
    public List<SizingExampleImportModel>? Examples { get; set; }
    
    // ===== NOVÁ POLE Z JSON (pro nový formát) =====
    
    /// <summary>
    /// Kód velikosti ("S", "M", "L") - alternativa k SizeName
    /// </summary>
    public string? SizeCode { get; set; }
    
    /// <summary>
    /// Popis velikostní varianty
    /// </summary>
    public string? Description { get; set; }
    
    /// <summary>
    /// Délka trvání ve dnech
    /// </summary>
    public int? DurationInDays { get; set; }
    
    /// <summary>
    /// Velikost týmu (textový popis)
    /// </summary>
    public string? TeamSize { get; set; }
    
    /// <summary>
    /// Komplexita ("LOW", "MEDIUM", "HIGH")
    /// </summary>
    public string? Complexity { get; set; }
    
    /// <summary>
    /// Effort objekt z JSON
    /// </summary>
    public EffortObjectImportModel? Effort { get; set; }
    
    /// <summary>
    /// Sizing kritéria
    /// </summary>
    public List<SizingCriterionJsonImportModel>? SizingCriteria { get; set; }
    
    /// <summary>
    /// Rozpad úsilí
    /// </summary>
    public List<EffortBreakdownJsonImportModel>? EffortBreakdown { get; set; }
    
    /// <summary>
    /// Dodatečné komplexity
    /// </summary>
    public List<ComplexityAdditionJsonImportModel>? ComplexityAdditions { get; set; }
    
    /// <summary>
    /// Team allocation v novém formátu (role + allocation jako string)
    /// </summary>
    public List<TeamAllocationJsonImportModel>? TeamAllocation { get; set; }
    
    /// <summary>
    /// Závislosti scope
    /// </summary>
    public List<ScopeDependencyJsonImportModel>? ScopeDependencies { get; set; }
    
    /// <summary>
    /// Sizing parametry
    /// </summary>
    public List<SizingParameterJsonImportModel>? SizingParameters { get; set; }
    
    // ===== HELPER METODY =====
    
    /// <summary>
    /// Vrátí efektivní název velikosti (SizeName nebo SizeCode)
    /// </summary>
    public string GetEffectiveSizeName() 
        => SizeName ?? SizeCode ?? "Unknown";
    
    /// <summary>
    /// Vrátí efektivní effort range
    /// </summary>
    public string? GetEffectiveEffortRange()
    {
        if (!string.IsNullOrEmpty(EffortRange))
            return EffortRange;
        
        if (Effort != null)
            return $"{Effort.Hours} {Effort.Currency ?? "hours"}";
        
        return null;
    }
    
    /// <summary>
    /// Vrátí efektivní popis
    /// </summary>
    public string? GetEffectiveDescription()
        => Description ?? SizeName ?? SizeCode;
    
    /// <summary>
    /// Konvertuje nový TeamAllocation formát na starý
    /// </summary>
    public List<TeamAllocationImportModel> GetTeamAllocationsNormalized()
    {
        if (TeamAllocations != null && TeamAllocations.Any())
            return TeamAllocations;
        
        if (TeamAllocation == null || !TeamAllocation.Any())
            return new List<TeamAllocationImportModel>();
        
        // Konverze nového formátu na starý
        var result = new TeamAllocationImportModel
        {
            SizeName = GetEffectiveSizeName()
        };
        
        foreach (var ta in TeamAllocation)
        {
            var allocation = ParseAllocation(ta.Allocation);
            var roleLower = (ta.Role ?? "").ToLower();
            
            if (roleLower.Contains("cloud architect"))
                result.CloudArchitects = (result.CloudArchitects ?? 0) + allocation;
            else if (roleLower.Contains("security"))
                result.SecuritySpecialists = (result.SecuritySpecialists ?? 0) + allocation;
            else if (roleLower.Contains("network"))
                result.CloudArchitects = (result.CloudArchitects ?? 0) + allocation; // Map to cloud
            else if (roleLower.Contains("project manager"))
                result.ProjectManagers = (result.ProjectManagers ?? 0) + allocation;
            else if (roleLower.Contains("solution"))
                result.SolutionArchitects = (result.SolutionArchitects ?? 0) + allocation;
            else if (roleLower.Contains("developer"))
                result.Developers = (result.Developers ?? 0) + allocation;
            else if (roleLower.Contains("qa") || roleLower.Contains("test"))
                result.QAEngineers = (result.QAEngineers ?? 0) + allocation;
            else if (roleLower.Contains("devops"))
                result.DevOpsEngineers = (result.DevOpsEngineers ?? 0) + allocation;
            else if (roleLower.Contains("business analyst"))
                result.BusinessAnalysts = (result.BusinessAnalysts ?? 0) + allocation;
            else if (roleLower.Contains("technical lead"))
                result.TechnicalLeads = (result.TechnicalLeads ?? 0) + allocation;
        }
        
        return new List<TeamAllocationImportModel> { result };
    }
    
    private static decimal ParseAllocation(string? allocation)
    {
        if (string.IsNullOrEmpty(allocation))
            return 0;
        
        // Zkusí parsovat jako decimal (podporuje "0.8", "1.0" atd.)
        if (decimal.TryParse(allocation, NumberStyles.Any, CultureInfo.InvariantCulture, out var result))
            return result;
        
        return 0;
    }
}

// ===== NOVÉ POMOCNÉ MODELY PRO JSON FORMÁT =====

public class EffortObjectImportModel
{
    public int? Hours { get; set; }
    public string? Currency { get; set; }
}

public class SizingCriterionJsonImportModel
{
    public string? CriteriaName { get; set; }
    public List<string>? Values { get; set; }
}

public class EffortBreakdownJsonImportModel
{
    public string? ScopeArea { get; set; }
    public int? BaseHours { get; set; }
    public string? Notes { get; set; }
}

public class ComplexityAdditionJsonImportModel
{
    public string? Factor { get; set; }
    public string? Condition { get; set; }
    public int? AdditionalHours { get; set; }
}

public class TeamAllocationJsonImportModel
{
    public string? Role { get; set; }
    public string? Allocation { get; set; }
    public string? Notes { get; set; }
}

public class ScopeDependencyJsonImportModel
{
    public string? ScopeArea { get; set; }
    public List<string>? Requires { get; set; }
}

public class SizingParameterJsonImportModel
{
    public string? ParameterName { get; set; }
    public string? Value { get; set; }
}

// Původní TeamAllocationImportModel zůstává nezměněn
public class TeamAllocationImportModel
{
    public string? SizeName { get; set; }
    public decimal? CloudArchitects { get; set; }
    public decimal? SolutionArchitects { get; set; }
    public decimal? TechnicalLeads { get; set; }
    public decimal? Developers { get; set; }
    public decimal? QAEngineers { get; set; }
    public decimal? DevOpsEngineers { get; set; }
    public decimal? SecuritySpecialists { get; set; }
    public decimal? ProjectManagers { get; set; }
    public decimal? BusinessAnalysts { get; set; }
}
