-- Create quiz table
CREATE TABLE quiz (
  id BIGSERIAL PRIMARY KEY,
  question TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create quiz_option table for storing answer options
CREATE TABLE quiz_option (
  id BIGSERIAL PRIMARY KEY,
  quiz_id BIGINT NOT NULL REFERENCES quiz(id) ON DELETE CASCADE,
  option_text TEXT NOT NULL,
  is_correct BOOLEAN DEFAULT FALSE,
  option_index INT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO quiz (question) VALUES
  ('What is the capital of France?'),
  ('Which planet is known as the Red Planet?'),
  ('What is the largest ocean on Earth?'),
  ('Who painted the Mona Lisa?'),
  ('What is the smallest prime number?');

-- Insert options for question 1
INSERT INTO quiz_option (quiz_id, option_text, is_correct, option_index) VALUES
  (1, 'London', FALSE, 0),
  (1, 'Paris', TRUE, 1),
  (1, 'Berlin', FALSE, 2);

-- Insert options for question 2
INSERT INTO quiz_option (quiz_id, option_text, is_correct, option_index) VALUES
  (2, 'Venus', FALSE, 0),
  (2, 'Mars', TRUE, 1),
  (2, 'Jupiter', FALSE, 2);

-- Insert options for question 3
INSERT INTO quiz_option (quiz_id, option_text, is_correct, option_index) VALUES
  (3, 'Atlantic', FALSE, 0),
  (3, 'Indian', FALSE, 1),
  (3, 'Pacific', TRUE, 2);

-- Insert options for question 4
INSERT INTO quiz_option (quiz_id, option_text, is_correct, option_index) VALUES
  (4, 'Vincent van Gogh', FALSE, 0),
  (4, 'Leonardo da Vinci', TRUE, 1),
  (4, 'Pablo Picasso', FALSE, 2);

-- Insert options for question 5
INSERT INTO quiz_option (quiz_id, option_text, is_correct, option_index) VALUES
  (5, '0', FALSE, 0),
  (5, '1', FALSE, 1),
  (5, '2', TRUE, 2);

-- Enable RLS (Row Level Security) - disabled for now since authentication is skipped
ALTER TABLE quiz DISABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_option DISABLE ROW LEVEL SECURITY;
