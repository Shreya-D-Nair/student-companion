CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS confessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  anonymous_device_id TEXT NOT NULL,
  content VARCHAR(300) NOT NULL,
  reaction_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT confessions_content_length_check
    CHECK (char_length(trim(content)) BETWEEN 1 AND 300),
  CONSTRAINT confessions_reaction_count_check
    CHECK (reaction_count >= 0)
);

CREATE TABLE IF NOT EXISTS confession_reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  confession_id UUID NOT NULL REFERENCES confessions(id) ON DELETE CASCADE,
  anonymous_device_id UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT confession_reactions_unique_device
    UNIQUE (confession_id, anonymous_device_id)
);

CREATE TABLE IF NOT EXISTS confession_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  confession_id UUID NOT NULL REFERENCES confessions(id) ON DELETE CASCADE,
  anonymous_device_id UUID NOT NULL,
  reason VARCHAR(200) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT confession_reports_reason_check
    CHECK (char_length(trim(reason)) BETWEEN 1 AND 200),
  CONSTRAINT confession_reports_unique_device
    UNIQUE (confession_id, anonymous_device_id)
);

CREATE TABLE IF NOT EXISTS students (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(120) NOT NULL,
  course VARCHAR(120) NOT NULL,
  academic_year VARCHAR(60) NOT NULL,
  bio VARCHAR(300) NOT NULL,
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT students_name_check CHECK (char_length(trim(name)) > 0),
  CONSTRAINT students_course_check CHECK (char_length(trim(course)) > 0),
  CONSTRAINT students_academic_year_check CHECK (char_length(trim(academic_year)) > 0),
  CONSTRAINT students_bio_check CHECK (char_length(trim(bio)) > 0)
);

CREATE TABLE IF NOT EXISTS interests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(80) NOT NULL UNIQUE,
  icon_name VARCHAR(80) NOT NULL,
  CONSTRAINT interests_name_check CHECK (char_length(trim(name)) > 0),
  CONSTRAINT interests_icon_name_check CHECK (char_length(trim(icon_name)) > 0)
);

CREATE TABLE IF NOT EXISTS student_interests (
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  interest_id UUID NOT NULL REFERENCES interests(id) ON DELETE CASCADE,
  PRIMARY KEY (student_id, interest_id)
);

CREATE TABLE IF NOT EXISTS anonymous_user_interests (
  anonymous_device_id UUID NOT NULL,
  interest_id UUID NOT NULL REFERENCES interests(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (anonymous_device_id, interest_id)
);

CREATE TABLE IF NOT EXISTS connect_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  anonymous_device_id UUID NOT NULL,
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  status VARCHAR(20) NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT connect_requests_status_check
    CHECK (status IN ('pending', 'accepted', 'declined')),
  CONSTRAINT connect_requests_unique_device_student
    UNIQUE (anonymous_device_id, student_id)
);

CREATE TABLE IF NOT EXISTS support_resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category VARCHAR(120) NOT NULL UNIQUE,
  description TEXT NOT NULL,
  tips JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT support_resources_category_check CHECK (char_length(trim(category)) > 0),
  CONSTRAINT support_resources_description_check CHECK (char_length(trim(description)) > 0),
  CONSTRAINT support_resources_tips_check CHECK (jsonb_typeof(tips) = 'array')
);

DROP TRIGGER IF EXISTS confessions_set_updated_at ON confessions;
DROP FUNCTION IF EXISTS set_updated_at();

CREATE INDEX IF NOT EXISTS idx_confessions_created_at_desc
  ON confessions (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_confession_reactions_confession_id
  ON confession_reactions (confession_id);

CREATE INDEX IF NOT EXISTS idx_confession_reports_confession_id
  ON confession_reports (confession_id);

CREATE INDEX IF NOT EXISTS idx_student_interests_interest_id
  ON student_interests (interest_id);

CREATE INDEX IF NOT EXISTS idx_anonymous_user_interests_device_id
  ON anonymous_user_interests (anonymous_device_id);

CREATE INDEX IF NOT EXISTS idx_connect_requests_device_id
  ON connect_requests (anonymous_device_id);

CREATE INDEX IF NOT EXISTS idx_support_resources_category
  ON support_resources (category);
