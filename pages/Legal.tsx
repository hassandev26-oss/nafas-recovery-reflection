import React from 'react';
import { Link } from 'react-router-dom';

const Legal: React.FC = () => {
  return (
    <div className="min-h-screen p-6 md:p-12">
      <div className="max-w-3xl mx-auto">
        <Link to="/" className="text-emerald-600 hover:text-emerald-500 mb-8 inline-block">
          &larr; Back to Home
        </Link>
        <h1 className="text-3xl font-serif text-[#e7e5e4] mb-8">Privacy & Terms</h1>

        <section className="mb-8">
          <h2 className="text-xl font-semibold text-[#e7e5e4] mb-4">Privacy Policy</h2>
          <p className="text-[#a8a29e] leading-relaxed">
            Your privacy matters to us. We collect only the information necessary to provide
            our services and never share your personal data with third parties without your consent.
          </p>
        </section>

        <section className="mb-8">
          <h2 className="text-xl font-semibold text-[#e7e5e4] mb-4">Terms of Service</h2>
          <p className="text-[#a8a29e] leading-relaxed">
            By using Nafas, you agree to use the platform respectfully and in accordance with
            our community guidelines. We reserve the right to remove content that violates these terms.
          </p>
        </section>
      </div>
    </div>
  );
};

export default Legal;
