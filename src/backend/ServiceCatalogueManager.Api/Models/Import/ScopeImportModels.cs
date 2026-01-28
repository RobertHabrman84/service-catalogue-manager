using System.Text.Json;
using System.Text.Json.Serialization;

namespace ServiceCatalogueManager.Api.Models.Import;

// Main wrapper class matching expected structure
public class ScopeImportModel
{
    public List<ScopeCategoryImportModel>? InScope { get; set; }
    public List<string>? OutOfScope { get; set; }
}

public class ScopeCategoryImportModel
{
    public string CategoryName { get; set; } = string.Empty;
    public int? CategoryNumber { get; set; }
    public int SortOrder { get; set; }
    
    /// <summary>
    /// Akceptuje buď pole stringů ["item1", "item2"] 
    /// nebo pole objektů [{itemName: "item1"}]
    /// </summary>
    [JsonConverter(typeof(ScopeItemsFlexibleConverter))]
    public List<ScopeItemImportModel>? Items { get; set; }
}

public class ScopeItemImportModel
{
    public string ItemName { get; set; } = string.Empty;
    public string ItemDescription { get; set; } = string.Empty;
}

/// <summary>
/// Custom converter pro flexibilní parsování scope items
/// Akceptuje: ["string1", "string2"] nebo [{itemName: "x", itemDescription: "y"}]
/// </summary>
public class ScopeItemsFlexibleConverter : JsonConverter<List<ScopeItemImportModel>?>
{
    public override List<ScopeItemImportModel>? Read(
        ref Utf8JsonReader reader, 
        Type typeToConvert, 
        JsonSerializerOptions options)
    {
        if (reader.TokenType == JsonTokenType.Null)
            return null;

        if (reader.TokenType != JsonTokenType.StartArray)
            throw new JsonException("Expected array for Items");

        var result = new List<ScopeItemImportModel>();
        
        while (reader.Read())
        {
            if (reader.TokenType == JsonTokenType.EndArray)
                break;

            if (reader.TokenType == JsonTokenType.String)
            {
                // Případ: pole stringů ["item1", "item2"]
                result.Add(new ScopeItemImportModel 
                { 
                    ItemName = reader.GetString() ?? "",
                    ItemDescription = ""
                });
            }
            else if (reader.TokenType == JsonTokenType.StartObject)
            {
                // Případ: pole objektů [{itemName: "item1", itemDescription: "desc"}]
                using var doc = JsonDocument.ParseValue(ref reader);
                var root = doc.RootElement;
                
                var item = new ScopeItemImportModel();
                
                if (root.TryGetProperty("itemName", out var nameProp))
                    item.ItemName = nameProp.GetString() ?? "";
                else if (root.TryGetProperty("ItemName", out var nameCapProp))
                    item.ItemName = nameCapProp.GetString() ?? "";
                
                if (root.TryGetProperty("itemDescription", out var descProp))
                    item.ItemDescription = descProp.GetString() ?? "";
                else if (root.TryGetProperty("ItemDescription", out var descCapProp))
                    item.ItemDescription = descCapProp.GetString() ?? "";
                
                result.Add(item);
            }
        }

        return result;
    }

    public override void Write(
        Utf8JsonWriter writer, 
        List<ScopeItemImportModel>? value, 
        JsonSerializerOptions options)
    {
        if (value == null)
        {
            writer.WriteNullValue();
            return;
        }
        
        writer.WriteStartArray();
        foreach (var item in value)
        {
            writer.WriteStartObject();
            writer.WriteString("itemName", item.ItemName);
            writer.WriteString("itemDescription", item.ItemDescription);
            writer.WriteEndObject();
        }
        writer.WriteEndArray();
    }
}
