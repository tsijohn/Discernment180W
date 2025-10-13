-- Create app_feedback table for storing user feedback
CREATE TABLE IF NOT EXISTS app_feedback (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL,
    user_name TEXT,
    user_email TEXT,
    feedback_type TEXT NOT NULL,
    feedback_text TEXT NOT NULL,
    app_version TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    resolved BOOLEAN DEFAULT FALSE,
    developer_notes TEXT
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_app_feedback_user_id ON app_feedback(user_id);
CREATE INDEX IF NOT EXISTS idx_app_feedback_created_at ON app_feedback(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_app_feedback_type ON app_feedback(feedback_type);

-- Enable Row Level Security
ALTER TABLE app_feedback ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to insert their own feedback
CREATE POLICY "Users can insert their own feedback" ON app_feedback
    FOR INSERT WITH CHECK (auth.uid()::text = user_id);

-- Create policy to allow users to view their own feedback
CREATE POLICY "Users can view their own feedback" ON app_feedback
    FOR SELECT USING (auth.uid()::text = user_id);

-- Optional: Create a policy for admin/developer access
-- Uncomment and modify the email as needed
-- CREATE POLICY "Developer can view all feedback" ON app_feedback
--     FOR ALL USING (auth.email() = 'developer@example.com');