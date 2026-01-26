namespace ServiceCatalogueManager.Api.Models.Import;

public class ToolsAndEnvironmentImportModel
{
    public List<ToolItemImportModel>? CloudPlatforms { get; set; }
    public List<ToolItemImportModel>? DesignTools { get; set; }
    public List<ToolItemImportModel>? AutomationTools { get; set; }
    public List<ToolItemImportModel>? CollaborationTools { get; set; }
    public List<ToolItemImportModel>? Other { get; set; }
}

public class ToolItemImportModel
{
    public string? Category { get; set; }
    public string? ToolName { get; set; }
    public string? Version { get; set; }
    public string? Purpose { get; set; }
}
