require_relative 'study_item'
require 'io/console'

CREATE              = 1
LIST                = 2
SEARCH_BY_KEYWORD   = 3
SEARCH_BY_CATEGORY  = 4
DELETE              = 5
UPDATE              = 6
CHANGE_STATS        = 7
EXIT                = 8

def get_options
  puts <<~OPTIONS
    [#{CREATE}] Cadastrar um item para estudar
    [#{LIST}] Ver todos os itens cadastrados
    [#{SEARCH_BY_KEYWORD}] Buscar um termo de estudo
    [#{SEARCH_BY_CATEGORY}] Buscar por categoria
    [#{DELETE}] Excluir item
    [#{UPDATE}] Atualizar item
    [#{CHANGE_STATS}] Alterar status de um item
    [#{EXIT}] Sair
  OPTIONS
end

def clear
  system("clear")
end

def menu
  clear
  puts "Bem vindo ao diario de estudos\n\n".black.on_white
  @itens = StudyItem.all

  get_options
  puts "Escolha uma opção:"
  input = gets.chomp
  @option = input.to_i
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
    filtered_itens[0].list_details
  else
    puts "#{filtered_itens.length} itens encontrados:"
    puts "\n"
    StudyItem.list_itens(filtered_itens, true)
  end
end

def search_by_category
  puts "Menu de busca, digite 0 para cancelar\n\n".black.on_white
  puts Category.categories
  accepted_numbers = (1..Category.categories.length)
    
  begin
    puts "Digite o número da categoria desejada:"
    category = gets.chomp.to_i
    if category == 0
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
        filtered_itens[0].list_details
      else
        puts "#{ filtered_itens.length } itens encontrados:"
        puts "\n"
        StudyItem.list_itens(filtered_itens, true)
      end
    else
      puts "Categoria inválida, tente novamente".yellow
    end
  end until accepted_numbers.include?(category)
end

def delete_item
  puts "Menu de exclusão, digite 0 para cancelar\n\n".black.on_white
  StudyItem.list_itens(@itens, false)
  print "Digite o id do item a ser deletado: "
  id = gets.chomp
  if id == "0"
    
  end
  clear
  puts "Item selecionado:"
  selected_item = StudyItem.find_by_id(id)
  if selected_item
    selected_item.list_details
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
  else
    puts "Cancelado!".red
    return self
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
    StudyItem.list_itens(@itens, true)
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
    StudyItem.update
  when CHANGE_STATS
    clear
    StudyItem.change_stats
  when EXIT
  else
    puts "\nOpção invalida\n".yellow
  end

  unless @option == EXIT
    puts 'Pressione qualquer tecla para continuar'
    STDIN.getch
  end
end until @option == EXIT
clear
puts "Obrigado por usar o diario de estudos".black.on_white