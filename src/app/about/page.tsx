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
