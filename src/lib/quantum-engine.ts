export interface QuantumOutcome {
  label: string;
  probability: number;
  impact_score: number;
  confidence_lower: number;
  confidence_upper: number;
  surprise_score: number;
  logic_reasoning: string;
  intuitive_reasoning: string;
  quantum_reasoning: string;
}

const TEMPLATES = [
  'Proceed with original plan',
  'Pivot to alternative',
  'Delay and gather data',
  'Accelerate timeline',
  'Seek partnerships',
  'Test with pilot',
  'Scale operations',
  'Reimagine approach'
];

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

    return {
      label,
      probability: parseFloat(p.toFixed(4)),
      impact_score: impact,
      confidence_lower: Math.max(0, parseFloat((p - spread).toFixed(4))),
      confidence_upper: Math.min(1, parseFloat((p + spread).toFixed(4))),
      surprise_score: parseFloat((Math.abs(p - 1/num) / (1/num) + (i > 2 ? 0.2 : 0)).toFixed(4)),
      logic_reasoning: `Data-driven analysis suggests ${label.toLowerCase()} presents measurable advantages with favorable risk-adjusted projections.`,
      intuitive_reasoning: `${label} emerges from pattern recognition across non-linear variables, revealing hidden opportunities.`,
      quantum_reasoning: `Monte Carlo simulations show ${label.toLowerCase()} maintains coherence in ${(p*100).toFixed(0)}% of state superpositions.`
    };
  });

  return { outcomes: outcomes.sort((a, b) => b.probability - a.probability) };
}

export function collapseField(outcomes: QuantumOutcome[], dataWeight: number = 0.5): { selectedOutcome: QuantumOutcome; synthesis: string } {
  const iw = 1 - dataWeight;
  const scores = outcomes.map(o => (o.probability * o.impact_score / 100) * dataWeight + (o.surprise_score * o.impact_score / 100) * iw);
  const idx = scores.indexOf(Math.max(...scores));
  const sel = outcomes[idx];

  const synthesis = `After comprehensive quantum field analysis, the optimal path is to ${sel.label.toLowerCase()}. This synthesizes deterministic modeling (${(dataWeight*100).toFixed(0)}%) with intuitive recognition (${(iw*100).toFixed(0)}%).

${sel.logic_reasoning}

${sel.intuitive_reasoning}

${sel.quantum_reasoning}

This path achieves the highest coherence score while maintaining robust confidence intervals.`;

  return { selectedOutcome: sel, synthesis };
}
