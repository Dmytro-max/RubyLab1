require 'yaml'
require 'erb'
require 'json'

class AppConfigLoader
  attr_reader :config_data

  def initialize
    @config_data = {}
    @loaded_files = []
  end

  def config(config_path:, yaml_directory:)
    
    load_default_config(config_path)
    load_config(yaml_directory)
    yield(@config_data) if block_given?
  end

  def pretty_print_config_data
    puts JSON.pretty_generate(@config_data)
  end

  def load_libs
    # Системні бібліотеки
    system_libs = ['date', 'json', 'yaml', 'erb']
    system_libs.each do |lib|
      require lib
    end

    # Локальні бібліотеки
    Dir.glob('../lib/**/*.rb').each do |file|
      next if @loaded_files.include?(file)
      require_relative file
      @loaded_files << file
    end
  rescue StandardError => e
    puts "Failed to load libraries: #{e.message}"
  end

  private

  def load_default_config(config_path)
    erb = ERB.new(File.read(config_path)).result
    @config_data.merge!(YAML.safe_load(erb))
  rescue StandardError => e
    puts "Failed to load default config: #{e.message}"
  end

  def load_config(yaml_directory)
    Dir[File.join(yaml_directory, '*.yaml')].each do |file|
      erb = ERB.new(File.read(file)).result
      @config_data.merge!(YAML.safe_load(erb))
    end
  rescue StandardError => e
    puts "Failed to load config from directory: #{e.message}"
  end
end

# Приклад використання
loader = AppConfigLoader.new
loader.load_libs
loader.config(config_path: 'default_config.yaml', yaml_directory: 'config') do |config|
  # Обробка даних
end
loader.pretty_print_config_data