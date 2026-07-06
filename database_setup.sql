-- E-Ticketing Helpdesk Database Setup Script
-- Run this in your Supabase SQL Editor

-- ============================================
-- TABLES
-- ============================================

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  nama TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('user', 'admin', 'helpdesk')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tickets table
CREATE TABLE IF NOT EXISTS tickets (
  id TEXT PRIMARY KEY,
  judul TEXT NOT NULL,
  deskripsi TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('open', 'assign', 'in_progress', 'close')),
  id_user TEXT NOT NULL REFERENCES users(id),
  id_admin TEXT REFERENCES users(id),
  id_helpdesk TEXT REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Comments table
CREATE TABLE IF NOT EXISTS comments (
  id TEXT PRIMARY KEY,
  id_tiket TEXT NOT NULL REFERENCES tickets(id),
  id_user TEXT NOT NULL REFERENCES users(id),
  isi TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX IF NOT EXISTS idx_tickets_user ON tickets(id_user);
CREATE INDEX IF NOT EXISTS idx_tickets_admin ON tickets(id_admin);
CREATE INDEX IF NOT EXISTS idx_tickets_helpdesk ON tickets(id_helpdesk);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON tickets(status);
CREATE INDEX IF NOT EXISTS idx_comments_tiket ON comments(id_tiket);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
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
-- FUNCTIONS AND TRIGGERS
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
-- SAMPLE DATA
-- ============================================

-- Insert sample users
INSERT INTO users (id, email, nama, role) VALUES
  ('u1', 'admin@example.com', 'Admin', 'admin'),
  ('u2', 'naufal@example.com', 'Naufal', 'user'),
  ('u3', 'bagaskara@example.com', 'Bagaskara', 'user'),
  ('u4', 'helpdesk@example.com', 'Helpdesk', 'helpdesk')
ON CONFLICT (id) DO NOTHING;

-- Insert sample tickets
INSERT INTO tickets (id, judul, deskripsi, status, id_user, id_admin, id_helpdesk) VALUES
  ('t1', 'Internet Mati', 'Router kedip merah sejak pagi.', 'open', 'u2', null, null),
  ('t2', 'Printer Error', 'Kertas nyangkut di dalam printer.', 'in_progress', 'u3', 'u1', 'u4'),
  ('t3', 'Layar Blank', 'Monitor mati tapi PC nyala.', 'close', 'u2', 'u1', 'u4'),
  ('t4', 'Lupa Password Email', 'Tolong reset password Outlook.', 'close', 'u3', 'u1', 'u4'),
  ('t5', 'Mouse Rusak', 'Kursor tidak bergerak sama sekali.', 'open', 'u2', null, null)
ON CONFLICT (id) DO NOTHING;

-- Insert sample comments
INSERT INTO comments (id, id_tiket, id_user, isi, created_at) VALUES
  ('k1', 't1', 'u2', 'Tolong segera dibantu ya, butuh untuk meeting.', NOW() - INTERVAL '1 day 20 hours'),
  ('k2', 't1', 'u1', 'Baik pak, tim sedang meluncur ke ruangan bapak.', NOW() - INTERVAL '1 day 10 hours'),
  ('k3', 't2', 'u3', 'Printer di lantai 2 sebelah pantry.', NOW() - INTERVAL '20 hours'),
  ('k4', 't2', 'u1', 'Siap, sedang saya cek fisiknya sekarang.', NOW() - INTERVAL '2 hours'),
  ('k5', 't3', 'u2', 'Kabel VGA sudah saya cek tapi masih no signal.', NOW() - INTERVAL '2 days 10 hours'),
  ('k6', 't3', 'u1', 'Kabelnya putus di dalam pak, sudah saya ganti baru.', NOW() - INTERVAL '2 days 1 hour'),
  ('k7', 't4', 'u3', 'Bisa lewat WA saja password barunya?', NOW() - INTERVAL '4 days 20 hours'),
  ('k8', 't4', 'u1', 'Password baru sudah kami kirim via WhatsApp pribadi.', NOW() - INTERVAL '4 days 5 hours'),
  ('k9', 't5', 'u2', 'Baterai sudah diganti dua kali tetap mati.', NOW() - INTERVAL '50 minutes'),
  ('k10', 't5', 'u1', 'Bawa memousenya ke ruang IT lantai 1 pak untuk ditukar.', NOW() - INTERVAL '10 minutes')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- REAL-TIME SUBSCRIPTIONS SETUP
-- ============================================

-- Enable real-time for tables
ALTER TABLE tickets REPLICA IDENTITY FULL;
ALTER TABLE comments REPLICA IDENTITY FULL;

-- ============================================
-- VIEWS FOR COMMON QUERIES
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
