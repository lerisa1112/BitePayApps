import { useState } from 'react';
import {
  Shield,
  Eye,
  EyeOff,
  Lock,
  Mail,
} from 'lucide-react';

import axios from 'axios';

interface LoginProps {
  onLogin: () => void;
}

export default function Login({ onLogin }: LoginProps) {

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const [showPassword, setShowPassword] = useState(false);

  const [error, setError] = useState('');

  const [loading, setLoading] = useState(false);

  // =========================
  // LOGIN
  // =========================
  const handleSubmit = async (e: React.FormEvent) => {

    e.preventDefault();

    setError('');

    setLoading(true);

    try {

      const res = await axios.post(
        'https://bitepay.onrender.com/api/auth/login',
        {
          email,
          password,
        }
      );

      console.log(res.data);

      // save token
      localStorage.setItem('token', res.data.token);

      // save admin data
      localStorage.setItem(
        'admin',
        JSON.stringify(res.data)
      );

      // login success
      onLogin();

    } catch (err: any) {

      console.log(err);

      setError(
        err?.response?.data?.message ||
        'Login failed'
      );

    } finally {

      setLoading(false);

    }
  };

  return (
    <div
      className="min-h-screen flex items-center justify-center relative overflow-hidden"
      style={{
        background:
          'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)'
      }}
    >

      {/* Background */}
      <div
        className="absolute top-0 left-0 w-96 h-96 rounded-full opacity-10"
        style={{
          background: '#cbc3e3',
          transform: 'translate(-50%, -50%)'
        }}
      />

      <div
        className="absolute bottom-0 right-0 w-80 h-80 rounded-full opacity-10"
        style={{
          background: '#cbc3e3',
          transform: 'translate(40%, 40%)'
        }}
      />

      <div
        className="absolute top-1/2 right-20 w-40 h-40 rounded-full opacity-5"
        style={{
          background: '#cbc3e3'
        }}
      />

      <div className="relative z-10 w-full max-w-md mx-4">

        {/* Logo */}
        <div className="text-center mb-8">

          <div
            className="inline-flex items-center justify-center w-16 h-16 rounded-2xl mb-4 shadow-lg"
            style={{
              background:
                'linear-gradient(135deg, #cbc3e3, #a89cc8)'
            }}
          >
            <Shield className="w-8 h-8 text-white" />
          </div>

          <h1 className="text-3xl font-bold text-white tracking-tight">
            BitePay Admin
          </h1>

          <p
            className="text-sm mt-1"
            style={{
              color: '#cbc3e3'
            }}
          >
            Control Panel
          </p>

        </div>

        {/* Card */}
        <div
          className="rounded-2xl p-8 shadow-2xl border"
          style={{
            background: 'rgba(255,255,255,0.05)',
            backdropFilter: 'blur(20px)',
            borderColor: 'rgba(203,195,227,0.2)'
          }}
        >

          <h2 className="text-xl font-semibold text-white mb-2">
            Welcome back
          </h2>

          <p
            className="text-sm mb-6"
            style={{
              color: 'rgba(203,195,227,0.7)'
            }}
          >
            Sign in to access your dashboard
          </p>

          <form
            onSubmit={handleSubmit}
            className="space-y-5"
          >

            {/* EMAIL */}
            <div>

              <label
                className="block text-xs font-medium mb-2"
                style={{
                  color: '#cbc3e3'
                }}
              >
                Email Address
              </label>

              <div className="relative">

                <Mail
                  className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4"
                  style={{
                    color: '#a89cc8'
                  }}
                />

                <input
                  type="email"
                  value={email}
                  onChange={(e) =>
                    setEmail(e.target.value)
                  }
                  placeholder="admin@gmail.com"
                  required
                  className="w-full pl-10 pr-4 py-3 rounded-xl text-white text-sm outline-none transition-all"
                  style={{
                    background:
                      'rgba(255,255,255,0.08)',
                    border:
                      '1px solid rgba(203,195,227,0.25)',
                    color: 'white',
                  }}
                />

              </div>

            </div>

            {/* PASSWORD */}
            <div>

              <label
                className="block text-xs font-medium mb-2"
                style={{
                  color: '#cbc3e3'
                }}
              >
                Password
              </label>

              <div className="relative">

                <Lock
                  className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4"
                  style={{
                    color: '#a89cc8'
                  }}
                />

                <input
                  type={
                    showPassword
                      ? 'text'
                      : 'password'
                  }
                  value={password}
                  onChange={(e) =>
                    setPassword(e.target.value)
                  }
                  placeholder="••••••••"
                  required
                  className="w-full pl-10 pr-12 py-3 rounded-xl text-white text-sm outline-none transition-all"
                  style={{
                    background:
                      'rgba(255,255,255,0.08)',
                    border:
                      '1px solid rgba(203,195,227,0.25)',
                    color: 'white',
                  }}
                />

                <button
                  type="button"
                  onClick={() =>
                    setShowPassword(!showPassword)
                  }
                  className="absolute right-3 top-1/2 -translate-y-1/2"
                  style={{
                    color: '#a89cc8'
                  }}
                >

                  {showPassword
                    ? <EyeOff className="w-4 h-4" />
                    : <Eye className="w-4 h-4" />
                  }

                </button>

              </div>

            </div>

            {/* ERROR */}
            {error && (

              <div
                className="rounded-lg px-4 py-3 text-sm"
                style={{
                  background:
                    'rgba(239,68,68,0.15)',
                  border:
                    '1px solid rgba(239,68,68,0.3)',
                  color: '#fca5a5'
                }}
              >
                {error}
              </div>

            )}

            {/* BUTTON */}
            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 rounded-xl font-semibold text-sm transition-all duration-200 disabled:opacity-60"
              style={{
                background:
                  'linear-gradient(135deg, #cbc3e3, #a89cc8)',
                color: '#1a1a2e'
              }}
            >

              {loading
                ? 'Signing in...'
                : 'Sign In'
              }

            </button>

          </form>

        </div>
              
      </div>

    </div>
  );
}