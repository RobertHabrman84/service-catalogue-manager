using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

namespace ServiceCatalogueManager.Api.Templates.Pdf.Styles;

/// <summary>
/// Centralized PDF styling definitions for consistent document appearance
/// </summary>
public static class PdfStyles
{
    // Colors
    public static class Colors
    {
        public static readonly string Primary = "#1E40AF";      // Blue-800
        public static readonly string PrimaryLight = "#3B82F6"; // Blue-500
        public static readonly string Secondary = "#64748B";    // Slate-500
        public static readonly string Success = "#10B981";      // Emerald-500
        public static readonly string Warning = "#F59E0B";      // Amber-500
        public static readonly string Danger = "#EF4444";       // Red-500
        public static readonly string TextPrimary = "#1F2937";  // Gray-800
        public static readonly string TextSecondary = "#6B7280";// Gray-500
        public static readonly string TextMuted = "#9CA3AF";    // Gray-400
        public static readonly string Background = "#F9FAFB";   // Gray-50
        public static readonly string Border = "#E5E7EB";       // Gray-200
        public static readonly string White = "#FFFFFF";
        public static readonly string TableHeader = "#F3F4F6";  // Gray-100
        public static readonly string TableRowAlt = "#F9FAFB";  // Gray-50
    }

    // Font Sizes
    public static class FontSizes
    {
        public const float Title = 28;
        public const float Subtitle = 20;
        public const float Heading1 = 18;
        public const float Heading2 = 16;
        public const float Heading3 = 14;
        public const float Body = 11;
        public const float Small = 10;
        public const float Caption = 9;
        public const float Tiny = 8;
    }

    // Spacing
    public static class Spacing
    {
        public const float None = 0;
        public const float XSmall = 4;
        public const float Small = 8;
        public const float Medium = 12;
        public const float Large = 16;
        public const float XLarge = 24;
        public const float XXLarge = 32;
        public const float Section = 20;
        public const float Page = 40;
    }

    // Page Configuration
    public static class Page
    {
        public const float MarginTop = 50;
        public const float MarginBottom = 50;
        public const float MarginLeft = 50;
        public const float MarginRight = 50;
        public const float HeaderHeight = 40;
        public const float FooterHeight = 30;
    }

    // Text Styles
    public static TextStyle TitleStyle => TextStyle.Default
        .FontSize(FontSizes.Title)
        .FontColor(Colors.Primary)
        .Bold();

    public static TextStyle SubtitleStyle => TextStyle.Default
        .FontSize(FontSizes.Subtitle)
        .FontColor(Colors.Secondary);

    public static TextStyle Heading1Style => TextStyle.Default
        .FontSize(FontSizes.Heading1)
        .FontColor(Colors.Primary)
        .Bold();

    public static TextStyle Heading2Style => TextStyle.Default
        .FontSize(FontSizes.Heading2)
        .FontColor(Colors.TextPrimary)
        .Bold();

    public static TextStyle Heading3Style => TextStyle.Default
        .FontSize(FontSizes.Heading3)
        .FontColor(Colors.TextPrimary)
        .SemiBold();

    public static TextStyle BodyStyle => TextStyle.Default
        .FontSize(FontSizes.Body)
        .FontColor(Colors.TextPrimary)
        .LineHeight(1.5f);

    public static TextStyle SmallStyle => TextStyle.Default
        .FontSize(FontSizes.Small)
        .FontColor(Colors.TextSecondary);

    public static TextStyle CaptionStyle => TextStyle.Default
        .FontSize(FontSizes.Caption)
        .FontColor(Colors.TextMuted);

    public static TextStyle LabelStyle => TextStyle.Default
        .FontSize(FontSizes.Small)
        .FontColor(Colors.TextSecondary)
        .Bold();

    public static TextStyle ValueStyle => TextStyle.Default
        .FontSize(FontSizes.Body)
        .FontColor(Colors.TextPrimary);

    public static TextStyle LinkStyle => TextStyle.Default
        .FontSize(FontSizes.Body)
        .FontColor(Colors.PrimaryLight)
        .Underline();

    // Component Extensions
    public static IContainer SectionContainer(this IContainer container) => container
        .PaddingBottom(Spacing.Section);

    public static IContainer CardContainer(this IContainer container) => container
        .Background(Colors.White)
        .Border(1)
        .BorderColor(Colors.Border)
        .Padding(Spacing.Medium);

    public static IContainer HighlightBox(this IContainer container, string color) => container
        .Background(color)
        .Padding(Spacing.Small);

    public static IContainer TableHeaderCell(this IContainer container) => container
        .Background(Colors.TableHeader)
        .Padding(Spacing.Small)
        .BorderBottom(1)
        .BorderColor(Colors.Border);

    public static IContainer TableCell(this IContainer container) => container
        .Padding(Spacing.Small)
        .BorderBottom(1)
        .BorderColor(Colors.Border);

    public static IContainer Badge(this IContainer container, string backgroundColor) => container
        .Background(backgroundColor)
        .Padding(Spacing.XSmall)
        .PaddingHorizontal(Spacing.Small);
}

/// <summary>
/// Extension methods for common PDF component patterns
/// </summary>
public static class PdfComponentExtensions
{
    public static void SectionTitle(this IContainer container, string title)
    {
        container.Column(column =>
        {
            column.Item().Text(title).Style(PdfStyles.Heading1Style);
            column.Item().PaddingTop(PdfStyles.Spacing.XSmall)
                .LineHorizontal(2)
                .LineColor(PdfStyles.Colors.Primary);
            column.Item().PaddingBottom(PdfStyles.Spacing.Medium);
        });
    }

    public static void SubsectionTitle(this IContainer container, string title)
    {
        container.Column(column =>
        {
            column.Item().PaddingTop(PdfStyles.Spacing.Small)
                .Text(title).Style(PdfStyles.Heading2Style);
            column.Item().PaddingBottom(PdfStyles.Spacing.Small);
        });
    }

    public static void LabelValue(this IContainer container, string label, string value)
    {
        container.Row(row =>
        {
            row.RelativeItem(1).Text(label).Style(PdfStyles.LabelStyle);
            row.RelativeItem(2).Text(value ?? "-").Style(PdfStyles.ValueStyle);
        });
    }

    public static void BulletPoint(this IContainer container, string text)
    {
        container.Row(row =>
        {
            row.ConstantItem(15).AlignMiddle().Text("•").Style(PdfStyles.BodyStyle);
            row.RelativeItem().Text(text).Style(PdfStyles.BodyStyle);
        });
    }

    public static void NumberedItem(this IContainer container, int number, string text)
    {
        container.Row(row =>
        {
            row.ConstantItem(25).AlignRight().PaddingRight(5)
                .Text($"{number}.").Style(PdfStyles.BodyStyle);
            row.RelativeItem().Text(text).Style(PdfStyles.BodyStyle);
        });
    }

    public static void StatusBadge(this IContainer container, string status, bool isActive)
    {
        var backgroundColor = isActive ? "#D1FAE5" : "#FEE2E2"; // Green-100 or Red-100
        var textColor = isActive ? "#065F46" : "#991B1B";       // Green-800 or Red-800

        container.Badge(backgroundColor)
            .Text(status)
            .FontSize(PdfStyles.FontSizes.Caption)
            .FontColor(textColor)
            .Bold();
    }

    public static void InfoBox(this IContainer container, string title, string content, string? iconColor = null)
    {
        container.Background(PdfStyles.Colors.Background)
            .Border(1)
            .BorderColor(PdfStyles.Colors.Border)
            .Padding(PdfStyles.Spacing.Medium)
            .Column(column =>
            {
                column.Item().Text(title).Style(PdfStyles.Heading3Style);
                column.Item().PaddingTop(PdfStyles.Spacing.Small)
                    .Text(content).Style(PdfStyles.BodyStyle);
            });
    }

    public static void Divider(this IContainer container)
    {
        container.PaddingVertical(PdfStyles.Spacing.Medium)
            .LineHorizontal(1)
            .LineColor(PdfStyles.Colors.Border);
    }
}
