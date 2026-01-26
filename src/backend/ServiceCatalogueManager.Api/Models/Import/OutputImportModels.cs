using System.ComponentModel.DataAnnotations;

namespace ServiceCatalogueManager.Api.Models.Import;

public class OutputCategoryImportModel
{
    [Required]
    public string CategoryName { get; set; } = string.Empty;

    public int? CategoryNumber { get; set; }

    public List<OutputItemImportModel>? Items { get; set; }
}

public class OutputItemImportModel
{
    public string? ItemName { get; set; }
    public string? ItemDescription { get; set; }
}
