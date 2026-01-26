# Git Workflow

## Branch Strategy

We follow a modified GitFlow workflow.

```
main (production)
  │
  └── develop (integration)
        │
        ├── feature/* (new features)
        ├── bugfix/* (bug fixes)
        └── hotfix/* (production fixes)
```

## Branch Naming

| Type | Pattern | Example |
|------|---------|---------|
| Feature | `feature/<ticket>-<description>` | `feature/SCM-123-add-export-pdf` |
| Bugfix | `bugfix/<ticket>-<description>` | `bugfix/SCM-456-fix-pagination` |
| Hotfix | `hotfix/<ticket>-<description>` | `hotfix/SCM-789-security-patch` |
| Release | `release/<version>` | `release/1.2.0` |

## Workflow

### Starting New Work

```bash
# Update develop
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/SCM-123-add-export-pdf
```

### Making Changes

```bash
# Make changes
git add .
git commit -m "feat(export): add PDF generation"

# Push to remote
git push origin feature/SCM-123-add-export-pdf
```

### Creating Pull Request

1. Push your branch
2. Create PR in Azure DevOps
3. Fill out PR template
4. Request reviewers
5. Address feedback
6. Merge after approval

## Commit Guidelines

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation |
| `style` | Formatting |
| `refactor` | Code restructuring |
| `test` | Adding tests |
| `chore` | Maintenance |

### Examples

```bash
# Feature
git commit -m "feat(api): add service search endpoint"

# Bug fix
git commit -m "fix(ui): resolve date picker timezone issue"

# Documentation
git commit -m "docs: update API authentication guide"
```

## Pull Request Process

### Requirements

- [ ] All checks passing
- [ ] Code reviewed by at least 1 reviewer
- [ ] No merge conflicts
- [ ] Linked work item

### Merge Strategy

- **Squash merge** for feature branches
- **Merge commit** for release branches
- **Rebase** discouraged on shared branches

## Hotfix Process

```bash
# Create from main
git checkout main
git pull origin main
git checkout -b hotfix/SCM-999-critical-fix

# Fix and commit
git commit -m "fix(security): patch vulnerability"

# Create PRs to both main and develop
```

## Release Process

1. Create release branch from develop
2. Bump version numbers
3. Update CHANGELOG
4. Create PR to main
5. Tag release after merge
6. Merge back to develop
