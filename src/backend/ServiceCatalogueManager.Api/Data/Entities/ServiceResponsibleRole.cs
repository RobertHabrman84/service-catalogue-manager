namespace ServiceCatalogueManager.Api.Data.Entities;

public class ServiceResponsibleRole : BaseEntity, ISortable
{
    public int ResponsibleRoleId { get; set; }
    public int ServiceId { get; set; }
    public int RoleId { get; set; }
    public string Responsibility { get; set; } = string.Empty;
    public string? Responsibilities { get; set; }
    public bool IsPrimaryOwner { get; set; }
    public int SortOrder { get; set; }
    public virtual ServiceCatalogItem? Service { get; set; }
    public virtual LU_Role? Role { get; set; }
}
