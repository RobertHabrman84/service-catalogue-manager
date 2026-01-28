# Příklady / Examples

## Application_Landing_Zone_Design_FIXED.json

Tento soubor obsahuje příklad **správně strukturovaného** a **validního** JSON pro import služby.

### Co bylo opraveno:

1. ✅ **serviceCode**: Změněno z `"ID0XX"` na `"ID999"` (validní formát)
2. ✅ **toolsAndEnvironment**: Všechny položky správně strukturovány jako objekty
   - cloudPlatforms: Normalizováno z multi-cloud struktury
   - designTools: Konvertováno ze stringů na objekty
   - automationTools: Rozděleno comma-separated hodnoty
   - assessmentTools: Přesunuto do pole "other"

### Použití:

⚠️ **PŘED IMPORTEM ZMĚŇTE serviceCode!**

```json
"serviceCode": "ID999"  // <-- Změňte na skutečnou hodnotu (např. ID001, ID002, atd.)
```

Poté můžete soubor naimportovat:
1. Otevřete aplikaci Service Catalogue Manager
2. Přejděte na Import
3. Nahrajte tento soubor
4. Klikněte na "Validate"
5. Pokud je validace úspěšná, klikněte na "Import"

### Struktura toolsAndEnvironment:

Každý tool má následující strukturu:
```json
{
  "category": "název kategorie",
  "toolName": "název nástroje",
  "version": "verze (nebo prázdný string)",
  "purpose": "účel použití"
}
```

### Data Integrity:

✅ 100% dat z původního souboru zachováno  
✅ Pouze struktura normalizována pro splnění schématu  
✅ Všech 51 původních názvů nástrojů přítomno  
✅ Všechny sekce identické s originálem

Pro více informací viz `OPRAVY-CHANGELOG.md` v kořenovém adresáři projektu.
