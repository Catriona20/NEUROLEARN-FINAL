-- ============================================
-- NeuroLearn Supabase Database Setup
-- ============================================
-- Run this script in your Supabase SQL Editor
-- Dashboard > SQL Editor > New Query > Paste & Run
-- ============================================

-- Enable UUID extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. USERS TABLE (extends auth.users)
-- ============================================
-- This table stores additional user profile information
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Users can only read/update their own data
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- ============================================
-- 2. PROFILES TABLE
-- ============================================
-- Stores user profile setup and screening status
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  age INTEGER,
  grade TEXT,
  screening_completed BOOLEAN DEFAULT FALSE,
  profile_setup_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================
-- 3. SCREENING RESULTS TABLE
-- ============================================
-- Stores screening test results
CREATE TABLE IF NOT EXISTS public.screening_results (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  handwriting_score DECIMAL(5,2) DEFAULT 0,
  speech_score DECIMAL(5,2) DEFAULT 0,
  typing_score DECIMAL(5,2) DEFAULT 0,
  accuracy DECIMAL(5,2) DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.screening_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own screening results" ON public.screening_results
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own screening results" ON public.screening_results
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================
-- 4. LEARNING PROGRESS TABLE
-- ============================================
-- Tracks overall user progress (Level, XP, Streak)
CREATE TABLE IF NOT EXISTS public.learning_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  level INTEGER DEFAULT 1,
  xp INTEGER DEFAULT 0,
  streak INTEGER DEFAULT 0,
  stage TEXT DEFAULT 'Foundations',
  last_active TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Enable Row Level Security
ALTER TABLE public.learning_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own learning progress" ON public.learning_progress
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own learning progress" ON public.learning_progress
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own learning progress" ON public.learning_progress
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================
-- 5. JOURNEY DAYS TABLE
-- ============================================
-- Tracks individual level/day progress
CREATE TABLE IF NOT EXISTS public.journey_days (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  day_number INTEGER NOT NULL,
  stage TEXT,
  topic TEXT,
  description TEXT,
  is_unlocked BOOLEAN DEFAULT FALSE,
  is_completed BOOLEAN DEFAULT FALSE,
  total_tasks INTEGER DEFAULT 3,
  completed_tasks INTEGER DEFAULT 0,
  stars_earned INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, day_number)
);

-- Enable Row Level Security
ALTER TABLE public.journey_days ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own journey days" ON public.journey_days
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own journey days" ON public.journey_days
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own journey days" ON public.journey_days
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================
-- 6. FUNCTION: Auto-create user profile on signup
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert into users table
  INSERT INTO public.users (id, email, full_name)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name');
  
  -- Insert into learning_progress table with defaults
  INSERT INTO public.learning_progress (user_id, level, xp, streak, stage)
  VALUES (NEW.id, 1, 0, 0, 'Foundations');
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- 7. FUNCTION: Update timestamp on row update
-- ============================================
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_learning_progress_updated_at BEFORE UPDATE ON public.learning_progress
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_journey_days_updated_at BEFORE UPDATE ON public.journey_days
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- 8. INDEXES for Performance
-- ============================================
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON public.profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_screening_results_user_id ON public.screening_results(user_id);
CREATE INDEX IF NOT EXISTS idx_learning_progress_user_id ON public.learning_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_journey_days_user_id ON public.journey_days(user_id);
CREATE INDEX IF NOT EXISTS idx_journey_days_day_number ON public.journey_days(day_number);

-- ============================================
-- 9. SAMPLE DATA (Optional - for testing)
-- ============================================
-- Uncomment to insert sample journey days for a test user
-- Replace 'YOUR_USER_ID' with an actual user UUID

/*
INSERT INTO public.journey_days (user_id, day_number, stage, topic, description, is_unlocked, is_completed)
VALUES 
  ('YOUR_USER_ID', 1, 'Foundations', 'The Sorting Hat', 'Begin your magical journey', TRUE, FALSE),
  ('YOUR_USER_ID', 2, 'Foundations', 'Wand Selection', 'Choose your learning wand', TRUE, FALSE),
  ('YOUR_USER_ID', 3, 'Foundations', 'First Potions Class', 'Mix your first potion', TRUE, FALSE),
  ('YOUR_USER_ID', 4, 'Foundations', 'Charms Practice', 'Learn basic charms', TRUE, FALSE),
  ('YOUR_USER_ID', 5, 'Foundations', 'Defense Against Dark Arts', 'Protect yourself', TRUE, FALSE),
  ('YOUR_USER_ID', 6, 'Intermediate', 'Herbology Garden', 'Study magical plants', TRUE, FALSE),
  ('YOUR_USER_ID', 7, 'Intermediate', 'Transfiguration Magic', 'Transform objects', TRUE, FALSE),
  ('YOUR_USER_ID', 8, 'Intermediate', 'Quidditch Training', 'Fly on a broomstick', TRUE, FALSE),
  ('YOUR_USER_ID', 9, 'Advanced', 'Ancient Runes', 'Decode magical symbols', TRUE, FALSE),
  ('YOUR_USER_ID', 10, 'Advanced', 'Patronus Charm', 'Summon your Patronus', TRUE, FALSE),
  ('YOUR_USER_ID', 11, 'Advanced', 'Forbidden Forest', 'Explore the forest', TRUE, FALSE),
  ('YOUR_USER_ID', 12, 'Master', 'Chamber of Secrets', 'Final challenge', FALSE, FALSE);
*/

-- ============================================
-- SETUP COMPLETE! 🎉
-- ============================================
-- Next steps:
-- 1. Run this script in Supabase SQL Editor
-- 2. Verify tables in Table Editor
-- 3. Test your Flutter app
-- ============================================
