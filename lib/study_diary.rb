require_relative 'task'

def get_options
  options = <<~OPTIONS
    Cadastrar um item para estudar
    Ver todos os itens cadastrados
    Buscar um termo de estudo
    Buscar por categoria
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

  categorys_array = get_categorys
  categorys_array.each_with_index{ |text, index| puts "##{ index + 1 } - #{ text }" }
  puts "Defina a categoria:"
  
  valid_categorys = (1..categorys_array.length).to_a
  input = gets.chomp
  until valid_categorys.include?(input.to_i)
    puts "Categoria inválida, escolha novamente:"
    input = gets.chomp
  end
  category = input.to_i

  begin
    puts "Deseja adicionar alguma descrição? [Y/N]"
    yes_no = gets.chomp.chr.downcase
    description = add_description(yes_no)
  end until yes_no == "y" || yes_no == "n"

  Task.save_to_db(category, title, description)
end

def add_description(yes_no)
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

def list(itens)
  itens.sort_by!{|item| item.category}
  categorys_array = get_categorys
  puts "id - title"
  puts "==============================="
  categorys_array.each_with_index do |category, index|
    if itens.map{|item| item.category.to_i}.uniq.include?(index + 1)
      puts "==== ##{ index + 1 } - #{ category } ===="
      itens.each {|item| puts "#{item.id} - #{item.title}" if item.category.to_i == index + 1}
      puts "\n"
    end
  end
  puts "==============================="
end

def search_by_keyword
  clear

  puts "Digite o termo desejado:"
  key = gets.chomp.downcase

  filtered_itens = Task.find_by_title(key)

  if filtered_itens.length == 0
    puts "Nenhum item encontrado."
    puts "==============================="
  elsif filtered_itens.length == 1
    puts "1 item encontrado:"
    puts "\n"
    list(filtered_itens)
  else
    puts "#{filtered_itens.length} itens encontrados:"
    puts "\n"
    list(filtered_itens)
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
    list(filtered_itens)
  else
    puts "#{filtered_itens.length} itens encontrados:"
    puts "\n"
    list(filtered_itens)
  end
end



begin
  menu
  
  case @option
  when 1
    create
    puts "Pressione 'Enter' para continuar"
    gets
  when 2
    clear
    list(@itens)
    puts "Pressione 'Enter' para continuar"
    gets
  when 3
    search_by_keyword
    puts "Pressione 'Enter' para continuar"
    gets
  when 4
    search_by_category
    puts "Pressione 'Enter' para continuar"
    gets
  end
end until @option == 5
clear
puts "Obrigado por usar o diario de estudos"