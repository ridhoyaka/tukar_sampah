-- ============================================
-- TukarSampah - Supabase Database Schema
-- Jalankan SQL ini di Supabase SQL Editor
-- ============================================

-- 1. Tabel Profiles (data user)
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT NOT NULL,
  nama_lengkap TEXT NOT NULL DEFAULT '',
  no_telepon TEXT DEFAULT '',
  alamat TEXT DEFAULT '',
  total_poin INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policy: User hanya bisa lihat & edit profil sendiri
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- 2. Tabel Pickup Schedules (jadwal penjemputan)
CREATE TABLE pickup_schedules (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  tanggal_jemput DATE NOT NULL,
  waktu_jemput TEXT NOT NULL,
  alamat_jemput TEXT NOT NULL,
  catatan TEXT DEFAULT '',
  jenis_sampah TEXT[] NOT NULL DEFAULT '{}',
  estimasi_berat DECIMAL(10,2) NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE pickup_schedules ENABLE ROW LEVEL SECURITY;

-- Policy: User hanya bisa lihat & buat jadwal sendiri
CREATE POLICY "Users can view own pickups" ON pickup_schedules
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own pickups" ON pickup_schedules
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own pickups" ON pickup_schedules
  FOR UPDATE USING (auth.uid() = user_id);

-- 3. Tabel Catalog Items (item yang bisa ditukar)
CREATE TABLE catalog_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nama TEXT NOT NULL,
  deskripsi TEXT DEFAULT '',
  poin_dibutuhkan INTEGER NOT NULL,
  kategori TEXT NOT NULL, -- 'pulsa', 'tokenListrik', 'eWallet'
  nominal TEXT NOT NULL,
  stok INTEGER DEFAULT 0,
  image_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE catalog_items ENABLE ROW LEVEL SECURITY;

-- Policy: Semua user bisa lihat catalog
CREATE POLICY "Anyone can view catalog" ON catalog_items
  FOR SELECT USING (true);

-- 4. Tabel Transactions (riwayat transaksi poin)
CREATE TABLE transactions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  tipe TEXT NOT NULL, -- 'deposit' atau 'redeem'
  poin INTEGER NOT NULL,
  deskripsi TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- Policy: User hanya bisa lihat & buat transaksi sendiri
CREATE POLICY "Users can view own transactions" ON transactions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own transactions" ON transactions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================
-- DATA SAMPLE: Catalog Items
-- ============================================

INSERT INTO catalog_items (nama, deskripsi, poin_dibutuhkan, kategori, nominal, stok) VALUES
  ('Pulsa Telkomsel 10K', 'Voucher pulsa Telkomsel Rp 10.000', 200, 'pulsa', 'Rp 10.000', 50),
  ('Pulsa Telkomsel 25K', 'Voucher pulsa Telkomsel Rp 25.000', 450, 'pulsa', 'Rp 25.000', 30),
  ('Pulsa Telkomsel 50K', 'Voucher pulsa Telkomsel Rp 50.000', 850, 'pulsa', 'Rp 50.000', 20),
  ('Pulsa XL 10K', 'Voucher pulsa XL Rp 10.000', 200, 'pulsa', 'Rp 10.000', 50),
  ('Pulsa XL 25K', 'Voucher pulsa XL Rp 25.000', 450, 'pulsa', 'Rp 25.000', 30),
  ('Token Listrik 20K', 'Token listrik PLN Rp 20.000', 350, 'tokenListrik', 'Rp 20.000', 40),
  ('Token Listrik 50K', 'Token listrik PLN Rp 50.000', 850, 'tokenListrik', 'Rp 50.000', 25),
  ('Token Listrik 100K', 'Token listrik PLN Rp 100.000', 1600, 'tokenListrik', 'Rp 100.000', 15),
  ('Saldo GoPay 10K', 'Saldo GoPay Rp 10.000', 200, 'eWallet', 'Rp 10.000', 50),
  ('Saldo GoPay 25K', 'Saldo GoPay Rp 25.000', 450, 'eWallet', 'Rp 25.000', 30),
  ('Saldo OVO 10K', 'Saldo OVO Rp 10.000', 200, 'eWallet', 'Rp 10.000', 50),
  ('Saldo OVO 50K', 'Saldo OVO Rp 50.000', 850, 'eWallet', 'Rp 50.000', 20),
  ('Saldo DANA 10K', 'Saldo DANA Rp 10.000', 200, 'eWallet', 'Rp 10.000', 50),
  ('Saldo DANA 25K', 'Saldo DANA Rp 25.000', 450, 'eWallet', 'Rp 25.000', 30);
