// =============================================================================
// SERVICE CATALOGUE MANAGER - UU5 STRING HELPER TESTS
// =============================================================================

using ServiceCatalogueManager.Api.Helpers;

namespace ServiceCatalogueManager.Api.Tests.Unit.Helpers;

public class Uu5StringHelperTests
{
    [Fact]
    public void ToUu5String_WithSimpleText_ShouldWrapCorrectly()
    {
        var text = "Hello World";
        var result = Uu5StringHelper.ToUu5String(text);
        result.Should().Contain("<uu5string/>");
    }

    [Fact]
    public void ToUu5String_WithNull_ShouldReturnEmptyUu5String()
    {
        var result = Uu5StringHelper.ToUu5String(null);
        result.Should().Contain("<uu5string/>");
    }

    [Fact]
    public void CreateHeader_WithText_ShouldCreateUu5Header()
    {
        var result = Uu5StringHelper.CreateHeader("Test Header", 1);
        result.Should().Contain("<UU5.Bricks.Header");
        result.Should().Contain("level=\"1\"");
    }

    [Theory]
    [InlineData(1)]
    [InlineData(2)]
    [InlineData(3)]
    public void CreateHeader_WithDifferentLevels_ShouldUseCorrectLevel(int level)
    {
        var result = Uu5StringHelper.CreateHeader("Test", level);
        result.Should().Contain($"level=\"{level}\"");
    }

    [Fact]
    public void CreateParagraph_WithText_ShouldCreateUu5Paragraph()
    {
        var result = Uu5StringHelper.CreateParagraph("Test paragraph");
        result.Should().Contain("<UU5.Bricks.P>");
        result.Should().Contain("Test paragraph");
    }

    [Fact]
    public void CreateList_WithItems_ShouldCreateUu5List()
    {
        var items = new[] { "Item 1", "Item 2", "Item 3" };
        var result = Uu5StringHelper.CreateList(items);
        result.Should().Contain("<UU5.Bricks.Ul>");
        result.Should().Contain("<UU5.Bricks.Li>");
        result.Should().Contain("Item 1");
        result.Should().Contain("Item 2");
    }

    [Fact]
    public void CreateList_WithEmptyArray_ShouldReturnEmptyList()
    {
        var items = Array.Empty<string>();
        var result = Uu5StringHelper.CreateList(items);
        result.Should().Contain("<UU5.Bricks.Ul>");
    }

    [Fact]
    public void CreateTable_WithData_ShouldCreateUu5Table()
    {
        var headers = new[] { "Col1", "Col2" };
        var rows = new[] { new[] { "A", "B" }, new[] { "C", "D" } };
        var result = Uu5StringHelper.CreateTable(headers, rows);
        result.Should().Contain("<UU5.Bricks.Table>");
        result.Should().Contain("Col1");
        result.Should().Contain("Col2");
    }

    [Fact]
    public void EscapeHtml_WithSpecialCharacters_ShouldEscape()
    {
        var input = "<script>alert('test')</script>";
        var result = Uu5StringHelper.EscapeHtml(input);
        result.Should().NotContain("<script>");
        result.Should().Contain("&lt;script&gt;");
    }

    [Theory]
    [InlineData("<", "&lt;")]
    [InlineData(">", "&gt;")]
    [InlineData("&", "&amp;")]
    [InlineData("\"", "&quot;")]
    public void EscapeHtml_WithSpecialChar_ShouldEscapeCorrectly(string input, string expected)
    {
        var result = Uu5StringHelper.EscapeHtml(input);
        result.Should().Contain(expected);
    }

    [Fact]
    public void CreateSection_WithContent_ShouldWrapInSection()
    {
        var result = Uu5StringHelper.CreateSection("Title", "Content");
        result.Should().Contain("<UU5.Bricks.Section");
        result.Should().Contain("Title");
        result.Should().Contain("Content");
    }

    [Fact]
    public void CreateAlert_WithMessage_ShouldCreateAlert()
    {
        var result = Uu5StringHelper.CreateAlert("Warning message", "warning");
        result.Should().Contain("<UU5.Bricks.Alert");
        result.Should().Contain("colorSchema=\"warning\"");
    }
}
