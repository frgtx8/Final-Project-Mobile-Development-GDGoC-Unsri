-- ==============================================================================
-- UPDATE RLS POLICIES FOR ADMIN PLAYER CRUD & ROLE SYSTEM
-- Jalankan skrip ini di SQL Editor Supabase Anda untuk mengaktifkan Tambah/Hapus Pemain
-- ==============================================================================

-- 1. Tambahkan kolom role pada tabel profiles jika belum ada
alter table public.profiles add column if not exists role text default 'user';

-- 2. Kebijakan RLS agar Admin dapat Menambah, Mengedit, dan Menghapus Pemain
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
