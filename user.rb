

class User
  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end

  def average_karma
    average = QuestionsDB.instance.execute(<<-SQL, @id)
    SELECT
      (CAST (COUNT(DISTINCT(questions.id)) AS FLOAT)/COUNT(question_likes.user_id)) AS avg_likes
    FROM
      questions LEFT OUTER JOIN
        question_likes ON questions.id = question_likes.question_id
    WHERE
      questions.author_id = ?
    SQL
    average.first['avg_likes']
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def self.find_by_name(fname, lname)
    users = QuestionsDB.instance.execute(<<-SQL, fname, lname)
    SELECT
      *
    FROM
      users
    WHERE
      fname = ? AND lname = ?
    SQL
    return nil if users.empty?

    users.map {|user| User.new(user)}
  end

  def authored_questions
    questions = Question.find_by_author_id(@id)
    return nil if questions.empty?
    questions
  end

  def authored_replies
    replies = Reply.find_by_user_id(@id)
    return nil if replies.empty?
    replies
  end

  def followed_questions
    QuestionFollow.followers_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def save
    raise "#{self} already in  database" if @id
    QuestionsDB.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users(fname, lname)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDB.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDB.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
    SQL
  end
end
