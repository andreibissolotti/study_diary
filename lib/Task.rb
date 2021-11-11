require 'sqlite3'

class Task
  attr_accessor :id, :category, :title, :description

  def initialize(id:, category:, title:, description:)
    @id = id
    @category = category
    @title = title
    @description = description
  end

  def self.all
    db = SQLite3::Database.open "db/database.db"
    db.results_as_hash = true
    tasks = db.execute "SELECT * FROM tasks"
    db.close

    tasks.map {|task| new(id: task['id'], category: task['category'], title: task['title'], description: task['descr']) }
  end

  def self.save_to_db(category, title, description)
    db = SQLite3::Database.open "db/database.db"
    db.execute "INSERT INTO tasks (category, title, descr) VALUES('#{ category }', '#{ title }', '#{description}')"
    db.close

    self
  end

  def self.find_by_title(title)
    db = SQLite3::Database.open "db/database.db"
    db.results_as_hash = true
    tasks = db.execute "SELECT * FROM tasks where title LIKE '%#{title}%'"
    db.close

    tasks.map {|task| new(id: task['id'], category: task['category'], title: task['title'], description: task['descr']) }
  end

  def self.find_by_category(category)
    db = SQLite3::Database.open "db/database.db"
    db.results_as_hash = true
    tasks = db.execute "SELECT * FROM tasks where category LIKE '#{category}'"
    db.close

    tasks.map {|task| new(id: task['id'], category: task['category'], title: task['title'], description: task['descr']) }
  end

end