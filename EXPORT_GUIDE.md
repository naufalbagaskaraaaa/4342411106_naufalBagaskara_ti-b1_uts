# Database Export Guide - E-Ticketing Helpdesk

## How to Export Database from Supabase

### Method 1: Using Supabase Dashboard (Recommended)

1. **Login to Supabase Dashboard**
   - Go to [supabase.com](https://supabase.com)
   - Sign in and select your project

2. **Export Database Schema**
   - Navigate to **Database** → **SQL Editor**
   - Click on **"New Query"**
   - Run: `SELECT * FROM information_schema.columns` to see all table structures

3. **Export Complete SQL**
   - Go to **Database** → **Tables**
   - For each table, click on the table name
   - Copy the table structure and insert statements

### Method 2: Using pg_dump (Advanced)

If you have access to PostgreSQL tools:

```bash
# Export entire database
pg_dump -h <your-project>.supabase.co -U postgres -d postgres > database_export.sql

# Export only schema
pg_dump -h <your-project>.supabase.co -U postgres -d postgres --schema-only > schema_export.sql

# Export only data
pg_dump -h <your-project>.supabase.co -U postgres -d postgres --data-only > data_export.sql
```

### Method 3: Using Provided Script

The project includes a `database_setup.sql` file that can be used as:

1. **Documentation**: Shows the complete database structure
2. **Setup**: Can be run in any Supabase project to recreate the database
3. **Export**: Serves as the SQL export requirement for submission

## What to Include in Your Submission

For your project submission, include:

1. **database_setup.sql** (already provided in project)
   - Complete table structures
   - All indexes and constraints
   - Sample data for testing

2. **Optional: Custom Export**
   - If you added custom data during testing
   - Export your specific data using Method 2 above

## Using the Provided SQL Script

The `database_setup.sql` file in your project root contains:

✅ **Database Schema**
- Users table with roles
- Tickets table with status workflow
- Comments table for ticket discussions
- Proper foreign key constraints
- Indexes for performance

✅ **Row Level Security (RLS)**
- Security policies for data protection
- Development-friendly policies

✅ **Functions and Triggers**
- Automatic timestamp updates
- Data consistency enforcement

✅ **Sample Data**
- 3 sample users (admin, user, helpdesk)
- 5 sample tickets in various statuses
- 10 sample comments

✅ **Views**
- Pre-built views for common queries
- Simplifies data access patterns

✅ **Real-time Setup**
- Enabled real-time subscriptions
- Live updates for tickets and comments

## Verification

To verify your database setup:

```sql
-- Check table creation
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public';

-- Check data insertion
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM tickets;
SELECT COUNT(*) FROM comments;

-- Check RLS policies
SELECT policyname, tablename FROM pg_policies
WHERE schemaname = 'public';
```

## Troubleshooting

### Issues with Export

1. **Missing Foreign Keys**
   - Ensure users table is populated before tickets
   - Check all user references exist

2. **RLS Blocking Access**
   - For development: Use the provided policies
   - For production: Create specific user policies

3. **Real-time Not Working**
   - Verify REPLICA IDENTITY is set to FULL
   - Check Supabase real-time is enabled for your project

## Format for Submission

Your final submission should include:

```
e_ticketing_helpdesk/
├── database_setup.sql          ← Required SQL export
├── app-release.apk              ← Built APK
├── lib/                         ← Source code
└── other_project_files
```

The `database_setup.sql` file serves as your database export and documentation in one.
