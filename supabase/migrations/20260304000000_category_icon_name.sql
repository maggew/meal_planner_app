-- Add icon_name column to categories table
ALTER TABLE categories ADD COLUMN IF NOT EXISTS icon_name TEXT;
