-- ==============================================================================
-- eFootyTactics AI - Master Database Setup & Migration Script
-- 
-- PANDUAN PENGGUNAAN:
-- Jalankan skrip ini langsung di Supabase SQL Editor:
-- https://supabase.com/dashboard/project/urgxdptbipjfyhkcodda/sql
--
-- CATATAN MENGENAI FILE SQL:
-- File ini menggantikan dan menyatukan seluruh file SQL sebelumnya
-- (update_rls.sql, supabase_upgrade.sql, dan schema.sql).
-- Anda cukup menjalankan file setup_database.sql ini satu kali saja!
-- ==============================================================================

-- 1. EXTENSIONS
create extension if not exists "pgcrypto";
create extension if not exists "uuid-ossp";

-- 2. TABEL PROFILES (User & Admin Accounts)
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  username text unique not null,
  favorite_club text default 'Real Madrid',
  favorite_playstyle text default 'Quick Counter',
  role text default 'user', -- 'user' atau 'admin'
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.profiles add column if not exists role text default 'user';
alter table public.profiles enable row level security;

-- Policies Profiles
drop policy if exists "Public profiles are viewable by everyone" on public.profiles;
drop policy if exists "Users can insert their own profile" on public.profiles;
drop policy if exists "Users can update their own profile" on public.profiles;

create policy "Public profiles are viewable by everyone"
  on public.profiles for select
  using (true);

create policy "Users can insert their own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- 3. TRIGGER REGISTRASI USER SUPABASE AUTH KE PROFILES & AUTO-CONFIRM EMAIL
-- Otomatis aktifkan user baru tanpa perlu konfirmasi email
create or replace function public.auto_confirm_user()
returns trigger as $$
begin
  new.email_confirmed_at = coalesce(new.email_confirmed_at, now());
  new.confirmed_at = coalesce(new.confirmed_at, now());
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created_auto_confirm on auth.users;
create trigger on_auth_user_created_auto_confirm
  before insert on auth.users
  for each row execute procedure public.auto_confirm_user();

-- Trigger untuk sync ke profiles dengan proteksi duplikasi username
create or replace function public.handle_new_user()
returns trigger as $$
declare
  desired_username text;
  final_username text;
begin
  desired_username := coalesce(nullif(trim(new.raw_user_meta_data->>'username'), ''), 'Manager_' || substr(new.id::text, 1, 6));
  
  -- Jika username sudah ada di database, tambahkan suffix 4 digit id agar tidak memicu 23505 unique collision
  if exists (select 1 from public.profiles where username = desired_username and id <> new.id) then
    final_username := desired_username || '_' || substr(new.id::text, 1, 4);
  else
    final_username := desired_username;
  end if;

  insert into public.profiles (id, username, favorite_club, favorite_playstyle, role)
  values (
    new.id,
    final_username,
    coalesce(new.raw_user_meta_data->>'favorite_club', 'Real Madrid'),
    coalesce(new.raw_user_meta_data->>'favorite_playstyle', 'Quick Counter'),
    coalesce(new.raw_user_meta_data->>'role', 'user')
  )
  on conflict (id) do update set
    username = excluded.username,
    favorite_club = excluded.favorite_club,
    favorite_playstyle = excluded.favorite_playstyle;
    
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Konfirmasi semua user lama yang belum terkonfirmasi
update auth.users
set email_confirmed_at = coalesce(email_confirmed_at, now()),
    confirmed_at = coalesce(confirmed_at, now())
where email_confirmed_at is null;

-- 4. TABEL PLAYERS (Katalog Pemain & Multi-Posisi)
create table if not exists public.players (
  id text primary key,             -- Contoh: 'p-001'
  name text not null,
  club text not null,
  nationality text not null,
  primary_position text not null,  -- CF, SS, LWF, RWF, AMF, CMF, DMF, LB, RB, CB, GK
  secondary_positions text[] default '{}', -- Posisi alternatif (e.g. Mbappé: CF, SS; Davies: LMF, LWF)
  overall_rating integer not null,
  player_playstyle text not null,  -- Goal Poacher, Hole Player, Anchor Man, etc.
  key_stats jsonb not null,        -- { pace: 90, shooting: 85, etc. }
  skills text[] default '{}',
  image_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Pastikan kolom multi-posisi tersedia jika tabel sudah ada sebelumnya
alter table public.players add column if not exists secondary_positions text[] default '{}';
alter table public.players enable row level security;

-- Policies Players
drop policy if exists "Players are viewable by everyone" on public.players;
drop policy if exists "Allow insert on players" on public.players;
drop policy if exists "Allow update on players" on public.players;
drop policy if exists "Allow delete on players" on public.players;

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

-- 5. TABEL FORMATIONS (Formasi Cloud)
create table if not exists public.formations (
  id text primary key,
  name text not null,
  category text default 'Standard',
  slots jsonb not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.formations enable row level security;

drop policy if exists "Formations are viewable by everyone" on public.formations;
drop policy if exists "Allow insert on formations" on public.formations;
drop policy if exists "Allow update on formations" on public.formations;
drop policy if exists "Allow delete on formations" on public.formations;

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

-- Seed formasi bawaan eFootball
insert into public.formations (id, name, category, slots)
values
  ('4-2-1-3', '4-2-1-3 (Meta Counter)', 'Standard', '[
    {"id": "GK", "defaultPosition": "GK", "x": 0.50, "y": 0.90},
    {"id": "LB", "defaultPosition": "LB", "x": 0.15, "y": 0.74},
    {"id": "CB1", "defaultPosition": "CB", "x": 0.38, "y": 0.77},
    {"id": "CB2", "defaultPosition": "CB", "x": 0.62, "y": 0.77},
    {"id": "RB", "defaultPosition": "RB", "x": 0.85, "y": 0.74},
    {"id": "DMF1", "defaultPosition": "DMF", "x": 0.35, "y": 0.58},
    {"id": "DMF2", "defaultPosition": "CMF", "x": 0.65, "y": 0.58},
    {"id": "AMF", "defaultPosition": "AMF", "x": 0.50, "y": 0.42},
    {"id": "LWF", "defaultPosition": "LWF", "x": 0.18, "y": 0.24},
    {"id": "CF", "defaultPosition": "CF", "x": 0.50, "y": 0.18},
    {"id": "RWF", "defaultPosition": "RWF", "x": 0.82, "y": 0.24}
  ]'::jsonb),
  ('4-3-3', '4-3-3 (Flat Wing Play)', 'Standard', '[
    {"id": "GK", "defaultPosition": "GK", "x": 0.50, "y": 0.90},
    {"id": "LB", "defaultPosition": "LB", "x": 0.15, "y": 0.74},
    {"id": "CB1", "defaultPosition": "CB", "x": 0.38, "y": 0.77},
    {"id": "CB2", "defaultPosition": "CB", "x": 0.62, "y": 0.77},
    {"id": "RB", "defaultPosition": "RB", "x": 0.85, "y": 0.74},
    {"id": "DMF", "defaultPosition": "DMF", "x": 0.50, "y": 0.60},
    {"id": "CMF1", "defaultPosition": "CMF", "x": 0.30, "y": 0.46},
    {"id": "CMF2", "defaultPosition": "CMF", "x": 0.70, "y": 0.46},
    {"id": "LWF", "defaultPosition": "LWF", "x": 0.18, "y": 0.22},
    {"id": "CF", "defaultPosition": "CF", "x": 0.50, "y": 0.16},
    {"id": "RWF", "defaultPosition": "RWF", "x": 0.82, "y": 0.22}
  ]'::jsonb),
  ('3-2-2-3', '3-2-2-3 (Total Football)', 'Standard', '[
    {"id": "GK", "defaultPosition": "GK", "x": 0.50, "y": 0.90},
    {"id": "CB1", "defaultPosition": "CB", "x": 0.25, "y": 0.76},
    {"id": "CB2", "defaultPosition": "CB", "x": 0.50, "y": 0.78},
    {"id": "CB3", "defaultPosition": "CB", "x": 0.75, "y": 0.76},
    {"id": "DMF1", "defaultPosition": "DMF", "x": 0.38, "y": 0.60},
    {"id": "DMF2", "defaultPosition": "DMF", "x": 0.62, "y": 0.60},
    {"id": "AMF1", "defaultPosition": "AMF", "x": 0.35, "y": 0.42},
    {"id": "AMF2", "defaultPosition": "AMF", "x": 0.65, "y": 0.42},
    {"id": "LWF", "defaultPosition": "LWF", "x": 0.18, "y": 0.22},
    {"id": "CF", "defaultPosition": "CF", "x": 0.50, "y": 0.16},
    {"id": "RWF", "defaultPosition": "RWF", "x": 0.82, "y": 0.22}
  ]'::jsonb),
  ('4-2-2-2', '4-2-2-2 (Double SS/AMF)', 'Standard', '[
    {"id": "GK", "defaultPosition": "GK", "x": 0.50, "y": 0.90},
    {"id": "LB", "defaultPosition": "LB", "x": 0.15, "y": 0.74},
    {"id": "CB1", "defaultPosition": "CB", "x": 0.38, "y": 0.77},
    {"id": "CB2", "defaultPosition": "CB", "x": 0.62, "y": 0.77},
    {"id": "RB", "defaultPosition": "RB", "x": 0.85, "y": 0.74},
    {"id": "DMF1", "defaultPosition": "DMF", "x": 0.35, "y": 0.58},
    {"id": "DMF2", "defaultPosition": "CMF", "x": 0.65, "y": 0.58},
    {"id": "AMF1", "defaultPosition": "AMF", "x": 0.25, "y": 0.40},
    {"id": "AMF2", "defaultPosition": "AMF", "x": 0.75, "y": 0.40},
    {"id": "CF1", "defaultPosition": "CF", "x": 0.38, "y": 0.20},
    {"id": "CF2", "defaultPosition": "SS", "x": 0.62, "y": 0.20}
  ]'::jsonb),
  ('5-2-1-2', '5-2-1-2 (Solid Defense)', 'Standard', '[
    {"id": "GK", "defaultPosition": "GK", "x": 0.50, "y": 0.90},
    {"id": "LWB", "defaultPosition": "LB", "x": 0.12, "y": 0.70},
    {"id": "CB1", "defaultPosition": "CB", "x": 0.30, "y": 0.78},
    {"id": "CB2", "defaultPosition": "CB", "x": 0.50, "y": 0.80},
    {"id": "CB3", "defaultPosition": "CB", "x": 0.70, "y": 0.78},
    {"id": "RWB", "defaultPosition": "RB", "x": 0.88, "y": 0.70},
    {"id": "DMF1", "defaultPosition": "DMF", "x": 0.38, "y": 0.56},
    {"id": "DMF2", "defaultPosition": "CMF", "x": 0.62, "y": 0.56},
    {"id": "AMF", "defaultPosition": "AMF", "x": 0.50, "y": 0.38},
    {"id": "CF1", "defaultPosition": "CF", "x": 0.38, "y": 0.18},
    {"id": "CF2", "defaultPosition": "CF", "x": 0.62, "y": 0.18}
  ]'::jsonb)
on conflict (id) do nothing;

-- 6. TABEL SQUADS (Koleksi Skuad Tim)
create table if not exists public.squads (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  squad_name text not null,
  formation text not null,
  team_playstyle text not null,
  starting_eleven jsonb not null,
  team_strength integer default 0,
  is_public boolean default false,
  likes_count integer default 0,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.squads enable row level security;

drop policy if exists "Public squads are viewable by everyone" on public.squads;
drop policy if exists "Users can insert their own squads" on public.squads;
drop policy if exists "Users can update their own squads" on public.squads;
drop policy if exists "Users can delete their own squads" on public.squads;

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

-- 7. TABEL SQUAD AI REVIEWS (Hasil Analisis AI Doctor)
create table if not exists public.squad_ai_reviews (
  id uuid default gen_random_uuid() primary key,
  squad_id uuid references public.squads(id) on delete cascade not null,
  synergy_score integer not null,
  grade text not null,
  tactical_verdict text not null,
  strengths text[] not null default '{}',
  weaknesses text[] not null default '{}',
  tactical_instructions text[] not null default '{}',
  alternative_suggestions text[] not null default '{}',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.squad_ai_reviews enable row level security;

drop policy if exists "Reviews viewable by squad owners or if squad is public" on public.squad_ai_reviews;
drop policy if exists "Users can insert AI reviews for their squads" on public.squad_ai_reviews;

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
