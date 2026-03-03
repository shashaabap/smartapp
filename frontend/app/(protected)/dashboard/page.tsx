'use client';

export default function Dashboard() {
  const handleLogout = async () => {
    console.log('🚨 LOGOUT STARTED');
    
    // 1. Backend logout FIRST (clears HttpOnly cookie server-side)
    try {
      await fetch('http://localhost:4000/auth/logout', {
        method: 'POST',
        credentials: 'include'
      });
      console.log('🚨 BACKEND LOGOUT SUCCESS');
    } catch(e) {
      console.log('🚨 BACKEND SKIP (normal if no endpoint)');
    }
    
    // 2. Clear ALL client storage
    localStorage.clear();
    sessionStorage.clear();
    document.cookie.split(";").forEach(c => 
      document.cookie = c.replace(/^ +/, "").replace(/=.*/, "=;expires=" + new Date(0).toUTCString() + ";path=/")
    );
    
    console.log('🚨 CLIENT CLEARED');
    
    // 3. FORCE full page reload + redirect (bypasses proxy cache)
    window.location.replace('/login?nocache=' + Date.now());
  };

  return (
    <div className="min-h-screen p-8">
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold">Smartapp Dashboard</h1>
        
        <button
          onClick={handleLogout}
          className="bg-red-600 text-white px-2 py-1 rounded-xl font-bold hover:bg-red-700 text-lg shadow-lg hover:shadow-xl transition-all"
        >
          LOGOUT NOW
        </button>
      </div>
      
      <p>Open Console → Click button → Watch logs</p>
    </div>
  );
}
