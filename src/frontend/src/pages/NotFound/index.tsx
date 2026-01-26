// pages/NotFound/index.tsx
// 404 Not Found page

import React from 'react';
import { Link } from 'react-router-dom';
import { HomeIcon, ArrowLeftIcon, MagnifyingGlassIcon } from '@heroicons/react/24/outline';

export const NotFoundPage: React.FC = () => {
  return (
    <div className="min-h-[60vh] flex items-center justify-center">
      <div className="text-center max-w-md mx-auto px-4">
        {/* 404 Illustration */}
        <div className="mb-8">
          <div className="relative inline-block">
            <span className="text-9xl font-bold text-gray-200">404</span>
            <div className="absolute inset-0 flex items-center justify-center">
              <MagnifyingGlassIcon className="w-20 h-20 text-gray-400" />
            </div>
          </div>
        </div>

        {/* Message */}
        <h1 className="text-2xl font-bold text-gray-900 mb-2">
          Page not found
        </h1>
        <p className="text-gray-500 mb-8">
          Sorry, we couldn't find the page you're looking for. 
          The page might have been removed, renamed, or is temporarily unavailable.
        </p>

        {/* Actions */}
        <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
          <Link
            to="/"
            className="inline-flex items-center gap-2 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium"
          >
            <HomeIcon className="w-5 h-5" />
            Go to Dashboard
          </Link>
          <button
            onClick={() => window.history.back()}
            className="inline-flex items-center gap-2 px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
          >
            <ArrowLeftIcon className="w-5 h-5" />
            Go Back
          </button>
        </div>

        {/* Help links */}
        <div className="mt-12 pt-8 border-t border-gray-200">
          <p className="text-sm text-gray-500 mb-4">
            Here are some helpful links:
          </p>
          <div className="flex flex-wrap justify-center gap-4 text-sm">
            <Link to="/catalog" className="text-blue-600 hover:text-blue-700">
              Service Catalogue
            </Link>
            <Link to="/services/new" className="text-blue-600 hover:text-blue-700">
              Create Service
            </Link>
            <Link to="/export" className="text-blue-600 hover:text-blue-700">
              Export
            </Link>
            <Link to="/settings" className="text-blue-600 hover:text-blue-700">
              Settings
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
};

export default NotFoundPage;
