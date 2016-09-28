

class Reply
  attr_accessor :id, :body, :subject_id, :parent_reply, :user_id
  def self.all
    data = QuestionsDB.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @body = options['body']
    @subject_id = options['subject_id']
    @parent_reply = options['parent_reply']
    @user_id = options['user_id']
  end

  def save
    raise "#{self} already in  database" if @id
    QuestionsDB.instance.execute(<<-SQL, @body, @subject_id, @parent_reply, @user_id)
      INSERT INTO
        replies(body, subject_id, parent_reply, user_id)
      VALUES
        (?, ?, ?, ?)
    SQL
    @id = QuestionsDB.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDB.instance.execute(<<-SQL, @body, @subject_id, @parent_reply, @user_id, @id)
      UPDATE
        replies
      SET
        body = ?, subject_id = ?, parent_reply = ?, user_id = ?
      WHERE
        id = ?
    SQL
  end

  def self.find_by_user_id(user_id)
    replies = QuestionsDB.instance.execute(<<-SQL, user_id)
    SELECT
      *
    FROM
      replies
    WHERE
      user_id = ?
    SQL
    return nil if replies.empty?

    replies.map {|reply| Reply.new(reply)}
  end

  def self.find_by_subject_id(subject_id)
    replies = QuestionsDB.instance.execute(<<-SQL, subject_id)
    SELECT
      *
    FROM
      replies
    WHERE
      subject_id = ?
    SQL
    return nil if replies.empty?

    replies.map {|reply| Reply.new(reply)}
  end

  def author
    name = QuestionsDB.instance.execute(<<-SQL, @user_id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    User.new(name.first)
  end

  def question
    question = QuestionsDB.instance.execute(<<-SQL, @question_id)
    SELECT
      *
    FROM
      questions
    WHERE
      id = ?
    SQL
    Question.new(question.first)
  end

  def parent_reply
    parent_reply = QuestionsDB.instance.execute(<<-SQL, @parent_reply)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil if parent_reply.empty?
    Reply.new(parent_reply.first)
  end

  def child_replies
    child_replies = QuestionsDB.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply = @id
    SQL
    return nil if child_replies.empty?
    child_replies.map { |child| Reply.new(child) }
  end
end
