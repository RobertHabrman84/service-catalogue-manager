// =============================================================================
// SERVICE CATALOGUE MANAGER - MARKDOWN HELPER TESTS
// =============================================================================

using ServiceCatalogueManager.Api.Helpers;

namespace ServiceCatalogueManager.Api.Tests.Unit.Helpers;

public class MarkdownHelperTests
{
    [Theory]
    [InlineData("Test", 1, "# Test")]
    [InlineData("Test", 2, "## Test")]
    [InlineData("Test", 3, "### Test")]
    public void CreateHeader_WithLevel_ShouldCreateCorrectHeader(string text, int level, string expected)
    {
        var result = MarkdownHelper.CreateHeader(text, level);
        result.Should().Be(expected);
    }

    [Fact]
    public void CreateBold_ShouldWrapInAsterisks()
    {
        var result = MarkdownHelper.CreateBold("important");
        result.Should().Be("**important**");
    }

    [Fact]
    public void CreateItalic_ShouldWrapInUnderscores()
    {
        var result = MarkdownHelper.CreateItalic("emphasized");
        result.Should().Be("_emphasized_");
    }

    [Fact]
    public void CreateLink_ShouldFormatCorrectly()
    {
        var result = MarkdownHelper.CreateLink("Click here", "https://example.com");
        result.Should().Be("[Click here](https://example.com)");
    }

    [Fact]
    public void CreateBulletList_ShouldCreateListItems()
    {
        var items = new[] { "First", "Second", "Third" };
        var result = MarkdownHelper.CreateBulletList(items);
        result.Should().Contain("- First");
        result.Should().Contain("- Second");
        result.Should().Contain("- Third");
    }

    [Fact]
    public void CreateNumberedList_ShouldCreateNumberedItems()
    {
        var items = new[] { "First", "Second", "Third" };
        var result = MarkdownHelper.CreateNumberedList(items);
        result.Should().Contain("1. First");
        result.Should().Contain("2. Second");
        result.Should().Contain("3. Third");
    }

    [Fact]
    public void CreateTable_ShouldFormatCorrectly()
    {
        var headers = new[] { "Name", "Value" };
        var rows = new[] { new[] { "A", "1" }, new[] { "B", "2" } };
        var result = MarkdownHelper.CreateTable(headers, rows);
        result.Should().Contain("| Name | Value |");
        result.Should().Contain("| --- | --- |");
        result.Should().Contain("| A | 1 |");
    }

    [Fact]
    public void CreateCodeBlock_ShouldWrapInBackticks()
    {
        var code = "var x = 1;";
        var result = MarkdownHelper.CreateCodeBlock(code, "csharp");
        result.Should().StartWith("```csharp");
        result.Should().Contain(code);
        result.Should().EndWith("```");
    }

    [Fact]
    public void CreateInlineCode_ShouldWrapInSingleBackticks()
    {
        var result = MarkdownHelper.CreateInlineCode("variable");
        result.Should().Be("`variable`");
    }

    [Fact]
    public void CreateBlockquote_ShouldPrefixWithGreaterThan()
    {
        var result = MarkdownHelper.CreateBlockquote("Quote text");
        result.Should().StartWith("> Quote text");
    }

    [Fact]
    public void CreateHorizontalRule_ShouldReturnDashes()
    {
        var result = MarkdownHelper.CreateHorizontalRule();
        result.Should().Be("---");
    }

    [Fact]
    public void EscapeMarkdown_ShouldEscapeSpecialCharacters()
    {
        var input = "Test *with* _special_ characters";
        var result = MarkdownHelper.EscapeMarkdown(input);
        result.Should().Contain("\\*");
        result.Should().Contain("\\_");
    }

    [Theory]
    [InlineData("*", "\\*")]
    [InlineData("_", "\\_")]
    [InlineData("#", "\\#")]
    [InlineData("[", "\\[")]
    public void EscapeMarkdown_ShouldEscapeChar(string input, string expected)
    {
        var result = MarkdownHelper.EscapeMarkdown(input);
        result.Should().Be(expected);
    }

    [Fact]
    public void CreateImage_ShouldFormatCorrectly()
    {
        var result = MarkdownHelper.CreateImage("Alt text", "https://example.com/image.png");
        result.Should().Be("![Alt text](https://example.com/image.png)");
    }

    [Fact]
    public void CreateTaskList_ShouldCreateCheckboxes()
    {
        var items = new[] { ("Done task", true), ("Pending task", false) };
        var result = MarkdownHelper.CreateTaskList(items);
        result.Should().Contain("[x] Done task");
        result.Should().Contain("[ ] Pending task");
    }
}
