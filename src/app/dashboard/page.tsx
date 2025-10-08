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
      const { data } = await supabase
        .from('decision_fields')
        .select('*')
        .order('created_at', { ascending: false });
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
          <div>
            <h1 className="text-4xl font-light glow-text mb-2">Decision Fields</h1>
          </div>
          <div className="flex gap-4">
            <button onClick={() => router.push('/create')} className="glass-button glow-coral">
              + New Decision Field
            </button>
            <button onClick={() => router.push('/journal')} className="glass-button">
              Insight Journal
            </button>
            <button onClick={handleSignOut} className="glass-button">
              Sign Out
            </button>
          </div>
        </div>

        {loading ? (
          <div className="flex justify-center">
            <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-quantum-teal"></div>
          </div>
        ) : decisions.length === 0 ? (
          <div className="text-center py-20 glass-card p-12 max-w-2xl mx-auto">
            <h2 className="text-2xl font-light mb-4">No Decision Fields Yet</h2>
            <button onClick={() => router.push('/create')} className="glass-button glow-coral">
              Create Decision Field
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {decisions.map((d) => (
              <div
                key={d.id}
                onClick={() => router.push(`/field/${d.id}`)}
                className="glass-card p-6 cursor-pointer hover:bg-white/10 transition-all"
              >
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
