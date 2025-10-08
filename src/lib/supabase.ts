import { createClient } from '@supabase/supabase-js';
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
export const supabase = createClient(supabaseUrl, supabaseAnonKey);
export type Profile = { id: string; email: string; full_name?: string; created_at: string; updated_at: string; };
export type DecisionField = { id: string; user_id: string; title: string; description: string; variables: Record<string, any>; status: 'draft' | 'analyzing' | 'completed' | 'archived'; created_at: string; updated_at: string; };
export type DecisionOutcome = { id: string; decision_field_id: string; label: string; probability: number; impact_score: number; confidence_lower: number; confidence_upper: number; surprise_score: number; logic_reasoning?: string; intuitive_reasoning?: string; quantum_reasoning?: string; created_at: string; };
export type CollapsedDecision = { id: string; decision_field_id: string; selected_outcome_id?: string; synthesis: string; data_weight: number; intuition_weight: number; collapsed_at: string; };
export type InsightJournal = { id: string; decision_field_id: string; user_id: string; actual_outcome?: string; accuracy_score?: number; notes?: string; created_at: string; updated_at: string; };
