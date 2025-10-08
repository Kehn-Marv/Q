import './globals.css';
export const metadata = { title: 'QIDE - Quantum-Inspired Decision Engine', description: 'Decision-making reimagined through quantum logic' };
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return <html lang="en"><body className="antialiased bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950 text-quantum-silver min-h-screen">{children}</body></html>;
}
