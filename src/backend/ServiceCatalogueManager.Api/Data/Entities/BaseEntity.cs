namespace ServiceCatalogueManager.Api.Data.Entities;

/// <summary>
/// Base entity class with common audit fields
/// </summary>
public abstract class BaseEntity
{
    public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
    public string? CreatedBy { get; set; }
    public DateTime ModifiedDate { get; set; } = DateTime.UtcNow;
    public string? ModifiedBy { get; set; }
}

/// <summary>
/// Base entity with integer ID
/// </summary>
public abstract class BaseEntityWithId : BaseEntity
{
    public int Id { get; set; }
}

/// <summary>
/// Interface for soft delete entities
/// </summary>
public interface ISoftDeletable
{
    bool IsDeleted { get; set; }
    DateTime? DeletedDate { get; set; }
    string? DeletedBy { get; set; }
}

/// <summary>
/// Interface for entities with sort order
/// </summary>
public interface ISortable
{
    int SortOrder { get; set; }
}
