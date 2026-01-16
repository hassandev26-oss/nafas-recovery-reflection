import React from 'react';

interface OnboardingProps {
  onComplete: () => void;
}

const Onboarding: React.FC<OnboardingProps> = ({ onComplete }) => {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-6 bg-[#1c1c1a]">
      <div className="max-w-md w-full text-center space-y-8">
        <h1 className="text-3xl font-serif text-[#e7e5e4]">Welcome to Nafas</h1>
        <p className="text-[#a8a29e]">
          Your journey to recovery and reflection begins here.
        </p>
        <button
          onClick={onComplete}
          className="w-full bg-emerald-700 text-white py-3 px-6 rounded-xl font-medium hover:bg-emerald-600 transition-colors"
        >
          Begin Your Journey
        </button>
      </div>
    </div>
  );
};

export default Onboarding;
