using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ServiceCatalogueManager.Api.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "LU_CloudProvider",
                columns: table => new
                {
                    CloudProviderId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Code = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LU_CloudProvider", x => x.CloudProviderId);
                });

            migrationBuilder.CreateTable(
                name: "LU_DependencyType",
                columns: table => new
                {
                    DependencyTypeId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Code = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LU_DependencyType", x => x.DependencyTypeId);
                });

            migrationBuilder.CreateTable(
                name: "LU_EffortCategory",
                columns: table => new
                {
                    EffortCategoryId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Code = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LU_EffortCategory", x => x.EffortCategoryId);
                });

            migrationBuilder.CreateTable(
                name: "LU_InteractionLevel",
                columns: table => new
                {
                    InteractionLevelId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Code = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LU_InteractionLevel", x => x.InteractionLevelId);
                });

            migrationBuilder.CreateTable(
                name: "LU_LicenseType",
                columns: table => new
                {
                    LicenseTypeId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Code = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LU_LicenseType", x => x.LicenseTypeId);
                });

            migrationBuilder.CreateTable(
                name: "LU_PrerequisiteCategory",
                columns: table => new
                {
                    PrerequisiteCategoryId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Code = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LU_PrerequisiteCategory", x => x.PrerequisiteCategoryId);
                });

            migrationBuilder.CreateTable(
                name: "LU_RequirementLevel",
                columns: table => new
                {
                    RequirementLevelId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Code = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LU_RequirementLevel", x => x.RequirementLevelId);
                });

            migrationBuilder.CreateTable(
                name: "LU_Role",
                columns: table => new
                {
                    RoleId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Code = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LU_Role", x => x.RoleId);
                });

            migrationBuilder.CreateTable(
                name: "LU_ScopeType",
                columns: table => new
                {
                    ScopeTypeId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Code = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LU_ScopeType", x => x.ScopeTypeId);
                });

            migrationBuilder.CreateTable(
                name: "LU_ServiceCategory",
                columns: table => new
                {
                    CategoryId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ParentCategoryId = table.Column<int>(type: "int", nullable: true),
                    CategoryPath = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    CreatedDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Code = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LU_ServiceCategory", x => x.CategoryId);
                    table.ForeignKey(
                        name: "FK_LU_ServiceCategory_LU_ServiceCategory_ParentCategoryId",
                        column: x => x.ParentCategoryId,
                        principalTable: "LU_ServiceCategory",
                        principalColumn: "CategoryId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "LU_SizeOption",
                columns: table => new
                {
                    SizeOptionId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Code = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LU_SizeOption", x => x.SizeOptionId);
                });

            migrationBuilder.CreateTable(
                name: "LU_ToolCategory",
                columns: table => new
                {
                    ToolCategoryId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Code = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LU_ToolCategory", x => x.ToolCategoryId);
                });

            migrationBuilder.CreateTable(
                name: "ServiceCatalogItem",
                columns: table => new
                {
                    ServiceId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceCode = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    ServiceName = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Version = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false, defaultValue: "v1.0"),
                    CategoryId = table.Column<int>(type: "int", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Notes = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatedBy = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ModifiedBy = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ServiceCatalogItem", x => x.ServiceId);
                    table.ForeignKey(
                        name: "FK_ServiceCatalogItem_LU_ServiceCategory_CategoryId",
                        column: x => x.CategoryId,
                        principalTable: "LU_ServiceCategory",
                        principalColumn: "CategoryId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "CloudProviderCapabilities",
                columns: table => new
                {
                    CapabilityId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    CloudProviderId = table.Column<int>(type: "int", nullable: false),
                    CapabilityName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CapabilityDescription = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CloudProviderCapabilities", x => x.CapabilityId);
                    table.ForeignKey(
                        name: "FK_CloudProviderCapabilities_LU_CloudProvider_CloudProviderId",
                        column: x => x.CloudProviderId,
                        principalTable: "LU_CloudProvider",
                        principalColumn: "CloudProviderId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_CloudProviderCapabilities_ServiceCatalogItem_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "EffortEstimationItem",
                columns: table => new
                {
                    EstimationId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    EffortCategoryId = table.Column<int>(type: "int", nullable: false),
                    SizeOptionId = table.Column<int>(type: "int", nullable: false),
                    EffortDays = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    Notes = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EffortEstimationItem", x => x.EstimationId);
                    table.ForeignKey(
                        name: "FK_EffortEstimationItem_LU_EffortCategory_EffortCategoryId",
                        column: x => x.EffortCategoryId,
                        principalTable: "LU_EffortCategory",
                        principalColumn: "EffortCategoryId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_EffortEstimationItem_LU_SizeOption_SizeOptionId",
                        column: x => x.SizeOptionId,
                        principalTable: "LU_SizeOption",
                        principalColumn: "SizeOptionId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_EffortEstimationItem_ServiceCatalogItem_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ScopeDependencies",
                columns: table => new
                {
                    ScopeDependencyId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    AreaName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    RequiresDescription = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ScopeDependencies", x => x.ScopeDependencyId);
                    table.ForeignKey(
                        name: "FK_ScopeDependencies_ServiceCatalogItem_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ServiceDependency",
                columns: table => new
                {
                    DependencyId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    DependencyTypeId = table.Column<int>(type: "int", nullable: false),
                    DependentServiceId = table.Column<int>(type: "int", nullable: true),
                    DependencyName = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    RequirementLevelId = table.Column<int>(type: "int", nullable: true),
                    Notes = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ServiceDependency", x => x.DependencyId);
                    table.ForeignKey(
                        name: "FK_ServiceDependency_LU_DependencyType_DependencyTypeId",
                        column: x => x.DependencyTypeId,
                        principalTable: "LU_DependencyType",
                        principalColumn: "DependencyTypeId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ServiceDependency_LU_RequirementLevel_RequirementLevelId",
                        column: x => x.RequirementLevelId,
                        principalTable: "LU_RequirementLevel",
                        principalColumn: "RequirementLevelId");
                    table.ForeignKey(
                        name: "FK_ServiceDependency_ServiceCatalogItem_DependentServiceId",
                        column: x => x.DependentServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId");
                    table.ForeignKey(
                        name: "FK_ServiceDependency_ServiceCatalogItem_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ServiceInput",
                columns: table => new
                {
                    InputId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    InputName = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    RequirementLevelId = table.Column<int>(type: "int", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ServiceInput", x => x.InputId);
                    table.ForeignKey(
                        name: "FK_ServiceInput_LU_RequirementLevel_RequirementLevelId",
                        column: x => x.RequirementLevelId,
                        principalTable: "LU_RequirementLevel",
                        principalColumn: "RequirementLevelId");
                    table.ForeignKey(
                        name: "FK_ServiceInput_ServiceCatalogItem_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ServiceInteraction",
                columns: table => new
                {
                    InteractionId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    InteractionLevelId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ServiceInteraction", x => x.InteractionId);
                    table.ForeignKey(
                        name: "FK_ServiceInteraction_LU_InteractionLevel_InteractionLevelId",
                        column: x => x.InteractionLevelId,
                        principalTable: "LU_InteractionLevel",
                        principalColumn: "InteractionLevelId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ServiceInteraction_ServiceCatalogItem_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ServiceLicenses",
                columns: table => new
                {
                    LicenseId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    LicenseTypeId = table.Column<int>(type: "int", nullable: false),
                    LicenseName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    LicenseDescription = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ServiceLicenses", x => x.LicenseId);
                    table.ForeignKey(
                        name: "FK_ServiceLicenses_LU_LicenseType_LicenseTypeId",
                        column: x => x.LicenseTypeId,
                        principalTable: "LU_LicenseType",
                        principalColumn: "LicenseTypeId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ServiceLicenses_ServiceCatalogItem_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ServiceMultiCloudConsideration",
                columns: table => new
                {
                    ConsiderationId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    CloudProviderId = table.Column<int>(type: "int", nullable: false),
                    Considerations = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Limitations = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ServiceMultiCloudConsideration", x => x.ConsiderationId);
                    table.ForeignKey(
                        name: "FK_ServiceMultiCloudConsideration_LU_CloudProvider_CloudProviderId",
                        column: x => x.CloudProviderId,
                        principalTable: "LU_CloudProvider",
                        principalColumn: "CloudProviderId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ServiceMultiCloudConsideration_ServiceCatalogItem_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ServiceOutputCategory",
                columns: table => new
                {
                    OutputCategoryId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    CategoryName = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ServiceOutputCategory", x => x.OutputCategoryId);
                    table.ForeignKey(
                        name: "FK_ServiceOutputCategory_ServiceCatalogItem_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ServicePrerequisite",
                columns: table => new
                {
                    PrerequisiteId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    PrerequisiteCategoryId = table.Column<int>(type: "int", nullable: false),
                    PrerequisiteName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ServicePrerequisite", x => x.PrerequisiteId);
                    table.ForeignKey(
                        name: "FK_ServicePrerequisite_LU_PrerequisiteCategory_PrerequisiteCategoryId",
                        column: x => x.PrerequisiteCategoryId,
                        principalTable: "LU_PrerequisiteCategory",
                        principalColumn: "PrerequisiteCategoryId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ServicePrerequisite_ServiceCatalogItem_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ServiceResponsibleRole",
                columns: table => new
                {
                    ResponsibleRoleId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    RoleId = table.Column<int>(type: "int", nullable: false),
                    IsPrimary = table.Column<bool>(type: "bit", nullable: false),
                    Responsibilities = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ServiceResponsibleRole", x => x.ResponsibleRoleId);
                    table.ForeignKey(
                        name: "FK_ServiceResponsibleRole_LU_Role_RoleId",
                        column: x => x.RoleId,
                        principalTable: "LU_Role",
                        principalColumn: "RoleId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ServiceResponsibleRole_ServiceCatalogItem_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ServiceScopeCategory",
                columns: table => new
                {
                    ScopeCategoryId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    ScopeTypeId = table.Column<int>(type: "int", nullable: false),
                    CategoryNumber = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CategoryName = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ServiceScopeCategory", x => x.ScopeCategoryId);
                    table.ForeignKey(
                        name: "FK_ServiceScopeCategory_LU_ScopeType_ScopeTypeId",
                        column: x => x.ScopeTypeId,
                        principalTable: "LU_ScopeType",
                        principalColumn: "ScopeTypeId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ServiceScopeCategory_ServiceCatalogItem_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ServiceSizeOption",
                columns: table => new
                {
                    ServiceSizeOptionId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    SizeOptionId = table.Column<int>(type: "int", nullable: false),
                    ScopeDescription = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    DurationDisplay = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    EffortDisplay = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    TeamSizeDisplay = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Complexity = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ServiceSizeOption", x => x.ServiceSizeOptionId);
                    table.ForeignKey(
                        name: "FK_ServiceSizeOption_LU_SizeOption_SizeOptionId",
                        column: x => x.SizeOptionId,
                        principalTable: "LU_SizeOption",
                        principalColumn: "SizeOptionId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ServiceSizeOption_ServiceCatalogItem_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ServiceTeamAllocation",
                columns: table => new
                {
                    AllocationId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    RoleId = table.Column<int>(type: "int", nullable: false),
                    SizeOptionId = table.Column<int>(type: "int", nullable: false),
                    AllocationPercentage = table.Column<decimal>(type: "decimal(18,2)", nullable: true),
                    AllocationDescription = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ServiceTeamAllocation", x => x.AllocationId);
                    table.ForeignKey(
                        name: "FK_ServiceTeamAllocation_LU_Role_RoleId",
                        column: x => x.RoleId,
                        principalTable: "LU_Role",
                        principalColumn: "RoleId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ServiceTeamAllocation_LU_SizeOption_SizeOptionId",
                        column: x => x.SizeOptionId,
                        principalTable: "LU_SizeOption",
                        principalColumn: "SizeOptionId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ServiceTeamAllocation_ServiceCatalogItem_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ServiceToolFrameworks",
                columns: table => new
                {
                    ToolId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    ToolCategoryId = table.Column<int>(type: "int", nullable: false),
                    ToolName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ToolDescription = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ServiceToolFrameworks", x => x.ToolId);
                    table.ForeignKey(
                        name: "FK_ServiceToolFrameworks_LU_ToolCategory_ToolCategoryId",
                        column: x => x.ToolCategoryId,
                        principalTable: "LU_ToolCategory",
                        principalColumn: "ToolCategoryId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ServiceToolFrameworks_ServiceCatalogItem_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SizingCriterias",
                columns: table => new
                {
                    CriteriaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    CriteriaName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SizingCriterias", x => x.CriteriaId);
                    table.ForeignKey(
                        name: "FK_SizingCriterias_ServiceCatalogItem_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SizingExample",
                columns: table => new
                {
                    ExampleId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    SizeOptionId = table.Column<int>(type: "int", nullable: false),
                    ExampleName = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    ExampleDescription = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SizingExample", x => x.ExampleId);
                    table.ForeignKey(
                        name: "FK_SizingExample_LU_SizeOption_SizeOptionId",
                        column: x => x.SizeOptionId,
                        principalTable: "LU_SizeOption",
                        principalColumn: "SizeOptionId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_SizingExample_ServiceCatalogItem_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SizingParameters",
                columns: table => new
                {
                    ParameterId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    ParameterName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ParameterType = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SizingParameters", x => x.ParameterId);
                    table.ForeignKey(
                        name: "FK_SizingParameters_ServiceCatalogItem_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "TechnicalComplexityAdditions",
                columns: table => new
                {
                    AdditionId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    AdditionName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Condition = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    AdditionalHours = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TechnicalComplexityAdditions", x => x.AdditionId);
                    table.ForeignKey(
                        name: "FK_TechnicalComplexityAdditions_ServiceCatalogItem_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "TimelinePhase",
                columns: table => new
                {
                    PhaseId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    PhaseName = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    PhaseDescription = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TimelinePhase", x => x.PhaseId);
                    table.ForeignKey(
                        name: "FK_TimelinePhase_ServiceCatalogItem_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "UsageScenario",
                columns: table => new
                {
                    ScenarioId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ServiceId = table.Column<int>(type: "int", nullable: false),
                    ScenarioNumber = table.Column<int>(type: "int", nullable: false),
                    ScenarioTitle = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    ScenarioDescription = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UsageScenario", x => x.ScenarioId);
                    table.ForeignKey(
                        name: "FK_UsageScenario_ServiceCatalogItem_ServiceId",
                        column: x => x.ServiceId,
                        principalTable: "ServiceCatalogItem",
                        principalColumn: "ServiceId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "AccessRequirement",
                columns: table => new
                {
                    AccessId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    InteractionId = table.Column<int>(type: "int", nullable: false),
                    AccessDescription = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AccessRequirement", x => x.AccessId);
                    table.ForeignKey(
                        name: "FK_AccessRequirement_ServiceInteraction_InteractionId",
                        column: x => x.InteractionId,
                        principalTable: "ServiceInteraction",
                        principalColumn: "InteractionId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "CustomerRequirement",
                columns: table => new
                {
                    RequirementId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    InteractionId = table.Column<int>(type: "int", nullable: false),
                    RequirementDescription = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CustomerRequirement", x => x.RequirementId);
                    table.ForeignKey(
                        name: "FK_CustomerRequirement_ServiceInteraction_InteractionId",
                        column: x => x.InteractionId,
                        principalTable: "ServiceInteraction",
                        principalColumn: "InteractionId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "StakeholderInvolvement",
                columns: table => new
                {
                    InvolvementId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    InteractionId = table.Column<int>(type: "int", nullable: false),
                    RoleId = table.Column<int>(type: "int", nullable: false),
                    StakeholderRole = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    InvolvementDescription = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StakeholderInvolvement", x => x.InvolvementId);
                    table.ForeignKey(
                        name: "FK_StakeholderInvolvement_LU_Role_RoleId",
                        column: x => x.RoleId,
                        principalTable: "LU_Role",
                        principalColumn: "RoleId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_StakeholderInvolvement_ServiceInteraction_InteractionId",
                        column: x => x.InteractionId,
                        principalTable: "ServiceInteraction",
                        principalColumn: "InteractionId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ServiceOutputItem",
                columns: table => new
                {
                    OutputItemId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    OutputCategoryId = table.Column<int>(type: "int", nullable: false),
                    ItemDescription = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ServiceOutputItem", x => x.OutputItemId);
                    table.ForeignKey(
                        name: "FK_ServiceOutputItem_ServiceOutputCategory_OutputCategoryId",
                        column: x => x.OutputCategoryId,
                        principalTable: "ServiceOutputCategory",
                        principalColumn: "OutputCategoryId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ServiceScopeItem",
                columns: table => new
                {
                    ScopeItemId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ScopeCategoryId = table.Column<int>(type: "int", nullable: false),
                    ItemDescription = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ServiceScopeItem", x => x.ScopeItemId);
                    table.ForeignKey(
                        name: "FK_ServiceScopeItem_ServiceScopeCategory_ScopeCategoryId",
                        column: x => x.ScopeCategoryId,
                        principalTable: "ServiceScopeCategory",
                        principalColumn: "ScopeCategoryId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SizingCriteriaValues",
                columns: table => new
                {
                    CriteriaValueId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CriteriaId = table.Column<int>(type: "int", nullable: false),
                    SizeOptionId = table.Column<int>(type: "int", nullable: false),
                    Value = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SizingCriteriaValues", x => x.CriteriaValueId);
                    table.ForeignKey(
                        name: "FK_SizingCriteriaValues_LU_SizeOption_SizeOptionId",
                        column: x => x.SizeOptionId,
                        principalTable: "LU_SizeOption",
                        principalColumn: "SizeOptionId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_SizingCriteriaValues_SizingCriterias_CriteriaId",
                        column: x => x.CriteriaId,
                        principalTable: "SizingCriterias",
                        principalColumn: "CriteriaId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SizingExampleCharacteristics",
                columns: table => new
                {
                    CharacteristicId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ExampleId = table.Column<int>(type: "int", nullable: false),
                    CharacteristicDescription = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SizingExampleCharacteristics", x => x.CharacteristicId);
                    table.ForeignKey(
                        name: "FK_SizingExampleCharacteristics_SizingExample_ExampleId",
                        column: x => x.ExampleId,
                        principalTable: "SizingExample",
                        principalColumn: "ExampleId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SizingParameterValues",
                columns: table => new
                {
                    ParameterValueId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ParameterId = table.Column<int>(type: "int", nullable: false),
                    Condition = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Result = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SizingParameterValues", x => x.ParameterValueId);
                    table.ForeignKey(
                        name: "FK_SizingParameterValues_SizingParameters_ParameterId",
                        column: x => x.ParameterId,
                        principalTable: "SizingParameters",
                        principalColumn: "ParameterId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PhaseDurationBySize",
                columns: table => new
                {
                    PhaseDurationId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PhaseId = table.Column<int>(type: "int", nullable: false),
                    SizeOptionId = table.Column<int>(type: "int", nullable: false),
                    Duration = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PhaseDurationBySize", x => x.PhaseDurationId);
                    table.ForeignKey(
                        name: "FK_PhaseDurationBySize_LU_SizeOption_SizeOptionId",
                        column: x => x.SizeOptionId,
                        principalTable: "LU_SizeOption",
                        principalColumn: "SizeOptionId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_PhaseDurationBySize_TimelinePhase_PhaseId",
                        column: x => x.PhaseId,
                        principalTable: "TimelinePhase",
                        principalColumn: "PhaseId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AccessRequirement_InteractionId",
                table: "AccessRequirement",
                column: "InteractionId");

            migrationBuilder.CreateIndex(
                name: "IX_CloudProviderCapabilities_CloudProviderId",
                table: "CloudProviderCapabilities",
                column: "CloudProviderId");

            migrationBuilder.CreateIndex(
                name: "IX_CloudProviderCapabilities_ServiceId",
                table: "CloudProviderCapabilities",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_CustomerRequirement_InteractionId",
                table: "CustomerRequirement",
                column: "InteractionId");

            migrationBuilder.CreateIndex(
                name: "IX_EffortEstimationItem_EffortCategoryId",
                table: "EffortEstimationItem",
                column: "EffortCategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_EffortEstimationItem_ServiceId",
                table: "EffortEstimationItem",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_EffortEstimationItem_SizeOptionId",
                table: "EffortEstimationItem",
                column: "SizeOptionId");

            migrationBuilder.CreateIndex(
                name: "IX_LU_CloudProvider_Code",
                table: "LU_CloudProvider",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_LU_DependencyType_Code",
                table: "LU_DependencyType",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_LU_EffortCategory_Code",
                table: "LU_EffortCategory",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_LU_InteractionLevel_Code",
                table: "LU_InteractionLevel",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_LU_LicenseType_Code",
                table: "LU_LicenseType",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_LU_PrerequisiteCategory_Code",
                table: "LU_PrerequisiteCategory",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_LU_RequirementLevel_Code",
                table: "LU_RequirementLevel",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_LU_Role_Code",
                table: "LU_Role",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_LU_ScopeType_Code",
                table: "LU_ScopeType",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_LU_ServiceCategory_Code",
                table: "LU_ServiceCategory",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_LU_ServiceCategory_ParentCategoryId",
                table: "LU_ServiceCategory",
                column: "ParentCategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_LU_SizeOption_Code",
                table: "LU_SizeOption",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_LU_ToolCategory_Code",
                table: "LU_ToolCategory",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_PhaseDurationBySize_PhaseId",
                table: "PhaseDurationBySize",
                column: "PhaseId");

            migrationBuilder.CreateIndex(
                name: "IX_PhaseDurationBySize_SizeOptionId",
                table: "PhaseDurationBySize",
                column: "SizeOptionId");

            migrationBuilder.CreateIndex(
                name: "IX_ScopeDependencies_ServiceId",
                table: "ScopeDependencies",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceCatalogItem_CategoryId",
                table: "ServiceCatalogItem",
                column: "CategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceCatalogItem_IsActive",
                table: "ServiceCatalogItem",
                column: "IsActive");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceCatalogItem_ServiceCode",
                table: "ServiceCatalogItem",
                column: "ServiceCode",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ServiceDependency_DependencyTypeId",
                table: "ServiceDependency",
                column: "DependencyTypeId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceDependency_DependentServiceId",
                table: "ServiceDependency",
                column: "DependentServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceDependency_RequirementLevelId",
                table: "ServiceDependency",
                column: "RequirementLevelId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceDependency_ServiceId",
                table: "ServiceDependency",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceInput_RequirementLevelId",
                table: "ServiceInput",
                column: "RequirementLevelId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceInput_ServiceId",
                table: "ServiceInput",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceInteraction_InteractionLevelId",
                table: "ServiceInteraction",
                column: "InteractionLevelId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceInteraction_ServiceId",
                table: "ServiceInteraction",
                column: "ServiceId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ServiceLicenses_LicenseTypeId",
                table: "ServiceLicenses",
                column: "LicenseTypeId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceLicenses_ServiceId",
                table: "ServiceLicenses",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceMultiCloudConsideration_CloudProviderId",
                table: "ServiceMultiCloudConsideration",
                column: "CloudProviderId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceMultiCloudConsideration_ServiceId",
                table: "ServiceMultiCloudConsideration",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceOutputCategory_ServiceId",
                table: "ServiceOutputCategory",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceOutputItem_OutputCategoryId",
                table: "ServiceOutputItem",
                column: "OutputCategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_ServicePrerequisite_PrerequisiteCategoryId",
                table: "ServicePrerequisite",
                column: "PrerequisiteCategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_ServicePrerequisite_ServiceId",
                table: "ServicePrerequisite",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceResponsibleRole_RoleId",
                table: "ServiceResponsibleRole",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceResponsibleRole_ServiceId",
                table: "ServiceResponsibleRole",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceScopeCategory_ScopeTypeId",
                table: "ServiceScopeCategory",
                column: "ScopeTypeId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceScopeCategory_ServiceId",
                table: "ServiceScopeCategory",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceScopeItem_ScopeCategoryId",
                table: "ServiceScopeItem",
                column: "ScopeCategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceSizeOption_ServiceId",
                table: "ServiceSizeOption",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceSizeOption_SizeOptionId",
                table: "ServiceSizeOption",
                column: "SizeOptionId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceTeamAllocation_RoleId",
                table: "ServiceTeamAllocation",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceTeamAllocation_ServiceId",
                table: "ServiceTeamAllocation",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceTeamAllocation_SizeOptionId",
                table: "ServiceTeamAllocation",
                column: "SizeOptionId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceToolFrameworks_ServiceId",
                table: "ServiceToolFrameworks",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_ServiceToolFrameworks_ToolCategoryId",
                table: "ServiceToolFrameworks",
                column: "ToolCategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_SizingCriterias_ServiceId",
                table: "SizingCriterias",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_SizingCriteriaValues_CriteriaId",
                table: "SizingCriteriaValues",
                column: "CriteriaId");

            migrationBuilder.CreateIndex(
                name: "IX_SizingCriteriaValues_SizeOptionId",
                table: "SizingCriteriaValues",
                column: "SizeOptionId");

            migrationBuilder.CreateIndex(
                name: "IX_SizingExample_ServiceId",
                table: "SizingExample",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_SizingExample_SizeOptionId",
                table: "SizingExample",
                column: "SizeOptionId");

            migrationBuilder.CreateIndex(
                name: "IX_SizingExampleCharacteristics_ExampleId",
                table: "SizingExampleCharacteristics",
                column: "ExampleId");

            migrationBuilder.CreateIndex(
                name: "IX_SizingParameters_ServiceId",
                table: "SizingParameters",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_SizingParameterValues_ParameterId",
                table: "SizingParameterValues",
                column: "ParameterId");

            migrationBuilder.CreateIndex(
                name: "IX_StakeholderInvolvement_InteractionId",
                table: "StakeholderInvolvement",
                column: "InteractionId");

            migrationBuilder.CreateIndex(
                name: "IX_StakeholderInvolvement_RoleId",
                table: "StakeholderInvolvement",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "IX_TechnicalComplexityAdditions_ServiceId",
                table: "TechnicalComplexityAdditions",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_TimelinePhase_ServiceId",
                table: "TimelinePhase",
                column: "ServiceId");

            migrationBuilder.CreateIndex(
                name: "IX_UsageScenario_ServiceId",
                table: "UsageScenario",
                column: "ServiceId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AccessRequirement");

            migrationBuilder.DropTable(
                name: "CloudProviderCapabilities");

            migrationBuilder.DropTable(
                name: "CustomerRequirement");

            migrationBuilder.DropTable(
                name: "EffortEstimationItem");

            migrationBuilder.DropTable(
                name: "PhaseDurationBySize");

            migrationBuilder.DropTable(
                name: "ScopeDependencies");

            migrationBuilder.DropTable(
                name: "ServiceDependency");

            migrationBuilder.DropTable(
                name: "ServiceInput");

            migrationBuilder.DropTable(
                name: "ServiceLicenses");

            migrationBuilder.DropTable(
                name: "ServiceMultiCloudConsideration");

            migrationBuilder.DropTable(
                name: "ServiceOutputItem");

            migrationBuilder.DropTable(
                name: "ServicePrerequisite");

            migrationBuilder.DropTable(
                name: "ServiceResponsibleRole");

            migrationBuilder.DropTable(
                name: "ServiceScopeItem");

            migrationBuilder.DropTable(
                name: "ServiceSizeOption");

            migrationBuilder.DropTable(
                name: "ServiceTeamAllocation");

            migrationBuilder.DropTable(
                name: "ServiceToolFrameworks");

            migrationBuilder.DropTable(
                name: "SizingCriteriaValues");

            migrationBuilder.DropTable(
                name: "SizingExampleCharacteristics");

            migrationBuilder.DropTable(
                name: "SizingParameterValues");

            migrationBuilder.DropTable(
                name: "StakeholderInvolvement");

            migrationBuilder.DropTable(
                name: "TechnicalComplexityAdditions");

            migrationBuilder.DropTable(
                name: "UsageScenario");

            migrationBuilder.DropTable(
                name: "LU_EffortCategory");

            migrationBuilder.DropTable(
                name: "TimelinePhase");

            migrationBuilder.DropTable(
                name: "LU_DependencyType");

            migrationBuilder.DropTable(
                name: "LU_RequirementLevel");

            migrationBuilder.DropTable(
                name: "LU_LicenseType");

            migrationBuilder.DropTable(
                name: "LU_CloudProvider");

            migrationBuilder.DropTable(
                name: "ServiceOutputCategory");

            migrationBuilder.DropTable(
                name: "LU_PrerequisiteCategory");

            migrationBuilder.DropTable(
                name: "ServiceScopeCategory");

            migrationBuilder.DropTable(
                name: "LU_ToolCategory");

            migrationBuilder.DropTable(
                name: "SizingCriterias");

            migrationBuilder.DropTable(
                name: "SizingExample");

            migrationBuilder.DropTable(
                name: "SizingParameters");

            migrationBuilder.DropTable(
                name: "LU_Role");

            migrationBuilder.DropTable(
                name: "ServiceInteraction");

            migrationBuilder.DropTable(
                name: "LU_ScopeType");

            migrationBuilder.DropTable(
                name: "LU_SizeOption");

            migrationBuilder.DropTable(
                name: "LU_InteractionLevel");

            migrationBuilder.DropTable(
                name: "ServiceCatalogItem");

            migrationBuilder.DropTable(
                name: "LU_ServiceCategory");
        }
    }
}
