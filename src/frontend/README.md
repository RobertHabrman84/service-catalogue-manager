# Service Catalogue Manager - Frontend

React-based frontend application for the Service Catalogue Manager.

## Tech Stack

- **React 18** - UI library
- **TypeScript** - Type safety
- **Vite** - Build tool
- **Tailwind CSS** - Styling
- **Redux Toolkit** - State management
- **React Router** - Routing
- **React Hook Form** - Form handling
- **MSAL React** - Azure AD authentication
- **Vitest** - Unit testing
- **Playwright** - E2E testing

## Prerequisites

- Node.js 20.x or higher
- npm 10.x or higher
- Azure AD application configured for authentication

## Getting Started

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment

Copy the example environment file and update with your values:

```bash
cp .env.example .env.local
```

Required environment variables:
- `VITE_API_BASE_URL` - Backend API URL
- `VITE_AZURE_AD_CLIENT_ID` - Azure AD client ID
- `VITE_AZURE_AD_TENANT_ID` - Azure AD tenant ID

### 3. Start Development Server

```bash
npm run dev
```

The application will be available at `http://localhost:5173`

## Available Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start development server |
| `npm run build` | Build for production |
| `npm run preview` | Preview production build |
| `npm run lint` | Run ESLint |
| `npm run lint:fix` | Fix ESLint issues |
| `npm run format` | Format code with Prettier |
| `npm run test` | Run unit tests |
| `npm run test:coverage` | Run tests with coverage |
| `npm run test:ui` | Run tests with UI |
| `npm run type-check` | Check TypeScript types |

## Project Structure

```
src/
├── assets/          # Static assets (images, fonts)
├── components/      # Reusable components
│   ├── common/      # Generic UI components
│   ├── forms/       # Form components
│   ├── catalog/     # Catalog-specific components
│   ├── export/      # Export-related components
│   ├── auth/        # Authentication components
│   └── layout/      # Layout components
├── config/          # Configuration files
├── hooks/           # Custom React hooks
├── pages/           # Page components
├── services/        # API services
├── store/           # Redux store and slices
├── styles/          # Global styles
├── types/           # TypeScript type definitions
└── utils/           # Utility functions
```

## Code Style

- ESLint for linting
- Prettier for formatting
- TypeScript strict mode enabled

## Testing

### Unit Tests

```bash
npm run test
```

### Coverage Report

```bash
npm run test:coverage
```

Coverage thresholds:
- Branches: 70%
- Functions: 70%
- Lines: 70%
- Statements: 70%

## Building for Production

```bash
npm run build
```

Output will be in the `dist/` directory.

## Deployment

The application is deployed to Azure Static Web Apps via CI/CD pipeline.

### Manual Deployment

```bash
# Build
npm run build

# Deploy using Azure CLI
az staticwebapp deploy --app-name <app-name> --source dist
```

## Environment Configuration

| Variable | Description | Required |
|----------|-------------|----------|
| `VITE_API_BASE_URL` | Backend API base URL | Yes |
| `VITE_AZURE_AD_CLIENT_ID` | Azure AD client ID | Yes |
| `VITE_AZURE_AD_TENANT_ID` | Azure AD tenant ID | Yes |
| `VITE_AZURE_AD_REDIRECT_URI` | OAuth redirect URI | Yes |
| `VITE_FEATURE_EXPORT_PDF` | Enable PDF export | No |
| `VITE_FEATURE_UUBOOKKIT` | Enable UuBookKit | No |

## Contributing

1. Create a feature branch from `develop`
2. Make your changes
3. Run tests and linting
4. Create a pull request

## License

MIT
