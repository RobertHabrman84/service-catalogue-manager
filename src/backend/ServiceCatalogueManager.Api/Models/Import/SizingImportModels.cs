using System.Text.Json;
using System.Text.Json.Serialization;

namespace ServiceCatalogueManager.Api.Models.Import;

public class SizingExampleImportModel
{
    // Původní pole
    public int? ExampleNumber { get; set; }
    public string? ExampleTitle { get; set; }
    public string? Description { get; set; }
    
    // Nová pole z JSON formátu
    public string? ExampleName { get; set; }
    public string? Scenario { get; set; }
    public List<string>? Deliverables { get; set; }
    
    [JsonConverter(typeof(CharacteristicsFlexibleConverter))]
    public List<ExampleCharacteristicImportModel>? Characteristics { get; set; }
    
    /// <summary>
    /// Vrátí efektivní titulek příkladu
    /// </summary>
    public string GetEffectiveTitle() 
        => ExampleTitle ?? ExampleName ?? "Example";
    
    /// <summary>
    /// Vrátí efektivní popis
    /// </summary>
    public string? GetEffectiveDescription()
        => Description ?? Scenario;
}

public class ExampleCharacteristicImportModel
{
    // Původní pole
    public string CharacteristicDescription { get; set; } = string.Empty;
    
    // Nová pole z JSON formátu
    public string? Name { get; set; }
    public string? Value { get; set; }
    
    /// <summary>
    /// Vrátí normalizovaný popis charakteristiky
    /// </summary>
    public string GetNormalizedDescription()
    {
        if (!string.IsNullOrEmpty(CharacteristicDescription))
            return CharacteristicDescription;
        
        if (!string.IsNullOrEmpty(Name) && !string.IsNullOrEmpty(Value))
            return $"{Name}: {Value}";
        
        return Name ?? Value ?? "";
    }
}

/// <summary>
/// Converter pro flexibilní parsování characteristics
/// Akceptuje: [{characteristicDescription: "x"}] nebo [{name: "x", value: "y"}]
/// </summary>
public class CharacteristicsFlexibleConverter : JsonConverter<List<ExampleCharacteristicImportModel>?>
{
    public override List<ExampleCharacteristicImportModel>? Read(
        ref Utf8JsonReader reader, 
        Type typeToConvert, 
        JsonSerializerOptions options)
    {
        if (reader.TokenType == JsonTokenType.Null)
            return null;

        if (reader.TokenType != JsonTokenType.StartArray)
            throw new JsonException("Expected array for Characteristics");

        var result = new List<ExampleCharacteristicImportModel>();
        
        while (reader.Read())
        {
            if (reader.TokenType == JsonTokenType.EndArray)
                break;

            if (reader.TokenType == JsonTokenType.StartObject)
            {
                using var doc = JsonDocument.ParseValue(ref reader);
                var root = doc.RootElement;
                
                var item = new ExampleCharacteristicImportModel();
                
                // Zkusí načíst nový formát (name, value)
                if (root.TryGetProperty("name", out var nameProp))
                    item.Name = nameProp.GetString();
                if (root.TryGetProperty("value", out var valueProp))
                    item.Value = valueProp.GetString();
                
                // Zkusí načíst starý formát (characteristicDescription)
                if (root.TryGetProperty("characteristicDescription", out var descProp))
                    item.CharacteristicDescription = descProp.GetString() ?? "";
                else if (root.TryGetProperty("CharacteristicDescription", out var descCapProp))
                    item.CharacteristicDescription = descCapProp.GetString() ?? "";
                
                result.Add(item);
            }
        }

        return result;
    }

    public override void Write(
        Utf8JsonWriter writer, 
        List<ExampleCharacteristicImportModel>? value, 
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
            writer.WriteString("characteristicDescription", item.GetNormalizedDescription());
            writer.WriteEndObject();
        }
        writer.WriteEndArray();
    }
}

public class SizingParameterImportModel
{
    public string ParameterName { get; set; } = string.Empty;
    public string? Value { get; set; }
    public string? Unit { get; set; }
}

public class SizingCriterionImportModel
{
    public string CriteriaName { get; set; } = string.Empty;
    public string? Criteria { get; set; }
}

public class ScopeDependencyImportModel
{
    public string DependencyDescription { get; set; } = string.Empty;
}
