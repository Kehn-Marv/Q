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
