import { LayoutDashboard, Users, Store, ShoppingCart, Wallet, LogOut, Shield, Menu, X } from 'lucide-react';
import { Page } from '../types';

interface SidebarProps {
  currentPage: Page;
  onNavigate: (page: Page) => void;
  onLogout: () => void;
  collapsed: boolean;
  onToggle: () => void;
}

const navItems: { id: Page; label: string; icon: React.ElementType }[] = [
  { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { id: 'users', label: 'Users', icon: Users },
  { id: 'vendors', label: 'Vendors', icon: Store },
  { id: 'orders', label: 'Orders', icon: ShoppingCart },
  { id: 'wallet', label: 'Wallet', icon: Wallet },
];

export default function Sidebar({ currentPage, onNavigate, onLogout, collapsed, onToggle }: SidebarProps) {
  return (
    <aside
      className="flex flex-col h-screen sticky top-0 transition-all duration-300 shadow-xl z-20"
      style={{
        width: collapsed ? '72px' : '240px',
        background: 'linear-gradient(180deg, #1a1a2e 0%, #16213e 100%)',
        borderRight: '1px solid rgba(203,195,227,0.1)',
      }}
    >
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-5" style={{ borderBottom: '1px solid rgba(203,195,227,0.1)' }}>
        {!collapsed && (
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0" style={{ background: 'linear-gradient(135deg, #cbc3e3, #a89cc8)' }}>
              <Shield className="w-4 h-4 text-white" />
            </div>
            <span className="font-bold text-white text-base tracking-tight">AdminPro</span>
          </div>
        )}
        {collapsed && (
          <div className="w-8 h-8 rounded-lg flex items-center justify-center mx-auto" style={{ background: 'linear-gradient(135deg, #cbc3e3, #a89cc8)' }}>
            <Shield className="w-4 h-4 text-white" />
          </div>
        )}
        {!collapsed && (
          <button onClick={onToggle} className="text-gray-400 hover:text-white transition-colors p-1 rounded-lg hover:bg-white/10">
            <X className="w-4 h-4" />
          </button>
        )}
      </div>

      {collapsed && (
        <button onClick={onToggle} className="mt-3 mx-auto text-gray-400 hover:text-white transition-colors p-2 rounded-lg hover:bg-white/10">
          <Menu className="w-4 h-4" />
        </button>
      )}

      {/* Nav */}
      <nav className="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
        {!collapsed && (
          <p className="text-xs uppercase font-semibold mb-3 px-2" style={{ color: 'rgba(203,195,227,0.4)', letterSpacing: '0.1em' }}>
            Main Menu
          </p>
        )}
        {navItems.map(item => {
          const Icon = item.icon;
          const active = currentPage === item.id;
          return (
            <button
              key={item.id}
              onClick={() => onNavigate(item.id)}
              title={collapsed ? item.label : undefined}
              className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-xl transition-all duration-150 group ${
                active ? 'shadow-md' : 'hover:bg-white/5'
              }`}
              style={
                active
                  ? { background: 'linear-gradient(135deg, rgba(203,195,227,0.2), rgba(168,156,200,0.15))', borderLeft: '3px solid #cbc3e3' }
                  : {}
              }
            >
              <Icon
                className="w-4 h-4 flex-shrink-0 transition-colors"
                style={{ color: active ? '#cbc3e3' : 'rgba(203,195,227,0.5)' }}
              />
              {!collapsed && (
                <span className="text-sm font-medium transition-colors" style={{ color: active ? '#cbc3e3' : 'rgba(255,255,255,0.65)' }}>
                  {item.label}
                </span>
              )}
              {active && !collapsed && (
                <div className="ml-auto w-1.5 h-1.5 rounded-full" style={{ background: '#cbc3e3' }} />
              )}
            </button>
          );
        })}
      </nav>

      {/* Footer */}
      <div className="px-3 pb-4" style={{ borderTop: '1px solid rgba(203,195,227,0.1)', paddingTop: '12px' }}>
        {!collapsed && (
          <div className="flex items-center gap-3 px-3 py-2 rounded-xl mb-2" style={{ background: 'rgba(203,195,227,0.07)' }}>
            <div className="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 text-xs font-bold" style={{ background: 'linear-gradient(135deg, #cbc3e3, #a89cc8)', color: '#1a1a2e' }}>
              A
            </div>
            <div className="overflow-hidden">
              <p className="text-xs font-semibold text-white truncate">Admin User</p>
              <p className="text-xs truncate" style={{ color: 'rgba(203,195,227,0.5)' }}>admin@gmail.com</p>
            </div>
          </div>
        )}
        <button
          onClick={onLogout}
          title={collapsed ? 'Logout' : undefined}
          className="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl transition-all hover:bg-red-500/10 group"
        >
          <LogOut className="w-4 h-4 flex-shrink-0 transition-colors group-hover:text-red-400" style={{ color: 'rgba(203,195,227,0.4)' }} />
          {!collapsed && (
            <span className="text-sm transition-colors group-hover:text-red-400" style={{ color: 'rgba(203,195,227,0.5)' }}>
              Logout
            </span>
          )}
        </button>
      </div>
    </aside>
  );
}
