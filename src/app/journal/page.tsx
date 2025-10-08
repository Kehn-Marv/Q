'use client';
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/lib/supabase';
export default function JournalPage() {
  const router = useRouter();
  const [entries, setEntries] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    loadJournal();
  }, []);
  const loadJournal = async () => {
    try {
      const { data } = await supabase.from('insight_journal').select('*, decision_field:decision_fields(*)').order('created_at', { ascending: false });
      setEntries(data || []);
    } finally {
      setLoading(false);
    }
  };
  return (
    <div className="min-h-screen p-12">
      <div className="max-w-6xl mx-auto">
        <button onClick={() => router.push('/dashboard')} className="text-quantum-silver/60 hover:text-quantum-silver mb-4">← Back</button>
        <h1 className="text-4xl font-light glow-text mb-12">Insight Journal</h1>
        {loading ? <div className="flex justify-center"><div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-quantum-teal"></div></div> : entries.length === 0 ? (
          <div className="text-center py-20 glass-card p-12 max-w-2xl mx-auto">
            <h2 className="text-2xl font-light mb-4">No Journal Entries Yet</h2>
            <button onClick={() => router.push('/dashboard')} className="glass-button glow-coral">View Decision Fields</button>
          </div>
        ) : (
          <div className="space-y-6">
            {entries.map((entry) => (
              <div key={entry.id} className="glass-card p-6">
                <h3 className="text-xl font-medium mb-2">{entry.decision_field?.title}</h3>
                <p className="text-sm text-quantum-silver/70">{entry.decision_field?.description}</p>
                <div className="text-xs text-quantum-silver/50 mt-2">Logged: {new Date(entry.created_at).toLocaleDateString()}</div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
