-- ==============================================================================
-- eFootyTactics AI - Supabase Database Schema
-- Architecture: PostgreSQL + Row Level Security (RLS) + Cascade Deletion
-- ==============================================================================

-- 1. PROFILES TABLE
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  username text unique not null,
  favorite_club text default 'Default FC',
  favorite_playstyle text default 'Quick Counter',
  role text default 'user',
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on profiles
alter table public.profiles enable row level security;

create policy "Public profiles are viewable by everyone"
  on public.profiles for select
  using (true);

create policy "Users can insert their own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- 2. PLAYERS MASTER TABLE
create table if not exists public.players (
  id text primary key,
  name text not null,
  club text not null,
  nationality text,
  primary_position text not null, -- CF, AMF, DMF, CB, GK, etc.
  overall_rating integer not null,
  player_playstyle text not null, -- Goal Poacher, Hole Player, Anchor Man, etc.
  key_stats jsonb not null,        -- { pace: 90, shooting: 85, etc. }
  skills text[] default '{}',
  image_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on players
alter table public.players enable row level security;

create policy "Players are viewable by everyone"
  on public.players for select
  using (true);

create policy "Allow insert on players"
  on public.players for insert
  with check (true);

create policy "Allow update on players"
  on public.players for update
  using (true);

create policy "Allow delete on players"
  on public.players for delete
  using (true);

-- 3. SQUADS TABLE
create table if not exists public.squads (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  squad_name text not null,
  formation text not null,          -- '4-2-1-3', '4-3-3', '3-2-2-3', '4-2-2-2'
  team_playstyle text not null,     -- 'Quick Counter', 'Possession Game', 'Long Ball Counter', etc.
  starting_eleven jsonb not null,   -- Map of { "GK": "p-012", "CB1": "p-008", ... }
  team_strength integer default 0,
  is_public boolean default false,
  likes_count integer default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on squads
alter table public.squads enable row level security;

create policy "Public squads are viewable by everyone"
  on public.squads for select
  using (is_public = true or auth.uid() = user_id);

create policy "Users can insert their own squads"
  on public.squads for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own squads"
  on public.squads for update
  using (auth.uid() = user_id);

create policy "Users can delete their own squads"
  on public.squads for delete
  using (auth.uid() = user_id);

-- 4. SQUAD AI REVIEWS TABLE
create table if not exists public.squad_ai_reviews (
  id uuid default gen_random_uuid() primary key,
  squad_id uuid references public.squads(id) on delete cascade not null,
  synergy_score integer not null,           -- 0-100
  grade text not null,                      -- 'S', 'A', 'B', 'C'
  tactical_verdict text not null,
  strengths text[] not null default '{}',
  weaknesses text[] not null default '{}',
  tactical_instructions text[] not null default '{}',
  alternative_suggestions text[] not null default '{}',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS on AI Reviews
alter table public.squad_ai_reviews enable row level security;

create policy "Reviews viewable by squad owners or if squad is public"
  on public.squad_ai_reviews for select
  using (
    exists (
      select 1 from public.squads
      where squads.id = squad_ai_reviews.squad_id
        and (squads.is_public = true or squads.user_id = auth.uid())
    )
  );

create policy "Users can insert AI reviews for their squads"
  on public.squad_ai_reviews for insert
  with check (
    exists (
      select 1 from public.squads
      where squads.id = squad_ai_reviews.squad_id
        and squads.user_id = auth.uid()
    )
  );

-- Function to handle new user signup automatically
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, favorite_club, favorite_playstyle, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', 'Manager_' || substr(new.id::text, 1, 6)),
    coalesce(new.raw_user_meta_data->>'favorite_club', 'Real Madrid'),
    coalesce(new.raw_user_meta_data->>'favorite_playstyle', 'Quick Counter'),
    coalesce(new.raw_user_meta_data->>'role', 'user')
  );
  return new;
end;
$$ language plpgsql security definer;

-- Trigger on auth.users
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 5. FORMATIONS TABLE (Cloud-synced formations)
create table if not exists public.formations (
  id text primary key,
  name text not null,
  category text default 'Standard',
  slots jsonb not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.formations enable row level security;

create policy "Formations are viewable by everyone"
  on public.formations for select
  using (true);

create policy "Allow insert on formations"
  on public.formations for insert
  with check (true);

create policy "Allow update on formations"
  on public.formations for update
  using (true);

create policy "Allow delete on formations"
  on public.formations for delete
  using (true);

