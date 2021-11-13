class Category
  attr_accessor :id
  attr_reader :name

  def initialize(id)
    @id = id
    @name = get_category_name(id)
  end

  def self.take_category
    categorys_array = get_categorys
    categorys_array.each_with_index{ |text, index| puts "##{ index } - #{ text }" if index > 0}
    puts "Defina a categoria:"
    
    valid_categorys = (1..categorys_array.length).to_a
    input = gets.chomp
    until valid_categorys.include?(input.to_i)
      puts "Categoria inválida, escolha novamente:"
      input = gets.chomp
    end
    
    Category.new(input.to_i)
  end

  def get_category_name(id)
    name_options = Category.get_categorys

    name_options[id]
  end

  def self.get_categorys
    categorys = <<~CATEGORYS
      ---
      Ruby
      Rails
      HTML
      Javascript
    CATEGORYS
  
    categorys.split("\n")
  end
end