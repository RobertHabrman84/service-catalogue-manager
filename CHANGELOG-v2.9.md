# Version 2.9 - One-Command Startup

**Release Date:** 29. ledna 2026

## 🚀 Hlavní novinky

### Automatizovaný startup skript
- **start-scm.ps1** - Kompletní automatický startup celé aplikace jediným příkazem
- Žádná manuální konfigurace není potřeba
- Automatické nastavení všech služeb

## 📋 Co přináší verze 2.9

### 1. Startup Script (`start-scm.ps1`)
**Funkce:**
- ✅ Automatické vytvoření SQL Server databáze v Dockeru
- ✅ Inicializace databázového schématu z `db_structure.sql`
- ✅ Build backendu (.NET)
- ✅ Build frontendu (React + Vite)
- ✅ Spuštění backendu v novém procesu
- ✅ Spuštění frontendu v novém procesu
- ✅ Kontrola všech prerequisites (Docker, .NET, Node.js, func tools)
- ✅ Inteligentní handling existujících Docker containerů
- ✅ Barevný výstup s detailními informacemi

**Konfigurace:**
- Database container: `scm-sqlserver`
- SQL Server 2022 (latest)
- Database: `ServiceCatalogueManager`
- Port: 1433
- Credentials: sa / YourStrong@Passw0rd

### 2. Database Schema
- **db_structure.sql** zkopírován do rootu projektu
- Kompletní schéma pro Service Catalogue
- Lookup tabulky s předvyplněnými daty
- Views pro snadnější přístup k datům

### 3. Dokumentace
- Aktualizovaný README.md s Quick Start sekcí
- Jasné instrukce pro spuštění
- Seznam prerequisites
- Informace o portách a službách

## 🔧 Technické detaily

### Prerequisites
```
- Docker Desktop (running)
- .NET 8 SDK
- Node.js 18+
- PowerShell 7+
- Azure Functions Core Tools 4 (instaluje se automaticky pokud chybí)
```

### Spuštění
```powershell
.\start-scm.ps1
```

### Výsledek
- Frontend: http://localhost:5173
- Backend API: http://localhost:7071
- Database: localhost:1433

### Zastavení
```powershell
# Zavřete terminálová okna backendu a frontendu
docker stop scm-sqlserver
# Volitelně odstraňte container
docker rm scm-sqlserver
```

## 📁 Struktura projektu

### Nové soubory
```
service-catalogue-manager/
├── start-scm.ps1           # ⭐ Nový automatický startup script
├── db_structure.sql        # ⭐ SQL schéma pro databázi
└── README.md              # ✏️ Aktualizovaný s Quick Start
```

## 🎯 Výhody oproti předchozí verzi

### Version 2.8 → 2.9
- ❌ **Před:** Manuální setup databáze, manuální build, manuální start
- ✅ **Teď:** Jeden příkaz spustí vše automaticky

### Časová úspora
- **Před:** ~15-20 minut na kompletní setup
- **Teď:** ~2-3 minuty (většinou čekání na Docker)

## 🐛 Opravy a vylepšení

1. **Automatizace databáze**
   - Automatické vytvoření Docker containeru
   - Inteligentní detekce existujícího containeru
   - Automatická inicializace schématu

2. **Error handling**
   - Kontrola všech prerequisites
   - Jasné chybové hlášky
   - Barevný výstup pro lepší čitelnost

3. **Process management**
   - Backend a frontend běží v samostatných procesech
   - Jasné PID pro snadné zastavení
   - Informativní výstup o stavu služeb

## 📊 Kompatibilita

- ✅ Windows (PowerShell 7+)
- ✅ Linux (PowerShell Core 7+)
- ✅ macOS (PowerShell Core 7+)

## 🔄 Upgrade z předchozí verze

Žádné speciální kroky nejsou potřeba:
1. Stáhněte novou verzi
2. Spusťte `.\start-scm.ps1`

## 📚 Související dokumentace

- [README.md](README.md) - Hlavní dokumentace
- [db_structure.sql](db_structure.sql) - Databázové schéma
- [src/backend/](src/backend/) - Backend dokumentace
- [src/frontend/](src/frontend/) - Frontend dokumentace

## 🎉 Shrnutí

Version 2.9 přináší dramatické zjednodušení startu aplikace. Místo složité manuální konfigurace stačí **jeden příkaz** a celá aplikace je připravena k použití.

**Vyzkoušejte:**
```powershell
.\start-scm.ps1
```

---

**Předchozí verze:** [Version 1.5](docs/JSON-IMPORT-FIX-v1.5-FINAL.md)
