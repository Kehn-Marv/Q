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
