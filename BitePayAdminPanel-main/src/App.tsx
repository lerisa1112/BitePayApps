import { useState } from 'react';
import Login from './components/Login';
import Sidebar from './components/Sidebar';
import Header from './components/Header';
import Dashboard from './pages/Dashboard';
import Users from './pages/Users';
import Vendors from './pages/Vendors';
import Orders from './pages/Orders';
import Wallet from './pages/Wallet';
import { Page } from './types';

export default function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [currentPage, setCurrentPage] = useState<Page>('dashboard');
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);

  if (!isLoggedIn) {
    return <Login onLogin={() => setIsLoggedIn(true)} />;
  }

  const renderPage = () => {
    switch (currentPage) {
      case 'dashboard': return <Dashboard />;
      case 'users': return <Users />;
      case 'vendors': return <Vendors />;
      case 'orders': return <Orders />;
      case 'wallet': return <Wallet />;
    }
  };

  return (
    <div className="flex h-screen overflow-hidden" style={{ background: '#f8f7fc' }}>
      <Sidebar
        currentPage={currentPage}
        onNavigate={setCurrentPage}
        onLogout={() => setIsLoggedIn(false)}
        collapsed={sidebarCollapsed}
        onToggle={() => setSidebarCollapsed(c => !c)}
      />
      <main className="flex-1 flex flex-col overflow-hidden">
        <Header currentPage={currentPage} />
        <div className="flex-1 overflow-y-auto">
          {renderPage()}
        </div>
      </main>
    </div>
  );
}
