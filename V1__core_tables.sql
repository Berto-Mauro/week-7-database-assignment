-- V1: core tables
-- The lab assumes a `students` table already exists, so we create it here
-- and seed a few rows so Step 2 (UPDATE id=1, DELETE id=3) has data to work on.

CREATE TABLE students (
  id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name  TEXT NOT NULL,
  email TEXT UNIQUE
);

INSERT INTO students (name, email) VALUES
  ('Kofi',  'kofi@example.com'),
  ('Amina', 'amina@example.com'),
  ('Juma',  'juma@example.com');
