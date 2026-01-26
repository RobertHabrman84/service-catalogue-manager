using Xunit;

namespace ServiceCatalogueManager.Api.Tests.Services.Import;

/// <summary>
/// Base test class for import service tests
/// </summary>
public abstract class ImportTestBase
{
    protected const string ValidServiceCode = "ID001";
    protected const string InvalidServiceCode = "INVALID";
    protected const string ValidCategory = "Services/Architecture/Technical Architecture";
    
    /// <summary>
    /// Creates a minimal valid import model for testing
    /// </summary>
    protected static Models.Import.ImportServiceModel CreateMinimalValidModel()
    {
        return new Models.Import.ImportServiceModel
        {
            ServiceCode = ValidServiceCode,
            ServiceName = "Test Service",
            Version = "v1.0",
            Category = ValidCategory,
            Description = "Test service description for unit testing"
        };
    }
    
    /// <summary>
    /// Creates a complete import model with all sections populated
    /// </summary>
    protected static Models.Import.ImportServiceModel CreateCompleteModel()
    {
        var model = CreateMinimalValidModel();
        
        // Add usage scenarios
        model.UsageScenarios = new List<Models.Import.UsageScenarioImportModel>
        {
            new()
            {
                ScenarioNumber = 1,
                ScenarioTitle = "Test Scenario",
                ScenarioDescription = "Test scenario description",
                SortOrder = 1
            }
        };
        
        // Add dependencies
        model.Dependencies = new Models.Import.DependenciesImportModel
        {
            Prerequisite = new List<Models.Import.DependencyImportModel>
            {
                new()
                {
                    ServiceName = "Prerequisite Service",
                    ServiceCode = "ID002",
                    RequirementLevel = "REQUIRED"
                }
            }
        };
        
        // Add size options
        model.SizeOptions = new List<Models.Import.SizeOptionImportModel>
        {
            new()
            {
                SizeCode = "S",
                Description = "Small size option",
                Duration = "2-3 weeks",
                DurationInDays = 15,
                Effort = new Models.Import.EffortImportModel
                {
                    HoursMin = 40,
                    HoursMax = 60
                }
            }
        };
        
        return model;
    }
}
