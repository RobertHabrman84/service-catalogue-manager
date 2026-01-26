using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using ServiceCatalogueManager.Api.Templates.Pdf.Styles;

namespace ServiceCatalogueManager.Api.Templates.Pdf.Components;

/// <summary>
/// Interaction component for PDF documents - shows service interactions
/// </summary>
public static class Interaction
{
    public static void Compose(IContainer container, IEnumerable<InteractionData> interactions)
    {
        var interactionList = interactions?.ToList() ?? new List<InteractionData>();
        
        container.Column(column =>
        {
            column.Item().SectionTitle("Service Interactions");

            if (!interactionList.Any())
            {
                column.Item().Element(c => EmptyState(c, "No interactions defined."));
                return;
            }

            // Group by direction
            var incoming = interactionList.Where(i => i.Direction == "Incoming").ToList();
            var outgoing = interactionList.Where(i => i.Direction == "Outgoing").ToList();
            var bidirectional = interactionList.Where(i => i.Direction == "Bidirectional" || string.IsNullOrEmpty(i.Direction)).ToList();

            // Two-column layout for incoming/outgoing
            column.Item().Row(row =>
            {
                // Incoming
                row.RelativeItem().Element(c => ComposeInteractionGroup(c, "Incoming", incoming, "←", "#10B981"));
                
                row.ConstantItem(PdfStyles.Spacing.Medium);
                
                // Outgoing
                row.RelativeItem().Element(c => ComposeInteractionGroup(c, "Outgoing", outgoing, "→", "#3B82F6"));
            });

            // Bidirectional
            if (bidirectional.Any())
            {
                column.Item().PaddingTop(PdfStyles.Spacing.Medium)
                    .Element(c => ComposeInteractionGroup(c, "Bidirectional", bidirectional, "↔", "#8B5CF6"));
            }

            // Integration diagram hint
            column.Item().PaddingTop(PdfStyles.Spacing.Large)
                .InfoBox("Integration Notes", 
                    "For detailed integration diagrams and API specifications, please refer to the Architecture documentation.");
        });
    }

    private static void ComposeInteractionGroup(
        IContainer container, 
        string title, 
        List<InteractionData> interactions,
        string arrow,
        string accentColor)
    {
        container.Border(1)
            .BorderColor(PdfStyles.Colors.Border)
            .Column(column =>
            {
                // Header
                column.Item()
                    .Background(accentColor)
                    .Padding(PdfStyles.Spacing.Small)
                    .Row(row =>
                    {
                        row.ConstantItem(25)
                            .Text(arrow)
                            .FontSize(16)
                            .FontColor(PdfStyles.Colors.White);
                        row.RelativeItem()
                            .Text(title)
                            .FontColor(PdfStyles.Colors.White)
                            .Bold();
                        row.ConstantItem(30)
                            .AlignRight()
                            .Text(interactions.Count.ToString())
                            .FontColor(PdfStyles.Colors.White)
                            .Bold();
                    });

                // Interactions list
                column.Item().Padding(PdfStyles.Spacing.Small).Column(listCol =>
                {
                    if (!interactions.Any())
                    {
                        listCol.Item()
                            .Text("No interactions")
                            .Style(PdfStyles.CaptionStyle)
                            .Italic();
                    }
                    else
                    {
                        foreach (var interaction in interactions.OrderBy(i => i.SortOrder))
                        {
                            listCol.Item().PaddingBottom(PdfStyles.Spacing.Small)
                                .Element(c => ComposeInteractionItem(c, interaction));
                        }
                    }
                });
            });
    }

    private static void ComposeInteractionItem(IContainer container, InteractionData interaction)
    {
        container.Background(PdfStyles.Colors.Background)
            .Padding(PdfStyles.Spacing.Small)
            .Column(column =>
            {
                // System name and protocol
                column.Item().Row(row =>
                {
                    row.RelativeItem()
                        .Text(interaction.SystemName)
                        .Style(PdfStyles.BodyStyle)
                        .SemiBold();

                    if (!string.IsNullOrEmpty(interaction.Protocol))
                    {
                        row.AutoItem()
                            .Background(PdfStyles.Colors.Border)
                            .Padding(1)
                            .PaddingHorizontal(4)
                            .Text(interaction.Protocol)
                            .FontSize(7)
                            .FontColor(PdfStyles.Colors.TextSecondary);
                    }
                });

                // Description
                if (!string.IsNullOrEmpty(interaction.Description))
                {
                    column.Item().PaddingTop(2)
                        .Text(interaction.Description)
                        .Style(PdfStyles.CaptionStyle);
                }

                // Details row
                column.Item().PaddingTop(4).Row(row =>
                {
                    if (!string.IsNullOrEmpty(interaction.DataFormat))
                    {
                        row.AutoItem()
                            .Text($"Format: {interaction.DataFormat}")
                            .Style(PdfStyles.CaptionStyle);
                        row.ConstantItem(10);
                    }

                    if (!string.IsNullOrEmpty(interaction.Frequency))
                    {
                        row.AutoItem()
                            .Text($"Frequency: {interaction.Frequency}")
                            .Style(PdfStyles.CaptionStyle);
                    }
                });
            });
    }

    private static void EmptyState(IContainer container, string message)
    {
        container.Background(PdfStyles.Colors.Background)
            .Padding(PdfStyles.Spacing.Large)
            .AlignCenter()
            .Text(message)
            .Style(PdfStyles.SmallStyle)
            .Italic();
    }
}

/// <summary>
/// Data model for Interaction
/// </summary>
public class InteractionData
{
    public int InteractionId { get; set; }
    public string SystemName { get; set; } = string.Empty;
    public string? Direction { get; set; } // Incoming, Outgoing, Bidirectional
    public string? Description { get; set; }
    public string? Protocol { get; set; } // REST, SOAP, gRPC, Message Queue, etc.
    public string? DataFormat { get; set; } // JSON, XML, Binary, etc.
    public string? Frequency { get; set; } // Real-time, Daily, On-demand, etc.
    public string? Endpoint { get; set; }
    public int SortOrder { get; set; }
}
