require 'sqlite3'
require 'singleton'
require_relative 'questionlike'
require_relative 'questionfollow'
require_relative 'reply'
require_relative 'question'
require_relative 'user'

class QuestionsDB < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end


class ModelBase
  def find_by_id(options)
    QuestionsDB.instance.execute("SELECT #{options[0]} FROM ")
  end
end
