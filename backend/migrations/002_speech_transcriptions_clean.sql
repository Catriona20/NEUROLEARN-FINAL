-- ============================================
-- SPEECH TRANSCRIPTIONS TABLE ONLY
-- Run this separately - no conflicts
-- ============================================

-- Create speech_transcriptions table
CREATE TABLE IF NOT EXISTS public.speech_transcriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  transcription TEXT NOT NULL,
  confidence DECIMAL(5,4) DEFAULT 0,
  audio_filename TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.speech_transcriptions ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view own transcriptions" ON public.speech_transcriptions;
DROP POLICY IF EXISTS "Users can insert own transcriptions" ON public.speech_transcriptions;
DROP POLICY IF EXISTS "Service role can insert transcriptions" ON public.speech_transcriptions;

-- Create RLS Policies
CREATE POLICY "Users can view own transcriptions" ON public.speech_transcriptions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own transcriptions" ON public.speech_transcriptions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Service role can insert transcriptions" ON public.speech_transcriptions
  FOR INSERT WITH CHECK (true);

-- Create indexes for performance
DROP INDEX IF EXISTS idx_speech_transcriptions_user_id;
DROP INDEX IF EXISTS idx_speech_transcriptions_created_at;

CREATE INDEX idx_speech_transcriptions_user_id 
  ON public.speech_transcriptions(user_id);

CREATE INDEX idx_speech_transcriptions_created_at 
  ON public.speech_transcriptions(created_at DESC);

-- Auto-update timestamp trigger
DROP TRIGGER IF EXISTS update_speech_transcriptions_updated_at ON public.speech_transcriptions;

CREATE TRIGGER update_speech_transcriptions_updated_at 
  BEFORE UPDATE ON public.speech_transcriptions
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- SUCCESS! Table created.
-- ============================================
