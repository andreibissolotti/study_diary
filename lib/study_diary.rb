require_relative 'study_item'
require 'colorize'

def get_options
  options = <<~OPTIONS
    Cadastrar um item para estudar
    Ver todos os itens cadastrados
    Buscar um termo de estudo
    Buscar por categoria
    Excluir item
    Atualizar item
    Alterar status de um item
    Sair
  OPTIONS

  options.split("\n")
end

def clear
  puts `clear`
end

def menu
  clear
  puts "Bem vindo ao diario de estudos\n\n".black.on_white
  @itens = StudyItem.all

  options_array = get_options
  options_array.each_with_index{ |text, index| puts "[#{ index + 1 }] #{ text }" }
  puts "Escolha uma opção:"

  valid_options = (1..options_array.length).to_a
  input = gets.chomp
  until valid_options.include?(input.to_i)
    puts "Opção inválida, escolha novamente:".yellow
    input = gets.chomp
  end
  @option = input.to_i
end

def create
  puts "Menu de criação, para cancelar digite 0\n\n".black.on_white
  puts "Digite o titulo do item:"
  title = gets.chomp

  if title == "0"
    puts "Cancelado!".red
    return self
  end
  puts "==============================================".yellow

  category = Category.take_category

  begin
    puts "Deseja adicionar alguma descrição? [Y/N]"
    option = gets.chomp.chr.downcase
    description = take_description(option)
  end until option == "y" || option == "n"

  item = StudyItem.new(id: 0, category: category.id, title: title, description: description)
  StudyItem.save_to_db(category.id, title, description)
  puts "Item cadastrado!".green
  list_details(StudyItem.find_by_id(StudyItem.get_id)[0])
end

def take_description(option)
  if option == "y"
    begin
      puts "Digite a descrição (max: 255 caracteres)"
      desc = gets.chomp
      unless desc.length <= 255
        puts "Essa descrição ficou grande de mais, retire #{desc.length - 255} caracteres"
      end
    end until desc.length <= 255
    return desc
  elsif option == "n"
    return ""
  else
    puts "Opção invalida, tente novamente".yellow
  end
end

def list(itens, see_det)
  itens.sort_by!{|item| item.category.id}
  categorys_array = itens.map{|item| [item.category.id, item.category.name]}.uniq
  puts "id - title"
  puts "==============================================".yellow
  categorys_array.each do |category|
    if itens.map{|item| item.category.id.to_i}.uniq.include?(category[0])
      puts "==== ##{ category[0] } - #{ category[1] } ===="
      itens.each do |item| 
        if item.category.id.to_i == category[0]
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
  puts "==============================================".yellow

  if see_det
    puts "Para visualizar detalhes de um item digite o ID: (Enter para ignorar)"
    id = gets.chomp
    unless id == ""
      item = StudyItem.find_by_id(id)[0]
      if item
        list_details(item)
      else
        puts "Id invalido".yellow
      end
    end
  end
end

def list_details(item)
  puts "==============================================".yellow
  puts "==== ##{ item.category.id } - #{ item.category.name } ===="
  puts "#{item.id} - #{item.title}"
  if item.description != ""
    puts "\nDescrição:"
    puts item.description
    puts "\nStatus:"
      if item.done == 1
        puts "Concluido!".green
      else
        puts "Por fazer"
      end
    puts "==============================================".yellow
  else
    begin
      puts "Este item não possui descrição, deseja adcionar uma? [Y/N]"
      option = gets.chomp.chr.downcase
      description = take_description(option)
      item.description = description
      StudyItem.update(item) if option == "y"
    end until option == "y" || option == "n"
  end
end

def search_by_keyword
  puts "Menu de busca, digite # para cancelar\n\n".black.on_white
  puts "Digite o termo desejado:"
  key = gets.chomp.downcase
  if key == "#"
    puts "Cancelado!".red
    return self
  end

  filtered_itens = StudyItem.find_by_keyword(key)

  puts "==============================================".yellow
  if filtered_itens.length == 0
    puts "Nenhum item encontrado."
    puts "==============================================".yellow
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
  puts "Menu de busca, digite # para cancelar\n\n".black.on_white
  categorys_array = Category.get_categorys
  accepted_numbers = Array.new
  categorys_array.each_with_index do |text, index| 
    if index > 0
      puts "##{ index } - #{ text }"
      accepted_numbers << index.to_s
    end
  end
    
  begin
    puts "Digite o número da categoria desejada:"
    category = gets.chomp.downcase
    if category == "#"
      puts "Cancelado!".red
      return self
    elsif accepted_numbers.include?(category)
      filtered_itens = StudyItem.find_by_category(category)
  
      if filtered_itens.length == 0
        puts "Nenhum item encontrado."
        puts "==============================================".yellow
      elsif filtered_itens.length == 1
        puts "1 item encontrado:"
        puts "\n"
        list(filtered_itens, true)
      else
        puts "#{ filtered_itens.length } itens encontrados:"
        puts "\n"
        list(filtered_itens, true)
      end
    else
      puts "Categoria inválida, tente novamente".yellow
    end
  end until accepted_numbers.include?(category)
end

def delete_item
  puts "Menu de exclusão, digite 0 para cancelar\n\n".black.on_white
  list(@itens, false)
  puts "Digite o id do item a ser deletado:"
  id = gets.chomp
  if id == "0"
    puts "Cancelado!".red
    return self
  end
  clear
  puts "Item selecionado:"
  selected_item = StudyItem.find_by_id(id)
  list(selected_item, true)
  begin
    puts "Confirmar exclusão? [Y/N]"
    option = gets.chomp.downcase
    if option == "y"
      StudyItem.delet_by_id(id)
      puts "\n"
      puts "Removido com sucesso".green
    elsif option == "n"
      puts "Cancelado! selecione outro item ou cancele"
      clear
      delete_item
    else
      puts "Opção invalida! tente novamente."
    end
  end until option == "y" || option == "n"
  
end

def update
  puts "Menu de edição, digite 0 para cancelar\n\n".black.on_white
  list(@itens, false)
  puts "Digite o id do item a ser editado:"
  id = gets.chomp
  if id == "0"
    puts "Cancelado!".red
    return self
  end
  item = StudyItem.find_by_id(id)[0]
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
        category_new = Category.take_category
        unless category_new == ""
          item.category.id = category_new.id
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
    puts "Menu de edição, digite 0 para cancelar\n\n".black.on_white
    list(@itens, false)
    puts "Digite o id do item a ser editado:"
    id = gets.chomp
    if id == "0"
      puts "Cancelado!".red
      return self
    end
    item = StudyItem.find_by_id(id)[0]
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
        puts "Opção invalida, tente novamente".yellow
      end
    end until option == "y" || option == "n"

    StudyItem.update(item)
  else
    puts "Id invalido".red
  end
end


begin
  menu
  
  case @option
  when 1
    clear
    create
  when 2
    clear
    list(@itens, true)
  when 3
    clear
    search_by_keyword
  when 4
    clear
    search_by_category
  when 5
    clear
    delete_item
  when 6
    clear
    update
  when 7
    clear
    mark_as_done("")
  end

  unless @option == 8
    puts "Pressione 'Enter' para continuar"
    gets
  end
end until @option == 8
clear
puts "Obrigado por usar o diario de estudos".black.on_white