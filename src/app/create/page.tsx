'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/lib/supabase';
import { analyzeDecisionField } from '@/lib/quantum-engine';

export default function CreateDecisionPage() {
  const router = useRouter();
  const [user, setUser] = useState<any>(null);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [intuitionWeight, setIntuitionWeight] = useState(0.5);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    supabase.auth.getUser().then(({ data: { user } }) => {
      if (!user) router.push('/auth');
      else setUser(user);
    });
  }, []);

  const handleGenerate = async () => {
    if (!user || !title.trim() || !description.trim()) return;

    setLoading(true);
    try {
      const { data: fieldData, error: fieldError } = await supabase
        .from('decision_fields')
        .insert({
          user_id: user.id,
          title: title.trim(),
          description: description.trim(),
          variables: {},
          status: 'analyzing'
        })
        .select()
        .single();

      if (fieldError) throw fieldError;

      const analysis = await analyzeDecisionField({
        description: description.trim(),
        intuitionWeight
      });

      const outcomesData = analysis.outcomes.map(o => ({
        decision_field_id: fieldData.id,
        ...o
      }));

      await supabase.from('decision_outcomes').insert(outcomesData);
      await supabase.from('decision_fields').update({ status: 'completed' }).eq('id', fieldData.id);

      router.push(`/field/${fieldData.id}`);
    } catch (err) {
      alert('Failed to create decision field');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen p-12">
      <div className="max-w-4xl mx-auto">
        <button onClick={() => router.push('/dashboard')} className="text-quantum-silver/60 hover:text-quantum-silver mb-4">
          ← Back
        </button>
        <h1 className="text-4xl font-light glow-text mb-2">Create Decision Field</h1>
        <p className="text-quantum-silver/70 mb-8">Describe your decision scenario</p>

        <div className="glass-card p-8 space-y-6">
          <div>
            <label className="block text-sm font-medium mb-2">Decision Title</label>
            <input
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              className="w-full px-4 py-3 bg-white/5 border border-quantum-teal/30 rounded-lg focus:outline-none focus:border-quantum-teal/60 text-quantum-silver"
              placeholder="e.g., European Market Expansion"
            />
          </div>

          <div>
            <label className="block text-sm font-medium mb-2">Decision Scenario</label>
            <textarea
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              rows={6}
              className="w-full px-4 py-3 bg-white/5 border border-quantum-teal/30 rounded-lg focus:outline-none focus:border-quantum-teal/60 text-quantum-silver resize-none"
              placeholder="Should we enter the European market next quarter?"
            />
          </div>

          <div>
            <label className="block text-sm font-medium mb-3">Intuition Slider</label>
            <input
              type="range"
              min="0"
              max="1"
              step="0.1"
              value={intuitionWeight}
              onChange={(e) => setIntuitionWeight(parseFloat(e.target.value))}
              className="w-full"
            />
            <div className="text-center text-quantum-coral mt-2">
              {(intuitionWeight * 100).toFixed(0)}% Intuitive
            </div>
          </div>

          <button
            onClick={handleGenerate}
            disabled={loading || !title.trim() || !description.trim()}
            className="w-full glass-button glow-coral py-4 text-lg disabled:opacity-50"
          >
            {loading ? 'Generating...' : 'Generate Decision Field'}
          </button>
        </div>
      </div>
    </div>
  );
}
