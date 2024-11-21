# require 'nokogiri'
# require 'open-uri'

# document = Nokogiri::HTML(URI.open('https://smartcinema.ua/'))
# puts document.css('h2').text

# puts(URI.open('https://smartcinema.ua/'))


require 'logger'
require 'fileutils'
require 'open-uri'
require 'yaml'
require 'mechanize'
require 'nokogiri'
require 'concurrent-ruby'

require_relative 'appConfigLoader'
# require_relative 'loggerManager'


loader = AppConfigLoader.new
loader.load_libs

loader.config(config_path: ('../config/default_config.yaml'), yaml_directory: '../config') do |config|
#   logging_config = YAML.load_file('../config/log_config.yaml')
  Project_Hope::LoggerManager.initialize_logger(config["logging"])
end

# loader.pretty_print_config_data

item1 = Project_Hope::Item.new do |item|
    item.name = 'Item1'
    item.price = 10.0
    item.description = 'Description1'
    item.category = 'Category1'
  end
  
  puts item1.info
  
  item2 = Project_Hope::Item.new(name: 'Item2', price: 20.0, description: 'Description2', category: 'Category2')
  
  item3 = Project_Hope::Item.generate_fake
  
  puts item3.to_h
  
  puts item1 > item2
  
  item1.update do |item|
    item.price = 15.0
  end


# MyApplicationName::LoggerManager.log_processed_file('This is an info message.')
# MyApplicationName::LoggerManager.log_error('This is an error message.')