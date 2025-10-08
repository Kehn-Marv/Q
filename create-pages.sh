#!/bin/bash
cd /tmp/cc-agent/58223313/project

# Auth page
cat > src/app/auth/page.tsx << 'AUTHEOF'
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
AUTHEOF

# Dashboard - simple version
cat > src/app/dashboard/page.tsx << 'DASHEOF'
'use client';
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { supabase, DecisionField } from '@/lib/supabase';
export default function DashboardPage() {
  const router = useRouter();
  const [decisions, setDecisions] = useState<DecisionField[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    checkUser();
    loadDecisions();
  }, []);
  const checkUser = async () => {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) router.push('/auth');
  };
  const loadDecisions = async () => {
    try {
      const { data } = await supabase.from('decision_fields').select('*').order('created_at', { ascending: false });
      setDecisions(data || []);
    } finally {
      setLoading(false);
    }
  };
  const handleSignOut = async () => {
    await supabase.auth.signOut();
    router.push('/');
  };
  return (
    <div className="min-h-screen p-8">
      <div className="max-w-7xl mx-auto">
        <div className="flex justify-between items-center mb-12">
          <div><h1 className="text-4xl font-light glow-text mb-2">Decision Fields</h1></div>
          <div className="flex gap-4">
            <button onClick={() => router.push('/create')} className="glass-button glow-coral">+ New Decision Field</button>
            <button onClick={() => router.push('/journal')} className="glass-button">Insight Journal</button>
            <button onClick={handleSignOut} className="glass-button">Sign Out</button>
          </div>
        </div>
        {loading ? <div className="flex justify-center"><div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-quantum-teal"></div></div> : decisions.length === 0 ? (
          <div className="text-center py-20 glass-card p-12 max-w-2xl mx-auto">
            <h2 className="text-2xl font-light mb-4">No Decision Fields Yet</h2>
            <button onClick={() => router.push('/create')} className="glass-button glow-coral">Create Decision Field</button>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {decisions.map((d) => (
              <div key={d.id} onClick={() => router.push(\`/field/\${d.id}\`)} className="glass-card p-6 cursor-pointer hover:bg-white/10 transition-all">
                <div className="text-xs mb-4">{new Date(d.created_at).toLocaleDateString()}</div>
                <h3 className="text-xl font-medium mb-3">{d.title}</h3>
                <p className="text-sm text-quantum-silver/70 line-clamp-3">{d.description}</p>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
DASHEOF

#  About page
cat > src/app/about/page.tsx << 'ABOUTEOF'
'use client';
import { useRouter } from 'next/navigation';
export default function AboutPage() {
  const router = useRouter();
  return (
    <div className="min-h-screen p-12">
      <div className="max-w-4xl mx-auto">
        <button onClick={() => router.push('/')} className="text-quantum-silver/60 hover:text-quantum-silver mb-8">← Back</button>
        <div className="glass-card p-12 space-y-8">
          <div className="text-center"><h1 className="text-4xl font-light glow-text mb-4">About QIDE</h1><p className="text-xl text-quantum-teal">Where quantum thinking meets human decision-making</p></div>
          <section><h2 className="text-2xl font-light text-quantum-coral mb-4">The Philosophy</h2><p className="text-quantum-silver/80 leading-relaxed">QIDE draws inspiration from quantum mechanics, where particles exist in superposition. We apply this to decisions: every choice exists as a field of probabilistic outcomes until you consciously collapse it into action.</p></section>
          <div className="flex justify-center pt-4"><button onClick={() => router.push('/auth')} className="glass-button glow-coral px-8 py-4 text-lg">Begin Your Journey</button></div>
        </div>
      </div>
    </div>
  );
}
ABOUTEOF

echo "Pages created"
