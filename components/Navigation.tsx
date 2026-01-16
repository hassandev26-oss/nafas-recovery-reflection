import React from 'react';
import { Link, useLocation } from 'react-router-dom';

interface NavigationProps {
  onLogout: () => void;
}

const Navigation: React.FC<NavigationProps> = ({ onLogout }) => {
  const location = useLocation();

  const navItems = [
    { name: 'Home', path: '/home' },
    { name: 'Reflect', path: '/reflect' },
    { name: 'Community', path: '/community' },
    { name: 'Profile', path: '/me' },
  ];

  const isActive = (path: string) => location.pathname === path;

  return (
    <nav className="hidden md:flex sticky top-0 z-50 bg-[#1c1c1a]/95 backdrop-blur-md border-b border-stone-800 py-4 px-6 justify-between items-center">
      <Link to="/home" className="text-xl font-serif font-bold text-emerald-600 tracking-tight">
        Nafas
      </Link>
      <div className="flex space-x-8">
        {navItems.map((item) => (
          <Link
            key={item.path}
            to={item.path}
            className={`text-sm font-medium transition-colors ${
              isActive(item.path)
                ? 'text-emerald-500'
                : 'text-stone-400 hover:text-stone-200'
            }`}
          >
            {item.name}
          </Link>
        ))}
      </div>
      <button
        onClick={onLogout}
        className="text-sm text-stone-500 hover:text-stone-300 transition-colors"
      >
        Log Out
      </button>
    </nav>
  );
};

export default Navigation;
