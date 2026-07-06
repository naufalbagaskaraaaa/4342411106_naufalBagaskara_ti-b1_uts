# Setup Guide - E-Ticketing Helpdesk

## Prerequisites

Before running this application, ensure you have the following:

1. **Flutter SDK** (version 3.11.0 or higher)
   - Install from [flutter.dev](https://flutter.dev/docs/get-started/install)
   - Run `flutter doctor` to verify installation

2. **Supabase Account**
   - Create account at [supabase.com](https://supabase.com)
   - Create a new project

3. **Code Editor** (VS Code, Android Studio, or IntelliJ IDEA)

## Step-by-Step Setup

### 1. Clone and Install Dependencies

```bash
# Get Flutter dependencies
flutter pub get

# Run code generation (after adding new models/entities)
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Configure Supabase

1. Go to your Supabase project dashboard
2. Navigate to **Settings** → **API**
3. Copy the following values:
   - Project URL
   - Anon Key (public)

4. Update `.env` file in the project root:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

### 3. Setup Database Tables

Run the following SQL queries in your Supabase SQL Editor:

```sql
-- Create users table
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  nama TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('user', 'admin', 'helpdesk')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create tickets table
CREATE TABLE tickets (
  id TEXT PRIMARY KEY,
  judul TEXT NOT NULL,
  deskripsi TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('open', 'assign', 'in_progress', 'close')),
  id_user TEXT NOT NULL REFERENCES users(id),
  id_admin TEXT REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create comments table
CREATE TABLE comments (
  id TEXT PRIMARY KEY,
  id_tiket TEXT NOT NULL REFERENCES tickets(id),
  id_user TEXT NOT NULL REFERENCES users(id),
  isi TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_tickets_user ON tickets(id_user);
CREATE INDEX idx_tickets_admin ON tickets(id_admin);
CREATE INDEX idx_tickets_status ON tickets(status);
CREATE INDEX idx_comments_tiket ON comments(id_tiket);

-- Enable Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- Create RLS policies (adjust based on your security requirements)
-- For development, you can start with:
CREATE POLICY "Enable all access for development" ON users FOR ALL USING (true);
CREATE POLICY "Enable all access for development" ON tickets FOR ALL USING (true);
CREATE POLICY "Enable all access for development" ON comments FOR ALL USING (true);
```

### 4. Insert Sample Data

```sql
-- Insert sample users
INSERT INTO users (id, email, nama, role) VALUES
  ('u1', 'admin@example.com', 'Admin', 'admin'),
  ('u2', 'naufal@example.com', 'Naufal', 'user'),
  ('u3', 'bagaskara@example.com', 'Bagaskara', 'user');

-- Insert sample tickets
INSERT INTO tickets (id, judul, deskripsi, status, id_user, id_admin) VALUES
  ('t1', 'Internet Mati', 'Router kedip merah sejak pagi.', 'open', 'u2', null),
  ('t2', 'Printer Error', 'Kertas nyangkut di dalam printer.', 'in_progress', 'u3', 'u1');
```

### 5. Run the Application

```bash
# Development mode
flutter run

# Release mode
flutter run --release

# Build APK
flutter build apk --release
```

## Troubleshooting

### Common Issues

1. **"Supabase initialization failed"**
   - Check your `.env` file has correct SUPABASE_URL and SUPABASE_ANON_KEY
   - Verify your Supabase project is active

2. **"Code generation not working"**
   - Run `flutter clean` then `flutter pub get`
   - Run `flutter pub run build_runner build --delete-conflicting-outputs`

3. **"Database connection errors"**
   - Verify RLS policies allow access
   - Check Supabase logs for specific errors

## Development Commands

```bash
# Run with hot reload
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .

# Build for different platforms
flutter build apk --release          # Android APK
flutter build ios --release          # iOS
flutter build web --release          # Web
```

## Next Steps

After setup:
1. Test authentication flow (login/register)
2. Verify database connectivity
3. Test ticket creation and status changes
4. Implement real-time subscriptions for live updates
