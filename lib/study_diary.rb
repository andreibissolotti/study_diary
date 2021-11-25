require_relative 'study_item'

CREATE              = 1
LIST                = 2
SEARCH_BY_KEYWORD   = 3
SEARCH_BY_CATEGORY  = 4
DELETE              = 5
UPDATE              = 6
MARK_AS_DONE        = 7
EXIT                = 8

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
  system("clear")
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

def list(itens, see_det)
  itens.sort_by!{|item| item.category.id}
  categorys_array = itens.map{|item| item.category }.uniq
  puts "id - title"
  puts "==============================================".yellow
  categorys_array.each do |category|
    if categorys_array.include?(category)
      puts "==== #{category} ===="
      itens.each do |item| 
        if item.category == category
          puts item
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
      if item.done
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
  when CREATE
    clear
    StudyItem.create
  when LIST
    clear
    list(@itens, true)
  when SEARCH_BY_KEYWORD
    clear
    search_by_keyword
  when SEARCH_BY_CATEGORY
    clear
    search_by_category
  when DELETE
    clear
    delete_item
  when UPDATE
    clear
    update
  when MARK_AS_DONE
    clear
    mark_as_done("")
  end

  unless @option == EXIT
    puts "Pressione 'Enter' para continuar"
    gets
  end
end until @option == EXIT
clear
puts "Obrigado por usar o diario de estudos".black.on_white