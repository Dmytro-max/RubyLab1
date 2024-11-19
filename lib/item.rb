# module MyApplicationName

#   class Item

#     attr_accessor :name, :price, :description, :category, :image_path

#     # parameter array
#     @params_array = [:name, :price, :description, :category, :image_path]

#     def initialize(params = {})
#       @name = params[:name]
#       @price = params[:price]
#       @description = params[:description]
#       @category = params[:category]
#       @image_path = params[:image_path]
#     end

#     def name
#       @name
#     end
#     def price
#       @price
#     end
#     def description
#       @description
#     end
#     def category
#       @category
#     end
#     def image_path
#       @image_path
#     end

#     def to_s
#       print "Name: #{@name}, Price: #{@price}, Description: #{@description}, Category: #{@category}, Image_path: #{@image_path}"
#     end

#     def to_h
#       {
#         name: @name,
#         price: @price,
#         description: @description,
#         category: @category,
#         image_path: @image_path
#       }
#     end

#     def inspect
#       print "Name: #{@name}, 
#       Price: #{@price}, 
#       Description: #{@description}, 
#       Category: #{@category},
#       Image_path: #{@image_path},"
#     end

#     alias :info, :to_s


#     def self.generate_fake

#     end
#     #!!!
#     def update
#       for param in @params_array
#         yield param
#       end

#     end
    
#     def <=>(other)
#       @price <=> other.price
#     end

#   end


#   item = Item.new("apple")
#   puts item.name

# end

require 'faker'
require 'logger'

module MyApplicationName
  class LoggerManager
    def self.log_processed_file(message)
      logger.info(message)
    end

    def self.log_error(message)
      logger.error(message)
    end

    def self.logger
      @logger ||= Logger.new('application.log')
    end
  end

  
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
      new(
        name: Faker::Commerce.product_name,
        price: Faker::Commerce.price,
        description: Faker::Lorem.sentence,
        category: Faker::Commerce.department,
        image_path: Faker::LoremPixel.image
      )
    end

    def <=>(other)
      self.price <=> other.price
    end
  end
end