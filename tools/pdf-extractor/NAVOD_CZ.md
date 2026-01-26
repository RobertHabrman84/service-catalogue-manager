# 📘 Návod na použití PDF Extractor

**Service Catalogue Manager - PDF to JSON Extraction Tool**

---

## 📋 Co je PDF Extractor?

PDF Extractor je nástroj, který automaticky převádí PDF dokumenty služeb do strukturovaného JSON formátu pomocí Claude AI. Tento JSON lze pak importovat do Service Catalogue Manager databáze.

**Kdy ho použít:**
- Máte služby zdokumentované v PDF formátu
- Chcete je převést do strukturovaného JSON
- Potřebujete je naimportovat do databáze

**Co dělá:**
- Čte PDF dokumenty
- Extrahuje všechny důležité informace pomocí AI
- Vytváří validní JSON soubory
- Automaticky validuje výstup

---

## 🎯 Rychlý start (10 minut)

### Krok 1: Získání API klíče (3 minuty)

1. **Otevřete prohlížeč** a jděte na: https://console.anthropic.com/
2. **Přihlaste se** pomocí svého Anthropic účtu
3. V levém menu klikněte na **"API Keys"**
4. Klikněte na tlačítko **"Create Key"**
5. Pojmenujte klíč: **"PDF Extractor"**
6. Klikněte **"Create Key"**
7. **DŮLEŽITÉ:** Zkopírujte klíč OKAMŽITĚ - ukáže se pouze jednou!
   
   Klíč vypadá takto: `sk-ant-api03-xxxxxxxxxxxxxxxxxxxxxxxxxxx`

8. **Uložte klíč bezpečně** (do password manageru nebo poznámkového bloku)

#### 💳 Nastavení platby (pokud ještě nemáte)

1. V Console jděte na **"Settings"** → **"Billing"**
2. Přidejte platební kartu
3. Doporučujeme přidat kredit: **$10** (stačí na ~35 PDF dokumentů)

**Ceny:**
- 1 PDF dokument (20-30 stran): **~$0.27**
- 10 PDF dokumentů: **~$2.70**

---

### Krok 2: Instalace (2 minuty)

#### Windows:

1. **Otevřete PowerShell** (pravý klik na Start → Windows PowerShell)

2. **Přejděte do složky projektu:**
   ```powershell
   cd C:\cesta\k\projektu\service-catalogue-manager\tools\pdf-extractor
   ```

3. **Nainstalujte Python závislosti:**
   ```powershell
   pip install -r requirements.txt
   ```

#### Linux/Mac:

1. **Otevřete Terminal**

2. **Přejděte do složky projektu:**
   ```bash
   cd /cesta/k/projektu/service-catalogue-manager/tools/pdf-extractor
   ```

3. **Nainstalujte Python závislosti:**
   ```bash
   pip3 install -r requirements.txt
   ```

---

### Krok 3: Nastavení API klíče (1 minuta)

**DŮLEŽITÉ:** Použijte **pouze jednu** z následujících metod!

#### ✅ Doporučená metoda: Environment Variable

**Windows PowerShell:**
```powershell
$env:ANTHROPIC_API_KEY='sk-ant-api03-VÁŠ-KLÍČ-ZDE'
```

**Linux/Mac Terminal:**
```bash
export ANTHROPIC_API_KEY='sk-ant-api03-VÁŠ-KLÍČ-ZDE'
```

**Ověření, že klíč je nastaven:**

Windows:
```powershell
echo $env:ANTHROPIC_API_KEY
```

Linux/Mac:
```bash
echo $ANTHROPIC_API_KEY
```

Měl by se zobrazit váš API klíč (začínající `sk-ant-api03-...`)

---

### Krok 4: Příprava PDF souborů (1 minuta)

1. **Zkopírujte PDF soubory** do složky `pdfs/`:

   Windows:
   ```powershell
   Copy-Item "C:\Downloads\*.pdf" -Destination "pdfs\"
   ```

   Linux/Mac:
   ```bash
   cp ~/Downloads/*.pdf pdfs/
   ```

2. **Ověřte, že PDF jsou ve složce:**
   
   Windows:
   ```powershell
   ls pdfs\
   ```
   
   Linux/Mac:
   ```bash
   ls pdfs/
   ```

---

### Krok 5: Spuštění extrakce (3 minuty)

#### Windows PowerShell:
```powershell
.\run.ps1
```

#### Linux/Mac Terminal:
```bash
./run.sh
```

#### Nebo přímo Python:
```bash
python extract_services.py
```

---

### Krok 6: Kontrola výsledků

Po dokončení extrakce najdete JSON soubory ve složce **`output/`**:

```bash
# Zobrazení vytvořených souborů
ls output/

# Příklad výstupu:
# Enterprise_Scale_Landing_Zone_Design.json
# Application_Landing_Zone_Design.json
```

**Každý JSON soubor obsahuje:**
- ✅ Kompletní informace o službě
- ✅ Všechny sekce (usage scenarios, dependencies, scope, atd.)
- ✅ Validní strukturu pro import

---

## 📊 Co vidíte při spuštění

### Úspěšná extrakce vypadá takto:

```
🚀 Service Catalog PDF Extractor
============================================================
Schema: service-import-schema.json
PDF Directory: C:\projekt\tools\pdf-extractor\pdfs
Output Directory: C:\projekt\tools\pdf-extractor\output
Found 2 PDF file(s)
============================================================

[1/2] Processing: Enterprise_Scale_Landing_Zone_Design.pdf
------------------------------------------------------------
📄 Processing: Enterprise_Scale_Landing_Zone_Design.pdf
🤖 Calling Claude API...
✅ Extraction successful
✅ JSON schema validation passed
💾 Saved to: output/Enterprise_Scale_Landing_Zone_Design.json
📊 Service Code: ID001
📊 Service Name: Enterprise Scale Landing Zone Design
------------------------------------------------------------

[2/2] Processing: Application_Landing_Zone_Design.pdf
------------------------------------------------------------
📄 Processing: Application_Landing_Zone_Design.pdf
🤖 Calling Claude API...
✅ Extraction successful
✅ JSON schema validation passed
💾 Saved to: output/Application_Landing_Zone_Design.json
📊 Service Code: ID002
📊 Service Name: Application Landing Zone Design
------------------------------------------------------------

============================================================
📊 Summary
============================================================
✅ Successful: 2
❌ Failed: 0
📁 Output directory: output

✅ Extraction complete! JSON files are ready for import.
```

---

## ❓ Řešení problémů

### Problém 1: "ANTHROPIC_API_KEY environment variable not set"

**Příčina:** API klíč není nastaven

**Řešení:**
```powershell
# Windows
$env:ANTHROPIC_API_KEY='sk-ant-api03-VÁŠ-KLÍČ'

# Linux/Mac
export ANTHROPIC_API_KEY='sk-ant-api03-VÁŠ-KLÍČ'
```

---

### Problém 2: "No PDF files found in pdfs/"

**Příčina:** Ve složce `pdfs/` nejsou žádné PDF soubory

**Řešení:**
```bash
# Zkopírujte PDF soubory do pdfs/
cp /cesta/k/vasemu/souboru.pdf pdfs/

# Ověřte
ls pdfs/
```

---

### Problém 3: "pip: command not found"

**Příčina:** Python není nainstalován nebo není v PATH

**Řešení:**

**Windows:**
1. Stáhněte Python z: https://www.python.org/downloads/
2. Při instalaci zaškrtněte **"Add Python to PATH"**
3. Restartujte PowerShell

**Linux/Mac:**
```bash
# Mac (Homebrew)
brew install python3

# Ubuntu/Debian
sudo apt-get install python3 python3-pip

# Fedora
sudo dnf install python3 python3-pip
```

---

### Problém 4: "Module 'anthropic' not found"

**Příčina:** Závislosti nejsou nainstalovány

**Řešení:**
```bash
pip install -r requirements.txt
```

---

### Problém 5: "Claude API error: rate_limit_error"

**Příčina:** Překročili jste rate limit (příliš mnoho requestů)

**Řešení:**
- Počkejte 1-2 minuty
- Zkuste znovu
- Pokud problém přetrvává, kontaktujte Anthropic support

---

### Problém 6: "Insufficient credits"

**Příčina:** Došly vám kredity v Anthropic účtu

**Řešení:**
1. Jděte na: https://console.anthropic.com/settings/billing
2. Přidejte kredit (např. $10)
3. Zkuste znovu

---

### Problém 7: JSON schema validation failed

**Příčina:** Extrahovaná data neodpovídají očekávané struktuře

**Řešení:**
1. Zkontrolujte chybovou zprávu - ukazuje konkrétní problém
2. Otevřete vygenerovaný JSON soubor
3. Opravte ručně podle chybové zprávy
4. Nebo zkuste extrakci znovu

Příklad:
```
⚠️ JSON schema validation failed: 'serviceCode' is a required property
```
→ V JSON chybí povinné pole `serviceCode`

---

## 🔧 Pokročilé použití

### Permanentní nastavení API klíče

Pokud nechcete zadávat API klíč při každém spuštění:

#### Windows - Systémová proměnná:

1. Stiskněte **Win + R**
2. Napište: `sysdm.cpl` a stiskněte Enter
3. Záložka **"Advanced"** → **"Environment Variables"**
4. V sekci **"User variables"** klikněte **"New"**
5. Variable name: `ANTHROPIC_API_KEY`
6. Variable value: `sk-ant-api03-VÁŠ-KLÍČ`
7. **OK** → **OK** → **OK**
8. Restartujte PowerShell

#### Linux/Mac - Trvalé nastavení:

```bash
# Přidat do ~/.bashrc (nebo ~/.zshrc pro Mac)
echo 'export ANTHROPIC_API_KEY="sk-ant-api03-VÁŠ-KLÍČ"' >> ~/.bashrc

# Načíst změny
source ~/.bashrc

# Ověření
echo $ANTHROPIC_API_KEY
```

---

### Zpracování konkrétních PDF

Pokud chcete zpracovat pouze některé PDF soubory:

```bash
# Vyčistit složku pdfs/
rm pdfs/*.pdf

# Zkopírovat pouze konkrétní PDF
cp /cesta/k/Enterprise_LZ.pdf pdfs/

# Spustit extrakci
python extract_services.py
```

---

### Kontrola JSON výstupu

Po extrakci můžete JSON soubor otevřít a zkontrolovat:

```bash
# Windows
notepad output\Enterprise_Scale_Landing_Zone_Design.json

# Linux/Mac
cat output/Enterprise_Scale_Landing_Zone_Design.json | less

# Nebo ve VS Code
code output/Enterprise_Scale_Landing_Zone_Design.json
```

---

## 📁 Struktura souborů

Po úspěšné extrakci vypadá složka takto:

```
pdf-extractor/
├── extract_services.py          # Hlavní script
├── requirements.txt             # Python závislosti
├── run.sh                       # Runner pro Linux/Mac
├── run.ps1                      # Runner pro Windows
├── README.md                    # Dokumentace
├── QUICKSTART.md                # Rychlý návod
├── NAVOD_CZ.md                  # Tento návod (česky)
├── .env.example                 # Příklad konfigurace
├── .gitignore                   # Git ignore
├── pdfs/                        # 📥 VSTUP: Sem dáte PDF soubory
│   ├── .gitkeep
│   ├── Enterprise_Scale_LZ.pdf
│   └── Application_LZ.pdf
└── output/                      # 📤 VÝSTUP: Zde najdete JSON
    ├── .gitkeep
    ├── Enterprise_Scale_LZ.json
    └── Application_LZ.json
```

---

## 🎓 Co dělat s vytvořenými JSON soubory?

Po úspěšné extrakci máte JSON soubory připravené pro import do databáze.

### Další kroky:

1. **Zkontrolujte JSON soubory** - otevřete a ověřte, že data jsou správná

2. **Připravte na import:**
   ```bash
   # Zkopírovat JSON do hlavního projektu (volitelné)
   cp output/*.json ../../data/import/
   ```

3. **Import do databáze** (bude dostupné po dokončení Fáze 5-6):
   ```bash
   # Pomocí Import API
   curl -X POST http://localhost:7071/api/services/import \
     -H "Content-Type: application/json" \
     -d @output/Enterprise_Scale_LZ.json
   ```

4. **Nebo pomocí UI** (bude dostupné po dokončení Fáze 8):
   - Otevřete Service Catalogue Manager frontend
   - Klikněte "Import Service"
   - Nahrajte JSON soubor
   - Klikněte "Import"

---

## 💰 Informace o nákladech

### Aktuální ceny (leden 2026)

**Claude Sonnet 4:**
- Input: $3 za milion tokenů
- Output: $15 za milion tokenů

### Typické náklady

| Dokument | Strany | Tokeny | Cena |
|----------|--------|--------|------|
| Malá služba | 10-15 stran | ~30k input + 5k output | **~$0.15** |
| Střední služba | 20-30 stran | ~50k input + 8k output | **~$0.27** |
| Velká služba | 40-50 stran | ~80k input + 12k output | **~$0.42** |

### Doporučené kredity

- **Pro testování:** $10 (cca 35 středních dokumentů)
- **Pro malý projekt:** $25 (cca 90 dokumentů)
- **Pro větší projekt:** $50+ (podle potřeby)

### Monitoring nákladů

Sledujte využití na: https://console.anthropic.com/settings/billing

---

## 🔒 Bezpečnost API klíče

### ✅ DŮLEŽITÉ - Bezpečnostní pravidla:

1. **NIKDY** nesdílejte API klíč veřejně
2. **NIKDY** necommitujte klíč do Git repositáře
3. **NIKDY** nezadávejte klíč do emailu nebo chatu
4. **NIKDY** neukazujte klíč ve screenshotu nebo screen sharing
5. **VŽDY** ukládejte klíč do password manageru
6. **ROTUJTE** klíče pravidelně (např. každé 3 měsíce)

### Co dělat, když klíč unikne:

1. **OKAMŽITĚ** jděte na: https://console.anthropic.com/settings/keys
2. Najděte kompromitovaný klíč
3. Klikněte na ikonku koše (Delete)
4. Vygenerujte nový klíč
5. Aktualizujte klíč ve všech místech, kde ho používáte

---

## 📞 Podpora

### Dokumentace

- **Anthropic API Docs:** https://docs.anthropic.com/
- **Console:** https://console.anthropic.com/
- **Pricing:** https://www.anthropic.com/pricing

### Časté otázky

**Q: Musím platit za každé spuštění?**  
A: Ano, platíte podle počtu zpracovaných tokenů (cca $0.27 za dokument).

**Q: Můžu zpracovat více PDF najednou?**  
A: Ano, stačí umístit všechny PDF do `pdfs/` složky.

**Q: Jak dlouho trvá zpracování jednoho PDF?**  
A: Obvykle 30-60 sekund podle velikosti dokumentu.

**Q: Co když extrakce selže?**  
A: Script pokračuje s dalšími PDF. Chybové soubory můžete zkusit znovu.

**Q: Můžu upravit prompt pro extrakci?**  
A: Ano, upravte metodu `_create_extraction_prompt()` v `extract_services.py`.

**Q: Jsou moje data bezpečná?**  
A: Ano, Anthropic neukládá vaše PDF ani extrahovaná data. Více info: https://docs.anthropic.com/privacy

---

## ✅ Checklist

Před spuštěním ověřte:

- [ ] Python 3.8+ je nainstalován (`python --version`)
- [ ] Dependencies jsou nainstalovány (`pip list | grep anthropic`)
- [ ] API klíč je získán z console.anthropic.com
- [ ] API klíč je nastaven (`echo $ANTHROPIC_API_KEY`)
- [ ] PDF soubory jsou ve složce `pdfs/` (`ls pdfs/`)
- [ ] Máte dostatečný kredit v Anthropic účtu
- [ ] Jste připraveni spustit extrakci! 🚀

---

## 🎉 Hotovo!

Nyní máte vše připravené pro převod PDF dokumentů do JSON formátu.

**Příkaz pro spuštění:**

```bash
# Windows
.\run.ps1

# Linux/Mac
./run.sh

# Nebo přímo
python extract_services.py
```

**Výsledek:** JSON soubory ve složce `output/` připravené k importu!

---

**Vytvořeno:** 26. ledna 2026  
**Verze:** 1.0  
**Service Catalogue Manager - PDF Extraction Tool**
