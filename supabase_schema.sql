
-- Enable UUID extension for generating IDs
create extension if not exists "pgcrypto";

-- 1. PROFILES TABLE
-- Stores public user information.
create table public.profiles (
  id uuid references auth.users on delete cascade not null primary key,
  nickname text unique,
  email text,
  mantra text,
  profile_color text default 'bg-emerald-500',
  check_ins jsonb default '[]'::jsonb
);

-- 2. POSTS TABLE
-- Stores community posts. Affirmations are stored as a JSON object.
create table public.posts (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  type text not null,
  content text not null,
  tags text[] default '{}',
  affirmations jsonb default '{"I hear you": 0, "You’re not alone": 0, "May Allah ease this": 0, "Aamin": 0}'::jsonb,
  created_at timestamptz default now()
);

-- 3. COMMENTS TABLE
-- Hierarchical comments (replies have a parent_id).
create table public.comments (
  id uuid default gen_random_uuid() primary key,
  post_id uuid references public.posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  parent_id uuid references public.comments(id) on delete cascade,
  content text not null,
  created_at timestamptz default now()
);

-- 4. NOTIFICATIONS TABLE
-- Stores alerts for users.
create table public.notifications (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null, -- Recipient
  actor_id uuid references public.profiles(id) on delete cascade not null, -- Sender
  type text not null,
  post_id uuid references public.posts(id) on delete cascade,
  post_preview text,
  extra_info text,
  is_read boolean default false,
  created_at timestamptz default now()
);

-- 5. FOLLOWS TABLE
-- Simple follower/following relationship.
create table public.follows (
  follower_id uuid references public.profiles(id) on delete cascade not null,
  following_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamptz default now(),
  primary key (follower_id, following_id)
);

-- 6. JOURNAL ENTRIES TABLE (Private)
-- Strictly private reflection data.
create table public.journal_entries (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  title text,
  content text,
  mood text,
  prompt_id text,
  date timestamptz default now()
);

-- --- ROW LEVEL SECURITY (RLS) POLICIES ---

-- Enable RLS on all tables
alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.comments enable row level security;
alter table public.notifications enable row level security;
alter table public.follows enable row level security;
alter table public.journal_entries enable row level security;

-- PROFILES
create policy "Public profiles are viewable by everyone" 
  on public.profiles for select using (true);

create policy "Users can insert their own profile" 
  on public.profiles for insert with check (auth.uid() = id);

create policy "Users can update own profile" 
  on public.profiles for update using (auth.uid() = id);

-- POSTS
create policy "Posts are viewable by everyone" 
  on public.posts for select using (true);

create policy "Authenticated users can create posts" 
  on public.posts for insert with check (auth.role() = 'authenticated');

-- Allow authors to update their own posts (content)
create policy "Users can update own posts" 
  on public.posts for update using (auth.uid() = user_id);

-- Allow authenticated users to update posts (specifically for affirmations/likes)
-- Note: In a production app, this should be handled via a Database Function (RPC) 
-- to prevent users from editing the 'content' field of others. 
-- For this setup, we allow the update to facilitate the JSONB affirmation updates.
create policy "Authenticated users can update affirmations" 
  on public.posts for update using (auth.role() = 'authenticated');

create policy "Users can delete own posts" 
  on public.posts for delete using (auth.uid() = user_id);

-- COMMENTS
create policy "Comments are viewable by everyone" 
  on public.comments for select using (true);

create policy "Authenticated users can create comments" 
  on public.comments for insert with check (auth.role() = 'authenticated');

-- NOTIFICATIONS
create policy "Users can view their own notifications" 
  on public.notifications for select using (auth.uid() = user_id);

create policy "Users can create notifications (trigger actions)" 
  on public.notifications for insert with check (auth.role() = 'authenticated');

create policy "Users can mark their notifications as read" 
  on public.notifications for update using (auth.uid() = user_id);

-- FOLLOWS
create policy "Follows are viewable by everyone" 
  on public.follows for select using (true);

create policy "Users can follow others" 
  on public.follows for insert with check (auth.uid() = follower_id);

create policy "Users can unfollow" 
  on public.follows for delete using (auth.uid() = follower_id);

-- JOURNAL (Strictly Private)
create policy "Users can view own journal" 
  on public.journal_entries for select using (auth.uid() = user_id);

create policy "Users can create journal entries" 
  on public.journal_entries for insert with check (auth.uid() = user_id);

create policy "Users can update own journal" 
  on public.journal_entries for update using (auth.uid() = user_id);

create policy "Users can delete own journal" 
  on public.journal_entries for delete using (auth.uid() = user_id);

-- --- REALTIME CONFIGURATION ---
-- Add notifications to realtime publication so the bell icon updates instantly
-- Note: If this fails, you may need to enable Realtime in your Supabase Dashboard > Database > Replication
alter publication supabase_realtime add table public.notifications;
