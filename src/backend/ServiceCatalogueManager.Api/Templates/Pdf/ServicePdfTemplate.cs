using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using ServiceCatalogueManager.Api.Templates.Pdf.Components;
using ServiceCatalogueManager.Api.Templates.Pdf.Styles;

namespace ServiceCatalogueManager.Api.Templates.Pdf;

public class ServicePdfTemplate : IDocument
{
    private readonly ServicePdfData _data;
    public ServicePdfTemplate(ServicePdfData data) => _data = data;

    public DocumentMetadata GetMetadata() => new()
    {
        Title = $"Service Catalogue - {_data.ServiceName}",
        Author = _data.Author ?? "Service Catalogue Manager",
        Creator = "SCM PDF Generator",
        Subject = "Service Documentation",
        Keywords = "service, catalogue, documentation"
    };

    public void Compose(IDocumentContainer container)
    {
        container.Page(page =>
        {
            page.Size(PageSizes.A4);
            page.Margin(PdfStyles.Page.MarginLeft, Unit.Point);
            page.DefaultTextStyle(x => x.FontSize(PdfStyles.FontSizes.Body));

            page.Header().Element(ComposeHeader);
            page.Content().Element(ComposeContent);
            page.Footer().Element(ComposeFooter);
        });
    }

    private void ComposeHeader(IContainer container)
    {
        container.Row(row =>
        {
            row.RelativeItem().Text(_data.ServiceName).Style(PdfStyles.Heading2Style);
            row.ConstantItem(100).AlignRight().Text(_data.ServiceCode).Style(PdfStyles.CaptionStyle);
        });
    }

    private void ComposeFooter(IContainer container)
    {
        container.Row(row =>
        {
            row.RelativeItem().Text($"Generated: {DateTime.UtcNow:MMM dd, yyyy}").Style(PdfStyles.CaptionStyle);
            row.RelativeItem().AlignCenter().Text(x =>
            {
                x.Span("Page ").Style(PdfStyles.CaptionStyle);
                x.CurrentPageNumber().Style(PdfStyles.CaptionStyle);
                x.Span(" of ").Style(PdfStyles.CaptionStyle);
                x.TotalPages().Style(PdfStyles.CaptionStyle);
            });
            row.RelativeItem().AlignRight().Text("Service Catalogue Manager").Style(PdfStyles.CaptionStyle);
        });
    }

    private void ComposeContent(IContainer container)
    {
        container.Column(column =>
        {
            // Cover Page
            column.Item().Element(c => CoverPage.Compose(c, new CoverPageData
            {
                Title = _data.ServiceName,
                Subtitle = _data.Description,
                Version = _data.Version,
                Category = _data.CategoryName,
                Author = _data.Author,
                Status = _data.IsActive ? "Active" : "Inactive",
                IsActive = _data.IsActive
            }));

            // Table of Contents - commented out as TableOfContents class doesn't exist
            // if (_data.IncludeTableOfContents)
            // {
            //     column.Item().PageBreak();
            //     column.Item().Element(c => TableOfContents.ComposeSimple(c, GetSections()));
            // }

            // Service Overview
            if (_data.IncludeSections.Contains("overview"))
            {
                column.Item().PageBreak();
                column.Item().Element(c => ServiceOverview.Compose(c, new ServiceOverviewData
                {
                    ServiceName = _data.ServiceName,
                    ServiceCode = _data.ServiceCode,
                    Description = _data.Description,
                    Version = _data.Version,
                    IsActive = _data.IsActive,
                    CategoryName = _data.CategoryName,
                    OwnerName = _data.OwnerName,
                    ModifiedDate = _data.ModifiedDate,
                    UsageScenariosCount = _data.UsageScenarios?.Count() ?? 0,
                    DependenciesCount = _data.Dependencies?.Count() ?? 0,
                    PrerequisitesCount = _data.Prerequisites?.Count() ?? 0,
                    ToolsCount = _data.Tools?.Count() ?? 0
                }));
            }

            // Usage Scenarios
            if (_data.IncludeSections.Contains("scenarios") && _data.UsageScenarios?.Any() == true)
            {
                column.Item().PageBreak();
                column.Item().Element(c => UsageScenarios.Compose(c, _data.UsageScenarios));
            }

            // Dependencies
            if (_data.IncludeSections.Contains("dependencies") && _data.Dependencies?.Any() == true)
            {
                column.Item().PageBreak();
                column.Item().Element(c => Dependencies.Compose(c, _data.Dependencies));
            }

            // Scope
            if (_data.IncludeSections.Contains("scope"))
            {
                column.Item().PageBreak();
                column.Item().Element(c => Scope.Compose(c, _data.ScopeData ?? new ScopeData()));
            }

            // Prerequisites
            if (_data.IncludeSections.Contains("prerequisites") && _data.Prerequisites?.Any() == true)
            {
                column.Item().PageBreak();
                column.Item().Element(c => Prerequisites.Compose(c, _data.Prerequisites));
            }

            // Tools
            if (_data.IncludeSections.Contains("tools") && _data.Tools?.Any() == true)
            {
                column.Item().PageBreak();
                column.Item().Element(c => Tools.Compose(c, _data.Tools));
            }

            // Inputs/Outputs
            if (_data.IncludeSections.Contains("io"))
            {
                column.Item().PageBreak();
                if (_data.Inputs?.Any() == true)
                    column.Item().Element(c => Inputs.Compose(c, _data.Inputs));
                if (_data.Outputs?.Any() == true)
                    column.Item().PaddingTop(PdfStyles.Spacing.Large).Element(c => Outputs.Compose(c, _data.Outputs));
            }

            // Timeline
            if (_data.IncludeSections.Contains("timeline") && _data.TimelinePhases?.Any() == true)
            {
                column.Item().PageBreak();
                column.Item().Element(c => Timeline.Compose(c, _data.TimelinePhases));
            }

            // Sizing
            if (_data.IncludeSections.Contains("sizing") && _data.SizingOptions?.Any() == true)
            {
                column.Item().PageBreak();
                column.Item().Element(c => Sizing.Compose(c, _data.SizingOptions));
            }

            // Effort
            if (_data.IncludeSections.Contains("effort") && _data.EffortItems?.Any() == true)
            {
                column.Item().PageBreak();
                column.Item().Element(c => Effort.Compose(c, _data.EffortItems));
            }

            // Team
            if (_data.IncludeSections.Contains("team") && _data.TeamMembers?.Any() == true)
            {
                column.Item().PageBreak();
                column.Item().Element(c => Team.Compose(c, _data.TeamMembers));
            }

            // Examples
            if (_data.IncludeSections.Contains("examples") && _data.Examples?.Any() == true)
            {
                column.Item().PageBreak();
                column.Item().Element(c => Examples.Compose(c, _data.Examples));
            }

            // Multi-Cloud
            if (_data.IncludeSections.Contains("multicloud"))
            {
                column.Item().PageBreak();
                column.Item().Element(c => MultiCloud.Compose(c, _data.MultiCloudData ?? new MultiCloudData()));
            }
        });
    }

    private IEnumerable<string> GetSections()
    {
        var sections = new List<string>();
        if (_data.IncludeSections.Contains("overview")) sections.Add("Service Overview");
        if (_data.IncludeSections.Contains("scenarios")) sections.Add("Usage Scenarios");
        if (_data.IncludeSections.Contains("dependencies")) sections.Add("Dependencies");
        if (_data.IncludeSections.Contains("scope")) sections.Add("Scope");
        if (_data.IncludeSections.Contains("prerequisites")) sections.Add("Prerequisites");
        if (_data.IncludeSections.Contains("tools")) sections.Add("Tools & Technologies");
        if (_data.IncludeSections.Contains("io")) sections.Add("Inputs & Outputs");
        if (_data.IncludeSections.Contains("timeline")) sections.Add("Timeline");
        if (_data.IncludeSections.Contains("sizing")) sections.Add("Sizing Options");
        if (_data.IncludeSections.Contains("effort")) sections.Add("Effort Estimation");
        if (_data.IncludeSections.Contains("team")) sections.Add("Team Allocation");
        if (_data.IncludeSections.Contains("examples")) sections.Add("Examples");
        if (_data.IncludeSections.Contains("multicloud")) sections.Add("Multi-Cloud");
        return sections;
    }
}

public class ServicePdfData
{
    public string ServiceName { get; set; } = string.Empty;
    public string ServiceCode { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? Version { get; set; }
    public bool IsActive { get; set; } = true;
    public string? CategoryName { get; set; }
    public string? OwnerName { get; set; }
    public string? Author { get; set; }
    public DateTime? ModifiedDate { get; set; }
    public bool IncludeTableOfContents { get; set; } = true;
    public HashSet<string> IncludeSections { get; set; } = new() { "overview", "scenarios", "dependencies", "scope", "prerequisites", "tools", "io", "timeline", "sizing", "effort", "team", "examples", "multicloud" };
    
    public IEnumerable<UsageScenarioData>? UsageScenarios { get; set; }
    public IEnumerable<DependencyData>? Dependencies { get; set; }
    public ScopeData? ScopeData { get; set; }
    public IEnumerable<PrerequisiteData>? Prerequisites { get; set; }
    public IEnumerable<ToolData>? Tools { get; set; }
    public IEnumerable<InputData>? Inputs { get; set; }
    public IEnumerable<OutputData>? Outputs { get; set; }
    public IEnumerable<TimelinePhaseData>? TimelinePhases { get; set; }
    public IEnumerable<SizingOptionData>? SizingOptions { get; set; }
    public IEnumerable<EffortItemData>? EffortItems { get; set; }
    public IEnumerable<TeamMemberData>? TeamMembers { get; set; }
    public IEnumerable<ExampleData>? Examples { get; set; }
    public MultiCloudData? MultiCloudData { get; set; }
}
