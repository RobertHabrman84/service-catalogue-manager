using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;
using ServiceCatalogueManager.Api.Data.DbContext;
using ServiceCatalogueManager.Api.Data.Entities;
using ServiceCatalogueManager.Api.Models.Import;

namespace ServiceCatalogueManager.Api.Tests.E2E;

/// <summary>
/// End-to-end integration tests for the complete import pipeline
/// </summary>
public class ImportPipelineE2ETests : IClassFixture<TestWebApplicationFactory>
{
    private readonly HttpClient _client;
    private readonly TestWebApplicationFactory _factory;

    public ImportPipelineE2ETests(TestWebApplicationFactory factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task EndToEnd_CompleteImportWorkflow_Success()
    {
        // Arrange
        var service = CreateCompleteServiceModel("ID001", "E2E Test Service");

        // Act 1: Health Check
        var healthResponse = await _client.GetAsync("/api/services/import/health");
        Assert.Equal(HttpStatusCode.OK, healthResponse.StatusCode);

        // Act 2: Validate
        var validateResponse = await _client.PostAsJsonAsync(
            "/api/services/import/validate", service);
        Assert.Equal(HttpStatusCode.OK, validateResponse.StatusCode);

        var validationResult = await validateResponse.Content.ReadFromJsonAsync<ValidationResponse>();
        Assert.NotNull(validationResult);
        Assert.True(validationResult.IsValid);

        // Act 3: Import
        var importResponse = await _client.PostAsJsonAsync(
            "/api/services/import", service);
        Assert.Equal(HttpStatusCode.OK, importResponse.StatusCode);

        var importResult = await importResponse.Content.ReadFromJsonAsync<ImportResponse>();
        Assert.NotNull(importResult);
        Assert.True(importResult.Success);
        Assert.True(importResult.ServiceId > 0);
        Assert.Equal("ID001", importResult.ServiceCode);

        // Assert: Verify in database
        using var scope = _factory.Services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ServiceCatalogDbContext>();

        var dbService = await context.ServiceCatalogItems
            .Include(s => s.UsageScenarios)
            .Include(s => s.SizeOptions)
            .Include(s => s.ResponsibleRoles)
            .FirstOrDefaultAsync(s => s.ServiceCode == "ID001");

        Assert.NotNull(dbService);
        Assert.Equal("E2E Test Service", dbService.ServiceName);
        Assert.NotEmpty(dbService.UsageScenarios);
        Assert.NotEmpty(dbService.SizeOptions);
        Assert.NotEmpty(dbService.ResponsibleRoles);
    }

    [Fact]
    public async Task EndToEnd_BulkImport_PartialSuccess()
    {
        // Arrange
        var services = new List<ImportServiceModel>
        {
            CreateMinimalServiceModel("ID101", "Bulk Service 1"),
            CreateMinimalServiceModel("INVALID", "Invalid Service"), // Invalid code
            CreateMinimalServiceModel("ID103", "Bulk Service 3")
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/services/import/bulk", services);

        // Assert
        Assert.Equal(HttpStatusCode.MultiStatus, response.StatusCode);

        var result = await response.Content.ReadFromJsonAsync<BulkImportResponse>();
        Assert.NotNull(result);
        Assert.Equal(3, result.TotalCount);
        Assert.Equal(2, result.SuccessCount);
        Assert.Equal(1, result.FailCount);

        // Verify successful imports in database
        using var scope = _factory.Services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ServiceCatalogDbContext>();

        var imported = await context.ServiceCatalogItems
            .Where(s => s.ServiceCode == "ID101" || s.ServiceCode == "ID103")
            .ToListAsync();

        Assert.Equal(2, imported.Count);
    }

    [Fact]
    public async Task EndToEnd_ValidationError_NoDataImported()
    {
        // Arrange
        var invalidService = CreateMinimalServiceModel("INVALID_CODE", "Test");

        // Act
        var response = await _client.PostAsJsonAsync("/api/services/import", invalidService);

        // Assert
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);

        var result = await response.Content.ReadFromJsonAsync<ImportErrorResponse>();
        Assert.NotNull(result);
        Assert.False(result.Success);
        Assert.NotEmpty(result.Errors);

        // Verify nothing was imported
        using var scope = _factory.Services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ServiceCatalogDbContext>();

        var count = await context.ServiceCatalogItems
            .CountAsync(s => s.ServiceCode == "INVALID_CODE");
        Assert.Equal(0, count);
    }

    [Fact]
    public async Task EndToEnd_DuplicateServiceCode_ReturnsError()
    {
        // Arrange
        var service1 = CreateMinimalServiceModel("ID201", "First Service");
        var service2 = CreateMinimalServiceModel("ID201", "Second Service"); // Duplicate code

        // Act
        var response1 = await _client.PostAsJsonAsync("/api/services/import", service1);
        Assert.Equal(HttpStatusCode.OK, response1.StatusCode);

        var response2 = await _client.PostAsJsonAsync("/api/services/import", service2);

        // Assert
        Assert.Equal(HttpStatusCode.BadRequest, response2.StatusCode);

        var result = await response2.Content.ReadFromJsonAsync<ImportErrorResponse>();
        Assert.NotNull(result);
        Assert.Contains(result.Errors, e => e.Code == "DUPLICATE_SERVICE_CODE");
    }

    [Fact]
    public async Task EndToEnd_WithAllRelatedEntities_ImportsSuccessfully()
    {
        // Arrange
        var service = CreateCompleteServiceModel("ID301", "Complete Service");

        // Act
        var response = await _client.PostAsJsonAsync("/api/services/import", service);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        // Assert - Verify all related entities
        using var scope = _factory.Services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ServiceCatalogDbContext>();

        var dbService = await context.ServiceCatalogItems
            .Include(s => s.UsageScenarios)
            .Include(s => s.Dependencies)
            .Include(s => s.Prerequisites)
            .Include(s => s.Inputs)
            .Include(s => s.OutputCategories)
            .Include(s => s.TimelinePhases)
            .Include(s => s.SizeOptions)
            .Include(s => s.ResponsibleRoles)
            .FirstOrDefaultAsync(s => s.ServiceCode == "ID301");

        Assert.NotNull(dbService);
        Assert.NotEmpty(dbService.UsageScenarios);
        Assert.NotEmpty(dbService.Prerequisites);
        Assert.NotEmpty(dbService.Inputs);
        Assert.NotEmpty(dbService.OutputCategories);
        Assert.NotEmpty(dbService.TimelinePhases);
        Assert.NotEmpty(dbService.SizeOptions);
        Assert.NotEmpty(dbService.ResponsibleRoles);
    }

    [Fact]
    public async Task EndToEnd_InvalidJSON_ReturnsBadRequest()
    {
        // Arrange
        var invalidJson = "{ invalid json }";
        var content = new StringContent(invalidJson, System.Text.Encoding.UTF8, "application/json");

        // Act
        var response = await _client.PostAsync("/api/services/import", content);

        // Assert
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task EndToEnd_HealthCheck_ReturnsHealthy()
    {
        // Act
        var response = await _client.GetAsync("/api/services/import/health");

        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var result = await response.Content.ReadFromJsonAsync<HealthResponse>();
        Assert.NotNull(result);
        Assert.Equal("healthy", result.Status);
    }

    #region Helper Methods

    private ImportServiceModel CreateMinimalServiceModel(string code, string name)
    {
        return new ImportServiceModel
        {
            ServiceCode = code,
            ServiceName = name,
            Version = "v1.0",
            Category = "Services/Architecture",
            Description = $"Description for {name}",
            ResponsibleRoles = new List<ResponsibleRoleImportModel>
            {
                new() { RoleName = "Cloud Architect", IsPrimaryOwner = true }
            }
        };
    }

    private ImportServiceModel CreateCompleteServiceModel(string code, string name)
    {
        return new ImportServiceModel
        {
            ServiceCode = code,
            ServiceName = name,
            Version = "v1.0",
            Category = "Services/Architecture",
            Description = $"Complete description for {name}",
            UsageScenarios = new List<UsageScenarioImportModel>
            {
                new()
                {
                    ScenarioNumber = 1,
                    ScenarioTitle = "Scenario 1",
                    ScenarioDescription = "Description 1"
                }
            },
            Prerequisites = new PrerequisitesImportModel
            {
                Technical = new List<PrerequisiteItemImportModel>
                {
                    new()
                    {
                        Name = "Azure Subscription",
                        Description = "Active subscription",
                        RequirementLevel = "REQUIRED"
                    }
                }
            },
            ServiceInputs = new List<ServiceInputImportModel>
            {
                new()
                {
                    ParameterName = "Region",
                    Description = "Target region",
                    RequirementLevel = "REQUIRED"
                }
            },
            ServiceOutputs = new List<OutputCategoryImportModel>
            {
                new()
                {
                    CategoryNumber = 1,
                    CategoryName = "Documents",
                    Items = new List<OutputItemImportModel>
                    {
                        new() { ItemName = "Architecture Diagram" }
                    }
                }
            },
            Timeline = new List<TimelinePhaseImportModel>
            {
                new()
                {
                    PhaseNumber = 1,
                    PhaseName = "Discovery",
                    Description = "Requirements gathering"
                }
            },
            SizeOptions = new List<SizeOptionImportModel>
            {
                new()
                {
                    SizeCode = "M",
                    Description = "Medium",
                    Duration = "4 weeks",
                    Effort = new EffortImportModel { HoursMin = 100, HoursMax = 200 }
                }
            },
            ResponsibleRoles = new List<ResponsibleRoleImportModel>
            {
                new()
                {
                    RoleName = "Cloud Architect",
                    IsPrimaryOwner = true,
                    Responsibilities = "Lead design"
                }
            }
        };
    }

    #endregion

    #region Response Models

    private class ValidationResponse
    {
        public bool IsValid { get; set; }
        public string? Message { get; set; }
    }

    private class ImportResponse
    {
        public bool Success { get; set; }
        public int ServiceId { get; set; }
        public string? ServiceCode { get; set; }
    }

    private class ImportErrorResponse
    {
        public bool Success { get; set; }
        public string? Message { get; set; }
        public List<ErrorDetail> Errors { get; set; } = new();
    }

    private class ErrorDetail
    {
        public string? Field { get; set; }
        public string? Message { get; set; }
        public string? Code { get; set; }
    }

    private class BulkImportResponse
    {
        public int TotalCount { get; set; }
        public int SuccessCount { get; set; }
        public int FailCount { get; set; }
    }

    private class HealthResponse
    {
        public string? Status { get; set; }
    }

    #endregion
}
