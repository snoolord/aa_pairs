

class QuestionFollow
  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollow.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def self.followers_for_question_id(question_id)
    followers = QuestionsDB.instance.execute(<<-SQL, question_id)
      SELECT
        users.id, users.fname, users.lname
      FROM
        users JOIN question_follows
          ON users.id = question_follows.user_id
      WHERE
        question_follows.question_id = ?
      SQL
      return nil if followers.empty?
      followers.map { |follower| User.new(follower) }
  end

  def self.followers_for_user_id(user_id)
    followed_q = QuestionsDB.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions JOIN question_follows
          ON questions.id = question_follows.user_id
      WHERE
        question_follows.user_id = ?
      SQL
      return nil if followed_q.empty?
      followed_q.map { |follow| Question.new(follow) }
  end

  def self.most_followed_questions(n)
    most_followed = QuestionsDB.instance.execute(<<-SQL, n)
    SELECT
      questions.*
    FROM
      question_follows
      JOIN questions ON question_follows.question_id = questions.id
    GROUP BY
      questions.id
    ORDER BY
      COUNT(*) DESC
    LIMIT
      ?
    SQL
    most_followed.map {|question| Question.new(question)}
  end
end
