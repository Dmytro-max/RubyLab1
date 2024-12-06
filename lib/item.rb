require 'faker'

module Project_Hope  
  class Item
    include Comparable

    attr_accessor :name, :price, :description, :category, :image_path

    def initialize(attributes = {})
      @name = attributes[:name] || 'Default Name'
      @price = attributes[:price] || 0.0
      @description = attributes[:description] || 'Default Description'
      @category = attributes[:category] || 'Default Category'
      @image_path = attributes[:image_path] || 'default_image_path.jpg'

      yield(self) if block_given?

      # puts "Self: #{self}"
      LoggerManager.log_processed_file("Initialized Item: #{self.inspect}")
    end

    def to_s
      instance_variables.map { |var| "#{var}: #{instance_variable_get(var)}" }.join(', ')
    end

    def to_h
      Hash[instance_variables.map { |var| [var.to_s.delete('@').to_sym, instance_variable_get(var)] }]
    end

    def inspect
      "#<#{self.class}: #{to_s}>"
    end

    def update
      yield(self) if block_given?
    end

    alias_method :info, :to_s

    def self.generate_fake
      fname = Faker::Commerce.product_name
      new(
        name: fname,
        price: Faker::Commerce.price,
        description: Faker::Lorem.sentence,
        category: Faker::Commerce.department,
        image_path: "../catalogs/#{fname}.jpg"
      )
    end

    def <=>(other)
      self.price <=> other.price
    end
  end
end

