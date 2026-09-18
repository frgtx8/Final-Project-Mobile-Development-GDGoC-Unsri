-- ==============================================================================
-- eFootyTactics AI - Supabase Upgrade Script
-- Jalankan skrip ini di SQL Editor Supabase Dashboard Anda:
-- https://supabase.com/dashboard/project/urgxdptbipjfyhkcodda/sql
-- ==============================================================================

-- 1. PASTIKAN KOLOM ROLE PADA PROFILES
alter table public.profiles add column if not exists role text default 'user';

-- 2. UPDATE TRIGGER REGISTRASI USER DENGAN ROLE
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

-- 3. IZINKAN CRUD PEMAIN (AGAR PERUBAHAN ADMIN TERSINKRON KE SEMUA USER)
drop policy if exists "Allow insert on players" on public.players;
drop policy if exists "Allow update on players" on public.players;
drop policy if exists "Allow delete on players" on public.players;

create policy "Allow insert on players"
  on public.players for insert
  with check (true);

create policy "Allow update on players"
  on public.players for update
  using (true);

create policy "Allow delete on players"
  on public.players for delete
  using (true);

-- 4. TABEL FORMASI CLOUD (AGAR PERUBAHAN FORMASI ADMIN TERSINKRON KE SEMUA USER)
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

-- 5. SEED FORMASI STANDAR eFOOTBALL KE SUPABASE
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
    {"id": "CF", "defaultPosition": "CF", "x": 0.50, "y": 0.18},
    {"id": "RWF", "defaultPosition": "RWF", "x": 0.82, "y": 0.22}
  ]'::jsonb),
  ('4-2-2-2', '4-2-2-2 (Double AMF)', 'Standard', '[
    {"id": "GK", "defaultPosition": "GK", "x": 0.50, "y": 0.90},
    {"id": "LB", "defaultPosition": "LB", "x": 0.15, "y": 0.74},
    {"id": "CB1", "defaultPosition": "CB", "x": 0.38, "y": 0.77},
    {"id": "CB2", "defaultPosition": "CB", "x": 0.62, "y": 0.77},
    {"id": "RB", "defaultPosition": "RB", "x": 0.85, "y": 0.74},
    {"id": "DMF1", "defaultPosition": "DMF", "x": 0.35, "y": 0.60},
    {"id": "DMF2", "defaultPosition": "CMF", "x": 0.65, "y": 0.60},
    {"id": "AMF1", "defaultPosition": "AMF", "x": 0.25, "y": 0.38},
    {"id": "AMF2", "defaultPosition": "AMF", "x": 0.75, "y": 0.38},
    {"id": "CF1", "defaultPosition": "CF", "x": 0.38, "y": 0.18},
    {"id": "CF2", "defaultPosition": "CF", "x": 0.62, "y": 0.18}
  ]'::jsonb),
  ('3-2-2-3', '3-2-2-3 (Total Dominance)', 'Standard', '[
    {"id": "GK", "defaultPosition": "GK", "x": 0.50, "y": 0.90},
    {"id": "CB1", "defaultPosition": "CB", "x": 0.25, "y": 0.76},
    {"id": "CB2", "defaultPosition": "CB", "x": 0.50, "y": 0.78},
    {"id": "CB3", "defaultPosition": "CB", "x": 0.75, "y": 0.76},
    {"id": "DMF1", "defaultPosition": "DMF", "x": 0.35, "y": 0.60},
    {"id": "DMF2", "defaultPosition": "CMF", "x": 0.65, "y": 0.60},
    {"id": "AMF1", "defaultPosition": "AMF", "x": 0.30, "y": 0.40},
    {"id": "AMF2", "defaultPosition": "AMF", "x": 0.70, "y": 0.40},
    {"id": "LWF", "defaultPosition": "LWF", "x": 0.18, "y": 0.22},
    {"id": "CF", "defaultPosition": "CF", "x": 0.50, "y": 0.18},
    {"id": "RWF", "defaultPosition": "RWF", "x": 0.82, "y": 0.22}
  ]'::jsonb),
  ('5-2-1-2', '5-2-1-2 (Solid Counter)', 'Standard', '[
    {"id": "GK", "defaultPosition": "GK", "x": 0.50, "y": 0.90},
    {"id": "LWB", "defaultPosition": "LB", "x": 0.12, "y": 0.68},
    {"id": "CB1", "defaultPosition": "CB", "x": 0.30, "y": 0.78},
    {"id": "CB2", "defaultPosition": "CB", "x": 0.50, "y": 0.80},
    {"id": "CB3", "defaultPosition": "CB", "x": 0.70, "y": 0.78},
    {"id": "RWB", "defaultPosition": "RB", "x": 0.88, "y": 0.68},
    {"id": "DMF", "defaultPosition": "DMF", "x": 0.38, "y": 0.56},
    {"id": "CMF", "defaultPosition": "CMF", "x": 0.62, "y": 0.56},
    {"id": "AMF", "defaultPosition": "AMF", "x": 0.50, "y": 0.38},
    {"id": "CF1", "defaultPosition": "CF", "x": 0.38, "y": 0.18},
    {"id": "CF2", "defaultPosition": "CF", "x": 0.62, "y": 0.18}
  ]'::jsonb)
on conflict (id) do nothing;
