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

require_relative './appConfigLoader.rb'
# require_relative './lib/loggerManager.rb'



loader = AppConfigLoader.new
loader.load_libs

loader.config(config_path: ('./config/default_config.yaml'), yaml_directory: './config') do |config|
#   logging_config = YAML.load_file('../config/log_config.yaml')
  # puts "config: #{config}"
  Project_Hope::LoggerManager.initialize_logger(config["logging"])
  configurator = Configurator.new
  configurator.configure(config["methods_to_run"])
  config["methods_to_run"] = configurator.config

  engine = Engine.new
  # engine.initialize_logging
  engine.run(config)
end


# Приклад використання
# parser = Project_Hope::SimpleWebsiteParser.new('../config/web_parser.yaml')
# puts "Start parsing..."
# parser.start_parse

