class Configurator
  attr_accessor :config

  def initialize
    @config = {
      run_website_parser: 0,     # Запуск розбору сайту
      run_save_to_csv: 0,        # Збереження даних в CSV форматі
      run_save_to_json: 0,       # Збереження даних в JSON форматі
      run_save_to_yaml: 0,       # Збереження даних в YAML форматі
      run_save_to_sqlite: 0,     # Збереження даних в базі даних SQLite
      run_save_to_mongodb: 0     # Збереження даних в базі даних MongoDB
    }
  end

  def configure(overrides = {})
    overrides.each do |key, value|
      if @config.key?(key)
        @config[key] = value
      else
        puts "Warning: #{key} is not a valid configuration key."
      end
    end
  end

  def self.available_methods
    %i[
      run_website_parser
      run_save_to_csv
      run_save_to_json
      run_save_to_yaml
      run_save_to_sqlite
      run_save_to_mongodb
    ]
  end
end

# Приклад використання
configurator = Configurator.new
puts configurator.config

# Налаштування конфігураційних параметрів
configurator.configure(
  run_website_parser: 1,      # Включити розбір сайту
  run_save_to_csv: 1,         # Включити збереження даних в CSV
  run_save_to_yaml: 1,        # Включити збереження даних в YAML
  run_save_to_sqlite: 1       # Включити збереження даних в базі даних SQLite
)

puts configurator.config

# Виведення доступних методів
puts Configurator.available_methods