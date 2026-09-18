# ⚽ eFootyTactics AI

> **Smart Squad Builder, AI Meta Coach & Player Guide for eFootball Mobile**  
> Proyek Akhir Mobile Development - Google Developer Groups on Campus (GDGoC) Universitas Sriwijaya

[![Flutter](https://img.shields.io/badge/Flutter-3.44.4-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12.2-0175C2?logo=dart)](https://dart.dev)
[![Backend](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase)](https://supabase.com)
[![AI Engine](https://img.shields.io/badge/AI-Gemini%20Flash-8E75B2?logo=google)](https://deepmind.google/technologies/gemini/)
[![Tests](https://img.shields.io/badge/Tests-32%20Passed-success)](#-hasil-pengujian-otomatis-automated-testing)
[![Integration Test](https://img.shields.io/badge/Integration%20Test-Passed-success)](#3-integration-tests-integration_test)

---

## 📖 Ringkasan Proyek

**eFootyTactics AI** adalah aplikasi pendamping cerdas yang dirancang khusus untuk para penikmat dan pemain game **eFootball**. Aplikasi ini menyelesaikan permasalahan paling krusial di eFootball: **banyak pemain kalah bukan karena rating kartu pemainnya rendah, melainkan akibat *Playstyle Clash* (tabrakan gaya main) atau lubang taktis pertahanan.**

Aplikasi ini dapat digunakan secara **Solo / Mandiri** (100% dapat diuji dan dinikmati sendiri tanpa perlu mengundang orang lain), maupun **Bersama (Social/Community)** untuk saling berbagi dan menyalin formasi taktik meta via Supabase.

---

## 🌟 Fitur Utama / Kunci (Flagship Feature)

### 🩺 **AI Squad Doctor & Synergy Engine**
* **Konsep:** Engine kecerdasan buatan berbasis **Google Gemini 1.5 Flash API** yang menganalisis komposisi 11 pemain inti di lapangan berdasarkan *Team Playstyle* (*Quick Counter*, *Possession Game*, *Long Ball Counter*, *Out Wide*, *Long Ball*) dan posisi taktisnya.
* **Analisis Mendalam:**
  1. **Synergy Score (0 - 100)** beserta **Grade Sinergi (S, A, B, C)**.
  2. **Tactical Red Flags (Peringatan Bahaya Taktis):** Mendeteksi celah pertahanan spasial di game (misal: kedua bek sayap *Attacking Full-back* tanpa *Anchor Man*, atau bek tengah lambat pada garis pertahanan tinggi *Quick Counter*).
  3. **In-Game Tactical Instructions:** Rekomendasi instruksi individual spesifik (misal: pasang instruksi *"Defensive"* pada DMF atau *"Deep Line"*).
  4. **Alternative Player Swap:** Saran pemain pengganti dari database untuk menambal kelemahan tersebut.
* **Dual-Engine Architecture:** Didukung integrasi Gemini 1.5 Flash dengan fallback *eFootball Tactical Heuristic Engine* otomatis sehingga aplikasi tetap 100% berfungsi optimal bahkan saat offline atau sebelum API Key diisi.

---

## 📱 Fitur-Fitur Lengkap (Expanded Features)

1. **Interactive Pitch & Squad Builder:**
   * Lapangan sepak bola virtual eFootball dengan pilihan formasi meta (*4-2-1-3, 4-3-3, 4-2-2-2, 3-2-2-3, 4-1-2-3*).
   * Tap slot pemain untuk memilih atau menukar pemain via *bottom sheet picker*.
   * Kalkulasi otomatis **Team Strength (TS)** eFootball.
2. **AI Player Scout & Build Progression Recommender:**
   * Konsultasi pencarian pemain *hidden gem* dan rekomendasi alokasi poin latihan (*Progression Points*: Passing, Dribbling, Dexterity, Defending).
   * Dilengkapi *Quick Prompt Chips* untuk pencarian cepat.
3. **Database Katalog Pemain eFootball:**
   * Katalog pemain kaya data dengan pencarian responsif dan filter posisi (*CF, LWF, RWF, AMF, CMF, DMF, CB, LB, RB, GK*).
   * Modal detail statistik kunci (*Pace, Shooting, Passing, Dribbling, Defending, Physical*) dan daftar keahlian (*Player Skills*).
4. **Community Meta Tactics Hub (Supabase):**
   * Feed taktik publik dari komunitas pemain eFootball.
   * Fitur **"Salin Formasi"** (*One-tap Clone*) yang langsung memuat susunan taktik pemain lain ke Squad Builder pribadi.
5. **Koleksi Skuad Saya (Cloud & Local Sync):**
   * Menyimpan racikan taktik tanpa batas ke database cloud Supabase dengan penyimpanan cadangan lokal (*offline-first*).
6. **Autentikasi Fleksibel (Supabase Auth + Solo Guest Mode):**
   * Mendukung registrasi/login email Supabase (dengan enkripsi JWT) serta opsi **Mode Solo / Tamu (Tanpa Login)** untuk kemudahan pengujian instan.

---

## 🛠️ Versi dan Dependensi yang Dipakai

* **Flutter SDK:** `^3.44.4`
* **Dart SDK:** `^3.12.2`

### Daftar Dependensi Utama (`pubspec.yaml`):
| Dependensi | Versi | Kegunaan |
| :--- | :--- | :--- |
| `flutter_riverpod` | `^2.6.1` | Arsitektur State Management reaktif & testable |
| `supabase_flutter` | `^2.17.2` | Koneksi database PostgreSQL, Auth, dan Storage |
| `google_generative_ai` | `^0.4.7` | Integrasi model AI Gemini 1.5 Flash |
| `flutter_dotenv` | `^5.2.1` | Pengelolaan Environment Variables yang aman |
| `shared_preferences` | `^2.5.5` | Penyimpanan lokal sesi tamu & cache offline |
| `uuid` | `^4.6.0` | Generator UUID untuk identitas skuad & user |
| `intl` | `^0.20.3` | Format tanggal & penanggalan waktu |
| `mocktail` | `^1.0.5` | Mocking objek untuk pengujian otomatis |
| `integration_test` | `SDK` | Pengujian integrasi End-to-End di Flutter |

---

## 🗄️ Dokumentasi Backend & Endpoint API (Supabase)

Kode backend lengkap disertakan pada direktori [`/backend`](./backend):
* [`backend/schema.sql`](./backend/schema.sql): Skema DDL tabel PostgreSQL, relasi foreign keys, indeks, dan trigger `handle_new_user()`.
* [`backend/seed_players.sql`](./backend/seed_players.sql): Data awal (*seed data*) katalog pemain top eFootball 2024/2025.
* [`backend/README.md`](./backend/README.md): Panduan eksekusi SQL di Supabase.

### Struktur Tabel Database:
1. **`public.profiles`**: Menyimpan profil user (ID terikat dengan `auth.users`).
2. **`public.players`**: Master katalog pemain eFootball (Posisi, Rating OVR, Playstyle, Key Stats JSONB, Skills).
3. **`public.squads`**: Menyimpan formasi, taktik tim, starting XI, dan TS.
4. **`public.squad_ai_reviews`**: Menyimpan hasil diagnosis AI Squad Doctor.

### Keamanan & Best Practices:
* **JWT Authentication:** Setiap request Supabase diamankan dengan token JWT.
* **Row Level Security (RLS):** Pengguna hanya memiliki hak akses penuh (CRUD) pada skuad miliknya sendiri. Skuad publik dapat dibaca secara aman oleh pengguna lain (*read-only*).
* **Environment Secrets:** API Key Supabase dan Gemini tidak di-hardcode ke kode sumber, melainkan dimuat via `.env`.

---

## 🚀 Cara Menjalankan Aplikasi

### 1. Prasyarat:
Pastikan Flutter SDK dan Git sudah terpasang di komputer Anda.

### 2. Clone / Masuk ke Direktori Proyek:
```bash
cd Final-Project-Mobile-Development-GDGoC-Unsri
```

### 3. Konfigurasi Environment (`.env`):
Salin file `.env.example` menjadi `.env`:
```bash
cp .env.example .env
```
Isi nilai URL Supabase dan Gemini API Key Anda:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
GEMINI_API_KEY=your-gemini-api-key-here
```
> *Catatan: Jika Anda belum mengisi API key, aplikasi tetap berjalan 100% normal menggunakan mode data lokal dan Tactical Engine bawaan!*

### 4. Setup Database Supabase (Opsional tapi Direkomendasikan):
1. Buka [Supabase Dashboard](https://supabase.com) > **SQL Editor**.
2. Jalankan isi file [`backend/schema.sql`](./backend/schema.sql).
3. Jalankan isi file [`backend/seed_players.sql`](./backend/seed_players.sql).

### 5. Install Dependensi & Jalankan:
```bash
flutter pub get
flutter run
```

---

## 🧪 Hasil Pengujian Otomatis (Automated Testing)

Proyek ini telah dilengkapi dengan rangkaian pengujian otomatis lengkap (**Unit Test**, **Widget Test**, dan **Integration Test**) yang menguji seluruh fungsionalitas inti aplikasi secara komprehensif.

### 1. Menjalankan Unit Test & Widget Test:
```bash
flutter test test/
```

### 2. Menjalankan End-to-End Integration Test:
```bash
flutter test integration_test/app_flow_test.dart
```

---

### Rincian Modul Pengujian:
1. **Unit Tests (`test/unit/`):**
   * `ai_doctor_position_test.dart`: Pengujian deteksi kesalahan taktis posisi pemain (blunder penyerang di posisi bek menurunkan rating & sinergi, serta pemberian rating tinggi untuk posisi alami).
   * `ai_scout_test.dart`: Pengujian rekomendasi pemain eFootball cerdas berdasarkan *playstyle* resmi (Pemburu Celah -> Hole Player, Pemburu Gol -> Goal Poacher, Gelandang Jangkar -> Anchor Man).
   * `squad_calculator_test.dart`: Pengujian formula Team Strength (TS), penalti penurunan OVR saat pemain di luar posisi, bonus sinergi 11 pemain, dan serialisasi JSON.
   * `ai_synergy_report_test.dart`: Pengujian parser respon JSON dari Gemini AI dan inferensi grade otomatis (S/A/B/C).
   * `formation_repository_test.dart`: Pengujian registrasi formasi meta dinamis, koordinat slot lapangan, dan serialisasi JSON.
   * `player_repository_test.dart`: Pengujian query pencarian pemain, filter multi-posisi, dan filter gaya main.
2. **Widget Tests (`test/widget/`):**
   * `auth_screen_test.dart`: Verifikasi antarmuka Login, toggle pendaftaran (Sign Up), validasi konfirmasi password, dan toggle lihat/sembunyikan password (eye icon).
   * `synergy_score_badge_test.dart`: Verifikasi rendering badge grade S/B dan skor numerik.
   * `tactical_pitch_widget_test.dart`: Verifikasi letak 11 pin slot pemain pada koordinat lapangan sepak bola broadcast turf.
3. **Integration Tests (`integration_test/`):**
   * `app_flow_test.dart`: Pengujian alur End-to-End navigasi aplikasi: *Squad Builder -> Database -> AI Scout -> Komunitas -> Koleksi -> Kembali ke Squad Builder*.

---

### Bukti Kelulusan Pengujian Unit & Widget (`flutter test test/`):
```text
00:00 +0: test/unit/ai_doctor_position_test.dart: AI Doctor detects out-of-position blunder when striker is placed as defender
00:00 +1: test/unit/ai_doctor_position_test.dart: AI Doctor gives high rating when players are placed in natural positions
00:00 +2: test/unit/ai_scout_test.dart: Query for Pemburu Celah returns Hole Players and NOT Anchor Man or Build Up
00:00 +3: test/unit/ai_scout_test.dart: Query for Pemburu Gol returns Goal Poachers
00:00 +4: test/unit/ai_scout_test.dart: Query for Gelandang Jangkar returns Anchor Man
00:00 +5: test/unit/ai_synergy_report_test.dart: Correctly parses full JSON from Gemini AI
00:00 +6: test/unit/ai_synergy_report_test.dart: Infers grade automatically if not explicitly provided in JSON
00:00 +7: test/unit/formation_repository_test.dart: Default formations list contains all 7 standard tactical meta setups
00:01 +12: test/unit/player_repository_test.dart: Loads players and verifies non-empty catalog
00:01 +13: test/unit/player_repository_test.dart: Searches players by query string
00:01 +14: test/unit/player_repository_test.dart: Filters players by position (including multi-position support)
00:01 +19: test/unit/squad_calculator_test.dart: Player effective rating drops when placed out of position
00:01 +20: test/unit/squad_calculator_test.dart: calculateTeamStrength drops when striker is placed as defender
00:01 +22: test/widget/auth_screen_test.dart: Renders Login form by default and toggles to Sign Up
00:02 +28: test/widget/synergy_score_badge_test.dart: Renders Grade S and score 95 properly in full mode
00:03 +30: test/widget/tactical_pitch_widget_test.dart: Renders pitch and correctly displays assigned player name
00:03 +32: All tests passed!
```

### Bukti Kelulusan Integration Test (`flutter test integration_test/app_flow_test.dart`):
```text
00:00 +0: loading integration_test/app_flow_test.dart
Running Gradle task 'assembleDebug'...
00:00 +0: eFootyTactics AI - End to End Integration Test Full app navigation and feature workflow test
00:06 +1: (tearDownAll)
00:07 +1: All tests passed!
```

---

## 👨‍💻 Kontributor
* **Nama Pengembang:** Fadhil Rahman
* **Visca Barca**
