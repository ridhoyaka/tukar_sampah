-- ============================================
-- TukarSampah - Tambah Sistem Role (Admin & User)
-- Jalankan SQL ini di Supabase SQL Editor
-- SETELAH menjalankan supabase_schema.sql
-- ============================================

-- 1. Tambah kolom role ke tabel profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user';

-- 2. Buat admin pertama (ganti email sesuai akun admin kamu)
-- Jalankan SETELAH register akun admin via app, lalu update role-nya:
-- UPDATE profiles SET role = 'admin' WHERE email = 'admin@tukarsampah.com';

-- 3. Policy tambahan: Admin bisa lihat semua profiles
CREATE POLICY "Admin can view all profiles" ON profiles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- 4. Policy: Admin bisa update semua profiles (untuk update poin user)
CREATE POLICY "Admin can update all profiles" ON profiles
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- 5. Policy: Admin bisa lihat semua pickup_schedules
CREATE POLICY "Admin can view all pickups" ON pickup_schedules
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- 6. Policy: Admin bisa update semua pickup_schedules
CREATE POLICY "Admin can update all pickups" ON pickup_schedules
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- 7. Policy: Admin bisa insert, update, delete catalog_items
CREATE POLICY "Admin can insert catalog" ON catalog_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admin can update catalog" ON catalog_items
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admin can delete catalog" ON catalog_items
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- 8. Policy: Admin bisa lihat semua transactions
CREATE POLICY "Admin can view all transactions" ON transactions
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================
-- CARA MEMBUAT AKUN ADMIN:
-- 1. Register akun biasa lewat app (misal: admin@tukarsampah.com)
-- 2. Jalankan query ini di SQL Editor:
--    UPDATE profiles SET role = 'admin' WHERE email = 'admin@tukarsampah.com';
-- 3. Login ulang dengan akun tersebut → otomatis masuk ke panel admin
-- ============================================
