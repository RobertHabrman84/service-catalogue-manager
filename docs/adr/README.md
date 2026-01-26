# Architecture Decision Records (ADR)

## Overview

This directory contains Architecture Decision Records (ADRs) documenting significant architectural decisions made during the development of Service Catalogue Manager.

## What is an ADR?

An ADR is a document that captures an important architectural decision along with its context and consequences.

## ADR Index

| ID | Title | Status | Date |
|----|-------|--------|------|
| [001](./001-use-react-for-frontend.md) | Use React for Frontend | Accepted | 2025-01 |
| [002](./002-use-azure-functions-for-backend.md) | Use Azure Functions for Backend | Accepted | 2025-01 |
| [003](./003-use-entity-framework-core.md) | Use Entity Framework Core | Accepted | 2025-01 |

## ADR Statuses

| Status | Description |
|--------|-------------|
| Proposed | Under discussion |
| Accepted | Decision made and active |
| Deprecated | No longer valid |
| Superseded | Replaced by another ADR |

## Creating New ADRs

1. Copy [template.md](./template.md)
2. Name file: `NNN-short-title.md`
3. Fill in all sections
4. Submit for review
5. Update this index

## Template

See [template.md](./template.md) for the standard ADR format.

## References

- [ADR GitHub Organization](https://adr.github.io/)
- [Michael Nygard's Article](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
