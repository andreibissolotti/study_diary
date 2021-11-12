require 'sqlite3'
require_relative 'category'

class StudyItem
  attr_accessor :id, :category, :title, :description, :done

  def initialize(id: 0, category: , title:, description:, done: 0)
    if id == 0
      @id = get_id
    else
      @id = id
    end

    @category = Category.new(category)
    @title = title
    @description = description
    @done = done
  end

  def self.all
    db = SQLite3::Database.open "db/database.db"
    db.results_as_hash = true
    study_itens = db.execute "SELECT * FROM study_itens"
    db.close

    study_itens.map {|study_item| new(id: study_item['id'], category: study_item['category'], title: study_item['title'], description: study_item['descr'], done: study_item['done']) }
  end

  def save_to_db(category, title, description)
    db = SQLite3::Database.open "db/database.db"
    db.execute "INSERT INTO study_itens (category, title, descr, done) VALUES('#{ category }', '#{ title }', '#{description}')"
    db.close

    self
  end

  def self.find_by_keyword(keyword)
    db = SQLite3::Database.open "db/database.db"
    db.results_as_hash = true
    study_itens = db.execute "SELECT * FROM study_itens where title LIKE '%#{keyword}%' OR descr LIKE '%#{keyword}%'"
    db.close

    study_itens.map {|study_item| new(id: study_item['id'], category: study_item['category'], title: study_item['title'], description: study_item['descr'], done: study_item['done']) }
  end

  def self.find_by_category(category)
    db = SQLite3::Database.open "db/database.db"
    db.results_as_hash = true
    study_itens = db.execute "SELECT * FROM study_itens where category LIKE '#{category}'"
    db.close

    study_itens.map {|study_item| new(id: study_item['id'], category: study_item['category'], title: study_item['title'], description: study_item['descr'], done: study_item['done']) }
  end

  def self.find_by_id(id)
    db = SQLite3::Database.open "db/database.db"
    db.results_as_hash = true
    study_itens = db.execute "SELECT * FROM study_itens where id LIKE '#{id}'"
    db.close

    study_itens.map {|study_item| new(id: study_item['id'], category: study_item['category'], title: study_item['title'], description: study_item['descr'], done: study_item['done']) }[0]
  end

  def self.delet_by_id(id)
    db = SQLite3::Database.open "db/database.db"
    db.results_as_hash = true
    study_itens = db.execute "DELETE FROM study_itens WHERE id=#{id}"
    db.close
  end

  def self.update(item)
    db = SQLite3::Database.open "db/database.db"
    db.execute "
    UPDATE study_itens
    SET category = #{item.category.id}, title = '#{item.title}', descr = '#{item.description}', done = #{item.done}
    WHERE id LIKE #{item.id}"
    db.close

    puts "Item Atualizado"
  end

  private

  def get_id
    db = SQLite3::Database.open "db/database.db"
    db.results_as_hash = true
    id = db.execute "SELECT MAX(id) FROM study_itens"
    db.close

    id[0]['MAX(id)'].to_i + 1
  end
end