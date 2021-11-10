@itens = [{category: 1, title: "Usar hashs"}, {category: 3, title: "Aprender a fazer tabelas"}, {category: 2, title: "Automatizar tabelas no banco de dados"}, 
  {category: 1, title: "Usar banco de dados sem rails"}, {category: 4, title: "Aprender mais sobre uso de APIs"}]

def get_options
  options = <<~OPTIONS
    Cadastrar um item para estudar
    Ver todos os itens cadastrados
    Buscar um termo de estudo
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

def list(itens)
  clear

  itens.sort_by!{|item| item[:category]}
  categorys_array = get_categorys

  categorys_array.each_with_index do |category, index|
    puts "==== ##{ index + 1 } - #{ category } ===="
    itens.each {|item| puts item[:title] if item[:category] == index + 1}
    puts "\n"
  end
  puts "==============================="
end

def search
  clear

  puts "Digite o termo desejado:"
  key = gets.chomp.downcase

  filtered_itens = @itens.map{|item| item if item[:title].downcase.include?(key)}

  if filtered_itens.length == 0
    puts "Nenhum item encontrado.\n"
  elsif filtered_itens.length == 1
    puts "1 item encontrado:\n"
    list(filtered_itens)
  else
    puts "#{filtered_itens.length} itens em contrados:\n"
    list(filtered_itens)
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
    list(@itens)
    puts "Pressione 'Enter' para continuar"
    gets
  end
end until @option == 4
puts "Obrigado por usar o diario de estudos"