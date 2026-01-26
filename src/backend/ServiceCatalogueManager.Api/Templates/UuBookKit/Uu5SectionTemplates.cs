using System.Text;

namespace ServiceCatalogueManager.Api.Templates.UuBookKit;

public static class Uu5SectionTemplates
{
    private static string Esc(string? text) => Uu5PageTemplate.EscapeUu5(text);

    public static string GenerateUsageScenarios(IEnumerable<Uu5UsageScenario> scenarios)
    {
        var sb = new StringBuilder();
        sb.AppendLine("<UU5.Bricks.Section header=\"Usage Scenarios\">");
        int num = 1;
        foreach (var s in scenarios.OrderBy(x => x.SortOrder))
        {
            sb.AppendLine($"  <UU5.Bricks.Panel header=\"{num++}. {Esc(s.Name)}\" colorSchema=\"grey\">");
            if (!string.IsNullOrEmpty(s.Description)) sb.AppendLine($"    <UU5.Bricks.P>{Esc(s.Description)}</UU5.Bricks.P>");
            if (!string.IsNullOrEmpty(s.Actors)) sb.AppendLine($"    <UU5.Bricks.Lsi><b>Actors:</b> {Esc(s.Actors)}</UU5.Bricks.Lsi>");
            sb.AppendLine("  </UU5.Bricks.Panel>");
        }
        sb.AppendLine("</UU5.Bricks.Section>");
        return sb.ToString();
    }

    public static string GenerateDependencies(IEnumerable<Uu5Dependency> deps)
    {
        var sb = new StringBuilder();
        sb.AppendLine("<UU5.Bricks.Section header=\"Dependencies\">");
        sb.AppendLine("  <UU5.Bricks.Table striped><UU5.Bricks.Table.THead><UU5.Bricks.Table.Tr>");
        sb.AppendLine("    <UU5.Bricks.Table.Th>Name</UU5.Bricks.Table.Th><UU5.Bricks.Table.Th>Type</UU5.Bricks.Table.Th><UU5.Bricks.Table.Th>Criticality</UU5.Bricks.Table.Th>");
        sb.AppendLine("  </UU5.Bricks.Table.Tr></UU5.Bricks.Table.THead><UU5.Bricks.Table.TBody>");
        foreach (var d in deps.OrderBy(x => x.SortOrder))
        {
            sb.AppendLine($"    <UU5.Bricks.Table.Tr><UU5.Bricks.Table.Td>{Esc(d.Name)}</UU5.Bricks.Table.Td>");
            sb.AppendLine($"    <UU5.Bricks.Table.Td>{Esc(d.Type)}</UU5.Bricks.Table.Td><UU5.Bricks.Table.Td>{Esc(d.Criticality)}</UU5.Bricks.Table.Td></UU5.Bricks.Table.Tr>");
        }
        sb.AppendLine("  </UU5.Bricks.Table.TBody></UU5.Bricks.Table>");
        sb.AppendLine("</UU5.Bricks.Section>");
        return sb.ToString();
    }

    public static string GenerateScope(IEnumerable<string>? inScope, IEnumerable<string>? outScope)
    {
        var sb = new StringBuilder();
        sb.AppendLine("<UU5.Bricks.Section header=\"Scope\">");
        sb.AppendLine("  <UU5.Bricks.Row><UU5.Bricks.Column colWidth=\"xs-12 m-6\">");
        sb.AppendLine("    <UU5.Bricks.Header level=\"3\">In Scope</UU5.Bricks.Header><UU5.Bricks.Ul>");
        if (inScope != null) foreach (var i in inScope) sb.AppendLine($"      <UU5.Bricks.Li>{Esc(i)}</UU5.Bricks.Li>");
        sb.AppendLine("    </UU5.Bricks.Ul></UU5.Bricks.Column>");
        sb.AppendLine("  <UU5.Bricks.Column colWidth=\"xs-12 m-6\">");
        sb.AppendLine("    <UU5.Bricks.Header level=\"3\">Out of Scope</UU5.Bricks.Header><UU5.Bricks.Ul>");
        if (outScope != null) foreach (var o in outScope) sb.AppendLine($"      <UU5.Bricks.Li>{Esc(o)}</UU5.Bricks.Li>");
        sb.AppendLine("    </UU5.Bricks.Ul></UU5.Bricks.Column></UU5.Bricks.Row>");
        sb.AppendLine("</UU5.Bricks.Section>");
        return sb.ToString();
    }

    public static string GeneratePrerequisites(IEnumerable<Uu5Prerequisite> prereqs)
    {
        var sb = new StringBuilder();
        sb.AppendLine("<UU5.Bricks.Section header=\"Prerequisites\"><UU5.Bricks.Ul>");
        foreach (var p in prereqs.OrderBy(x => x.SortOrder))
        {
            var badge = p.IsMandatory ? "<UU5.Bricks.Badge colorSchema=\"danger\">Required</UU5.Bricks.Badge>" : "";
            sb.AppendLine($"  <UU5.Bricks.Li><b>{Esc(p.Name)}</b> {badge} - {Esc(p.Description)}</UU5.Bricks.Li>");
        }
        sb.AppendLine("</UU5.Bricks.Ul></UU5.Bricks.Section>");
        return sb.ToString();
    }

    public static string GenerateTools(IEnumerable<Uu5Tool> tools)
    {
        var sb = new StringBuilder();
        sb.AppendLine("<UU5.Bricks.Section header=\"Tools\">");
        sb.AppendLine("  <UU5.Bricks.Table striped><UU5.Bricks.Table.THead><UU5.Bricks.Table.Tr>");
        sb.AppendLine("    <UU5.Bricks.Table.Th>Tool</UU5.Bricks.Table.Th><UU5.Bricks.Table.Th>Category</UU5.Bricks.Table.Th><UU5.Bricks.Table.Th>Version</UU5.Bricks.Table.Th>");
        sb.AppendLine("  </UU5.Bricks.Table.Tr></UU5.Bricks.Table.THead><UU5.Bricks.Table.TBody>");
        foreach (var t in tools.OrderBy(x => x.SortOrder))
            sb.AppendLine($"    <UU5.Bricks.Table.Tr><UU5.Bricks.Table.Td>{Esc(t.Name)}</UU5.Bricks.Table.Td><UU5.Bricks.Table.Td>{Esc(t.Category)}</UU5.Bricks.Table.Td><UU5.Bricks.Table.Td>{Esc(t.Version)}</UU5.Bricks.Table.Td></UU5.Bricks.Table.Tr>");
        sb.AppendLine("  </UU5.Bricks.Table.TBody></UU5.Bricks.Table></UU5.Bricks.Section>");
        return sb.ToString();
    }

    public static string GenerateInputsOutputs(IEnumerable<Uu5Input>? inputs, IEnumerable<Uu5Output>? outputs)
    {
        var sb = new StringBuilder();
        sb.AppendLine("<UU5.Bricks.Section header=\"Inputs & Outputs\">");
        if (inputs?.Any() == true)
        {
            sb.AppendLine("  <UU5.Bricks.Header level=\"3\">Inputs</UU5.Bricks.Header>");
            sb.AppendLine("  <UU5.Bricks.Table striped><UU5.Bricks.Table.TBody>");
            foreach (var i in inputs.OrderBy(x => x.SortOrder))
                sb.AppendLine($"    <UU5.Bricks.Table.Tr><UU5.Bricks.Table.Td>{Esc(i.Name)}</UU5.Bricks.Table.Td><UU5.Bricks.Table.Td>{Esc(i.DataType)}</UU5.Bricks.Table.Td><UU5.Bricks.Table.Td>{(i.IsRequired ? "Required" : "Optional")}</UU5.Bricks.Table.Td></UU5.Bricks.Table.Tr>");
            sb.AppendLine("  </UU5.Bricks.Table.TBody></UU5.Bricks.Table>");
        }
        if (outputs?.Any() == true)
        {
            sb.AppendLine("  <UU5.Bricks.Header level=\"3\">Outputs</UU5.Bricks.Header>");
            sb.AppendLine("  <UU5.Bricks.Table striped><UU5.Bricks.Table.TBody>");
            foreach (var o in outputs.OrderBy(x => x.SortOrder))
                sb.AppendLine($"    <UU5.Bricks.Table.Tr><UU5.Bricks.Table.Td>{Esc(o.Name)}</UU5.Bricks.Table.Td><UU5.Bricks.Table.Td>{Esc(o.DataType)}</UU5.Bricks.Table.Td><UU5.Bricks.Table.Td>{Esc(o.Format)}</UU5.Bricks.Table.Td></UU5.Bricks.Table.Tr>");
            sb.AppendLine("  </UU5.Bricks.Table.TBody></UU5.Bricks.Table>");
        }
        sb.AppendLine("</UU5.Bricks.Section>");
        return sb.ToString();
    }

    public static string GenerateTimeline(IEnumerable<Uu5TimelinePhase> phases)
    {
        var sb = new StringBuilder();
        var total = phases.Sum(p => p.DurationDays);
        sb.AppendLine("<UU5.Bricks.Section header=\"Timeline\">");
        sb.AppendLine($"  <UU5.Bricks.P><b>Total Duration:</b> {total} days</UU5.Bricks.P>");
        sb.AppendLine("  <UU5.Bricks.ProgressBar>");
        foreach (var p in phases.OrderBy(x => x.SortOrder))
        {
            var pct = total > 0 ? (int)(100.0 * p.DurationDays / total) : 0;
            sb.AppendLine($"    <UU5.Bricks.ProgressBar.Item progress=\"{pct}\" colorSchema=\"blue\">{Esc(p.Name)}</UU5.Bricks.ProgressBar.Item>");
        }
        sb.AppendLine("  </UU5.Bricks.ProgressBar></UU5.Bricks.Section>");
        return sb.ToString();
    }
}
