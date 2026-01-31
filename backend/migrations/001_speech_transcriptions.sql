-- ============================================
-- Speech Transcriptions Table
-- For storing speech-to-text results
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

-- RLS Policies
CREATE POLICY "Users can view own transcriptions" ON public.speech_transcriptions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own transcriptions" ON public.speech_transcriptions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Service role can insert transcriptions" ON public.speech_transcriptions
  FOR INSERT WITH CHECK (true);

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_speech_transcriptions_user_id 
  ON public.speech_transcriptions(user_id);

CREATE INDEX IF NOT EXISTS idx_speech_transcriptions_created_at 
  ON public.speech_transcriptions(created_at DESC);

-- Auto-update timestamp trigger
CREATE TRIGGER update_speech_transcriptions_updated_at 
  BEFORE UPDATE ON public.speech_transcriptions
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- Run this in Supabase SQL Editor
-- ============================================
