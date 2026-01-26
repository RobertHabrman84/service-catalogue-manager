# CI/CD Pipelines

Azure DevOps pipelines for Service Catalogue Manager.

## Pipeline Structure

```
pipelines/
├── azure-pipelines.yml      # Main pipeline (triggers CI)
├── ci-pipeline.yml          # Continuous Integration
├── cd-pipeline-dev.yml      # Deploy to Development
├── cd-pipeline-staging.yml  # Deploy to Staging
├── cd-pipeline-prod.yml     # Deploy to Production
├── templates/
│   ├── jobs/               # Reusable job templates
│   ├── stages/             # Reusable stage templates
│   ├── steps/              # Reusable step templates
│   └── variables/          # Environment variables
└── scripts/                # Pipeline helper scripts
```

## Pipelines

| Pipeline | Trigger | Description |
|----------|---------|-------------|
| CI | PR, develop | Build, test, scan |
| CD-Dev | develop merge | Deploy to dev |
| CD-Staging | release/* | Deploy to staging |
| CD-Prod | main merge | Deploy to production |

## Usage

### Manual Run

```yaml
trigger: none
```

### Branch Triggers

```yaml
trigger:
  branches:
    include:
      - main
      - develop
```

## Templates

Templates are reusable components that can be included in pipelines.

### Jobs
- `build-frontend.yml` - Build React app
- `build-backend.yml` - Build .NET Functions
- `run-unit-tests.yml` - Run unit tests
- `security-scan.yml` - Run security scans

### Steps
- `setup-node.yml` - Install Node.js
- `setup-dotnet.yml` - Install .NET SDK
- `cache-npm.yml` - Cache npm packages
- `publish-artifacts.yml` - Publish build artifacts

## Variables

Environment-specific variables are defined in `templates/variables/`.

## Scripts

Helper scripts for pipeline tasks:
- `set-build-version.ps1` - Set semantic version
- `run-database-migration.ps1` - Run DB migrations
- `health-check.ps1` - Post-deployment health check
