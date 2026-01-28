namespace ServiceCatalogueManager.Api.Models.Import;

public class ToolsAndEnvironmentImportModel
{
    public List<ToolItemImportModel>? CloudPlatforms { get; set; }
    public List<ToolItemImportModel>? DesignTools { get; set; }
    public List<ToolItemImportModel>? AutomationTools { get; set; }
    
    /// <summary>
    /// Pole CollaborationTools je volitelné.
    /// Pokud chybí v JSON, vrátí prázdný seznam.
    /// </summary>
    public List<ToolItemImportModel>? CollaborationTools { get; set; }
    
    public List<ToolItemImportModel>? Other { get; set; }
    
    /// <summary>
    /// Zajistí, že CollaborationTools nikdy není null
    /// </summary>
    public List<ToolItemImportModel> GetCollaborationToolsSafe() 
        => CollaborationTools ?? new List<ToolItemImportModel>();
    
    /// <summary>
    /// Zajistí, že CloudPlatforms nikdy není null
    /// </summary>
    public List<ToolItemImportModel> GetCloudPlatformsSafe() 
        => CloudPlatforms ?? new List<ToolItemImportModel>();
    
    /// <summary>
    /// Zajistí, že DesignTools nikdy není null
    /// </summary>
    public List<ToolItemImportModel> GetDesignToolsSafe() 
        => DesignTools ?? new List<ToolItemImportModel>();
    
    /// <summary>
    /// Zajistí, že AutomationTools nikdy není null
    /// </summary>
    public List<ToolItemImportModel> GetAutomationToolsSafe() 
        => AutomationTools ?? new List<ToolItemImportModel>();
    
    /// <summary>
    /// Zajistí, že Other nikdy není null
    /// </summary>
    public List<ToolItemImportModel> GetOtherSafe() 
        => Other ?? new List<ToolItemImportModel>();
}

public class ToolItemImportModel
{
    public string? Category { get; set; }
    public string? ToolName { get; set; }
    public string? Version { get; set; }
    public string? Purpose { get; set; }
}
