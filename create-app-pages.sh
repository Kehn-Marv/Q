#!/bin/bash
cd /tmp/cc-agent/58223313/project

# Create page
cat > src/app/create/page.tsx << 'CREATEEOF'
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
    supabase.auth.getUser().then(({ data: { user } }) => { if (!user) router.push('/auth'); else setUser(user); });
  }, []);
  const handleGenerate = async () => {
    if (!user || !title.trim() || !description.trim()) return;
    setLoading(true);
    try {
      const { data: fieldData, error: fieldError } = await supabase.from('decision_fields').insert({ user_id: user.id, title: title.trim(), description: description.trim(), variables: {}, status: 'analyzing' }).select().single();
      if (fieldError) throw fieldError;
      const analysis = await analyzeDecisionField({ description: description.trim(), intuitionWeight });
      const outcomesData = analysis.outcomes.map(o => ({ decision_field_id: fieldData.id, ...o }));
      await supabase.from('decision_outcomes').insert(outcomesData);
      await supabase.from('decision_fields').update({ status: 'completed' }).eq('id', fieldData.id);
      router.push(\`/field/\${fieldData.id}\`);
    } catch (err) {
      alert('Failed to create decision field');
    } finally {
      setLoading(false);
    }
  };
  return (
    <div className="min-h-screen p-12">
      <div className="max-w-4xl mx-auto">
        <button onClick={() => router.push('/dashboard')} className="text-quantum-silver/60 hover:text-quantum-silver mb-4">← Back</button>
        <h1 className="text-4xl font-light glow-text mb-2">Create Decision Field</h1>
        <p className="text-quantum-silver/70 mb-8">Describe your decision scenario</p>
        <div className="glass-card p-8 space-y-6">
          <div>
            <label className="block text-sm font-medium mb-2">Decision Title</label>
            <input type="text" value={title} onChange={(e) => setTitle(e.target.value)} className="w-full px-4 py-3 bg-white/5 border border-quantum-teal/30 rounded-lg focus:outline-none focus:border-quantum-teal/60 text-quantum-silver" placeholder="e.g., European Market Expansion" />
          </div>
          <div>
            <label className="block text-sm font-medium mb-2">Decision Scenario</label>
            <textarea value={description} onChange={(e) => setDescription(e.target.value)} rows={6} className="w-full px-4 py-3 bg-white/5 border border-quantum-teal/30 rounded-lg focus:outline-none focus:border-quantum-teal/60 text-quantum-silver resize-none" placeholder="Should we enter the European market next quarter?" />
          </div>
          <div>
            <label className="block text-sm font-medium mb-3">Intuition Slider</label>
            <input type="range" min="0" max="1" step="0.1" value={intuitionWeight} onChange={(e) => setIntuitionWeight(parseFloat(e.target.value))} className="w-full" />
            <div className="text-center text-quantum-coral mt-2">{(intuitionWeight * 100).toFixed(0)}% Intuitive</div>
          </div>
          <button onClick={handleGenerate} disabled={loading || !title.trim() || !description.trim()} className="w-full glass-button glow-coral py-4 text-lg disabled:opacity-50">{loading ? 'Generating...' : 'Generate Decision Field'}</button>
        </div>
      </div>
    </div>
  );
}
CREATEEOF

# Field page - simplified
cat > src/app/field/\[id\]/page.tsx << 'FIELDEOF'
'use client';
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { supabase, DecisionField, DecisionOutcome, CollapsedDecision } from '@/lib/supabase';
import { collapseField } from '@/lib/quantum-engine';
export default function FieldPage({ params }: { params: Promise<{ id: string }> }) {
  const router = useRouter();
  const [field, setField] = useState<DecisionField | null>(null);
  const [outcomes, setOutcomes] = useState<DecisionOutcome[]>([]);
  const [collapsed, setCollapsed] = useState<CollapsedDecision | null>(null);
  const [loading, setLoading] = useState(true);
  const [collapsing, setCollapsing] = useState(false);
  const [dataWeight, setDataWeight] = useState(0.5);
  useEffect(() => {
    params.then(p => loadFieldData(p.id));
  }, []);
  const loadFieldData = async (id: string) => {
    try {
      const { data: fieldData } = await supabase.from('decision_fields').select('*').eq('id', id).single();
      setField(fieldData);
      const { data: outcomesData } = await supabase.from('decision_outcomes').select('*').eq('decision_field_id', id).order('probability', { ascending: false });
      setOutcomes(outcomesData || []);
      const { data: collapsedData } = await supabase.from('collapsed_decisions').select('*').eq('decision_field_id', id).maybeSingle();
      setCollapsed(collapsedData);
    } finally {
      setLoading(false);
    }
  };
  const handleCollapse = async () => {
    if (!field) return;
    setCollapsing(true);
    await new Promise(r => setTimeout(r, 2000));
    const qOutcomes = outcomes.map(o => ({ ...o, logic_reasoning: o.logic_reasoning || '', intuitive_reasoning: o.intuitive_reasoning || '', quantum_reasoning: o.quantum_reasoning || '' }));
    const result = collapseField(qOutcomes, dataWeight);
    const selectedOutcome = outcomes.find(o => o.label === result.selectedOutcome.label);
    const { data } = await supabase.from('collapsed_decisions').insert({ decision_field_id: field.id, selected_outcome_id: selectedOutcome?.id, synthesis: result.synthesis, data_weight: dataWeight, intuition_weight: 1 - dataWeight }).select().single();
    setCollapsed(data);
    setCollapsing(false);
  };
  if (loading) return <div className="min-h-screen flex items-center justify-center"><div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-quantum-teal"></div></div>;
  if (!field) return <div className="min-h-screen flex items-center justify-center"><div className="text-center"><p className="text-xl mb-4">Decision field not found</p><button onClick={() => router.push('/dashboard')} className="glass-button">Back</button></div></div>;
  return (
    <div className="min-h-screen p-12">
      <div className="max-w-7xl mx-auto">
        <button onClick={() => router.push('/dashboard')} className="text-quantum-silver/60 hover:text-quantum-silver mb-4">← Back</button>
        <h1 className="text-4xl font-light glow-text mb-2">{field.title}</h1>
        <p className="text-quantum-silver/70 mb-8">{field.description}</p>
        {!collapsed ? (
          <>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
              {outcomes.map((o) => (
                <div key={o.id} className="glass-card p-6">
                  <h3 className="text-lg font-medium mb-3">{o.label}</h3>
                  <div className="space-y-2 mb-4">
                    <div className="flex justify-between text-sm"><span className="text-quantum-silver/70">Probability</span><span className="text-quantum-coral font-medium">{(o.probability * 100).toFixed(1)}%</span></div>
                    <div className="flex justify-between text-sm"><span className="text-quantum-silver/70">Impact</span><span className="text-quantum-teal font-medium">{o.impact_score}/100</span></div>
                    <div className="flex justify-between text-sm"><span className="text-quantum-silver/70">Surprise</span><span className="font-medium">{(o.surprise_score * 100).toFixed(0)}%</span></div>
                  </div>
                </div>
              ))}
            </div>
            <div className="glass-card p-8">
              <h2 className="text-2xl font-light mb-4">Collapse the Field</h2>
              <div className="mb-6">
                <label className="block text-sm font-medium mb-3">Analysis Weight</label>
                <input type="range" min="0" max="1" step="0.1" value={dataWeight} onChange={(e) => setDataWeight(parseFloat(e.target.value))} className="w-full" />
                <div className="text-center text-quantum-coral mt-2">{(dataWeight * 100).toFixed(0)}% Data-Driven</div>
              </div>
              <button onClick={handleCollapse} disabled={collapsing} className="w-full glass-button glow-coral py-4 text-lg disabled:opacity-50">{collapsing ? 'Collapsing...' : 'Collapse the Field'}</button>
            </div>
          </>
        ) : (
          <div className="glass-card p-8">
            <div className="text-center mb-8"><h2 className="text-3xl font-light glow-text mb-2">Field Collapsed</h2></div>
            <div className="bg-quantum-teal/10 border border-quantum-teal/30 rounded-xl p-6 mb-8">
              <p className="text-quantum-silver whitespace-pre-line leading-relaxed">{collapsed.synthesis}</p>
            </div>
            <button onClick={() => router.push('/journal')} className="glass-button glow-coral">Journal This Decision</button>
          </div>
        )}
      </div>
    </div>
  );
}
FIELDEOF

# Journal page - simplified
cat > src/app/journal/page.tsx << 'JOURNALEOF'
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
JOURNALEOF

echo "App pages created"
