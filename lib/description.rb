class Description
  def self.take_description(option)
    if option == "y"
      begin
        puts "Digite a descrição (max: 255 caracteres)"
        desc = gets.chomp
        unless desc.length <= 255
          puts "Essa descrição ficou muito grande, retire #{desc.length - 255} caracteres"
        end
      end until desc.length <= 255
      return desc
    elsif option == "n"
      return ""
    else
      puts "Opção invalida, tente novamente".yellow
    end
  end
end