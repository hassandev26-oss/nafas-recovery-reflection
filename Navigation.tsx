
import React from 'react';
import { Link, useLocation } from 'react-router-dom';

const Navigation: React.FC = () => {
  const location = useLocation();
  
  const navItems = [
    { name: 'The Sanctuary', path: '/circle' },
    { name: 'Private Journal', path: '/journal' },
    { name: 'Urgent Help', path: '/urge-control' },
    { name: 'Knowledge Garden', path: '/garden' },
    { name: 'Recovery Path', path: '/path' },
  ];

  const isActive = (path: string) => location.pathname === path;

  return (
    <nav className="sticky top-0 z-50 bg-white/80 backdrop-blur-md border-b border-stone-100 py-3 px-6 md:px-12 flex justify-between items-center">
      <Link to="/" className="text-xl font-serif font-bold text-emerald-800 tracking-tight">
        Nafas
      </Link>
      <div className="hidden lg:flex space-x-8">
        {navItems.map((item) => (
          <Link
            key={item.path}
            to={item.path}
            className={`text-[11px] font-bold uppercase tracking-widest transition-all hover:text-emerald-700 ${
              isActive(item.path) ? 'text-emerald-800' : 'text-stone-400'
            }`}
          >
            {item.name}
          </Link>
        ))}
      </div>
      <Link to="/circle" className="bg-stone-900 text-white px-5 py-2 rounded-xl text-[10px] font-bold uppercase tracking-widest hover:bg-stone-800 transition-all">
        Enter quietly
      </Link>
    </nav>
  );
};

export default Navigation;
