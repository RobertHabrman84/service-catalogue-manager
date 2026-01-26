import { useMsal } from "@azure/msal-react";
import { loginRequest } from "@services/auth/msalInstance";
export const LoginPage = () => {
  const { instance } = useMsal();
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="card p-8 max-w-md w-full text-center">
        <h1 className="text-2xl font-bold mb-4">Service Catalogue Manager</h1>
        <p className="text-gray-600 mb-6">Sign in to access the service catalog.</p>
        <button onClick={() => instance.loginRedirect(loginRequest)} className="btn-primary w-full">
          Sign in with Microsoft
        </button>
      </div>
    </div>
  );
};
export default LoginPage;
