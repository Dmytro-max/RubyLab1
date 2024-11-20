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
require_relative 'loggerManager'

puts "directory exists" if Dir.exist?('../config')

# loader = AppConfigLoader.new
# loader.load_libs

# loader.config(config_path: ('../config/default_config.yaml'), yaml_directory: '../config') do |config|
#   logging_config = YAML.load_file('../config/log_config.yaml')
#   MyApplicationName::LoggerManager.initialize_logger(logging_config)
# end

# loader.pretty_print_config_data

# MyApplicationName::LoggerManager.log_processed_file('This is an info message.')
# MyApplicationName::LoggerManager.log_error('This is an error message.')