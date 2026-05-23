import { Bell, Search, Settings } from 'lucide-react';
import { Page } from '../types';

interface HeaderProps {
  currentPage: Page;
}

const pageTitles: Record<Page, { title: string; subtitle: string }> = {
  dashboard: { title: 'Dashboard', subtitle: 'Welcome back, Admin!' },
  users: { title: 'User Management', subtitle: 'Manage all registered users' },
  vendors: { title: 'Vendor Approvals', subtitle: 'Review and approve vendor requests' },
  orders: { title: 'Orders', subtitle: 'Track and manage all orders' },
  wallet: { title: 'Wallet Overview', subtitle: 'Monitor wallet transactions' },
};

export default function Header({ currentPage }: HeaderProps) {
  const info = pageTitles[currentPage];

  return (
    <header className="sticky top-0 z-10 flex items-center justify-between px-6 py-4" style={{ background: 'rgba(248,247,252,0.9)', backdropFilter: 'blur(12px)', borderBottom: '1px solid rgba(203,195,227,0.3)' }}>
      <div>
        <h1 className="text-xl font-bold" style={{ color: '#1a1a2e' }}>{info.title}</h1>
        <p className="text-xs mt-0.5" style={{ color: '#7c6f9f' }}>{info.subtitle}</p>
      </div>

      <div className="flex items-center gap-3">
        <div className="relative hidden sm:block">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4" style={{ color: '#a89cc8' }} />
          <input
            type="text"
            placeholder="Search..."
            className="pl-9 pr-4 py-2 rounded-xl text-sm outline-none transition-all w-48"
            style={{ background: 'rgba(203,195,227,0.2)', border: '1px solid rgba(203,195,227,0.4)', color: '#1a1a2e' }}
            onFocus={e => e.target.style.borderColor = '#a89cc8'}
            onBlur={e => e.target.style.borderColor = 'rgba(203,195,227,0.4)'}
          />
        </div>

        <button className="relative p-2 rounded-xl transition-all hover:scale-105" style={{ background: 'rgba(203,195,227,0.2)', border: '1px solid rgba(203,195,227,0.4)' }}>
          <Bell className="w-4 h-4" style={{ color: '#7c6f9f' }} />
          <span className="absolute top-1 right-1 w-2 h-2 rounded-full" style={{ background: '#e05c7a' }} />
        </button>

        <button className="p-2 rounded-xl transition-all hover:scale-105" style={{ background: 'rgba(203,195,227,0.2)', border: '1px solid rgba(203,195,227,0.4)' }}>
          <Settings className="w-4 h-4" style={{ color: '#7c6f9f' }} />
        </button>
      </div>
    </header>
  );
}
