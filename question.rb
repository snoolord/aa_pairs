

class Question
  attr_accessor :id, :title, :body, :author_id
  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end
  def save
    raise "#{self} already in  database" if @id
    QuestionsDB.instance.execute(<<-SQL, @title, @body, @author_id)
      INSERT INTO
        questions(title, body, author_id)
      VALUES
        (?, ?, ?)
    SQL
    @id = QuestionsDB.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDB.instance.execute(<<-SQL, @title, @body, @author_id, @id)
      UPDATE
        questions
      SET
        title = ?, body = ?, author_id = ?
      WHERE
        id = ?
    SQL
  end

  def self.find_by_author_id(author_id)
    questions = QuestionsDB.instance.execute(<<-SQL, author_id)
    SELECT
      *
    FROM
      questions
    WHERE
      author_id = ?
    SQL
    return nil if questions.empty?

    questions.map {|question| Question.new(question)}
  end

  def author
    name = QuestionsDB.instance.execute(<<-SQL, @author_id)
      SELECT
        id, fname, lname
      FROM
        users
      WHERE
        id = ?
    SQL
    author = User.new(name.first)
  end

  def replies
    replies = Reply.find_by_subject_id(@id)
    return nil if replies.empty?
    replies
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end
  def self.most_liked(n)
    QuestionFollow.most_liked_questions(n)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end
end
