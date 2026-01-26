import React, { createContext, useContext, useState, useEffect } from 'react';

interface User {
  id: string;
  name: string;
  email: string;
}

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: () => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | null>(null);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    // Auto-login in dev mode
    if (import.meta.env.VITE_SKIP_AUTH === 'true' || import.meta.env.VITE_DEV_MODE === 'true') {
      setUser({
        id: 'dev-user-1',
        name: 'Development User',
        email: 'dev@example.com'
      });
    }
  }, []);

  const login = async () => {
    setIsLoading(true);
    // Mock login
    setTimeout(() => {
      setUser({
        id: 'dev-user-1',
        name: 'Development User',
        email: 'dev@example.com'
      });
      setIsLoading(false);
    }, 500);
  };

  const logout = () => {
    setUser(null);
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        isAuthenticated: !!user,
        isLoading,
        login,
        logout
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};
