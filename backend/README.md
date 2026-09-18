# Backend Documentation - eFootyTactics AI

Dokumentasi arsitektur backend berbasis **Supabase (PostgreSQL + Auth + Row Level Security)**.

---

## 1. Struktur Tabel Database

1. **`public.profiles`**: Menyimpan profil pengguna yang terikat dengan `auth.users`.
   - `id`: UUID (Primary Key, references `auth.users.id` ON DELETE CASCADE)
   - `username`: TEXT (Unique)
   - `favorite_club`: TEXT
   - `favorite_playstyle`: TEXT
   - `avatar_url`: TEXT
   - `created_at`: TIMESTAMP WITH TIME ZONE

2. **`public.players`**: Master katalog database pemain eFootball.
   - `id`: TEXT (Primary Key, e.g. `'p-001'`)
   - `name`: TEXT
   - `club`: TEXT
   - `nationality`: TEXT
   - `primary_position`: TEXT ('CF', 'AMF', 'DMF', 'CB', 'GK', dll.)
   - `overall_rating`: INTEGER
   - `player_playstyle`: TEXT ('Goal Poacher', 'Hole Player', 'Anchor Man', dll.)
   - `key_stats`: JSONB (Pace, Shooting, Passing, Dribbling, Defending, Physical)
   - `skills`: TEXT[]
   - `image_url`: TEXT

3. **`public.squads`**: Menyimpan racikan starting XI dan taktik pengguna.
   - `id`: UUID (Primary Key)
   - `user_id`: UUID (references `public.profiles.id` ON DELETE CASCADE)
   - `squad_name`: TEXT
   - `formation`: TEXT ('4-2-1-3', '4-3-3', dll.)
   - `team_playstyle`: TEXT ('Quick Counter', 'Possession Game', dll.)
   - `starting_eleven`: JSONB (Mapping slot posisi ke player_id)
   - `team_strength`: INTEGER
   - `is_public`: BOOLEAN (Apakah di-share ke Community Hub)
   - `likes_count`: INTEGER
   - `created_at` & `updated_at`: TIMESTAMP

4. **`public.squad_ai_reviews`**: Menyimpan hasil analisis dari Fitur Kunci AI Squad Doctor.
   - `id`: UUID (Primary Key)
   - `squad_id`: UUID (references `public.squads.id` ON DELETE CASCADE)
   - `synergy_score`: INTEGER (0 - 100)
   - `grade`: TEXT ('S', 'A', 'B', 'C')
   - `tactical_verdict`: TEXT
   - `strengths`: TEXT[]
   - `weaknesses`: TEXT[]
   - `tactical_instructions`: TEXT[]
   - `alternative_suggestions`: TEXT[]

---

## 2. Keamanan & Best Practices (Row Level Security)

Semua tabel dilindungi dengan PostgreSQL **Row Level Security (RLS)**:
- **`profiles`**: Publik dapat melihat profil; Hanya pemilik yang dapat mengedit profilnya sendiri (`auth.uid() = id`).
- **`players`**: Bersifat *read-only* bagi semua pengguna aplikasi.
- **`squads`**:
  - *SELECT*: Publik bisa melihat jika `is_public = true`, atau jika pemiliknya adalah pengguna yang sedang login (`auth.uid() = user_id`).
  - *INSERT, UPDATE, DELETE*: Hanya pemilik skuad yang bersangkutan (`auth.uid() = user_id`).
- **`squad_ai_reviews`**: Terikat langsung dengan hak akses skuad.

---

## 3. Langkah Setup di Dashboard Supabase

1. Buka dashboard proyek Supabase Anda: [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Masuk ke menu **SQL Editor** di sisi kiri.
3. Buka file [`schema.sql`](./schema.sql), salin seluruh isinya, tempel ke dalam SQL Editor, lalu klik **Run**.
4. Buka file [`seed_players.sql`](./seed_players.sql), salin seluruh isinya, tempel ke SQL Editor, lalu klik **Run** untuk mengisi data awal pemain eFootball.
5. Salin **Project URL** dan **anon/public API Key** dari menu `Project Settings > API` ke file `.env` di aplikasi Flutter:
   ```env
   SUPABASE_URL=https://xxxxxxxx.supabase.co
   SUPABASE_ANON_KEY=eyJh...
   ```
