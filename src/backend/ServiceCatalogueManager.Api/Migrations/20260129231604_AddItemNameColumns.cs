using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ServiceCatalogueManager.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddItemNameColumns : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Add ItemName column to ServiceScopeItem
            migrationBuilder.AddColumn<string>(
                name: "ItemName",
                table: "ServiceScopeItem",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: false,
                defaultValue: "");

            // Add ItemName column to ServiceOutputItem
            migrationBuilder.AddColumn<string>(
                name: "ItemName",
                table: "ServiceOutputItem",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Remove ItemName column from ServiceScopeItem
            migrationBuilder.DropColumn(
                name: "ItemName",
                table: "ServiceScopeItem");

            // Remove ItemName column from ServiceOutputItem
            migrationBuilder.DropColumn(
                name: "ItemName",
                table: "ServiceOutputItem");
        }
    }
}
