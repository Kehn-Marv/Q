#!/bin/bash
cd /tmp/cc-agent/58223313/project

# Supabase client
cat > src/lib/supabase.ts << 'LIBEOF'
import { createClient } from '@supabase/supabase-js';
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
export const supabase = createClient(supabaseUrl, supabaseAnonKey);
export type Profile = { id: string; email: string; full_name?: string; created_at: string; updated_at: string; };
export type DecisionField = { id: string; user_id: string; title: string; description: string; variables: Record<string, any>; status: 'draft' | 'analyzing' | 'completed' | 'archived'; created_at: string; updated_at: string; };
export type DecisionOutcome = { id: string; decision_field_id: string; label: string; probability: number; impact_score: number; confidence_lower: number; confidence_upper: number; surprise_score: number; logic_reasoning?: string; intuitive_reasoning?: string; quantum_reasoning?: string; created_at: string; };
export type CollapsedDecision = { id: string; decision_field_id: string; selected_outcome_id?: string; synthesis: string; data_weight: number; intuition_weight: number; collapsed_at: string; };
export type InsightJournal = { id: string; decision_field_id: string; user_id: string; actual_outcome?: string; accuracy_score?: number; notes?: string; created_at: string; updated_at: string; };
LIBEOF

# Quantum engine - simplified
cat > src/lib/quantum-engine.ts << 'QEOF'
export interface QuantumOutcome { label: string; probability: number; impact_score: number; confidence_lower: number; confidence_upper: number; surprise_score: number; logic_reasoning: string; intuitive_reasoning: string; quantum_reasoning: string; }
const TEMPLATES = ['Proceed with original plan', 'Pivot to alternative', 'Delay and gather data', 'Accelerate timeline', 'Seek partnerships', 'Test with pilot', 'Scale operations', 'Reimagine approach'];
export async function analyzeDecisionField(input: { description: string; intuitionWeight?: number }): Promise<{ outcomes: QuantumOutcome[] }> {
  await new Promise(r => setTimeout(r, 1500));
  const iw = input.intuitionWeight ?? 0.5;
  const num = Math.min(Math.max(4, Math.floor(input.description.split(' ').length / 15)), 8);
  const labels = TEMPLATES.sort(() => Math.random() - 0.5).slice(0, num);
  const raw = Array.from({ length: num }, () => Math.random());
  if (iw > 0.5) raw[Math.floor(Math.random() * num)] *= 2;
  const total = raw.reduce((s, v) => s + v, 0);
  const probs = raw.map(v => v / total);
  const outcomes: QuantumOutcome[] = labels.map((label, i) => {
    const p = probs[i];
    const impact = Math.min(Math.floor(40 + p * 60 + Math.random() * 20), 100);
    const spread = 0.05 + Math.random() * 0.1;
    return { label, probability: parseFloat(p.toFixed(4)), impact_score: impact, confidence_lower: Math.max(0, parseFloat((p - spread).toFixed(4))), confidence_upper: Math.min(1, parseFloat((p + spread).toFixed(4))), surprise_score: parseFloat((Math.abs(p - 1/num) / (1/num) + (i > 2 ? 0.2 : 0)).toFixed(4)), logic_reasoning: \`Data-driven analysis suggests \${label.toLowerCase()} presents measurable advantages with favorable risk-adjusted projections.\`, intuitive_reasoning: \`\${label} emerges from pattern recognition across non-linear variables, revealing hidden opportunities.\`, quantum_reasoning: \`Monte Carlo simulations show \${label.toLowerCase()} maintains coherence in \${(p*100).toFixed(0)}% of state superpositions.\` };
  });
  return { outcomes: outcomes.sort((a, b) => b.probability - a.probability) };
}
export function collapseField(outcomes: QuantumOutcome[], dataWeight: number = 0.5): { selectedOutcome: QuantumOutcome; synthesis: string } {
  const iw = 1 - dataWeight;
  const scores = outcomes.map(o => (o.probability * o.impact_score / 100) * dataWeight + (o.surprise_score * o.impact_score / 100) * iw);
  const idx = scores.indexOf(Math.max(...scores));
  const sel = outcomes[idx];
  return { selectedOutcome: sel, synthesis: \`After comprehensive quantum field analysis, the optimal path is to \${sel.label.toLowerCase()}. This synthesizes deterministic modeling (\${(dataWeight*100).toFixed(0)}%) with intuitive recognition (\${(iw*100).toFixed(0)}%).\n\n\${sel.logic_reasoning}\n\n\${sel.intuitive_reasoning}\n\n\${sel.quantum_reasoning}\n\nThis path achieves the highest coherence score while maintaining robust confidence intervals.\` };
}
QEOF

# Layout
cat > src/app/layout.tsx << 'LAYEOF'
import './globals.css';
export const metadata = { title: 'QIDE - Quantum-Inspired Decision Engine', description: 'Decision-making reimagined through quantum logic' };
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return <html lang="en"><body className="antialiased bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950 text-quantum-silver min-h-screen">{children}</body></html>;
}
LAYEOF

# Home page - simplified
cat > src/app/page.tsx << 'PGEOF'
'use client';
import { useRouter } from 'next/navigation';
export default function HomePage() {
  const router = useRouter();
  return (
    <div className="relative min-h-screen flex flex-col items-center justify-center px-6">
      <div className="text-center">
        <h1 className="text-7xl font-light mb-6 glow-text">QIDE</h1>
        <p className="text-3xl font-light text-quantum-teal mb-4">Quantum-Inspired Decision Engine</p>
        <p className="text-2xl text-quantum-silver/80 mb-12">Decision-making, reimagined through quantum logic.<br/><span className="text-quantum-coral">See the unseen possibilities.</span></p>
        <div className="flex gap-4 justify-center">
          <button onClick={() => router.push('/auth')} className="glass-button glow-coral px-8 py-4 text-lg">Create a Decision Field</button>
          <button onClick={() => router.push('/about')} className="glass-button px-8 py-4 text-lg">Learn More</button>
        </div>
      </div>
    </div>
  );
}
PGEOF

echo "Core files created successfully"
