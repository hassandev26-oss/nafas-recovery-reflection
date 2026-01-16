
import React, { useState, useEffect } from 'react';
import { HashRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { supabase } from './services/api';
import Onboarding from './pages/Onboarding';
import Home from './pages/Home';
import Reflect from './pages/Reflect';
import Community from './pages/Circle'; 
import Me from './pages/Me';
import Login from './pages/Login';
import Landing from './pages/Landing';
import Legal from './pages/Legal';
import BottomNav from './components/BottomNav';
import Navigation from './components/Navigation';

const App: React.FC = () => {
  const [isLoggedIn, setIsLoggedIn] = useState<boolean | null>(null);
  const [isOnboarded, setIsOnboarded] = useState<boolean | null>(null);

  useEffect(() => {
    // Initial check from local storage
    const onboardedStatus = localStorage.getItem('nafas_onboarded') === 'true';
    const loggedInStatus = localStorage.getItem('nafas_logged_in') === 'true';
    setIsOnboarded(onboardedStatus);
    setIsLoggedIn(loggedInStatus);

    // Listen for Supabase auth changes (e.g. email link click)
    const { data: { subscription } } = supabase.auth.onAuthStateChange((event, session) => {
      if (event === 'SIGNED_IN' || event === 'TOKEN_REFRESHED') {
        localStorage.setItem('nafas_logged_in', 'true');
        // Ensure user ID is saved if missing
        if (session?.user) {
             localStorage.setItem('nafas_user_id', session.user.id);
             // We assume if they signed in successfully via email link, we can consider them onboarded for simplicity
             if (!onboardedStatus) {
                 localStorage.setItem('nafas_onboarded', 'true');
                 setIsOnboarded(true);
             }
        }
        setIsLoggedIn(true);
      } else if (event === 'SIGNED_OUT') {
        localStorage.removeItem('nafas_logged_in');
        setIsLoggedIn(false);
      }
    });

    return () => {
      subscription.unsubscribe();
    };
  }, []);

  const handleLogin = () => {
    localStorage.setItem('nafas_logged_in', 'true');
    setIsLoggedIn(true);
  };

  const handleLogout = () => {
    localStorage.removeItem('nafas_logged_in');
    setIsLoggedIn(false);
  };

  const handleOnboardingComplete = () => {
    localStorage.setItem('nafas_onboarded', 'true');
    localStorage.setItem('nafas_logged_in', 'true');
    setIsOnboarded(true);
    setIsLoggedIn(true);
  };

  if (isLoggedIn === null || isOnboarded === null) return null;

  return (
    <Router>
      <div className="min-h-screen flex flex-col bg-[#1c1c1a] text-[#e7e5e4]">
        <Routes>
          {/* Public Routes */}
          <Route path="/" element={<Landing />} />
          <Route path="/legal" element={<Legal />} />
          <Route path="/login" element={<Login onLogin={handleLogin} />} />
          <Route path="/onboarding" element={<Onboarding onComplete={handleOnboardingComplete} />} />

          {/* Protected App Routes */}
          <Route path="/*" element={
            isLoggedIn ? (
              <>
                <Navigation onLogout={handleLogout} />
                <main className="flex-1 w-full max-w-7xl mx-auto px-4 md:px-8 pb-24 md:pb-12">
                  <Routes>
                    <Route path="home" element={<Home />} />
                    <Route path="reflect" element={<Reflect />} />
                    <Route path="community" element={<Community />} />
                    <Route path="me" element={<Me onLogout={handleLogout} />} />
                    <Route path="*" element={<Navigate to="/home" replace />} />
                  </Routes>
                </main>
                <div className="md:hidden">
                  <BottomNav />
                </div>
              </>
            ) : (
              <Navigate to="/login" replace />
            )
          } />
        </Routes>
      </div>
    </Router>
  );
};

export default App;
