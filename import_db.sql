DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  subject_id INTEGER NOT NULL,
  parent_reply INTEGER,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (subject_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
  users(fname, lname)
VALUES
  ('Fan', 'Song'),
  ('Winston',  'Zhao'),
  ('Doug', 'Bill'),
  ('Henry', 'Tom');

INSERT INTO
  questions(title, body, author_id)
VALUES
  ('age','How old are you', (SELECT id FROM users WHERE fname = 'Winston' AND lname = 'Zhao')),
  ('home', 'Where are you from', (SELECT id FROM users WHERE fname = 'Fan' AND lname = 'Song')),
  ('food', 'what''s your favorite food', 1),
  ('movie', 'what''s your favorite movie', 1);

INSERT INTO
  question_follows(question_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'age'), (SELECT id FROM users WHERE fname = 'Winston' AND lname = 'Zhao')),
  ((SELECT id FROM questions WHERE title = 'home'), (SELECT id FROM users WHERE fname = 'Fan' AND lname = 'Song')),
  (1,3),
  (1,4);

INSERT INTO
  replies(body, subject_id, parent_reply, user_id)
VALUES
  ('25', (SELECT id FROM questions WHERE title = 'age'), NULL, (SELECT id FROM users WHERE fname = 'Winston' AND lname = 'Zhao')),
  ('earth', (SELECT id FROM questions WHERE title = 'home'), NULL, (SELECT id FROM users WHERE fname = 'Fan' AND lname = 'Song')),
  ('earth', (SELECT id FROM questions WHERE title = 'home'), 2, (SELECT id FROM users WHERE fname = 'Fan' AND lname = 'Song'));

INSERT INTO
  question_likes(question_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'home'), (SELECT id FROM users WHERE fname = 'Winston' AND lname = 'Zhao')),
  ((SELECT id FROM questions WHERE title = 'age'), (SELECT id FROM users WHERE fname = 'Fan' AND lname = 'Song')),
  (1,3),
  (1,4),
  (2,4),
  (3,4),
  (4,1);
