using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using ServiceCatalogueManager.Api.Data.DbContext;
using ServiceCatalogueManager.Api.Data.Entities;

namespace ServiceCatalogueManager.Api.Tests.E2E;

/// <summary>
/// Custom WebApplicationFactory for integration testing
/// </summary>
public class TestWebApplicationFactory : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureServices(services =>
        {
            // Remove existing DbContext registration
            var descriptor = services.SingleOrDefault(
                d => d.ServiceType == typeof(DbContextOptions<ServiceCatalogDbContext>));
            
            if (descriptor != null)
            {
                services.Remove(descriptor);
            }

            // Add in-memory database for testing
            services.AddDbContext<ServiceCatalogDbContext>(options =>
            {
                options.UseInMemoryDatabase($"TestDb_{Guid.NewGuid()}");
            });

            // Build service provider and seed test data
            var sp = services.BuildServiceProvider();
            using var scope = sp.CreateScope();
            var scopedServices = scope.ServiceProvider;
            var db = scopedServices.GetRequiredService<ServiceCatalogDbContext>();

            db.Database.EnsureCreated();
            SeedTestData(db);
        });
    }

    private void SeedTestData(ServiceCatalogDbContext context)
    {
        // Seed lookup data
        SeedLookupTables(context);
        context.SaveChanges();
    }

    private void SeedLookupTables(ServiceCatalogDbContext context)
    {
        // Size options
        context.Set<LU_SizeOption>().AddRange(
            new LU_SizeOption { SizeOptionId = 1, Code = "S", Name = "Small", IsActive = true },
            new LU_SizeOption { SizeOptionId = 2, Code = "M", Name = "Medium", IsActive = true },
            new LU_SizeOption { SizeOptionId = 3, Code = "L", Name = "Large", IsActive = true },
            new LU_SizeOption { SizeOptionId = 4, Code = "XL", Name = "Extra Large", IsActive = true },
            new LU_SizeOption { SizeOptionId = 5, Code = "XXL", Name = "Extra Extra Large", IsActive = true }
        );

        // Categories
        context.Set<LU_ServiceCategory>().AddRange(
            new LU_ServiceCategory
            {
                CategoryId = 1,
                Code = "ARCH",
                Name = "Architecture",
                CategoryPath = "Services/Architecture",
                IsActive = true
            },
            new LU_ServiceCategory
            {
                CategoryId = 2,
                Code = "DEV",
                Name = "Development",
                CategoryPath = "Services/Development",
                IsActive = true
            }
        );

        // Dependency types
        context.Set<LU_DependencyType>().AddRange(
            new LU_DependencyType { DependencyTypeId = 1, Code = "PREREQUISITE", Name = "Prerequisite", IsActive = true },
            new LU_DependencyType { DependencyTypeId = 2, Code = "TRIGGERS_FOR", Name = "Triggers For", IsActive = true },
            new LU_DependencyType { DependencyTypeId = 3, Code = "PARALLEL_WITH", Name = "Parallel With", IsActive = true }
        );

        // Requirement levels
        context.Set<LU_RequirementLevel>().AddRange(
            new LU_RequirementLevel { RequirementLevelId = 1, Code = "REQUIRED", Name = "Required", IsActive = true },
            new LU_RequirementLevel { RequirementLevelId = 2, Code = "RECOMMENDED", Name = "Recommended", IsActive = true },
            new LU_RequirementLevel { RequirementLevelId = 3, Code = "OPTIONAL", Name = "Optional", IsActive = true }
        );

        // Roles
        context.Set<LU_Role>().AddRange(
            new LU_Role { RoleId = 1, Code = "CLOUD_ARCHITECT", Name = "Cloud Architect", IsActive = true },
            new LU_Role { RoleId = 2, Code = "SOLUTION_ARCHITECT", Name = "Solution Architect", IsActive = true },
            new LU_Role { RoleId = 3, Code = "TECHNICAL_LEAD", Name = "Technical Lead", IsActive = true }
        );

        // Prerequisite categories
        context.Set<LU_PrerequisiteCategory>().AddRange(
            new LU_PrerequisiteCategory { PrerequisiteCategoryId = 1, Code = "ORGANIZATIONAL", Name = "Organizational", IsActive = true },
            new LU_PrerequisiteCategory { PrerequisiteCategoryId = 2, Code = "TECHNICAL", Name = "Technical", IsActive = true },
            new LU_PrerequisiteCategory { PrerequisiteCategoryId = 3, Code = "DOCUMENTATION", Name = "Documentation", IsActive = true }
        );

        // Tool categories
        context.Set<LU_ToolCategory>().AddRange(
            new LU_ToolCategory { ToolCategoryId = 1, Code = "CLOUD_PLATFORMS", Name = "Cloud Platforms", IsActive = true },
            new LU_ToolCategory { ToolCategoryId = 2, Code = "DESIGN_TOOLS", Name = "Design Tools", IsActive = true },
            new LU_ToolCategory { ToolCategoryId = 3, Code = "AUTOMATION_TOOLS", Name = "Automation Tools", IsActive = true },
            new LU_ToolCategory { ToolCategoryId = 4, Code = "COLLABORATION_TOOLS", Name = "Collaboration Tools", IsActive = true },
            new LU_ToolCategory { ToolCategoryId = 5, Code = "OTHER", Name = "Other", IsActive = true }
        );

        // License types
        context.Set<LU_LicenseType>().AddRange(
            new LU_LicenseType { LicenseTypeId = 1, Code = "REQUIRED", Name = "Required", IsActive = true },
            new LU_LicenseType { LicenseTypeId = 2, Code = "RECOMMENDED", Name = "Recommended", IsActive = true },
            new LU_LicenseType { LicenseTypeId = 3, Code = "PROVIDED", Name = "Provided", IsActive = true }
        );

        // Interaction levels
        context.Set<LU_InteractionLevel>().AddRange(
            new LU_InteractionLevel { InteractionLevelId = 1, Code = "LOW", Name = "Low", IsActive = true },
            new LU_InteractionLevel { InteractionLevelId = 2, Code = "MEDIUM", Name = "Medium", IsActive = true },
            new LU_InteractionLevel { InteractionLevelId = 3, Code = "HIGH", Name = "High", IsActive = true }
        );

        // Scope types
        context.Set<LU_ScopeType>().AddRange(
            new LU_ScopeType { ScopeTypeId = 1, Code = "IN_SCOPE", Name = "In Scope", IsActive = true },
            new LU_ScopeType { ScopeTypeId = 2, Code = "OUT_OF_SCOPE", Name = "Out of Scope", IsActive = true }
        );

        // Cloud providers
        context.Set<LU_CloudProvider>().AddRange(
            new LU_CloudProvider { CloudProviderId = 1, Code = "AZURE", Name = "Microsoft Azure", IsActive = true },
            new LU_CloudProvider { CloudProviderId = 2, Code = "AWS", Name = "Amazon Web Services", IsActive = true },
            new LU_CloudProvider { CloudProviderId = 3, Code = "GCP", Name = "Google Cloud Platform", IsActive = true }
        );
    }
}

// Program marker class for WebApplicationFactory
public partial class Program { }
