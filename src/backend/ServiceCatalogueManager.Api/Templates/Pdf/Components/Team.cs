using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using ServiceCatalogueManager.Api.Templates.Pdf.Styles;

namespace ServiceCatalogueManager.Api.Templates.Pdf.Components;

public static class Team
{
    public static void Compose(IContainer container, IEnumerable<TeamMemberData> members)
    {
        var memberList = members?.ToList() ?? new List<TeamMemberData>();
        
        container.Column(column =>
        {
            column.Item().SectionTitle("Team Allocation");

            if (!memberList.Any())
            {
                column.Item().Background(PdfStyles.Colors.Background)
                    .Padding(PdfStyles.Spacing.Large).AlignCenter()
                    .Text("No team allocation defined.").Style(PdfStyles.SmallStyle).Italic();
                return;
            }

            var totalFte = memberList.Sum(m => m.FteAllocation);
            column.Item().PaddingBottom(PdfStyles.Spacing.Medium)
                .Text($"Total FTE: {totalFte:N1}").Style(PdfStyles.BodyStyle).Bold();

            var grouped = memberList.GroupBy(m => m.RoleCategory ?? "Other").OrderBy(g => g.Key);
            foreach (var group in grouped)
            {
                column.Item().PaddingBottom(PdfStyles.Spacing.Small)
                    .Element(c => ComposeRoleGroup(c, group.Key, group.ToList()));
            }
        });
    }

    private static void ComposeRoleGroup(IContainer container, string category, List<TeamMemberData> members)
    {
        container.Column(col =>
        {
            col.Item().Background(PdfStyles.Colors.TableHeader)
                .Padding(PdfStyles.Spacing.XSmall).Row(r =>
                {
                    r.RelativeItem().Text(category).Style(PdfStyles.Heading3Style);
                    r.ConstantItem(60).AlignRight()
                        .Text($"{members.Sum(m => m.FteAllocation):N1} FTE").Style(PdfStyles.SmallStyle);
                });

            foreach (var member in members.OrderBy(m => m.SortOrder))
            {
                col.Item().Border(1).BorderColor(PdfStyles.Colors.Border)
                    .Padding(PdfStyles.Spacing.Small).Row(row =>
                    {
                        row.RelativeItem(2).Column(c =>
                        {
                            c.Item().Text(member.RoleName).Style(PdfStyles.BodyStyle).SemiBold();
                            if (!string.IsNullOrEmpty(member.Responsibilities))
                                c.Item().Text(member.Responsibilities).Style(PdfStyles.CaptionStyle);
                        });
                        row.RelativeItem(1).AlignCenter().Column(c =>
                        {
                            c.Item().Text($"{member.FteAllocation:N1}").FontSize(16).FontColor(PdfStyles.Colors.Primary).Bold();
                            c.Item().Text("FTE").Style(PdfStyles.CaptionStyle);
                        });
                    });
            }
        });
    }
}

public class TeamMemberData
{
    public int AllocationId { get; set; }
    public string RoleName { get; set; } = string.Empty;
    public string? RoleCategory { get; set; }
    public decimal FteAllocation { get; set; }
    public string? Responsibilities { get; set; }
    public int SortOrder { get; set; }
}
