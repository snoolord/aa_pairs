

class QuestionLike
  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| QuestionLike.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def self.likers_for_question_id(question_id)
    likers = QuestionsDB.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        questions JOIN question_likes
          ON questions.id = question_likes.question_id
                  JOIN users
          ON users.id = question_likes.user_id
      WHERE
        questions.id  = ?
    SQL
    likers.map {|liker| User.new(liker)}
  end

  def self.num_likes_for_question_id(question_id)
    likes = QuestionsDB.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*) AS num_likes
      FROM
        question_likes
      WHERE
        question_id = ?
    SQL
    likes.first["num_likes"]
  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionsDB.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        questions JOIN question_likes
          ON questions.id = question_likes.question_id
      WHERE
        question_likes.user_id = ?
    SQL
    questions.map { |question| Question.new(question) }
  end

  def self.most_liked_questions(n)
    most_liked = QuestionsDB.instance.execute(<<-SQL, n)
    SELECT
      questions.*
    FROM
      question_likes
      JOIN questions ON question_likes.question_id = questions.id
    GROUP BY
      questions.id
    ORDER BY
      COUNT(*) DESC
    LIMIT
      ?
    SQL
    most_liked.map {|question| Question.new(question)}
  end
end
