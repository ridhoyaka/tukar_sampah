# TukarSampah 🌿♻️

Aplikasi Bank Sampah & Tukar Poin Digital berbasis Flutter + Supabase.

## Fitur Utama

1. **Kalkulator Konversi Poin** - Hitung estimasi poin dari berat sampah (plastik, kertas, elektronik, logam, kaca)
2. **Penjadwalan Penjemputan** - Jadwalkan penjemputan sampah oleh petugas bank sampah
3. **Katalog Penukaran Poin** - Tukar poin dengan voucher pulsa, token listrik, atau saldo e-wallet
4. **Profil & Riwayat** - Lihat total poin dan riwayat transaksi

## Tech Stack

- **Frontend:** Flutter 3.x + Dart
- **State Management:** Riverpod
- **Routing:** GoRouter
- **Backend:** Supabase (Auth, Database, RLS)
- **Font:** Google Fonts (Poppins)

## Setup

### 1. Setup Supabase

1. Buat project baru di [supabase.com](https://supabase.com)
2. Buka **SQL Editor** dan jalankan file `supabase_schema.sql`
3. Salin **Project URL** dan **Anon Key** dari Settings > API

### 2. Konfigurasi Flutter

Simpan kredensial Supabase ke file lingkungan lokal yang tidak dikomit (`.env`). Salin file contoh `.env.example` menjadi `.env` lalu isi nilai:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Periksa bahwa file `.env` tidak dikomit (sudah ada di `.gitignore`). Aplikasi sudah dikonfigurasi untuk membaca variabel ini saat startup.

### 3. Jalankan Aplikasi

```bash
flutter pub get
flutter run
```

## Struktur Project

```
lib/
├── main.dart                    # Entry point
├── app/
│   └── router.dart              # GoRouter configuration
├── core/
│   ├── constants/
│   │   └── app_constants.dart   # Konstanta (poin per kg, kategori)
│   ├── models/
│   │   ├── user_profile.dart
│   │   ├── pickup_schedule.dart
│   │   ├── catalog_item.dart
│   │   └── transaction_history.dart
│   └── providers/
│       └── auth_provider.dart   # Riverpod auth providers
├── features/
│   ├── auth/
│   │   └── screens/
│   │       ├── login_screen.dart
│   │       └── register_screen.dart
│   ├── home/
│   │   └── screens/
│   │       ├── home_screen.dart
│   │       └── main_shell.dart  # Bottom navigation
│   ├── calculator/
│   │   └── screens/
│   │       └── calculator_screen.dart
│   ├── pickup/
│   │   └── screens/
│   │       ├── pickup_screen.dart
│   │       └── schedule_pickup_screen.dart
│   ├── catalog/
│   │   └── screens/
│   │       └── catalog_screen.dart
│   └── profile/
│       └── screens/
│           └── profile_screen.dart
```

## Database Schema (Supabase)

| Tabel              | Deskripsi                                            |
| ------------------ | ---------------------------------------------------- |
| `profiles`         | Data profil user (nama, telepon, alamat, total_poin) |
| `pickup_schedules` | Jadwal penjemputan sampah                            |
| `catalog_items`    | Item yang bisa ditukar dengan poin                   |
| `transactions`     | Riwayat transaksi poin (deposit/redeem)              |

## Konversi Poin

| Jenis Sampah | Poin per Kg |
| ------------ | ----------- |
| Plastik      | 50          |
| Kertas       | 30          |
| Elektronik   | 200         |
| Logam        | 100         |
| Kaca         | 40          |
