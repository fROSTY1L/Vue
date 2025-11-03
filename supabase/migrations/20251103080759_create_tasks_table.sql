/*
  # Create tasks table

  1. New Tables
    - `tasks`
      - `id` (uuid, primary key) - Unique identifier for each task
      - `title` (text, not null) - Task title/description
      - `completed` (boolean, default false) - Task completion status
      - `created_at` (timestamptz, default now()) - Task creation timestamp
  
  2. Security
    - Enable RLS on `tasks` table
    - Add policy for all users to read all tasks
    - Add policy for all users to insert new tasks
    - Add policy for all users to update tasks
    - Add policy for all users to delete tasks
    
  Note: This is a simple demo app where all users can access all tasks
*/

CREATE TABLE IF NOT EXISTS tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  completed boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view tasks"
  ON tasks
  FOR SELECT
  USING (true);

CREATE POLICY "Anyone can insert tasks"
  ON tasks
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Anyone can update tasks"
  ON tasks
  FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Anyone can delete tasks"
  ON tasks
  FOR DELETE
  USING (true);