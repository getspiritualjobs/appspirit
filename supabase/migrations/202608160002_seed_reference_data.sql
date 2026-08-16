insert into public.spiritual_gifts (id, name, description, biblical_description, scripture_reference) values
  ('prophecy', 'Prophecy', 'Truth-telling, conviction, discernment, and moral courage.', 'Romans 12 describes prophecy as a grace to be exercised in proportion to faith.', 'Romans 12:6'),
  ('serving', 'Serving', 'Practical help, reliability, and tangible care.', 'Romans 12 names service as a grace that builds others through faithful action.', 'Romans 12:7'),
  ('teaching', 'Teaching', 'Helping people understand ideas, develop knowledge, and grow through learning.', 'Romans 12 includes teaching as a grace for forming understanding.', 'Romans 12:7'),
  ('encouragement', 'Encouragement', 'Strengthening people with hope, wise words, and next steps.', 'Romans 12 names exhortation as a gift of strengthening and urging others forward.', 'Romans 12:8'),
  ('giving', 'Giving', 'Generosity, stewardship, and open-handed use of resources.', 'Romans 12 describes giving with generosity.', 'Romans 12:8'),
  ('leadership', 'Leadership', 'Direction, initiative, responsibility, and coordinated action.', 'Romans 12 calls leaders to lead diligently.', 'Romans 12:8'),
  ('mercy', 'Mercy', 'Compassion, patience, empathy, and dignifying presence.', 'Romans 12 describes mercy as something to practice cheerfully.', 'Romans 12:8')
on conflict (id) do update set
  name = excluded.name,
  description = excluded.description,
  biblical_description = excluded.biblical_description,
  scripture_reference = excluded.scripture_reference;

insert into public.assessment_questions (id, question_text, display_order) values
  ('q1', 'I enjoy explaining ideas until they finally click for someone.', 1),
  ('q2', 'I naturally notice practical needs and want to help.', 2),
  ('q3', 'People often come to me when they need encouragement.', 3),
  ('q4', 'I am comfortable taking responsibility when a group needs direction.', 4),
  ('q5', 'I feel deeply affected when I see someone struggling.', 5),
  ('q6', 'I enjoy using my resources to help others succeed.', 6),
  ('q7', 'I am willing to speak up about what I believe is right, even when it is uncomfortable.', 7),
  ('q8', 'I like turning complicated information into a simple path forward.', 8),
  ('q9', 'I would rather help behind the scenes than be recognized publicly.', 9),
  ('q10', 'When someone feels stuck, I look for a practical next step they can take.', 10)
on conflict (id) do update set question_text = excluded.question_text, display_order = excluded.display_order;

insert into public.question_gift_weights (question_id, gift_id, weight, reverse_scored) values
  ('q1', 'teaching', 1.0, false),
  ('q2', 'serving', 1.0, false),
  ('q3', 'encouragement', 1.0, false),
  ('q4', 'leadership', 1.0, false),
  ('q5', 'mercy', 1.0, false),
  ('q6', 'giving', 1.0, false),
  ('q7', 'prophecy', 1.0, false),
  ('q8', 'teaching', 0.8, false),
  ('q8', 'leadership', 0.4, false),
  ('q9', 'serving', 0.9, false),
  ('q10', 'encouragement', 0.8, false)
on conflict (question_id, gift_id) do update set weight = excluded.weight, reverse_scored = excluded.reverse_scored;

insert into public.careers (id, title, description, category, salary_low, salary_high, education_requirement, responsibilities, work_environment, interests, values) values
  ('learning-and-development-specialist', 'Learning and Development Specialist', 'Helping people learn and grow at work.', 'Education', 58000, 98000, 'Bachelor degree often preferred', '["Design training", "Facilitate workshops", "Measure learning outcomes"]', 'Corporate, nonprofit, or remote training teams', '{Teaching,Business,Communication}', '{"Helping others","Work-life balance"}'),
  ('corporate-trainer', 'Corporate Trainer', 'Building practical training experiences for adult learners.', 'Education', 54000, 95000, 'Bachelor degree or equivalent experience', '["Facilitate training", "Create learning materials", "Coach learners"]', 'Classroom, hybrid, or remote learning environments', '{Teaching,Business}', '{"Helping others","Leadership opportunities"}'),
  ('career-coach', 'Career Coach', 'Helping people identify strengths and take vocational next steps.', 'Counseling', 50000, 105000, 'Certification helpful', '["Coach clients", "Clarify goals", "Support job-search actions"]', 'Private practice, workforce programs, or universities', '{"Helping people",Communication}', '{"Flexible schedule","Helping others"}')
on conflict (id) do update set
  title = excluded.title,
  description = excluded.description,
  category = excluded.category,
  salary_low = excluded.salary_low,
  salary_high = excluded.salary_high,
  education_requirement = excluded.education_requirement,
  responsibilities = excluded.responsibilities,
  work_environment = excluded.work_environment,
  interests = excluded.interests,
  values = excluded.values;

insert into public.career_gift_weights (career_id, gift_id, weight) values
  ('learning-and-development-specialist', 'teaching', 95),
  ('learning-and-development-specialist', 'encouragement', 82),
  ('learning-and-development-specialist', 'leadership', 69),
  ('corporate-trainer', 'teaching', 95),
  ('corporate-trainer', 'encouragement', 82),
  ('corporate-trainer', 'leadership', 69),
  ('career-coach', 'encouragement', 95),
  ('career-coach', 'teaching', 82),
  ('career-coach', 'leadership', 69)
on conflict (career_id, gift_id) do update set weight = excluded.weight;
