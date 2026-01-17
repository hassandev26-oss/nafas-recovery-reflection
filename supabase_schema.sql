
-- Enable UUID extension for generating IDs
create extension if not exists "pgcrypto";

-- 1. PROFILES TABLE
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade not null primary key,
  nickname text unique,
  email text,
  mantra text,
  profile_color text default 'bg-emerald-500',
  role text default 'user', -- 'user' or 'moderator'
  check_ins jsonb default '[]'::jsonb
);

-- 2. POSTS TABLE
create table if not exists public.posts (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  type text not null,
  content text not null,
  tags text[] default '{}',
  affirmations jsonb default '{"I hear you": 0, "You’re not alone": 0, "May Allah ease this": 0, "Aamin": 0}'::jsonb,
  is_hidden boolean default false, -- For moderation
  created_at timestamptz default now()
);

-- 3. COMMENTS TABLE
create table if not exists public.comments (
  id uuid default gen_random_uuid() primary key,
  post_id uuid references public.posts(id) on delete cascade not null,
  user_id uuid references public.profiles(id) on delete cascade not null,
  parent_id uuid references public.comments(id) on delete cascade,
  content text not null,
  is_hidden boolean default false, -- For moderation
  created_at timestamptz default now()
);

-- 4. NOTIFICATIONS TABLE
create table if not exists public.notifications (
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
create table if not exists public.follows (
  follower_id uuid references public.profiles(id) on delete cascade not null,
  following_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamptz default now(),
  primary key (follower_id, following_id)
);

-- 6. BLOCKS TABLE
create table if not exists public.blocks (
  blocker_id uuid references public.profiles(id) on delete cascade not null,
  blocked_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamptz default now(),
  primary key (blocker_id, blocked_id)
);

-- 7. JOURNAL ENTRIES TABLE (Private)
create table if not exists public.journal_entries (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  title text,
  content text,
  mood text,
  prompt_id text,
  date timestamptz default now()
);

-- 8. FLAGS TABLE (Moderation)
create table if not exists public.flags (
  id uuid default gen_random_uuid() primary key,
  reporter_id uuid references public.profiles(id) on delete cascade not null,
  post_id uuid references public.posts(id) on delete cascade,
  reason text not null,
  status text default 'pending', -- pending, resolved, dismissed
  created_at timestamptz default now()
);

-- 9. FEEDBACK TABLE (User suggestions)
create table if not exists public.feedback (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  content text not null,
  type text default 'general', -- suggestion, bug, other
  status text default 'new', -- new, reviewed
  created_at timestamptz default now()
);

-- --- ROW LEVEL SECURITY (RLS) POLICIES ---

-- Helper macro to safely recreate policies
-- Note: 'create or replace' for policies isn't standard, so we drop if exists then create.

do $$ 
begin
  -- Enable RLS on all tables
  execute 'alter table public.profiles enable row level security';
  execute 'alter table public.posts enable row level security';
  execute 'alter table public.comments enable row level security';
  execute 'alter table public.notifications enable row level security';
  execute 'alter table public.follows enable row level security';
  execute 'alter table public.blocks enable row level security';
  execute 'alter table public.journal_entries enable row level security';
  execute 'alter table public.flags enable row level security';
  execute 'alter table public.feedback enable row level security';
exception when others then null; end $$;

-- Drop existing policies to avoid conflicts during updates
drop policy if exists "Public profiles are viewable by everyone" on public.profiles;
drop policy if exists "Users can insert their own profile" on public.profiles;
drop policy if exists "Users can update own profile" on public.profiles;

drop policy if exists "Posts are viewable by everyone" on public.posts;
drop policy if exists "Moderators can view all posts" on public.posts;
drop policy if exists "Authenticated users can create posts" on public.posts;
drop policy if exists "Users can update own posts" on public.posts;
drop policy if exists "Moderators can update any post (hide)" on public.posts;
drop policy if exists "Authenticated users can update affirmations" on public.posts;
drop policy if exists "Users can delete own posts" on public.posts;

drop policy if exists "Comments are viewable by everyone" on public.comments;
drop policy if exists "Authenticated users can create comments" on public.comments;

drop policy if exists "Users can view their own notifications" on public.notifications;
drop policy if exists "Users can create notifications (trigger actions)" on public.notifications;
drop policy if exists "Users can mark their notifications as read" on public.notifications;

drop policy if exists "Follows are viewable by everyone" on public.follows;
drop policy if exists "Users can follow others" on public.follows;
drop policy if exists "Users can unfollow" on public.follows;

drop policy if exists "Users can view their own blocks" on public.blocks;
drop policy if exists "Users can block others" on public.blocks;
drop policy if exists "Users can unblock" on public.blocks;

drop policy if exists "Users can view own journal" on public.journal_entries;
drop policy if exists "Users can create journal entries" on public.journal_entries;
drop policy if exists "Users can update own journal" on public.journal_entries;
drop policy if exists "Users can delete own journal" on public.journal_entries;

drop policy if exists "Users can create flags" on public.flags;
drop policy if exists "Moderators can view flags" on public.flags;
drop policy if exists "Moderators can update flags" on public.flags;

drop policy if exists "Users can create feedback" on public.feedback;
drop policy if exists "Moderators can view feedback" on public.feedback;
drop policy if exists "Moderators can update feedback" on public.feedback;


-- PROFILES
create policy "Public profiles are viewable by everyone" 
  on public.profiles for select using (true);

create policy "Users can insert their own profile" 
  on public.profiles for insert with check (auth.uid() = id);

create policy "Users can update own profile" 
  on public.profiles for update using (auth.uid() = id);

-- POSTS
create policy "Posts are viewable by everyone" 
  on public.posts for select using (is_hidden = false);

create policy "Moderators can view all posts" 
  on public.posts for select using (
    exists (select 1 from public.profiles where id = auth.uid() and role = 'moderator')
  );

create policy "Authenticated users can create posts" 
  on public.posts for insert with check (auth.role() = 'authenticated');

create policy "Users can update own posts" 
  on public.posts for update using (auth.uid() = user_id);

create policy "Moderators can update any post (hide)" 
  on public.posts for update using (
    exists (select 1 from public.profiles where id = auth.uid() and role = 'moderator')
  );

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

-- BLOCKS
create policy "Users can view their own blocks" 
  on public.blocks for select using (auth.uid() = blocker_id);

create policy "Users can block others" 
  on public.blocks for insert with check (auth.uid() = blocker_id);

create policy "Users can unblock" 
  on public.blocks for delete using (auth.uid() = blocker_id);

-- JOURNAL (Strictly Private)
create policy "Users can view own journal" 
  on public.journal_entries for select using (auth.uid() = user_id);

create policy "Users can create journal entries" 
  on public.journal_entries for insert with check (auth.uid() = user_id);

create policy "Users can update own journal" 
  on public.journal_entries for update using (auth.uid() = user_id);

create policy "Users can delete own journal" 
  on public.journal_entries for delete using (auth.uid() = user_id);

-- FLAGS
create policy "Users can create flags" 
  on public.flags for insert with check (auth.role() = 'authenticated');

create policy "Moderators can view flags" 
  on public.flags for select using (
    exists (select 1 from public.profiles where id = auth.uid() and role = 'moderator')
  );

create policy "Moderators can update flags" 
  on public.flags for update using (
    exists (select 1 from public.profiles where id = auth.uid() and role = 'moderator')
  );

-- FEEDBACK
create policy "Users can create feedback" 
  on public.feedback for insert with check (auth.role() = 'authenticated');

create policy "Moderators can view feedback" 
  on public.feedback for select using (
    exists (select 1 from public.profiles where id = auth.uid() and role = 'moderator')
  );
  
create policy "Moderators can update feedback" 
  on public.feedback for update using (
    exists (select 1 from public.profiles where id = auth.uid() and role = 'moderator')
  );

-- --- REALTIME CONFIGURATION ---
-- Check if publication exists before creating/altering (simple approach: just alter)
alter publication supabase_realtime add table public.notifications;

-- --- MIGRATIONS ---
-- Safely add is_hidden column to posts and comments if missing
do $$
begin
  if not exists (select 1 from information_schema.columns where table_name = 'posts' and column_name = 'is_hidden') then
    alter table public.posts add column is_hidden boolean default false;
  end if;

  if not exists (select 1 from information_schema.columns where table_name = 'comments' and column_name = 'is_hidden') then
    alter table public.comments add column is_hidden boolean default false;
  end if;
end $$;
