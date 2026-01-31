-- Enable UUID usage
create extension if not exists "uuid-ossp";

-- 1. USERS TABLE (General User Info)
create table public.users (
  id uuid references auth.users not null primary key,
  name text,
  age int,
  class text,
  language text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. PROFILES (Status Flags)
create table public.profiles (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) on delete cascade not null,
  onboarding_completed boolean default false,
  screening_completed boolean default false,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. LEARNING PROGRESS
create table public.learning_progress (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) on delete cascade not null,
  stage text default 'Foundations',
  level int default 1,
  xp int default 0,
  streak int default 0,
  last_active timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 4. SCREENING RESULTS
create table public.screening_results (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) on delete cascade not null,
  handwriting_score double precision,
  speech_score double precision,
  typing_score double precision,
  accuracy double precision,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 5. JOURNEY DAYS
create table public.journey_days (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) on delete cascade not null,
  day_number int not null,
  stage text,
  topic text,
  description text,
  is_unlocked boolean default false,
  is_completed boolean default false,
  total_tasks int default 0,
  completed_tasks int default 0,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 6. ANALYTICS EVENTS
create table public.analytics_events (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) on delete cascade not null,
  event_type text not null,
  event_data jsonb,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- SECURITY POLICIES (Row Level Security)
alter table public.users enable row level security;
alter table public.profiles enable row level security;
alter table public.learning_progress enable row level security;
alter table public.screening_results enable row level security;
alter table public.journey_days enable row level security;
alter table public.analytics_events enable row level security;

-- Policy: Users can only see/edit their own data
create policy "Users can view own data" on public.users for select using (auth.uid() = id);
create policy "Users can insert own data" on public.users for insert with check (auth.uid() = id);
create policy "Users can update own data" on public.users for update using (auth.uid() = id);

create policy "Users can view own profiles" on public.profiles for select using (auth.uid() = user_id);
create policy "Users can insert own profiles" on public.profiles for insert with check (auth.uid() = user_id);
create policy "Users can update own profiles" on public.profiles for update using (auth.uid() = user_id);

create policy "Users can view own progress" on public.learning_progress for select using (auth.uid() = user_id);
create policy "Users can insert own progress" on public.learning_progress for insert with check (auth.uid() = user_id);
create policy "Users can update own progress" on public.learning_progress for update using (auth.uid() = user_id);

-- (Simplified Policies for others)
create policy "Users own screening" on public.screening_results for all using (auth.uid() = user_id);
create policy "Users own journey" on public.journey_days for all using (auth.uid() = user_id);
create policy "Users own analytics" on public.analytics_events for all using (auth.uid() = user_id);

-- Allow Public Read for Authenticated Users (Optional, usually safer to stick to strict RLS but debugging is easier with this)
-- For now, strict RLS above is safest.
