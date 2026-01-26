using System.ComponentModel.DataAnnotations;

namespace ServiceCatalogueManager.Api.Models.Import;

public class ResponsibleRoleImportModel
{
    [Required]
    public string RoleName { get; set; } = string.Empty;

    public bool IsPrimaryOwner { get; set; }

    public string? Responsibilities { get; set; }
}
