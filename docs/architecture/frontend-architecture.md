# Frontend Architecture

## Overview

The frontend is a modern Single Page Application (SPA) built with React and TypeScript.

## Technology Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| React | 18.x | UI framework |
| TypeScript | 5.x | Type safety |
| Vite | 5.x | Build tool |
| TailwindCSS | 3.x | Styling |
| Redux Toolkit | 2.x | State management |
| React Router | 6.x | Routing |
| MSAL React | 3.x | Authentication |

## Project Structure

```
src/
├── components/
│   ├── common/        # Reusable UI components
│   ├── forms/         # Form components
│   ├── layout/        # Layout components
│   └── auth/          # Auth-related components
├── pages/             # Page components
├── hooks/             # Custom React hooks
├── store/             # Redux store & slices
├── services/          # API service layer
├── types/             # TypeScript type definitions
├── utils/             # Utility functions
└── styles/            # Global styles
```

## Component Architecture

### Atomic Design Pattern

```
Atoms → Molecules → Organisms → Templates → Pages
```

- **Atoms**: Button, Input, Badge
- **Molecules**: SearchInput, FormField
- **Organisms**: Header, Sidebar, ServiceCard
- **Templates**: MainLayout, FormLayout
- **Pages**: Dashboard, CatalogList, CreateService

## State Management

### Redux Store Structure

```typescript
{
  auth: {
    user: User | null,
    isAuthenticated: boolean,
    loading: boolean
  },
  catalog: {
    services: Service[],
    selectedService: Service | null,
    loading: boolean
  },
  lookups: {
    statuses: Status[],
    categories: Category[]
  },
  ui: {
    sidebarOpen: boolean,
    notifications: Notification[]
  }
}
```

## Routing

| Route | Component | Auth Required |
|-------|-----------|---------------|
| `/login` | LoginPage | No |
| `/dashboard` | Dashboard | Yes |
| `/catalog` | CatalogList | Yes |
| `/services/create` | CreateService | Yes |
| `/services/:id` | ViewService | Yes |
| `/services/:id/edit` | EditService | Yes |

## API Communication

```typescript
// services/api.ts
const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
});

api.interceptors.request.use((config) => {
  const token = getAccessToken();
  config.headers.Authorization = `Bearer ${token}`;
  return config;
});
```

## Testing Strategy

| Type | Tool | Coverage Target |
|------|------|-----------------|
| Unit | Vitest | 80% |
| Component | React Testing Library | Key components |
| E2E | Playwright | Critical paths |

## Build & Deployment

```bash
# Development
npm run dev

# Production build
npm run build

# Preview production build
npm run preview
```

## Performance Optimization

- Code splitting via React.lazy()
- Image optimization
- Bundle analysis with vite-plugin-analyzer
- Service Worker for PWA support
