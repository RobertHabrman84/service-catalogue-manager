using System.Text;
using System.Text.RegularExpressions;

namespace ServiceCatalogueManager.Api.Helpers;

/// <summary>
/// Helper for generating safe file names
/// </summary>
public static class FileNameHelper
{
    private static readonly char[] InvalidChars = Path.GetInvalidFileNameChars();
    private static readonly Regex MultipleSpaces = new(@"\s+", RegexOptions.Compiled);

    /// <summary>
    /// Generate safe file name from service code and version
    /// </summary>
    public static string GenerateFileName(string serviceCode, string version, string extension)
    {
        var baseName = $"{SanitizeFileName(serviceCode)}_{SanitizeFileName(version)}";
        return $"{baseName}.{extension.TrimStart('.')}";
    }

    /// <summary>
    /// Generate export file name with timestamp
    /// </summary>
    public static string GenerateExportFileName(string prefix, string extension)
    {
        var timestamp = DateTime.UtcNow.ToString("yyyyMMdd_HHmmss");
        return $"{prefix}_{timestamp}.{extension.TrimStart('.')}";
    }

    /// <summary>
    /// Sanitize file name by removing invalid characters
    /// </summary>
    public static string SanitizeFileName(string fileName)
    {
        if (string.IsNullOrEmpty(fileName)) return "unnamed";

        var sanitized = new StringBuilder();
        foreach (var c in fileName)
        {
            if (!InvalidChars.Contains(c))
            {
                sanitized.Append(c);
            }
        }

        var result = MultipleSpaces.Replace(sanitized.ToString(), "_").Trim();
        return string.IsNullOrEmpty(result) ? "unnamed" : result;
    }
}

/// <summary>
/// Helper for Markdown generation
/// </summary>
public static class MarkdownHelper
{
    public static string Header(string text, int level = 1)
    {
        var prefix = new string('#', Math.Min(Math.Max(level, 1), 6));
        return $"{prefix} {text}";
    }

    public static string Bold(string text) => $"**{text}**";

    public static string Italic(string text) => $"*{text}*";

    public static string Code(string text) => $"`{text}`";

    public static string CodeBlock(string code, string language = "")
    {
        return $"```{language}\n{code}\n```";
    }

    public static string Link(string text, string url) => $"[{text}]({url})";

    public static string Image(string alt, string url) => $"![{alt}]({url})";

    public static string UnorderedList(IEnumerable<string> items)
    {
        return string.Join("\n", items.Select(i => $"- {i}"));
    }

    public static string OrderedList(IEnumerable<string> items)
    {
        return string.Join("\n", items.Select((item, index) => $"{index + 1}. {item}"));
    }

    public static string Table(string[] headers, IEnumerable<string[]> rows)
    {
        var sb = new StringBuilder();
        
        // Header row
        sb.AppendLine($"| {string.Join(" | ", headers)} |");
        
        // Separator row
        sb.AppendLine($"| {string.Join(" | ", headers.Select(_ => "---"))} |");
        
        // Data rows
        foreach (var row in rows)
        {
            sb.AppendLine($"| {string.Join(" | ", row)} |");
        }

        return sb.ToString();
    }

    public static string Quote(string text) => $"> {text}";

    public static string HorizontalRule() => "---";
}

/// <summary>
/// Helper for Uu5String generation (UuBookKit format)
/// </summary>
public static class Uu5StringHelper
{
    public static string Document(string content)
    {
        return $"<uu5string/>{content}";
    }

    public static string Header(string text, int level = 1)
    {
        return $"<UU5.Bricks.Header level=\"{level}\">{EscapeHtml(text)}</UU5.Bricks.Header>";
    }

    public static string Paragraph(string text)
    {
        return $"<UU5.Bricks.P>{EscapeHtml(text)}</UU5.Bricks.P>";
    }

    public static string Strong(string text)
    {
        return $"<UU5.Bricks.Strong>{EscapeHtml(text)}</UU5.Bricks.Strong>";
    }

    public static string Em(string text)
    {
        return $"<UU5.Bricks.Em>{EscapeHtml(text)}</UU5.Bricks.Em>";
    }

    public static string Section(string header, string content)
    {
        return $"<UU5.Bricks.Section header=\"{EscapeAttribute(header)}\">{content}</UU5.Bricks.Section>";
    }

    public static string List(IEnumerable<string> items)
    {
        var listItems = string.Join("", items.Select(i => $"<UU5.Bricks.Li>{EscapeHtml(i)}</UU5.Bricks.Li>"));
        return $"<UU5.Bricks.Ul>{listItems}</UU5.Bricks.Ul>";
    }

    public static string Table(string[] headers, IEnumerable<string[]> rows)
    {
        var headerCells = string.Join("", headers.Select(h => $"<UU5.Bricks.Table.Th>{EscapeHtml(h)}</UU5.Bricks.Table.Th>"));
        var headerRow = $"<UU5.Bricks.Table.Tr>{headerCells}</UU5.Bricks.Table.Tr>";

        var bodyRows = string.Join("", rows.Select(row =>
        {
            var cells = string.Join("", row.Select(c => $"<UU5.Bricks.Table.Td>{EscapeHtml(c)}</UU5.Bricks.Table.Td>"));
            return $"<UU5.Bricks.Table.Tr>{cells}</UU5.Bricks.Table.Tr>";
        }));

        return $"<UU5.Bricks.Table>" +
               $"<UU5.Bricks.Table.THead>{headerRow}</UU5.Bricks.Table.THead>" +
               $"<UU5.Bricks.Table.TBody>{bodyRows}</UU5.Bricks.Table.TBody>" +
               $"</UU5.Bricks.Table>";
    }

    public static string Badge(string text, string colorSchema = "blue")
    {
        return $"<UU5.Bricks.Badge colorSchema=\"{colorSchema}\">{EscapeHtml(text)}</UU5.Bricks.Badge>";
    }

    public static string Alert(string text, string colorSchema = "info")
    {
        return $"<UU5.Bricks.Alert colorSchema=\"{colorSchema}\">{EscapeHtml(text)}</UU5.Bricks.Alert>";
    }

    private static string EscapeHtml(string text)
    {
        if (string.IsNullOrEmpty(text)) return string.Empty;
        return System.Web.HttpUtility.HtmlEncode(text);
    }

    private static string EscapeAttribute(string text)
    {
        if (string.IsNullOrEmpty(text)) return string.Empty;
        return text.Replace("\"", "&quot;").Replace("'", "&#39;");
    }
}

/// <summary>
/// Helper for date/time formatting
/// </summary>
public static class DateTimeHelper
{
    public static string ToIso8601(DateTime dateTime)
    {
        return dateTime.ToString("yyyy-MM-ddTHH:mm:ssZ");
    }

    public static string ToFriendlyDate(DateTime dateTime)
    {
        return dateTime.ToString("MMMM d, yyyy");
    }

    public static string ToFriendlyDateTime(DateTime dateTime)
    {
        return dateTime.ToString("MMMM d, yyyy 'at' h:mm tt");
    }

    public static string ToRelativeTime(DateTime dateTime)
    {
        var now = DateTime.UtcNow;
        var diff = now - dateTime;

        if (diff.TotalMinutes < 1) return "just now";
        if (diff.TotalMinutes < 60) return $"{(int)diff.TotalMinutes} minutes ago";
        if (diff.TotalHours < 24) return $"{(int)diff.TotalHours} hours ago";
        if (diff.TotalDays < 7) return $"{(int)diff.TotalDays} days ago";
        if (diff.TotalDays < 30) return $"{(int)(diff.TotalDays / 7)} weeks ago";
        if (diff.TotalDays < 365) return $"{(int)(diff.TotalDays / 30)} months ago";
        return $"{(int)(diff.TotalDays / 365)} years ago";
    }
}

/// <summary>
/// Helper for generating unique identifiers
/// </summary>
public static class IdHelper
{
    public static string NewGuid() => Guid.NewGuid().ToString("N");
    
    public static string NewShortGuid() => Guid.NewGuid().ToString("N")[..8];
    
    public static string NewTimestampId() => $"{DateTime.UtcNow:yyyyMMddHHmmss}_{NewShortGuid()}";
}
