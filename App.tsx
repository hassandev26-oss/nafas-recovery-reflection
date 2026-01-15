
import React, { useState, useEffect } from 'react';
import { HashRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
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
    const onboardedStatus = localStorage.getItem('nafas_onboarded') === 'true';
    const loggedInStatus = localStorage.getItem('nafas_logged_in') === 'true';
    setIsOnboarded(onboardedStatus);
    setIsLoggedIn(loggedInStatus);
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
          {/* Allow access to onboarding even if onboarded flag is set, to satisfy "Join Sanctuary Quietly" always taking them there */}
          <Route path="/onboarding" element={<Onboarding onComplete={handleOnboardingComplete} />} />

          {/* Protected App Routes */}
          <Route 
            path="/*" 
            element={
              isLoggedIn ? (
                <>
                  <Navigation onLogout={handleLogout} />
                  <main className="flex-1 w-full max-w-7xl mx-auto px-4 md:px-8 pb-24 md:pb-12">
                    <Routes>
                      <Route path="/home" element={<Home />} />
                      <Route path="/reflect" element={<Reflect />} />
                      <Route path="/community" element={<Community />} />
                      <Route path="/me" element={<Me onLogout={handleLogout} />} />
                      <Route path="*" element={<Navigate to="/home" />} />
                    </Routes>
                  </main>
                  <div className="md:hidden">
                    <BottomNav />
                  </div>
                </>
              ) : (
                <Navigate to="/login" />
              )
            } 
          />
        </Routes>
      </div>
    </Router>
  );
};

export default App;
