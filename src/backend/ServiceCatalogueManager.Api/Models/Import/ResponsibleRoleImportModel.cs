using System.ComponentModel.DataAnnotations;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace ServiceCatalogueManager.Api.Models.Import;

public class ResponsibleRoleImportModel
{
    [Required]
    public string RoleName { get; set; } = string.Empty;

    public bool IsPrimaryOwner { get; set; }

    /// <summary>
    /// Akceptuje buď string "responsibility" 
    /// nebo pole stringů ["resp1", "resp2"]
    /// </summary>
    [JsonConverter(typeof(ResponsibilitiesFlexibleConverter))]
    public string? Responsibilities { get; set; }
    
    /// <summary>
    /// Původní pole responsibilities pro přístup k jednotlivým položkám (pokud byly pole)
    /// </summary>
    [JsonIgnore]
    public List<string>? ResponsibilitiesList { get; set; }
}

/// <summary>
/// Custom converter - akceptuje string nebo string[]
/// </summary>
public class ResponsibilitiesFlexibleConverter : JsonConverter<string?>
{
    public override string? Read(
        ref Utf8JsonReader reader, 
        Type typeToConvert, 
        JsonSerializerOptions options)
    {
        if (reader.TokenType == JsonTokenType.Null)
            return null;

        if (reader.TokenType == JsonTokenType.String)
        {
            // Případ: string "responsibility"
            return reader.GetString();
        }
        
        if (reader.TokenType == JsonTokenType.StartArray)
        {
            // Případ: pole stringů ["resp1", "resp2"]
            var items = new List<string>();
            while (reader.Read())
            {
                if (reader.TokenType == JsonTokenType.EndArray)
                    break;
                if (reader.TokenType == JsonTokenType.String)
                    items.Add(reader.GetString() ?? "");
            }
            // Spojí pole do jednoho stringu odděleného čárkou
            return string.Join(", ", items);
        }

        throw new JsonException($"Unexpected token type for Responsibilities: {reader.TokenType}");
    }

    public override void Write(
        Utf8JsonWriter writer, 
        string? value, 
        JsonSerializerOptions options)
    {
        if (value == null)
            writer.WriteNullValue();
        else
            writer.WriteStringValue(value);
    }
}
