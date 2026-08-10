-- Demo history for marketing screenshots. Fictional data only.
-- Bind :user_id to the signed-in account's email before running.
-- Idempotent: clears anything this script previously inserted (ids >= 9000).

PRAGMA foreign_keys = OFF;

DELETE FROM completed_sets WHERE exercise_id >= 9000;
DELETE FROM completed_exercises WHERE id >= 9000;
DELETE FROM completed_workouts WHERE id >= 9000;

-- Twelve sessions, roughly three per fortnight, most recent last.
INSERT INTO completed_workouts (id, title, user_id, date, elapsed_time) VALUES
  (9001, 'Push Day',  :user_id, datetime('now', '-56 days'), '01:04:12'),
  (9002, 'Pull Day',  :user_id, datetime('now', '-54 days'), '00:58:40'),
  (9003, 'Leg Day',   :user_id, datetime('now', '-51 days'), '01:11:05'),
  (9004, 'Push Day',  :user_id, datetime('now', '-47 days'), '01:02:33'),
  (9005, 'Pull Day',  :user_id, datetime('now', '-45 days'), '00:56:18'),
  (9006, 'Leg Day',   :user_id, datetime('now', '-42 days'), '01:09:47'),
  (9007, 'Push Day',  :user_id, datetime('now', '-33 days'), '01:05:51'),
  (9008, 'Pull Day',  :user_id, datetime('now', '-31 days'), '00:59:26'),
  (9009, 'Leg Day',   :user_id, datetime('now', '-28 days'), '01:13:02'),
  (9010, 'Push Day',  :user_id, datetime('now', '-12 days'), '01:03:44'),
  (9011, 'Pull Day',  :user_id, datetime('now',  '-9 days'), '01:00:09'),
  (9012, 'Push Day',  :user_id, datetime('now',  '-3 days'), '01:06:37');

-- Bench Press across every Push session: 80 -> 95 kg, a clean upward trend.
INSERT INTO completed_exercises (id, name, workout_id, base_exercise_id, note, exercise_type)
SELECT 9101, 'Bench Press', 9001, e.id, NULL, 'weight_reps' FROM exercises e
  WHERE e.user_id = :user_id AND e.name = 'Bench Press' AND e.is_custom = 0;
INSERT INTO completed_exercises (id, name, workout_id, base_exercise_id, note, exercise_type)
SELECT 9102, 'Bench Press', 9004, e.id, NULL, 'weight_reps' FROM exercises e
  WHERE e.user_id = :user_id AND e.name = 'Bench Press' AND e.is_custom = 0;
INSERT INTO completed_exercises (id, name, workout_id, base_exercise_id, note, exercise_type)
SELECT 9103, 'Bench Press', 9007, e.id, 'Paused reps felt strong today.', 'weight_reps' FROM exercises e
  WHERE e.user_id = :user_id AND e.name = 'Bench Press' AND e.is_custom = 0;
INSERT INTO completed_exercises (id, name, workout_id, base_exercise_id, note, exercise_type)
SELECT 9104, 'Bench Press', 9010, e.id, NULL, 'weight_reps' FROM exercises e
  WHERE e.user_id = :user_id AND e.name = 'Bench Press' AND e.is_custom = 0;
INSERT INTO completed_exercises (id, name, workout_id, base_exercise_id, note, exercise_type)
SELECT 9105, 'Bench Press', 9012, e.id, NULL, 'weight_reps' FROM exercises e
  WHERE e.user_id = :user_id AND e.name = 'Bench Press' AND e.is_custom = 0;

INSERT INTO completed_sets (set_order, weight, reps, exercise_id, duration) VALUES
  (1, 80.0, 8, 9101, NULL), (2, 80.0, 8, 9101, NULL), (3, 82.5, 6, 9101, NULL),
  (1, 85.0, 8, 9102, NULL), (2, 85.0, 7, 9102, NULL), (3, 87.5, 5, 9102, NULL),
  (1, 87.5, 8, 9103, NULL), (2, 90.0, 6, 9103, NULL), (3, 90.0, 6, 9103, NULL),
  (1, 90.0, 8, 9104, NULL), (2, 92.5, 6, 9104, NULL), (3, 92.5, 5, 9104, NULL),
  (1, 92.5, 8, 9105, NULL), (2, 95.0, 6, 9105, NULL), (3, 95.0, 5, 9105, NULL);

-- Squat across the Leg sessions: 100 -> 115 kg.
INSERT INTO completed_exercises (id, name, workout_id, base_exercise_id, note, exercise_type)
SELECT 9201, 'Squat', 9003, e.id, NULL, 'weight_reps' FROM exercises e
  WHERE e.user_id = :user_id AND e.name = 'Squat' AND e.is_custom = 0;
INSERT INTO completed_exercises (id, name, workout_id, base_exercise_id, note, exercise_type)
SELECT 9202, 'Squat', 9006, e.id, NULL, 'weight_reps' FROM exercises e
  WHERE e.user_id = :user_id AND e.name = 'Squat' AND e.is_custom = 0;
INSERT INTO completed_exercises (id, name, workout_id, base_exercise_id, note, exercise_type)
SELECT 9203, 'Squat', 9009, e.id, NULL, 'weight_reps' FROM exercises e
  WHERE e.user_id = :user_id AND e.name = 'Squat' AND e.is_custom = 0;

INSERT INTO completed_sets (set_order, weight, reps, exercise_id, duration) VALUES
  (1, 100.0, 6, 9201, NULL), (2, 100.0, 6, 9201, NULL), (3, 105.0, 4, 9201, NULL),
  (1, 105.0, 6, 9202, NULL), (2, 107.5, 5, 9202, NULL), (3, 110.0, 4, 9202, NULL),
  (1, 110.0, 6, 9203, NULL), (2, 112.5, 5, 9203, NULL), (3, 115.0, 3, 9203, NULL);

-- Barbell Row on the Pull sessions, for a populated history list.
INSERT INTO completed_exercises (id, name, workout_id, base_exercise_id, note, exercise_type)
SELECT 9301, 'Barbell Row', 9002, e.id, NULL, 'weight_reps' FROM exercises e
  WHERE e.user_id = :user_id AND e.name = 'Barbell Row' AND e.is_custom = 0;
INSERT INTO completed_exercises (id, name, workout_id, base_exercise_id, note, exercise_type)
SELECT 9302, 'Barbell Row', 9008, e.id, NULL, 'weight_reps' FROM exercises e
  WHERE e.user_id = :user_id AND e.name = 'Barbell Row' AND e.is_custom = 0;
INSERT INTO completed_exercises (id, name, workout_id, base_exercise_id, note, exercise_type)
SELECT 9303, 'Barbell Row', 9011, e.id, NULL, 'weight_reps' FROM exercises e
  WHERE e.user_id = :user_id AND e.name = 'Barbell Row' AND e.is_custom = 0;

INSERT INTO completed_sets (set_order, weight, reps, exercise_id, duration) VALUES
  (1, 60.0, 10, 9301, NULL), (2, 62.5, 9, 9301, NULL), (3, 62.5, 8, 9301, NULL),
  (1, 65.0, 10, 9302, NULL), (2, 67.5, 8, 9302, NULL), (3, 67.5, 8, 9302, NULL),
  (1, 70.0, 10, 9303, NULL), (2, 72.5, 8, 9303, NULL), (3, 72.5, 7, 9303, NULL);

PRAGMA foreign_keys = ON;
