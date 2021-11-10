def menu
  options = <<~OPTIONS
  Cadastrar um item para estudar
  Ver todos os itens cadastrados
  Buscar um item de estudo
  Sair
  OPTIONS

  options_array = options.split("\n")
  
  options_array.each_with_index{ |text, index| puts "[#{ index + 1 }] #{ text }" }
  puts "Escolha uma opção:"

  valid_options = (1..options_array.length).to_a
  input = gets.chomp
  until valid_options.include?(input.to_i)
    puts "Opção inválida, escolha novamente:"
    input = gets.chomp
  end
  @option = input
end

menu
puts @option