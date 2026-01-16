import React from 'react';

interface MeProps {
  onLogout: () => void;
}

const Me: React.FC<MeProps> = ({ onLogout }) => {
  return (
    <div className="py-8">
      <h1 className="text-2xl font-serif text-[#e7e5e4] mb-6">Profile</h1>
      <p className="text-[#a8a29e] mb-8">
        Your personal space for tracking progress.
      </p>
      <button
        onClick={onLogout}
        className="bg-stone-700 text-white py-2 px-4 rounded-lg hover:bg-stone-600 transition-colors"
      >
        Log Out
      </button>
    </div>
  );
};

export default Me;
