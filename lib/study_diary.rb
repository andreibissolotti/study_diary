@itens = [{category: 1, title: "asdasf"}, {category: 3, title: "title"}, {category: 2, title: "title"}, {category: 1, title: "title"}, {category: 4, title: "title"}]

def get_options
  options = <<~OPTIONS
    Cadastrar um item para estudar
    Ver todos os itens cadastrados
    Buscar um item de estudo
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

  @itens << {category: category, title: title}
end

def list
  clear

  @itens.sort_by!{|item| item[:category]}
  categorys_array = get_categorys

  categorys_array.each_with_index do |category, index|
    puts "==== ##{ index + 1 } - #{ category } ===="
    @itens.each {|item| puts item[:title] if item[:category] == index + 1}
    puts "\n"
  end
  puts "==============================="
end



begin
  menu

  case @option
  when 1
    create
    puts "Pressione 'Enter' para continuar"
    gets
  when 2
    list
    puts "Pressione 'Enter' para continuar"
    gets
  end
end until @option == 4
puts "Obrigado por usar o diario de estudos"