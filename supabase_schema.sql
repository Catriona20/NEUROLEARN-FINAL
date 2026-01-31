-- ==========================================
-- NEUROLEARN SUPABASE DATABASE SCHEMA
-- ==========================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- USERS TABLE
-- ==========================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    age INTEGER NOT NULL CHECK (age >= 3 AND age <= 18),
    class TEXT NOT NULL,
    language TEXT NOT NULL DEFAULT 'English',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only read/update their own data
CREATE POLICY "Users can view own data" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own data" ON users
    FOR UPDATE USING (auth.uid() = id);

-- ==========================================
-- PROFILES TABLE
-- ==========================================
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    onboarding_completed BOOLEAN DEFAULT FALSE,
    screening_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = user_id);

-- ==========================================
-- SCREENING RESULTS TABLE
-- ==========================================
CREATE TABLE screening_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    handwriting_score DECIMAL(3,2) NOT NULL CHECK (handwriting_score >= 0 AND handwriting_score <= 1),
    speech_score DECIMAL(3,2) NOT NULL CHECK (speech_score >= 0 AND speech_score <= 1),
    typing_score DECIMAL(3,2) NOT NULL CHECK (typing_score >= 0 AND typing_score <= 1),
    accuracy DECIMAL(3,2) NOT NULL CHECK (accuracy >= 0 AND accuracy <= 1),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_screening_user_id ON screening_results(user_id);
CREATE INDEX idx_screening_created_at ON screening_results(created_at DESC);

ALTER TABLE screening_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own screening results" ON screening_results
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own screening results" ON screening_results
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ==========================================
-- LEARNING PROGRESS TABLE
-- ==========================================
CREATE TABLE learning_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    stage TEXT NOT NULL DEFAULT 'Foundations',
    level INTEGER NOT NULL DEFAULT 1 CHECK (level >= 1),
    xp INTEGER NOT NULL DEFAULT 0 CHECK (xp >= 0),
    streak INTEGER NOT NULL DEFAULT 0 CHECK (streak >= 0),
    last_active TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

CREATE INDEX idx_learning_progress_user_id ON learning_progress(user_id);

ALTER TABLE learning_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own learning progress" ON learning_progress
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own learning progress" ON learning_progress
    FOR UPDATE USING (auth.uid() = user_id);

-- ==========================================
-- JOURNEY DAYS TABLE
-- ==========================================
CREATE TABLE journey_days (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    day_number INTEGER NOT NULL CHECK (day_number >= 1),
    stage TEXT NOT NULL,
    topic TEXT NOT NULL,
    description TEXT NOT NULL,
    is_unlocked BOOLEAN DEFAULT FALSE,
    is_completed BOOLEAN DEFAULT FALSE,
    total_tasks INTEGER DEFAULT 5,
    completed_tasks INTEGER DEFAULT 0 CHECK (completed_tasks >= 0 AND completed_tasks <= total_tasks),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, day_number)
);

CREATE INDEX idx_journey_user_id ON journey_days(user_id);
CREATE INDEX idx_journey_day_number ON journey_days(day_number);

ALTER TABLE journey_days ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own journey days" ON journey_days
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own journey days" ON journey_days
    FOR UPDATE USING (auth.uid() = user_id);

-- ==========================================
-- ANALYTICS EVENTS TABLE
-- ==========================================
CREATE TABLE analytics_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL,
    event_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_analytics_user_id ON analytics_events(user_id);
CREATE INDEX idx_analytics_event_type ON analytics_events(event_type);
CREATE INDEX idx_analytics_created_at ON analytics_events(created_at DESC);

ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own analytics" ON analytics_events
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own analytics" ON analytics_events
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ==========================================
-- FUNCTIONS & TRIGGERS
-- ==========================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_learning_progress_updated_at BEFORE UPDATE ON learning_progress
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_journey_days_updated_at BEFORE UPDATE ON journey_days
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==========================================
-- STORAGE BUCKETS (Run in Supabase Dashboard)
-- ==========================================

-- Create storage buckets:
-- 1. handwriting-uploads (public)
-- 2. profile-images (public)

-- Storage policies will be configured in Supabase Dashboard

-- ==========================================
-- INDEXES FOR PERFORMANCE
-- ==========================================

CREATE INDEX idx_users_created_at ON users(created_at DESC);
CREATE INDEX idx_profiles_user_id ON profiles(user_id);

-- ==========================================
-- VIEWS FOR ANALYTICS
-- ==========================================

CREATE OR REPLACE VIEW user_stats AS
SELECT 
    u.id,
    u.name,
    u.age,
    p.onboarding_completed,
    p.screening_completed,
    lp.stage,
    lp.level,
    lp.xp,
    lp.streak,
    lp.last_active,
    (SELECT COUNT(*) FROM journey_days jd WHERE jd.user_id = u.id AND jd.is_completed = TRUE) as completed_days,
    (SELECT AVG((sr.handwriting_score + sr.speech_score + sr.typing_score) / 3) 
     FROM screening_results sr WHERE sr.user_id = u.id) as avg_screening_score
FROM users u
LEFT JOIN profiles p ON p.user_id = u.id
LEFT JOIN learning_progress lp ON lp.user_id = u.id;

-- ==========================================
-- SAMPLE DATA (Optional - for testing)
-- ==========================================

-- Uncomment to insert sample data
/*
INSERT INTO users (id, name, age, class, language) VALUES
    ('00000000-0000-0000-0000-000000000001', 'Test User', 8, 'Grade 3', 'English');

INSERT INTO profiles (user_id, onboarding_completed, screening_completed) VALUES
    ('00000000-0000-0000-0000-000000000001', TRUE, TRUE);

INSERT INTO learning_progress (user_id, stage, level, xp, streak) VALUES
    ('00000000-0000-0000-0000-000000000001', 'Foundations', 1, 0, 0);
*/

-- ==========================================
-- NOTES
-- ==========================================

/*
1. Run this schema in your Supabase SQL Editor
2. Create storage buckets in Supabase Dashboard:
   - handwriting-uploads (public read)
   - profile-images (public read)
3. Configure storage policies for user-specific uploads
4. Enable Realtime for tables that need live updates
5. Set up email templates for OTP in Supabase Auth settings
*/
