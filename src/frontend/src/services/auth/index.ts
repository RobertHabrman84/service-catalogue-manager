// Auth Services barrel export
export { msalInstance } from './msalInstance';
export { 
  msalConfig, 
  loginRequest, 
  silentRequest,
  apiScopes, 
  graphScopes,
  APP_ROLES,
  hasRole,
  hasAnyRole,
  hasAllRoles,
  canEdit,
  canAdmin,
  type AppRole,
} from './authConfig';

export { 
  authService, 
  type AuthUser, 
  type AuthState 
} from './authService';

export { 
  tokenService, 
  type TokenInfo 
} from './tokenService';
