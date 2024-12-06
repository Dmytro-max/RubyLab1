class Configurator
  attr_accessor :config

  def initialize
    @config = {
      # run_website_parser: 0,     # Запуск розбору сайту
      run_save_to_csv: 0,        # Збереження даних в CSV форматі
      run_save_to_json: 0,       # Збереження даних в JSON форматі
      run_save_to_yaml: 0,       # Збереження даних в YAML форматі
      run_save_to_sqlite: 0,     # Збереження даних в базі даних SQLite
      run_save_to_mongodb: 0     # Збереження даних в базі даних MongoDB
    }
  end

  def configure(overrides = {})
  @config.each do |key, value|
    # puts "Config type:#{(key.class)} to #{value}"
  end
    overrides.each do |key, value|
      key = key.to_sym
      # puts "Configuring type:#{(key.class)} to #{value}"
      if @config.key?(key)
        @config[key] = value
      else
        puts "Warning: #{key} is not a valid configuration key."
      end
    end
  end

  def self.available_methods
    %i[
      # run_website_parser
      run_save_to_csv
      run_save_to_json
      run_save_to_yaml
      run_save_to_sqlite
      run_save_to_mongodb
    ]
  end
end
