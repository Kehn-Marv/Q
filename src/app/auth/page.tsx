'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/lib/supabase';
export default function AuthPage() {
  const router = useRouter();
  const [isSignUp, setIsSignUp] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const handleAuth = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      if (isSignUp) {
        const { data, error: err } = await supabase.auth.signUp({ email, password });
        if (err) throw err;
        if (data.user) await supabase.from('profiles').insert({ id: data.user.id, email: data.user.email! });
        router.push('/dashboard');
      } else {
        const { error: err } = await supabase.auth.signInWithPassword({ email, password });
        if (err) throw err;
        router.push('/dashboard');
      }
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };
  return (
    <div className="relative min-h-screen flex items-center justify-center px-6">
      <div className="w-full max-w-md glass-card p-8">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-light mb-2 glow-text">{isSignUp ? 'Create Account' : 'Welcome Back'}</h1>
        </div>
        <form onSubmit={handleAuth} className="space-y-5">
          <div>
            <label className="block text-sm font-medium mb-2">Email</label>
            <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required className="w-full px-4 py-3 bg-white/5 border border-quantum-teal/30 rounded-lg focus:outline-none focus:border-quantum-teal/60 transition-colors text-quantum-silver" placeholder="your@email.com" />
          </div>
          <div>
            <label className="block text-sm font-medium mb-2">Password</label>
            <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} required className="w-full px-4 py-3 bg-white/5 border border-quantum-teal/30 rounded-lg focus:outline-none focus:border-quantum-teal/60 transition-colors text-quantum-silver" placeholder="••••••••" />
          </div>
          {error && <div className="p-3 bg-red-500/10 border border-red-500/30 rounded-lg text-red-400 text-sm">{error}</div>}
          <button type="submit" disabled={loading} className="w-full glass-button glow-coral py-3 font-medium disabled:opacity-50">{loading ? 'Processing...' : isSignUp ? 'Create Account' : 'Sign In'}</button>
        </form>
        <div className="mt-6 text-center">
          <button onClick={() => { setIsSignUp(!isSignUp); setError(''); }} className="text-quantum-teal hover:text-quantum-coral transition-colors text-sm">{isSignUp ? 'Already have an account? Sign in' : "Don't have an account? Sign up"}</button>
        </div>
        <div className="text-center mt-6">
          <button onClick={() => router.push('/')} className="text-quantum-silver/60 hover:text-quantum-silver transition-colors text-sm">← Back to Home</button>
        </div>
      </div>
    </div>
  );
}
