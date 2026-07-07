-- ============================================
-- 1. BERSIH-BERSIH DATA LAMA (TEARDOWN)
-- ============================================
DROP VIEW IF EXISTS tickets_with_users CASCADE;
DROP VIEW IF EXISTS comments_with_users CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS tickets CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ============================================
-- 2. BUAT TABEL BARU DENGAN UUID
-- ============================================

-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  nama TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('user', 'admin', 'helpdesk')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tickets table
CREATE TABLE tickets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  judul TEXT NOT NULL,
  deskripsi TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('open', 'assign', 'in_progress', 'close')),
  id_user UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  id_admin UUID REFERENCES users(id) ON DELETE SET NULL,
  id_helpdesk UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Comments table
CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  id_tiket UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  id_user UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  isi TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 3. INDEXES
-- ============================================

CREATE INDEX idx_tickets_user ON tickets(id_user);
CREATE INDEX idx_tickets_admin ON tickets(id_admin);
CREATE INDEX idx_tickets_helpdesk ON tickets(id_helpdesk);
CREATE INDEX idx_tickets_status ON tickets(status);
CREATE INDEX idx_comments_tiket ON comments(id_tiket);

-- ============================================
-- 4. ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- Development policies (adjust for production)
CREATE POLICY "Enable all access for development" ON users FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable all access for development" ON tickets FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Enable all access for development" ON comments FOR ALL USING (true) WITH CHECK (true);

-- ============================================
-- 5. FUNCTIONS AND TRIGGERS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for automatic updated_at
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tickets_updated_at
    BEFORE UPDATE ON tickets
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 6. SAMPLE DATA (Using valid UUIDs)
-- ============================================

-- Insert sample users
INSERT INTO users (id, email, nama, role) VALUES
  ('11111111-1111-1111-1111-111111111111', 'admin@example.com', 'Admin', 'admin'),
  ('22222222-2222-2222-2222-222222222222', 'naufal@example.com', 'Naufal', 'user'),
  ('33333333-3333-3333-3333-333333333333', 'bagaskara@example.com', 'Bagaskara', 'user'),
  ('44444444-4444-4444-4444-444444444444', 'helpdesk@example.com', 'Helpdesk', 'helpdesk')
ON CONFLICT (id) DO NOTHING;

-- Insert sample tickets
INSERT INTO tickets (id, judul, deskripsi, status, id_user, id_admin, id_helpdesk) VALUES
  ('aaaa0000-0000-0000-0000-000000000001', 'Internet Mati', 'Router kedip merah sejak pagi.', 'open', '22222222-2222-2222-2222-222222222222', null, null),
  ('aaaa0000-0000-0000-0000-000000000002', 'Printer Error', 'Kertas nyangkut di dalam printer.', 'in_progress', '33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', '44444444-4444-4444-4444-444444444444'),
  ('aaaa0000-0000-0000-0000-000000000003', 'Layar Blank', 'Monitor mati tapi PC nyala.', 'close', '22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', '44444444-4444-4444-4444-444444444444'),
  ('aaaa0000-0000-0000-0000-000000000004', 'Lupa Password Email', 'Tolong reset password Outlook.', 'close', '33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', '44444444-4444-4444-4444-444444444444'),
  ('aaaa0000-0000-0000-0000-000000000005', 'Mouse Rusak', 'Kursor tidak bergerak sama sekali.', 'open', '22222222-2222-2222-2222-222222222222', null, null)
ON CONFLICT (id) DO NOTHING;

-- Insert sample comments
INSERT INTO comments (id, id_tiket, id_user, isi, created_at) VALUES
  ('bbbb0000-0000-0000-0000-000000000001', 'aaaa0000-0000-0000-0000-000000000001', '22222222-2222-2222-2222-222222222222', 'Tolong segera dibantu ya, butuh untuk meeting.', NOW() - INTERVAL '1 day 20 hours'),
  ('bbbb0000-0000-0000-0000-000000000002', 'aaaa0000-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'Baik pak, tim sedang meluncur ke ruangan bapak.', NOW() - INTERVAL '1 day 10 hours'),
  ('bbbb0000-0000-0000-0000-000000000003', 'aaaa0000-0000-0000-0000-000000000002', '33333333-3333-3333-3333-333333333333', 'Printer di lantai 2 sebelah pantry.', NOW() - INTERVAL '20 hours'),
  ('bbbb0000-0000-0000-0000-000000000004', 'aaaa0000-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111', 'Siap, sedang saya cek fisiknya sekarang.', NOW() - INTERVAL '2 hours'),
  ('bbbb0000-0000-0000-0000-000000000005', 'aaaa0000-0000-0000-0000-000000000003', '22222222-2222-2222-2222-222222222222', 'Kabel VGA sudah saya cek tapi masih no signal.', NOW() - INTERVAL '2 days 10 hours'),
  ('bbbb0000-0000-0000-0000-000000000006', 'aaaa0000-0000-0000-0000-000000000003', '11111111-1111-1111-1111-111111111111', 'Kabelnya putus di dalam pak, sudah saya ganti baru.', NOW() - INTERVAL '2 days 1 hour'),
  ('bbbb0000-0000-0000-0000-000000000007', 'aaaa0000-0000-0000-0000-000000000004', '33333333-3333-3333-3333-333333333333', 'Bisa lewat WA saja password barunya?', NOW() - INTERVAL '4 days 20 hours'),
  ('bbbb0000-0000-0000-0000-000000000008', 'aaaa0000-0000-0000-0000-000000000004', '11111111-1111-1111-1111-111111111111', 'Password baru sudah kami kirim via WhatsApp pribadi.', NOW() - INTERVAL '4 days 5 hours'),
  ('bbbb0000-0000-0000-0000-000000000009', 'aaaa0000-0000-0000-0000-000000000005', '22222222-2222-2222-2222-222222222222', 'Baterai sudah diganti dua kali tetap mati.', NOW() - INTERVAL '50 minutes'),
  ('bbbb0000-0000-0000-0000-000000000010', 'aaaa0000-0000-0000-0000-000000000005', '11111111-1111-1111-1111-111111111111', 'Bawa memousenya ke ruang IT lantai 1 pak untuk ditukar.', NOW() - INTERVAL '10 minutes')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 7. REAL-TIME SUBSCRIPTIONS SETUP
-- ============================================

-- Enable real-time for tables
ALTER TABLE tickets REPLICA IDENTITY FULL;
ALTER TABLE comments REPLICA IDENTITY FULL;

-- ============================================
-- 8. VIEWS FOR COMMON QUERIES
-- ============================================

-- View for tickets with user and admin details
CREATE OR REPLACE VIEW tickets_with_users AS
SELECT
    t.id,
    t.judul,
    t.deskripsi,
    t.status,
    t.created_at,
    t.updated_at,
    u.id as user_id,
    u.nama as user_nama,
    u.email as user_email,
    a.id as admin_id,
    a.nama as admin_nama,
    a.email as admin_email,
    h.id as helpdesk_id,
    h.nama as helpdesk_nama,
    h.email as helpdesk_email
FROM tickets t
LEFT JOIN users u ON t.id_user = u.id
LEFT JOIN users a ON t.id_admin = a.id
LEFT JOIN users h ON t.id_helpdesk = h.id;

-- View for comments with user details
CREATE OR REPLACE VIEW comments_with_users AS
SELECT
    c.id,
    c.id_tiket,
    c.isi,
    c.created_at,
    u.id as user_id,
    u.nama as user_nama,
    u.email as user_email
FROM comments c
LEFT JOIN users u ON c.id_user = u.id;