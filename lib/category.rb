class Category
  attr_reader :id, :name

  @@next_id = 1

  def initialize(name)
    @id = @@next_id
    @name = name
    @@next_id += 1
  end

  def to_s
    "##{ id } - #{ name }"
  end

  CATEGORIES = [
    Category.new("Ruby"),
    Category.new("Rails"),
    Category.new("HTML"),
    Category.new("Javascript")
  ]

  def self.categories
    CATEGORIES
  end

  def self.take_category
    CATEGORIES.each{ |category| puts category }
    puts "Defina a categoria:"
    
    valid_categories = (1..CATEGORIES.length).to_a
    input = gets.chomp.to_i
    until valid_categories.include?(input)
      puts "Categoria inválida, escolha novamente:"
      input = gets.chomp.to_i
    end
    
    CATEGORIES[input - 1]
  end
end