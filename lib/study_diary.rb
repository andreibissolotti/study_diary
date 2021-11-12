require_relative 'task'
require 'colorize'

def get_options
  options = <<~OPTIONS
    Cadastrar um item para estudar
    Ver todos os itens cadastrados
    Buscar um termo de estudo
    Buscar por categoria
    Excluir item
    Atualizar item
    Alterar status de comcluido de um item
    Sair
  OPTIONS

  options.split("\n")
end

def get_categorys
  categorys = <<~CATEGORYS
    Ruby
    Rails
    HTML
    Javascript
  CATEGORYS

  categorys.split("\n")
end

def clear
  puts `clear`
end

def menu
  clear
  @itens = Task.all

  options_array = get_options
  options_array.each_with_index{ |text, index| puts "[#{ index + 1 }] #{ text }" }
  puts "Escolha uma opção:"

  valid_options = (1..options_array.length).to_a
  input = gets.chomp
  until valid_options.include?(input.to_i)
    puts "Opção inválida, escolha novamente:"
    input = gets.chomp
  end
  @option = input.to_i
end

def create
  clear

  puts "Digite o titulo do item:"
  title = gets.chomp

  puts "==============================="

  category = take_category

  begin
    puts "Deseja adicionar alguma descrição? [Y/N]"
    yes_no = gets.chomp.chr.downcase
    description = take_description(yes_no)
  end until yes_no == "y" || yes_no == "n"

  Task.save_to_db(category, title, description)
end

def take_category
  categorys_array = get_categorys
  categorys_array.each_with_index{ |text, index| puts "##{ index + 1 } - #{ text }" }
  puts "Defina a categoria:"
  
  valid_categorys = (1..categorys_array.length).to_a
  input = gets.chomp
  until valid_categorys.include?(input.to_i)
    puts "Categoria inválida, escolha novamente:"
    input = gets.chomp
  end
  input.to_i
end

def take_description(yes_no)
  if yes_no == "y"
    begin
      puts "Digite a descrição (max: 255 caracteres)"
      desc = gets.chomp
      unless desc.length <= 255
        puts "Essa descrição ficou grande de mais, retire #{desc.length - 255} caracteres"
      end
    end until desc.length <= 255
    return desc
  elsif yes_no == "n"
    return ""
  else
    puts "Opção invalida, tente novamente"
  end
end

def list(itens, see_desc)
  itens.sort_by!{|item| item.category}
  categorys_array = get_categorys
  puts "id - title"
  puts "==============================="
  categorys_array.each_with_index do |category, index|
    if itens.map{|item| item.category.to_i}.uniq.include?(index + 1)
      puts "==== ##{ index + 1 } - #{ category } ===="
      itens.each do |item| 
        if item.category.to_i == index + 1
          if item.done == 1
            puts "#{item.id} - #{item.title}".green
          else
            puts "#{item.id} - #{item.title}"
          end
        end
      end
      puts "\n"
    end
  end
  puts "==============================="

  if see_desc
    puts "Para visualizar a descrição de algum item, digite seu ID: (Enter para ignorar)"
    id = gets.chomp
    unless id == ""
      item = Task.find_by_id(id)
      if item
        list_description(item)
      else
        puts "Id invalido"
      end
    end
  end
end

def list_description(item)
  categorys_array = get_categorys
  puts "==== ##{ item.category } - #{ categorys_array[item.category.to_i - 1] } ===="
  puts "#{item.id} - #{item.title}"
  if item.description != ""
    puts "Descrição:"
    puts item.description
    puts "==============================="
  else
    puts "Este item não possui descrição, deseja adcionar uma? [Y/N]"
    yes_no = gets.chomp.chr.downcase
    description = take_description(yes_no)
    item.description = description
    Task.update(item)
  end
end

def search_by_keyword
  clear

  puts "Digite o termo desejado:"
  key = gets.chomp.downcase

  filtered_itens = Task.find_by_keyword(key)

  if filtered_itens.length == 0
    puts "Nenhum item encontrado."
    puts "==============================="
  elsif filtered_itens.length == 1
    puts "1 item encontrado:"
    puts "\n"
    list(filtered_itens, true)
  else
    puts "#{filtered_itens.length} itens encontrados:"
    puts "\n"
    list(filtered_itens, true)
  end
end

def search_by_category
  clear

  categorys_array = get_categorys
  categorys_array.each_with_index{ |text, index| puts "##{ index + 1 } - #{ text }" }
  puts "Digite a categoria desejada:"
  category = gets.chomp

  filtered_itens = Task.find_by_category(category)

  if filtered_itens.length == 0
    puts "Nenhum item encontrado."
    puts "==============================="
  elsif filtered_itens.length == 1
    puts "1 item encontrado:"
    puts "\n"
    list(filtered_itens, true)
  else
    puts "#{filtered_itens.length} itens encontrados:"
    puts "\n"
    list(filtered_itens, true)
  end
end

def delete_item
  list(@itens, false)
  puts "Digite o id do item a ser deletado:"
  id = gets.chomp
  Task.delet_by_id(id)
  puts "\n"
  puts "Removido com sucesso"
end

def update
  list(@itens, false)
  puts "Digite o id do item a ser editado:"
  id = gets.chomp
  item = Task.find_by_id(id)
  if item
    
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
        category_new = take_category
        unless category_new == ""
          item.category = category_new
        end
      elsif option == "n"
      else
        puts "Opção invalida, tente novamente"
      end
    end until option == "y" || option == "n"

    clear
    puts "(vazio para manter atual)"
    description_new = take_description("y")
    unless description_new == ""
      item.description = description_new
    end

    clear
    mark_as_done(item)
  else
    puts "Id invalido"
  end
end

def mark_as_done(item)
  if item == ""
    list(@itens, false)
    puts "Digite o id do item a ser alterado:"
    id = gets.chomp
    item = Task.find_by_id(id)
  end

  if item
    begin
      puts "Esta tarefa está concluida? [Y/N]"
      option = gets.chomp.chr.downcase
      if option == "y"
        item.done = 1
      elsif option == "n"
        item.done = 0
      else
        puts "Opção invalida, tente novamente"
      end
    end until option == "y" || option == "n"

    Task.update(item)
  else
    puts "Id invalido"
  end
end


begin
  menu
  
  case @option
  when 1
    create
  when 2
    clear
    list(@itens, true)
  when 3
    search_by_keyword
  when 4
    search_by_category
  when 5
    delete_item
  when 6
    update
  when 7
    mark_as_done("")
  end

  unless @option == 8
    puts "Pressione 'Enter' para continuar"
    gets
  end
end until @option == 8
clear
puts "Obrigado por usar o diario de estudos"