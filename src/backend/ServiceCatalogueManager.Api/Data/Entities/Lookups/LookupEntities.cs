namespace ServiceCatalogueManager.Api.Data.Entities;

/// <summary>
/// Base class for lookup tables
/// </summary>
public abstract class LookupBase
{
    public string Code { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int SortOrder { get; set; }
    public bool IsActive { get; set; } = true;
}

/// <summary>
/// Service category lookup (hierarchical)
/// </summary>
public class LU_ServiceCategory : LookupBase
{
    public int CategoryId { get; set; }
    public int? ParentCategoryId { get; set; }
    public string? CategoryPath { get; set; }
    public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    public DateTime ModifiedDate { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public virtual LU_ServiceCategory? ParentCategory { get; set; }
    public virtual ICollection<LU_ServiceCategory> ChildCategories { get; set; } = new List<LU_ServiceCategory>();
    public virtual ICollection<ServiceCatalogItem> Services { get; set; } = new List<ServiceCatalogItem>();
}

/// <summary>
/// Size option lookup (S, M, L, XL)
/// </summary>
public class LU_SizeOption : LookupBase
{
    public int SizeOptionId { get; set; }
}

/// <summary>
/// Cloud provider lookup
/// </summary>
public class LU_CloudProvider : LookupBase
{
    public int CloudProviderId { get; set; }
}

/// <summary>
/// Dependency type lookup
/// </summary>
public class LU_DependencyType : LookupBase
{
    public int DependencyTypeId { get; set; }
}

/// <summary>
/// Prerequisite category lookup
/// </summary>
public class LU_PrerequisiteCategory : LookupBase
{
    public int PrerequisiteCategoryId { get; set; }
}

/// <summary>
/// License type lookup
/// </summary>
public class LU_LicenseType : LookupBase
{
    public int LicenseTypeId { get; set; }
}

/// <summary>
/// Tool category lookup
/// </summary>
public class LU_ToolCategory : LookupBase
{
    public int ToolCategoryId { get; set; }
}

/// <summary>
/// Scope type lookup (In Scope, Out of Scope)
/// </summary>
public class LU_ScopeType : LookupBase
{
    public int ScopeTypeId { get; set; }
}

/// <summary>
/// Interaction level lookup
/// </summary>
public class LU_InteractionLevel : LookupBase
{
    public int InteractionLevelId { get; set; }
}

/// <summary>
/// Requirement level lookup
/// </summary>
public class LU_RequirementLevel : LookupBase
{
    public int RequirementLevelId { get; set; }
}

/// <summary>
/// Role lookup
/// </summary>
public class LU_Role : LookupBase
{
    public int RoleId { get; set; }
}

/// <summary>
/// Effort category lookup
/// </summary>
public class LU_EffortCategory : LookupBase
{
    public int EffortCategoryId { get; set; }
}
