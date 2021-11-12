require 'sqlite3'

class Task
  attr_accessor :id, :category, :title, :description, :done

  def initialize(id:, category:, title:, description:, done: 0)
    @id = id
    @category = category
    @title = title
    @description = description
    @done = done
  end

  def self.all
    db = SQLite3::Database.open "db/database.db"
    db.results_as_hash = true
    tasks = db.execute "SELECT * FROM tasks"
    db.close

    tasks.map {|task| new(id: task['id'], category: task['category'], title: task['title'], description: task['descr'], done: task['done']) }
  end

  def self.save_to_db(category, title, description)
    db = SQLite3::Database.open "db/database.db"
    db.execute "INSERT INTO tasks (category, title, descr, done) VALUES('#{ category }', '#{ title }', '#{description}', #{0})"
    db.close

    self
  end

  def self.find_by_keyword(keyword)
    db = SQLite3::Database.open "db/database.db"
    db.results_as_hash = true
    tasks = db.execute "SELECT * FROM tasks where title LIKE '%#{keyword}%' OR descr LIKE '%#{keyword}%'"
    db.close

    tasks.map {|task| new(id: task['id'], category: task['category'], title: task['title'], description: task['descr'], done: task['done']) }
  end

  def self.find_by_category(category)
    db = SQLite3::Database.open "db/database.db"
    db.results_as_hash = true
    tasks = db.execute "SELECT * FROM tasks where category LIKE '#{category}'"
    db.close

    tasks.map {|task| new(id: task['id'], category: task['category'], title: task['title'], description: task['descr'], done: task['done']) }
  end

  def self.find_by_id(id)
    db = SQLite3::Database.open "db/database.db"
    db.results_as_hash = true
    tasks = db.execute "SELECT * FROM tasks where id LIKE '#{id}'"
    db.close

    tasks.map {|task| new(id: task['id'], category: task['category'], title: task['title'], description: task['descr'], done: task['done']) }[0]
  end

  def self.delet_by_id(id)
    db = SQLite3::Database.open "db/database.db"
    db.results_as_hash = true
    tasks = db.execute "DELETE FROM tasks WHERE id=#{id}"
    db.close
  end

  def self.update(item)
    db = SQLite3::Database.open "db/database.db"
    db.execute "
    UPDATE tasks
    SET category = #{item.category}, title = '#{item.title}', descr = '#{item.description}', done = #{item.done}
    WHERE id LIKE #{item.id}"
    db.close

    puts "Item Atualizado"
  end
end