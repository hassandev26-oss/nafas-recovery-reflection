import React from 'react';
import { Link } from 'react-router-dom';

const Landing: React.FC = () => {
  return (
    <div className="min-h-screen flex flex-col">
      <header className="p-6">
        <Link to="/" className="text-2xl font-serif font-bold text-emerald-600">
          Nafas
        </Link>
      </header>
      <main className="flex-1 flex flex-col items-center justify-center p-6 text-center">
        <h1 className="text-4xl md:text-5xl font-serif text-[#e7e5e4] mb-6">
          Begin Your Recovery Journey
        </h1>
        <p className="text-lg text-[#a8a29e] max-w-xl mb-8">
          A safe, supportive space for reflection, growth, and community connection.
        </p>
        <div className="flex flex-col sm:flex-row gap-4">
          <Link
            to="/login"
            className="bg-emerald-700 text-white py-3 px-8 rounded-xl font-medium hover:bg-emerald-600 transition-colors"
          >
            Sign In
          </Link>
          <Link
            to="/onboarding"
            className="bg-stone-700 text-white py-3 px-8 rounded-xl font-medium hover:bg-stone-600 transition-colors"
          >
            Get Started
          </Link>
        </div>
      </main>
      <footer className="p-6 text-center">
        <Link to="/legal" className="text-sm text-[#a8a29e] hover:text-[#e7e5e4]">
          Privacy & Terms
        </Link>
      </footer>
    </div>
  );
};

export default Landing;
