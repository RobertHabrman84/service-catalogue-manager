using Microsoft.EntityFrameworkCore;
using ServiceCatalogueManager.Api.Data.Entities;

namespace ServiceCatalogueManager.Api.Data.DbContext;

/// <summary>
/// Entity Framework Core database context for Service Catalogue Manager
/// </summary>
public class ServiceCatalogDbContext : Microsoft.EntityFrameworkCore.DbContext
{
    public ServiceCatalogDbContext(DbContextOptions<ServiceCatalogDbContext> options)
        : base(options)
    {
    }

    // Main entities
    public DbSet<ServiceCatalogItem> ServiceCatalogItems => Set<ServiceCatalogItem>();
    public DbSet<UsageScenario> UsageScenarios => Set<UsageScenario>();
    public DbSet<ServiceDependency> ServiceDependencies => Set<ServiceDependency>();
    public DbSet<ServiceScopeCategory> ServiceScopeCategories => Set<ServiceScopeCategory>();
    public DbSet<ServiceScopeItem> ServiceScopeItems => Set<ServiceScopeItem>();
    public DbSet<ServicePrerequisite> ServicePrerequisites => Set<ServicePrerequisite>();
    public DbSet<CloudProviderCapability> CloudProviderCapabilities => Set<CloudProviderCapability>();
    public DbSet<ServiceToolFramework> ServiceToolFrameworks => Set<ServiceToolFramework>();
    public DbSet<ServiceLicense> ServiceLicenses => Set<ServiceLicense>();
    public DbSet<ServiceInteraction> ServiceInteractions => Set<ServiceInteraction>();
    public DbSet<CustomerRequirement> CustomerRequirements => Set<CustomerRequirement>();
    public DbSet<AccessRequirement> AccessRequirements => Set<AccessRequirement>();
    public DbSet<StakeholderInvolvement> StakeholderInvolvements => Set<StakeholderInvolvement>();
    public DbSet<ServiceInput> ServiceInputs => Set<ServiceInput>();
    public DbSet<ServiceOutputCategory> ServiceOutputCategories => Set<ServiceOutputCategory>();
    public DbSet<ServiceOutputItem> ServiceOutputItems => Set<ServiceOutputItem>();
    public DbSet<TimelinePhase> TimelinePhases => Set<TimelinePhase>();
    public DbSet<PhaseDurationBySize> PhaseDurationsBySizes => Set<PhaseDurationBySize>();
    public DbSet<ServiceSizeOption> ServiceSizeOptions => Set<ServiceSizeOption>();
    public DbSet<SizingCriteria> SizingCriterias => Set<SizingCriteria>();
    public DbSet<SizingCriteriaValue> SizingCriteriaValues => Set<SizingCriteriaValue>();
    public DbSet<SizingParameter> SizingParameters => Set<SizingParameter>();
    public DbSet<SizingParameterValue> SizingParameterValues => Set<SizingParameterValue>();
    public DbSet<EffortEstimationItem> EffortEstimationItems => Set<EffortEstimationItem>();
    public DbSet<TechnicalComplexityAddition> TechnicalComplexityAdditions => Set<TechnicalComplexityAddition>();
    public DbSet<ScopeDependency> ScopeDependencies => Set<ScopeDependency>();
    public DbSet<SizingExample> SizingExamples => Set<SizingExample>();
    public DbSet<SizingExampleCharacteristic> SizingExampleCharacteristics => Set<SizingExampleCharacteristic>();
    public DbSet<ServiceResponsibleRole> ServiceResponsibleRoles => Set<ServiceResponsibleRole>();
    public DbSet<ServiceTeamAllocation> ServiceTeamAllocations => Set<ServiceTeamAllocation>();
    public DbSet<ServiceMultiCloudConsideration> ServiceMultiCloudConsiderations => Set<ServiceMultiCloudConsideration>();

    // Calculator entities
    public DbSet<ServicePricingConfig> ServicePricingConfigs => Set<ServicePricingConfig>();
    public DbSet<ServiceRoleRate> ServiceRoleRates => Set<ServiceRoleRate>();
    public DbSet<ServiceBaseEffort> ServiceBaseEfforts => Set<ServiceBaseEffort>();
    public DbSet<ServiceContextMultiplier> ServiceContextMultipliers => Set<ServiceContextMultiplier>();
    public DbSet<ServiceContextMultiplierValue> ServiceContextMultiplierValues => Set<ServiceContextMultiplierValue>();
    public DbSet<ServiceScopeArea> ServiceScopeAreas => Set<ServiceScopeArea>();
    public DbSet<ServiceComplianceFactor> ServiceComplianceFactors => Set<ServiceComplianceFactor>();
    public DbSet<ServiceCalculatorSection> ServiceCalculatorSections => Set<ServiceCalculatorSection>();
    public DbSet<ServiceCalculatorGroup> ServiceCalculatorGroups => Set<ServiceCalculatorGroup>();
    public DbSet<ServiceCalculatorParameter> ServiceCalculatorParameters => Set<ServiceCalculatorParameter>();
    public DbSet<ServiceCalculatorParameterOption> ServiceCalculatorParameterOptions => Set<ServiceCalculatorParameterOption>();
    public DbSet<ServiceCalculatorScenario> ServiceCalculatorScenarios => Set<ServiceCalculatorScenario>();
    public DbSet<ServiceCalculatorPhase> ServiceCalculatorPhases => Set<ServiceCalculatorPhase>();
    public DbSet<ServiceTeamComposition> ServiceTeamCompositions => Set<ServiceTeamComposition>();
    public DbSet<ServiceSizingCriteria> ServiceSizingCriterias => Set<ServiceSizingCriteria>();

    // Lookup tables
    public DbSet<LU_ServiceCategory> LU_ServiceCategories => Set<LU_ServiceCategory>();
    public DbSet<LU_SizeOption> LU_SizeOptions => Set<LU_SizeOption>();
    public DbSet<LU_CloudProvider> LU_CloudProviders => Set<LU_CloudProvider>();
    public DbSet<LU_DependencyType> LU_DependencyTypes => Set<LU_DependencyType>();
    public DbSet<LU_PrerequisiteCategory> LU_PrerequisiteCategories => Set<LU_PrerequisiteCategory>();
    public DbSet<LU_LicenseType> LU_LicenseTypes => Set<LU_LicenseType>();
    public DbSet<LU_ToolCategory> LU_ToolCategories => Set<LU_ToolCategory>();
    public DbSet<LU_ScopeType> LU_ScopeTypes => Set<LU_ScopeType>();
    public DbSet<LU_InteractionLevel> LU_InteractionLevels => Set<LU_InteractionLevel>();
    public DbSet<LU_RequirementLevel> LU_RequirementLevels => Set<LU_RequirementLevel>();
    public DbSet<LU_Role> LU_Roles => Set<LU_Role>();
    public DbSet<LU_EffortCategory> LU_EffortCategories => Set<LU_EffortCategory>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Apply configurations
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ServiceCatalogDbContext).Assembly);

        // Configure ServiceCatalogItem
        modelBuilder.Entity<ServiceCatalogItem>(entity =>
        {
            entity.ToTable("ServiceCatalogItem");
            entity.HasKey(e => e.ServiceId);
            entity.Property(e => e.ServiceCode).IsRequired().HasMaxLength(50);
            entity.Property(e => e.ServiceName).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Version).HasMaxLength(20).HasDefaultValue("v1.0");
            entity.Property(e => e.Description).IsRequired();
            entity.HasIndex(e => e.ServiceCode).IsUnique();
            entity.HasIndex(e => e.CategoryId);
            entity.HasIndex(e => e.IsActive);

            entity.HasOne(e => e.Category)
                .WithMany(c => c.Services)
                .HasForeignKey(e => e.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // Configure UsageScenario
        modelBuilder.Entity<UsageScenario>(entity =>
        {
            entity.ToTable("UsageScenario");
            entity.HasKey(e => e.ScenarioId);
            entity.Property(e => e.ScenarioTitle).IsRequired().HasMaxLength(200);
            entity.Property(e => e.ScenarioDescription).IsRequired();

            entity.HasOne(e => e.Service)
                .WithMany(s => s.UsageScenarios)
                .HasForeignKey(e => e.ServiceId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure ServiceDependency
        modelBuilder.Entity<ServiceDependency>(entity =>
        {
            entity.ToTable("ServiceDependency");
            entity.HasKey(e => e.DependencyId);
            
            // Column mapping - C# uses RelatedServiceId, SQL uses DependentServiceID
            entity.Property(e => e.RelatedServiceId).HasColumnName("DependentServiceID");

            entity.HasOne(e => e.Service)
                .WithMany(s => s.Dependencies)
                .HasForeignKey(e => e.ServiceId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(e => e.DependencyType)
                .WithMany()
                .HasForeignKey(e => e.DependencyTypeId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // Configure ServiceScopeCategory
        modelBuilder.Entity<ServiceScopeCategory>(entity =>
        {
            entity.ToTable("ServiceScopeCategory");
            entity.HasKey(e => e.ScopeCategoryId);
            entity.Property(e => e.CategoryName).IsRequired().HasMaxLength(200);

            entity.HasOne(e => e.Service)
                .WithMany(s => s.ScopeCategories)
                .HasForeignKey(e => e.ServiceId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure ServiceScopeItem
        modelBuilder.Entity<ServiceScopeItem>(entity =>
        {
            entity.ToTable("ServiceScopeItem");
            entity.HasKey(e => e.ScopeItemId);
            entity.Property(e => e.ItemDescription).IsRequired();

            entity.HasOne(e => e.ScopeCategory)
                .WithMany(c => c.Items)
                .HasForeignKey(e => e.ScopeCategoryId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure ServiceInteraction (one-to-one with ServiceCatalogItem)
        modelBuilder.Entity<ServiceInteraction>(entity =>
        {
            entity.ToTable("ServiceInteraction");
            entity.HasKey(e => e.InteractionId);

            entity.HasOne(e => e.Service)
                .WithOne(s => s.Interaction)
                .HasForeignKey<ServiceInteraction>(e => e.ServiceId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        
        // Configure CustomerRequirement
        modelBuilder.Entity<CustomerRequirement>(entity =>
        {
            entity.ToTable("CustomerRequirement");
            entity.HasKey(e => e.RequirementId);
            entity.Property(e => e.RequirementDescription).IsRequired();

            entity.HasOne(e => e.Interaction)
                .WithMany(i => i.CustomerRequirements)
                .HasForeignKey(e => e.InteractionId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure AccessRequirement
        modelBuilder.Entity<AccessRequirement>(entity =>
        {
            entity.ToTable("AccessRequirement");
            entity.HasKey(e => e.AccessId);
            entity.Property(e => e.AccessDescription).IsRequired();

            entity.HasOne(e => e.Interaction)
                .WithMany(i => i.AccessRequirements)
                .HasForeignKey(e => e.InteractionId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure StakeholderInvolvement
        modelBuilder.Entity<StakeholderInvolvement>(entity =>
        {
            entity.ToTable("StakeholderInvolvement");
            entity.HasKey(e => e.InvolvementId);
            entity.Property(e => e.StakeholderRole).IsRequired().HasMaxLength(100);

            entity.HasOne(e => e.Interaction)
                .WithMany(i => i.StakeholderInvolvements)
                .HasForeignKey(e => e.InteractionId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure ServicePrerequisite
        modelBuilder.Entity<ServicePrerequisite>(entity =>
        {
            entity.ToTable("ServicePrerequisite");
            entity.HasKey(e => e.PrerequisiteId);
            entity.Property(e => e.PrerequisiteName).IsRequired();

            entity.HasOne(e => e.Service)
                .WithMany(s => s.Prerequisites)
                .HasForeignKey(e => e.ServiceId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure ServiceInput
        modelBuilder.Entity<ServiceInput>(entity =>
        {
            entity.ToTable("ServiceInput");
            entity.HasKey(e => e.InputId);
            entity.Property(e => e.InputName).IsRequired().HasMaxLength(200);

            entity.HasOne(e => e.Service)
                .WithMany(s => s.Inputs)
                .HasForeignKey(e => e.ServiceId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure ServiceOutputCategory
        modelBuilder.Entity<ServiceOutputCategory>(entity =>
        {
            entity.ToTable("ServiceOutputCategory");
            entity.HasKey(e => e.OutputCategoryId);
            entity.Property(e => e.CategoryName).IsRequired().HasMaxLength(200);

            entity.HasOne(e => e.Service)
                .WithMany(s => s.OutputCategories)
                .HasForeignKey(e => e.ServiceId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure ServiceOutputItem
        modelBuilder.Entity<ServiceOutputItem>(entity =>
        {
            entity.ToTable("ServiceOutputItem");
            entity.HasKey(e => e.OutputItemId);
            entity.Property(e => e.ItemDescription).IsRequired();

            entity.HasOne(e => e.OutputCategory)
                .WithMany(c => c.Items)
                .HasForeignKey(e => e.OutputCategoryId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure TimelinePhase
        modelBuilder.Entity<TimelinePhase>(entity =>
        {
            entity.ToTable("TimelinePhase");
            entity.HasKey(e => e.PhaseId);
            entity.Property(e => e.PhaseName).IsRequired().HasMaxLength(200);

            entity.HasOne(e => e.Service)
                .WithMany(s => s.TimelinePhases)
                .HasForeignKey(e => e.ServiceId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure PhaseDurationBySize
        modelBuilder.Entity<PhaseDurationBySize>(entity =>
        {
            entity.ToTable("PhaseDurationBySize");
            entity.HasKey(e => e.PhaseDurationId);

            entity.HasOne(e => e.Phase)
                .WithMany(p => p.DurationsBySize)
                .HasForeignKey(e => e.PhaseId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure ServiceSizeOption
        modelBuilder.Entity<ServiceSizeOption>(entity =>
        {
            entity.ToTable("ServiceSizeOption");
            entity.HasKey(e => e.ServiceSizeOptionId);

            entity.HasOne(e => e.Service)
                .WithMany(s => s.SizeOptions)
                .HasForeignKey(e => e.ServiceId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure EffortEstimationItem
        modelBuilder.Entity<EffortEstimationItem>(entity =>
        {
            entity.ToTable("EffortEstimationItem");
            entity.HasKey(e => e.EstimationId);
            entity.Property(e => e.EffortDays).HasPrecision(18, 2);

            entity.HasOne(e => e.Service)
                .WithMany(s => s.EffortEstimations)
                .HasForeignKey(e => e.ServiceId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure ServiceResponsibleRole
        modelBuilder.Entity<ServiceResponsibleRole>(entity =>
        {
            entity.ToTable("ServiceResponsibleRole");
            entity.HasKey(e => e.ResponsibleRoleId);

            entity.HasOne(e => e.Service)
                .WithMany(s => s.ResponsibleRoles)
                .HasForeignKey(e => e.ServiceId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure ServiceTeamAllocation
        modelBuilder.Entity<ServiceTeamAllocation>(entity =>
        {
            entity.ToTable("ServiceTeamAllocation");
            entity.HasKey(e => e.TeamAllocationId);
            entity.Property(e => e.CloudArchitects).HasPrecision(18, 2);
            entity.Property(e => e.SolutionArchitects).HasPrecision(18, 2);
            entity.Property(e => e.TechnicalLeads).HasPrecision(18, 2);
            entity.Property(e => e.Developers).HasPrecision(18, 2);
            entity.Property(e => e.QAEngineers).HasPrecision(18, 2);
            entity.Property(e => e.DevOpsEngineers).HasPrecision(18, 2);
            entity.Property(e => e.SecuritySpecialists).HasPrecision(18, 2);
            entity.Property(e => e.ProjectManagers).HasPrecision(18, 2);
            entity.Property(e => e.BusinessAnalysts).HasPrecision(18, 2);

            entity.HasOne(e => e.Service)
                .WithMany(s => s.TeamAllocations)
                .HasForeignKey(e => e.ServiceId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure ServiceMultiCloudConsideration
        modelBuilder.Entity<ServiceMultiCloudConsideration>(entity =>
        {
            entity.ToTable("ServiceMultiCloudConsideration");
            entity.HasKey(e => e.ConsiderationId);

            entity.HasOne(e => e.Service)
                .WithMany(s => s.MultiCloudConsiderations)
                .HasForeignKey(e => e.ServiceId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure SizingExample
        modelBuilder.Entity<SizingExample>(entity =>
        {
            entity.ToTable("SizingExample");
            entity.HasKey(e => e.ExampleId);
            entity.Property(e => e.ExampleTitle).IsRequired().HasMaxLength(200);

            entity.HasOne(e => e.Service)
                .WithMany(s => s.SizingExamples)
                .HasForeignKey(e => e.ServiceId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configure remaining entities with primary keys and table names
        
        // CloudProviderCapability - needs .ToTable()
        modelBuilder.Entity<CloudProviderCapability>()
            .ToTable("CloudProviderCapability")
            .HasKey(e => e.CapabilityId);

        // ServiceToolFramework - needs .ToTable() + column mapping for PK
        modelBuilder.Entity<ServiceToolFramework>(entity =>
        {
            entity.ToTable("ServiceToolFramework");
            entity.HasKey(e => e.ToolId);
            entity.Property(e => e.ToolId).HasColumnName("ToolFrameworkID");
        });

        // ServiceLicense - needs .ToTable() + column mapping
        modelBuilder.Entity<ServiceLicense>(entity =>
        {
            entity.ToTable("ServiceLicense");
            entity.HasKey(e => e.LicenseId);
            entity.Property(e => e.LicenseName).HasColumnName("LicenseDescription");
        });

        // Sizing entities - need .ToTable()
        modelBuilder.Entity<SizingCriteria>()
            .ToTable("SizingCriteria")
            .HasKey(e => e.CriteriaId);
        
        modelBuilder.Entity<SizingCriteriaValue>()
            .ToTable("SizingCriteriaValue")
            .HasKey(e => e.CriteriaValueId);
        
        modelBuilder.Entity<SizingParameter>()
            .ToTable("SizingParameter")
            .HasKey(e => e.ParameterId);
        
        modelBuilder.Entity<SizingParameterValue>()
            .ToTable("SizingParameterValue")
            .HasKey(e => e.ParameterValueId);

        // TechnicalComplexityAddition - needs .ToTable() + column mapping for PK
        modelBuilder.Entity<TechnicalComplexityAddition>(entity =>
        {
            entity.ToTable("TechnicalComplexityAddition");
            entity.HasKey(e => e.AdditionId);
            entity.Property(e => e.AdditionId).HasColumnName("ComplexityAdditionID");
        });

        // ScopeDependency - needs .ToTable()
        modelBuilder.Entity<ScopeDependency>()
            .ToTable("ScopeDependency")
            .HasKey(e => e.ScopeDependencyId);
        
        // SizingExampleCharacteristic - needs .ToTable()
        modelBuilder.Entity<SizingExampleCharacteristic>()
            .ToTable("SizingExampleCharacteristic")
            .HasKey(e => e.CharacteristicId);

        // Configure Calculator entities
        modelBuilder.Entity<ServicePricingConfig>().HasKey(e => e.PricingConfigId);
        modelBuilder.Entity<ServiceRoleRate>().HasKey(e => e.RoleRateId);
        modelBuilder.Entity<ServiceBaseEffort>().HasKey(e => e.BaseEffortId);
        modelBuilder.Entity<ServiceContextMultiplier>().HasKey(e => e.MultiplierId);
        modelBuilder.Entity<ServiceContextMultiplierValue>().HasKey(e => e.ValueId);
        modelBuilder.Entity<ServiceScopeArea>().HasKey(e => e.ScopeAreaId);
        modelBuilder.Entity<ServiceComplianceFactor>().HasKey(e => e.FactorId);
        modelBuilder.Entity<ServiceCalculatorSection>().HasKey(e => e.SectionId);
        modelBuilder.Entity<ServiceCalculatorGroup>().HasKey(e => e.GroupId);
        modelBuilder.Entity<ServiceCalculatorParameter>().HasKey(e => e.ParameterId);
        modelBuilder.Entity<ServiceCalculatorParameterOption>().HasKey(e => e.OptionId);
        modelBuilder.Entity<ServiceCalculatorScenario>().HasKey(e => e.ScenarioId);
        modelBuilder.Entity<ServiceCalculatorPhase>().HasKey(e => e.PhaseId);
        modelBuilder.Entity<ServiceTeamComposition>().HasKey(e => e.CompositionId);
        modelBuilder.Entity<ServiceSizingCriteria>().HasKey(e => e.SizingCriteriaId);

        // Configure Calculator entities with decimal precision
        modelBuilder.Entity<ServicePricingConfig>(entity =>
        {
            entity.Property(e => e.Margin).HasColumnType("decimal(5,2)");
            entity.Property(e => e.RiskPremium).HasColumnType("decimal(5,2)");
            entity.Property(e => e.Contingency).HasColumnType("decimal(5,2)");
            entity.Property(e => e.Discount).HasColumnType("decimal(5,2)");
        });

        modelBuilder.Entity<ServiceRoleRate>(entity =>
        {
            entity.Property(e => e.DailyRate).HasColumnType("decimal(10,2)");
        });

        modelBuilder.Entity<ServiceContextMultiplierValue>(entity =>
        {
            entity.Property(e => e.MultiplierValue).HasColumnType("decimal(5,2)");
        });

        modelBuilder.Entity<ServiceTeamComposition>(entity =>
        {
            entity.Property(e => e.FteAllocation).HasColumnType("decimal(3,2)");
        });



        // Configure Lookup tables
        ConfigureLookupTables(modelBuilder);
    }

    private static void ConfigureLookupTables(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<LU_ServiceCategory>(entity =>
        {
            entity.ToTable("LU_ServiceCategory");
            entity.HasKey(e => e.CategoryId);
            entity.Property(e => e.Code).IsRequired().HasMaxLength(50).HasColumnName("CategoryCode");
            entity.Property(e => e.Name).IsRequired().HasMaxLength(200).HasColumnName("CategoryName");
            entity.Property(e => e.CategoryPath).HasMaxLength(500);
            entity.HasIndex(e => e.Code).IsUnique();

            entity.HasOne(e => e.ParentCategory)
                .WithMany(e => e.ChildCategories)
                .HasForeignKey(e => e.ParentCategoryId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<LU_SizeOption>(entity =>
        {
            entity.ToTable("LU_SizeOption");
            entity.HasKey(e => e.SizeOptionId);
            entity.Property(e => e.Code).IsRequired().HasMaxLength(10).HasColumnName("SizeCode");
            entity.Property(e => e.Name).IsRequired().HasMaxLength(50).HasColumnName("SizeName");
            entity.HasIndex(e => e.Code).IsUnique();
        });

        modelBuilder.Entity<LU_CloudProvider>(entity =>
        {
            entity.ToTable("LU_CloudProvider");
            entity.HasKey(e => e.CloudProviderId);
            entity.Property(e => e.Code).IsRequired().HasMaxLength(20).HasColumnName("ProviderCode");
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100).HasColumnName("ProviderName");
            entity.HasIndex(e => e.Code).IsUnique();
        });

        modelBuilder.Entity<LU_DependencyType>(entity =>
        {
            entity.ToTable("LU_DependencyType");
            entity.HasKey(e => e.DependencyTypeId);
            entity.Property(e => e.Code).IsRequired().HasMaxLength(50).HasColumnName("TypeCode");
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100).HasColumnName("TypeName");
            entity.HasIndex(e => e.Code).IsUnique();
        });

        modelBuilder.Entity<LU_PrerequisiteCategory>(entity =>
        {
            entity.ToTable("LU_PrerequisiteCategory");
            entity.HasKey(e => e.PrerequisiteCategoryId);
            entity.Property(e => e.Code).IsRequired().HasMaxLength(50).HasColumnName("CategoryCode");
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100).HasColumnName("CategoryName");
            entity.HasIndex(e => e.Code).IsUnique();
        });

        modelBuilder.Entity<LU_LicenseType>(entity =>
        {
            entity.ToTable("LU_LicenseType");
            entity.HasKey(e => e.LicenseTypeId);
            entity.Property(e => e.Code).IsRequired().HasMaxLength(50).HasColumnName("TypeCode");
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100).HasColumnName("TypeName");
            entity.HasIndex(e => e.Code).IsUnique();
        });

        modelBuilder.Entity<LU_ToolCategory>(entity =>
        {
            entity.ToTable("LU_ToolCategory");
            entity.HasKey(e => e.ToolCategoryId);
            entity.Property(e => e.Code).IsRequired().HasMaxLength(50).HasColumnName("CategoryCode");
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100).HasColumnName("CategoryName");
            entity.HasIndex(e => e.Code).IsUnique();
        });

        modelBuilder.Entity<LU_ScopeType>(entity =>
        {
            entity.ToTable("LU_ScopeType");
            entity.HasKey(e => e.ScopeTypeId);
            entity.Property(e => e.Code).IsRequired().HasMaxLength(20).HasColumnName("TypeCode");
            entity.Property(e => e.Name).IsRequired().HasMaxLength(50).HasColumnName("TypeName");
            entity.HasIndex(e => e.Code).IsUnique();
        });

        modelBuilder.Entity<LU_InteractionLevel>(entity =>
        {
            entity.ToTable("LU_InteractionLevel");
            entity.HasKey(e => e.InteractionLevelId);
            entity.Property(e => e.Code).IsRequired().HasMaxLength(20).HasColumnName("LevelCode");
            entity.Property(e => e.Name).IsRequired().HasMaxLength(50).HasColumnName("LevelName");
            entity.HasIndex(e => e.Code).IsUnique();
        });

        modelBuilder.Entity<LU_RequirementLevel>(entity =>
        {
            entity.ToTable("LU_RequirementLevel");
            entity.HasKey(e => e.RequirementLevelId);
            entity.Property(e => e.Code).IsRequired().HasMaxLength(20).HasColumnName("LevelCode");
            entity.Property(e => e.Name).IsRequired().HasMaxLength(50).HasColumnName("LevelName");
            entity.HasIndex(e => e.Code).IsUnique();
        });

        modelBuilder.Entity<LU_Role>(entity =>
        {
            entity.ToTable("LU_Role");
            entity.HasKey(e => e.RoleId);
            entity.Property(e => e.Code).IsRequired().HasMaxLength(50).HasColumnName("RoleCode");
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100).HasColumnName("RoleName");
            entity.HasIndex(e => e.Code).IsUnique();
        });


        modelBuilder.Entity<LU_EffortCategory>(entity =>
        {
            entity.ToTable("LU_EffortCategory");
            entity.HasKey(e => e.EffortCategoryId);
            entity.Property(e => e.Code).IsRequired().HasMaxLength(50).HasColumnName("CategoryCode");
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100).HasColumnName("CategoryName");
            entity.HasIndex(e => e.Code).IsUnique();
        });
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        UpdateAuditFields();
        return base.SaveChangesAsync(cancellationToken);
    }

    public override int SaveChanges()
    {
        UpdateAuditFields();
        return base.SaveChanges();
    }

    private void UpdateAuditFields()
    {
        var entries = ChangeTracker.Entries<BaseEntity>();

        foreach (var entry in entries)
        {
            if (entry.State == EntityState.Added)
            {
                entry.Entity.CreatedDate = DateTime.UtcNow;
                entry.Entity.ModifiedDate = DateTime.UtcNow;
            }
            else if (entry.State == EntityState.Modified)
            {
                entry.Entity.ModifiedDate = DateTime.UtcNow;
            }
        }
    }
}





