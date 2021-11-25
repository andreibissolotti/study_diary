require 'sqlite3'
require 'colorize'
require_relative 'category'
require_relative 'description'

class StudyItem
  attr_accessor :id, :category, :title, :description, :done

  def initialize(id: 0, category:, title:, description:, done: 0)
    @id = id
    @category = category
    @title = title
    @description = description
    @done = done
  end

  def done?
    done == 1
  end

  def list_details
    puts <<~TEXT
      ==============================================
      #{ title } - #{ category.name }

      === Descrição ===
      #{ description }

      === Status ===
      #{ done? ? "Finalizada".green : "Pendente" }
      ==============================================
    TEXT
  end

  def list_new
    puts <<~TEXT
      ==============================================
      #{ title } - #{ category.name }

      === Descrição ===
      #{ description }
      ==============================================
    TEXT
  end

  def to_s
    done? ? "##{ id } - #{title}".green : "##{ id } - #{title}"
  end

  def self.create
    puts "Menu de criação, para cancelar digite 0 no titulo\n\n".black.on_white
    print "Digite o titulo do item: "
    title = gets.chomp
  
    if title == "0"
      puts "Cancelado!".red
      return nil
    end
    puts "==============================================".yellow
  
    category = Category.take_category
  
    begin
      print "Deseja adicionar alguma descrição? [Y/N]   "
      option = gets.chomp.chr.downcase
      description = Description.take_description(option)
    end until option == "y" || option == "n"
  
    item = StudyItem.new(category: category, title: title, description: description)
    item.save_to_db
  end

  def self.list_itens(itens, see_desc)
    itens.sort_by!{|item| item.category.id}
    categorys_array = itens.map{|item| item.category }.uniq
    puts "id - title"
    puts "==============================================".yellow
    categorys_array.each do |category|
      puts "==== #{category} ===="
      itens.each do |item| 
        if item.category == category
          puts item
        end
      end
      puts "\n"
    end

    if see_desc
      puts "Para ignorar deixe em branco..."
      print "Para ver os detalhes de algum item, insira seu id: "
      id = gets.to_i
      itens.each{|item| item.list_details if item.id == id}
    end
    puts "==============================================".yellow
  end

  def self.all
    db = SQLite3::Database.open "db/database.db"
    db.results_as_hash = true
    study_itens = db.execute "SELECT * FROM study_itens"
    db.close

    study_itens.map do |study_item| 
      new(
        id: study_item['id'],
        category: Category.get(study_item['category']),
        title: study_item['title'],
        description: study_item['descr'],
        done: study_item['done']
      )
    end
  end

  def save_to_db
    db = SQLite3::Database.open "db/database.db"
    db.execute "INSERT INTO study_itens (category, title, descr, done) VALUES('#{ category.id }', '#{ title }', '#{ description }', #{ done })"
    db.close

    self.list_new
  end

  def self.find_by_keyword(keyword)
    db = SQLite3::Database.open "db/database.db"
    db.results_as_hash = true
    study_itens = db.execute "SELECT * FROM study_itens where title LIKE '%#{keyword}%' OR descr LIKE '%#{keyword}%'"
    db.close

    study_itens.map do |study_item| 
      new(
        id: study_item['id'],
        category: Category.get(study_item['category']),
        title: study_item['title'],
        description: study_item['descr'],
        done: study_item['done']
      )
    end
  end

  def self.find_by_category(category)
    db = SQLite3::Database.open "db/database.db"
    db.results_as_hash = true
    study_itens = db.execute "SELECT * FROM study_itens where category LIKE '#{category}'"
    db.close

    study_itens.map do |study_item| 
      new(
        id: study_item['id'],
        category: Category.get(study_item['category']),
        title: study_item['title'],
        description: study_item['descr'],
        done: study_item['done']
      )
    end
  end

  def self.find_by_id(id)
    db = SQLite3::Database.open "db/database.db"
    db.results_as_hash = true
    study_item = db.execute "SELECT * FROM study_itens where id = '#{id}'"
    db.close
    if !study_item.empty?
      return new(
                  id: study_item[0]['id'],
                  category: Category.get(study_item[0]['category']),
                  title: study_item[0]['title'],
                  description: study_item[0]['descr'],
                  done: study_item[0]['done']
                )
    end
    false
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
    UPDATE study_itens SET category = #{item.category.id}, title = '#{item.title}', descr = '#{item.description}', done = #{item.done} WHERE id LIKE #{item.id}"
    db.close

    puts "Item Atualizado".green
  end
end