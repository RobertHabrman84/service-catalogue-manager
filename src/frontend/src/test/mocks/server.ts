import { setupServer } from 'msw/node';
import { handlers } from './handlers';

// Setup MSW server with handlers
export const server = setupServer(...handlers);

// Reset handlers after each test
export const resetHandlers = () => server.resetHandlers();

// Add custom handlers for specific tests
export const addHandler = (...newHandlers: Parameters<typeof server.use>) => 
  server.use(...newHandlers);

export default server;
