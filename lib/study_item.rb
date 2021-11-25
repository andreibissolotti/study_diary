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

  def clear
    system("clear")
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

  def self.update
    puts "Menu de edição, digite 0 para cancelar\n\n".black.on_white
    StudyItem.list_itens(all, false)
    puts "Digite o id do item a ser editado:"
    id = gets.chomp
    if id == "0"
      puts "Cancelado!".red
      return self
    end
    
    item = StudyItem.find_by_id(id)
    if item
      clear
      puts "Item selecionado:"
      selected_item = StudyItem.find_by_id(id)
      selected_item.list_details
      begin
        puts "Confirmar seleção? [Y/N]"
        option = gets.chomp.downcase
        if option == "y"
          clear
          puts "(vazio para manter atual)"
          puts "Digite novo titulo:"
          titulo_new = gets.chomp
          unless titulo_new == ""
            item.title = titulo_new
          end

          clear
          begin
            puts "Alterar categoria? [Y/N]"
            option = gets.chomp.chr.downcase
            if option == "y"
              clear
              item.category = Category.take_category
            elsif option == "n"
            else
              puts "Opção invalida, tente novamente"
            end
          end until option == "y" || option == "n"

          clear
          puts "(vazio para manter atual)"
          description_new = Description.take_description("y")
          unless description_new == ""
            item.description = description_new
          end
          clear
          item.update_db.list_new

        elsif option == "n"
          puts "Cancelado! selecione outro item ou cancele"
          clear
          update
        else
          puts "Opção invalida! tente novamente."
        end
      end until option == "y" || option == "n"
    end
  end

  def self.change_stats
    puts "Menu de edição, digite 0 para cancelar\n\n".black.on_white
    StudyItem.list_itens(all, false)
    puts "Digite o id do item a ser editado:"
    id = gets.chomp
    if id == "0"
      puts "Cancelado!".red
      return self
    end
    
    item = StudyItem.find_by_id(id)
    if item
      clear
      puts "Item selecionado:"
      selected_item = StudyItem.find_by_id(id)
      selected_item.list_details
      begin
        puts "Confirmar seleção? [Y/N]"
        option = gets.chomp.downcase
        if option == "y"
          if selected_item.done?
            selected_item.done = 0
          else
            selected_item.done = 1
          end
          clear
          selected_item.update_db.list_details
        elsif option == "n"
          puts "Cancelado! selecione outro item ou cancele"
          clear
          update
        else
          puts "Opção invalida! tente novamente."
        end
      end until option == "y" || option == "n"
    end
  end

  def update_db
    db = SQLite3::Database.open "db/database.db"
    db.execute "
    UPDATE study_itens SET category = #{category.id}, title = '#{title}', descr = '#{description}', done = #{done} WHERE id LIKE #{id}"
    db.close

    puts "Item Atualizado".green
    self
  end
end