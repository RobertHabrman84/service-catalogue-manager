# Oprava start-all-fixed.ps1 - Návod k použití

## Problém
Při spuštění `start-all-fixed.ps1 -UseDocker` není vytvořena databáze, což způsobuje chyby připojení.

## Řešení

### Krok 1: Spuštění s Dockerem
```powershell
cd /home/user/webapp
pwsh ./start-all-fixed.ps1 -UseDocker -RecreateDb
```

### Krok 2: Kontrola Docker kontejneru
```powershell
pwsh ./docker-diagnostics.ps1
```

### Krok 3: Test databáze
```powershell
# Pro Docker SQL Server:
pwsh ./test-db-setup.ps1 -UseDocker

# Pro SQLite:
pwsh ./test-db-setup.ps1
```

### Krok 4: Ruční vytvoření databáze (pokud automatické selže)
```powershell
# Pro Docker:
pwsh ./database/scripts/setup-db-fixed.ps1 -DbName ServiceCatalogueManager -ContainerName scm-sqlserver -Force

# Pro SQLite:
pwsh ./database/scripts/setup-sqlite.ps1 -Force
```

## Co bylo opraveno

1. **setup-db-fixed.ps1** - Nový script pro vytvoření databáze v Dockeru:
   - Používá správný název databáze `ServiceCatalogueManager`
   - Používá správné heslo `YourStrong@Passw0rd`
   - Podporuje EF Core migrace i SQL skripty
   - Lepší error handling

2. **start-all-fixed.ps1** - Vylepšená logika:
   - Automaticky volá `Setup-DockerDatabase` pro vytvoření schématu
   - Správně nastavuje konfiguraci pro Docker/SQLite
   - Lepší kontrola existujících kontejnerů

3. **local.settings.docker.json** - Konfigurace pro Docker:
   - Správná connection string pro SQL Server
   - Kompatibilní se stávajícím kódem

4. **Testovací skripty**:
   - `test-db-setup.ps1` - Testuje připojení a tabulky
   - `docker-diagnostics.ps1` - Kontroluje Docker kontejner

## Parametry scriptu

```powershell
# Základní spuštění s Dockerem
pwsh ./start-all-fixed.ps1 -UseDocker

# Vynucení převytvoření databáze
pwsh ./start-all-fixed.ps1 -UseDocker -RecreateDb

# Pouze databáze
pwsh ./start-all-fixed.ps1 -UseDocker -DbOnly

# Pouze backend
pwsh ./start-all-fixed.ps1 -UseDocker -BackendOnly

# SQLite (pro sandbox bez Dockeru)
pwsh ./start-all-fixed.ps1
```

## Troubleshooting

### Docker není k dispozici
- Script automaticky přepne na SQLite
- Nebo použijte: `pwsh ./start-all-fixed.ps1` (bez `-UseDocker`)

### Databáze existuje ale nefunguje
- Použijte `-RecreateDb` parametr
- Nebo ručně: `pwsh ./database/scripts/setup-db-fixed.ps1 -Force`

### Kontejner běží ale databáze neexistuje
- Zkontrolujte logy: `docker logs scm-sqlserver`
- Spusťte diagnostiku: `pwsh ./docker-diagnostics.ps1`
- Vytvořte ručně: `pwsh ./database/scripts/setup-db-fixed.ps1`

### EF Core migrace selhávají
- Script automaticky použije SQL skript jako fallback
- Zkontrolujte connection string v `local.settings.json`

## Úspěšné spuštění
Když vše funguje správně, uvidíte:
```
✅ SQL Server container started
✅ Database setup complete!
✅ Backend built successfully
✅ Backend is HEALTHY!
✅ All services started!
```