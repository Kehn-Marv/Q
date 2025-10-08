# QIDE - Quantum-Inspired Decision Engine

**See the unseen possibilities.**

QIDE is a revolutionary decision-making platform that treats every choice as a probabilistic field rather than a binary outcome. Inspired by quantum superposition, it helps leaders and strategists explore multiple potential outcomes simultaneously before collapsing into actionable recommendations.

## 🌌 Core Features

- **Decision Field Creation**: Describe scenarios in natural language
- **Quantum Analysis Engine**: Multi-layered reasoning (logic + intuition + probabilistic simulation)
- **3D Visualization**: Interactive probability fields with floating outcome orbs
- **Field Collapse**: Synthesize outcomes into coherent recommendations
- **Insight Journal**: Track predictions and measure accuracy over time

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ 
- Supabase account

### Installation

1. Install dependencies:
\`\`\`bash
npm install
\`\`\`

2. Configure environment variables:
\`\`\`bash
cp .env.local.example .env.local
\`\`\`

Update with your Supabase credentials:
- \`NEXT_PUBLIC_SUPABASE_URL\`
- \`NEXT_PUBLIC_SUPABASE_ANON_KEY\`

3. Run database migrations (via Supabase dashboard or CLI)

4. Start development server:
\`\`\`bash
npm run dev
\`\`\`

Visit http://localhost:3000

### Production Build

\`\`\`bash
npm run build
npm start
\`\`\`

## 🎨 Design Philosophy

QIDE embodies **calm minimalism meets quantum flow**:

- **Misty silver** base with **teal-gray** gradients
- **Iridescent coral** highlights for key actions
- Translucent **glass-morphism** UI elements
- Subtle **wave interference** background patterns
- Fluid animations mimicking quantum decoherence

## 📊 Tech Stack

- **Frontend**: Next.js 15, React 19, TypeScript
- **Styling**: Tailwind CSS 4, Framer Motion
- **3D**: Three.js, React Three Fiber
- **Database**: Supabase (PostgreSQL)
- **Auth**: Supabase Auth

## 🔐 Database Schema

Key tables:
- `profiles` - User data
- `decision_fields` - Decision scenarios
- `decision_outcomes` - Probabilistic outcomes
- `collapsed_decisions` - Final recommendations
- `insight_journal` - Historical tracking

All tables use Row Level Security for data protection.

## 🧭 User Flow

1. **Home** → Learn about quantum decision-making
2. **Auth** → Sign up/login
3. **Dashboard** → View all decision fields
4. **Create** → Define new decision scenario
5. **Field View** → Explore outcomes, adjust weights
6. **Collapse** → Generate final recommendation
7. **Journal** → Track and reflect on decisions

## 📦 Project Structure

\`\`\`
src/
├── app/                # Next.js app router pages
│   ├── auth/          # Authentication
│   ├── dashboard/     # Decision list
│   ├── create/        # New decision form
│   ├── field/[id]/    # Decision visualization
│   ├── journal/       # Historical insights
│   └── about/         # Philosophy & info
├── components/        # Reusable UI components
└── lib/              # Core utilities
    ├── supabase.ts   # Database client
    └── quantum-engine.ts  # Analysis logic
\`\`\`

## 🔮 Future Enhancements

- Real-time collaborative "Quantum Rooms"
- PDF export of decision briefs
- Voice input via Web Speech API
- AR visualization via WebXR
- Advanced quantum simulation with Qiskit

## 💬 Philosophy

Traditional decision-making forces binary choices. QIDE embraces quantum thinking: **all possibilities exist simultaneously until you choose to observe one**. This reveals non-obvious paths that pure logic misses while maintaining analytical rigor.

## 📄 License

MIT

---

*"The goal is not to mimic existing AI tools. The goal is to craft an interface that feels like a glimpse into the future of thought."*
