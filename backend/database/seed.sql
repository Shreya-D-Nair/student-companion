INSERT INTO confessions (id, anonymous_device_id, content, created_at)
VALUES
  (
    '11111111-1111-4111-8111-111111111111',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    'I miss my family more than I expected after joining college.',
    NOW() - INTERVAL '5 days'
  ),
  (
    '22222222-2222-4222-8222-222222222222',
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    'Today was difficult, but talking to my roommate made me feel better.',
    NOW() - INTERVAL '4 days'
  ),
  (
    '33333333-3333-4333-8333-333333333333',
    'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
    'Does anyone else feel nervous before every lab exam?',
    NOW() - INTERVAL '3 days'
  ),
  (
    '44444444-4444-4444-8444-444444444444',
    'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
    'I finally made a good friend in class today.',
    NOW() - INTERVAL '2 days'
  ),
  (
    '55555555-5555-4555-8555-555555555555',
    'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
    'Living away from home is teaching me a lot about myself.',
    NOW() - INTERVAL '1 day'
  )
ON CONFLICT (id) DO NOTHING;

INSERT INTO interests (id, name, icon_name)
VALUES
  ('10000000-0000-4000-8000-000000000001', 'Coding', 'code'),
  ('10000000-0000-4000-8000-000000000002', 'Music', 'music_note'),
  ('10000000-0000-4000-8000-000000000003', 'Photography', 'camera_alt'),
  ('10000000-0000-4000-8000-000000000004', 'Gaming', 'sports_esports'),
  ('10000000-0000-4000-8000-000000000005', 'Movies', 'movie'),
  ('10000000-0000-4000-8000-000000000006', 'Sports', 'sports_soccer'),
  ('10000000-0000-4000-8000-000000000007', 'Reading', 'menu_book'),
  ('10000000-0000-4000-8000-000000000008', 'Travelling', 'flight'),
  ('10000000-0000-4000-8000-000000000009', 'Design', 'palette'),
  ('10000000-0000-4000-8000-000000000010', 'Dancing', 'celebration'),
  ('10000000-0000-4000-8000-000000000011', 'Fitness', 'fitness_center'),
  ('10000000-0000-4000-8000-000000000012', 'Volunteering', 'volunteer_activism'),
  ('10000000-0000-4000-8000-000000000013', 'Entrepreneurship', 'business_center'),
  ('10000000-0000-4000-8000-000000000014', 'Drawing', 'brush'),
  ('10000000-0000-4000-8000-000000000015', 'Public Speaking', 'record_voice_over'),
  ('10000000-0000-4000-8000-000000000016', 'Writing', 'edit_note')
ON CONFLICT (name) DO NOTHING;

INSERT INTO students (id, name, course, academic_year, bio, avatar_url)
VALUES
  (
    '20000000-0000-4000-8000-000000000001',
    'Anjali Nair',
    'B.Tech CSE',
    'Second Year',
    'Enjoys web development, campus events, and creative photography.',
    NULL
  ),
  (
    '20000000-0000-4000-8000-000000000002',
    'Rahul Menon',
    'B.Com',
    'First Year',
    'Football fan who enjoys multiplayer games and meeting new people.',
    NULL
  ),
  (
    '20000000-0000-4000-8000-000000000003',
    'Sneha Joseph',
    'B.Tech ECE',
    'Third Year',
    'Interested in UI design, sketching, and cultural activities.',
    NULL
  ),
  (
    '20000000-0000-4000-8000-000000000004',
    'Arjun Das',
    'BBA',
    'Second Year',
    'Interested in startups, networking, and learning from new experiences.',
    NULL
  ),
  (
    '20000000-0000-4000-8000-000000000005',
    'Meera Krishnan',
    'BA English',
    'First Year',
    'Book lover who enjoys meaningful conversations and creative writing.',
    NULL
  )
ON CONFLICT (id) DO NOTHING;

INSERT INTO student_interests (student_id, interest_id)
SELECT students.id, interests.id
FROM (
  VALUES
    ('Anjali Nair', 'Coding'),
    ('Anjali Nair', 'Music'),
    ('Anjali Nair', 'Photography'),
    ('Rahul Menon', 'Sports'),
    ('Rahul Menon', 'Gaming'),
    ('Rahul Menon', 'Movies'),
    ('Sneha Joseph', 'Design'),
    ('Sneha Joseph', 'Drawing'),
    ('Sneha Joseph', 'Music'),
    ('Arjun Das', 'Entrepreneurship'),
    ('Arjun Das', 'Public Speaking'),
    ('Arjun Das', 'Travelling'),
    ('Meera Krishnan', 'Reading'),
    ('Meera Krishnan', 'Movies'),
    ('Meera Krishnan', 'Writing')
) AS mappings(student_name, interest_name)
JOIN students ON students.name = mappings.student_name
JOIN interests ON interests.name = mappings.interest_name
ON CONFLICT DO NOTHING;

INSERT INTO support_resources (id, category, description, tips)
VALUES
  (
    '30000000-0000-4000-8000-000000000001',
    'Stay Connected',
    'Small, regular connections can make a new place feel less overwhelming.',
    '["Schedule regular calls with family", "Share small moments from your day", "Stay connected without isolating yourself from campus life"]'::jsonb
  ),
  (
    '30000000-0000-4000-8000-000000000002',
    'Build a Routine',
    'A steady routine can make college life feel more predictable and manageable.',
    '["Maintain regular sleep timings", "Eat meals regularly", "Plan study sessions", "Include breaks", "Make time for enjoyable activities"]'::jsonb
  ),
  (
    '30000000-0000-4000-8000-000000000003',
    'Explore Your Surroundings',
    'Getting familiar with campus can help it feel more like your own space.',
    '["Visit the campus library", "Take a short walk", "Attend a student event", "Join a club", "Explore a nearby cafe"]'::jsonb
  ),
  (
    '30000000-0000-4000-8000-000000000004',
    'Talk to Someone',
    'Speaking with a trusted person can make difficult days easier to handle.',
    '["Speak with a trusted friend", "Talk to your roommate", "Contact a faculty mentor", "Reach out to your college counsellor"]'::jsonb
  ),
  (
    '30000000-0000-4000-8000-000000000005',
    'Quick Mood Boosters',
    'Simple actions can help you reset when you feel low or overwhelmed.',
    '["Listen to a favourite song", "Call someone you trust", "Go for a 10-minute walk", "Drink water", "Take a short break", "Write down three positive things"]'::jsonb
  )
ON CONFLICT (category) DO NOTHING;
