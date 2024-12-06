require 'zip'
require 'sidekiq'
require 'pony'
# require_relative 'simpleWebsiteParser'
# require_relative 'databaseConnector'
# require_relative 'loggerManager'

class Engine
  attr_accessor :config, :item_collection

  # @config_file
  # @config_directory

  # def initialize(config_file='application.yaml')
  #   # puts "Dir: #{@config_directory}"
  #   # puts "File: #{@config_file}"
  #   @config_file = config_file
  #   initialize_logging
  #   @config = load_config
  # end

  # def load_config
  #   config_directory = 'config'
  #   config_file = 'application.yaml'
  #   config_path = "./#{config_directory}/#{config_file}"
  #   # config_path = File.join(@config_directory, @config_file)
  #   puts "Config path: #{File.absolute_path(config_path)}"
  #   YAML.load_file(config_path).tap do
  #     Project_Hope::LoggerManager.log_processed_file("Configuration loaded from #{@config_file}")
  #   end
  # rescue StandardError => e
  #   Project_Hope::LoggerManager.log_error("Failed to load configuration: #{e.message}")
  #   raise "Failed to load configuration: #{e.message}"
  # end

  def run_methods(config_params)
    @item_collection = run_website_parser
    # puts "Item collection: #{@item_collection}"
    config_params.each do |method_name, should_run|
      method_name = method_name.to_sym
      # puts "Method: #{method_name} - #{should_run}"
      # puts "Respond to: #{respond_to?(method_name, true)}"
      if should_run == 1
        if respond_to?(method_name, true)
          send(method_name)
        else
          Project_Hope::LoggerManager.log_error("Method #{method_name} not found")
        end
      end
    end
    rescue StandardError => e
      Project_Hope::LoggerManager.log_error("Error running methods: #{e.message}")
    raise "Error running methods: #{e.message}"
  end

  def run(config)
    # puts "Config: #{config}"
    @config = config
    initialize_logging
    Project_Hope::LoggerManager.log_processed_file("Engine started")
    # db_connector = DatabaseConnector.new(@config_file)
    # db_connector.connect_to_database

    # puts "Config: #{@config}"
    run_methods(@config["methods_to_run"])

    # db_connector.close_connection
    # archive_results
    # send_archive_in_background

    Project_Hope::LoggerManager.log_processed_file("Engine finished")
  rescue StandardError => e
    Project_Hope::LoggerManager.log_error("Engine run failed: #{e.message}")
    raise "Engine run failed: #{e.message}"
  end

  private

  def initialize_logging
    Project_Hope::LoggerManager.initialize_logger(@config['logging'])
    # LoggerManager.logger
    Project_Hope::LoggerManager.log_processed_file("Logging initialized")
  end

  def run_website_parser
    # puts "Config: #{@config['web_scraping']}"
    parser = Project_Hope::SimpleWebsiteParser.new(@config['web_scraping'])
    parser.start_parse
    
    # puts "Items: #{parser.item_collection}"
    parser.item_collection
  end

  def run_save_to_csv
    # puts "Saving to csv"

      category = @config['web_scraping']['product_category']
      directory_path = "./catalogs/#{category}"
      unless Dir.exist?(directory_path)
        Dir.mkdir(directory_path)
      end

      @item_collection.save_to_csv(directory_path)
    
      # CSV.open('data.csv', 'w') do |csv|
      #   csv << @item_collection.first.keys # Заголовки колонок
      #   @item_collection.each do |item|
      #   csv << item.values
      # end
      
      Project_Hope::LoggerManager.log_processed_file("Data saved to data.csv")
    rescue StandardError => e
      Project_Hope::LoggerManager.log_error("Failed to save data to CSV: #{e.message}")
    raise "Failed to save data to CSV: #{e.message}"
  end

  def run_save_to_json
      # puts "Saving to json"
      
      category = @config['web_scraping']['product_category']
      directory_path = "./catalogs/#{category}"
      unless Dir.exist?(directory_path)
        Dir.mkdir(directory_path)
      end

      @item_collection.save_to_json(directory_path)
      # File.open(file_path, 'w') do |file|
      # file.write(JSON.pretty_generate(@item_collection))
      # end
      
      Project_Hope::LoggerManager.log_processed_file("Data saved to data.json")
    rescue StandardError => e
      Project_Hope::LoggerManager.log_error("Failed to save data to JSON: #{e.message}")
    raise "Failed to save data to JSON: #{e.message}"
  end

  def run_save_to_yaml
    # puts "Saving to yaml"

    category = @config['web_scraping']['product_category']
    directory_path = "./catalogs/#{category}"
    unless Dir.exist?(directory_path)
      Dir.mkdir(directory_path)
    end

    @item_collection.save_to_yml(directory_path)
    # File.open('data.yml', 'w') do |file|
    #   file.write(@item_collection.to_yaml)
    # end

      Project_Hope::LoggerManager.log_processed_file("Data saved to data.yml")
    rescue StandardError => e
      Project_Hope::LoggerManager.log_error("Failed to save data to YAML: #{e.message}")
    raise "Failed to save data to YAML: #{e.message}"
  end

  def run_save_to_sqlite
  db_connector = DatabaseConnector.new(@config_file)
  db_connector.connect_to_database
  db = db_connector.db

  db.execute <<-SQL
    CREATE TABLE IF NOT EXISTS items (
      id INTEGER PRIMARY KEY,
      name TEXT,
      price REAL,
      description TEXT,
      image TEXT
    );
  SQL

  @item_collection.each do |item|
    db.execute("INSERT INTO items (name, price, description, image) VALUES (?, ?, ?, ?)", 
               [item[:name], item[:price], item[:description], item[:image]])
  end

  db_connector.close_connection
  Project_Hope::LoggerManager.log_processed_file("Data saved to SQLite database")
rescue StandardError => e
  Project_Hope::LoggerManager.log_error("Failed to save data to SQLite: #{e.message}")
  raise "Failed to save data to SQLite: #{e.message}"
  end

  def run_save_to_mongodb
  db_connector = DatabaseConnector.new(@config_file)
  db_connector.connect_to_database
  db = db_connector.db

  collection = db[:items]
  @item_collection.each do |item|
    collection.insert_one(item)
  end

  db_connector.close_connection
  Project_Hope::LoggerManager.log_processed_file("Data saved to MongoDB database")
rescue StandardError => e
  Project_Hope::LoggerManager.log_error("Failed to save data to MongoDB: #{e.message}")
  raise "Failed to save data to MongoDB: #{e.message}"
  end

  def archive_results
    Zip::File.open('results.zip', Zip::File::CREATE) do |zipfile|
      Dir['results/*'].each do |file|
        zipfile.add(file.sub('results/', ''), file)
      end
    end
    Project_Hope::LoggerManager.log_processed_file("Results archived to results.zip")
  rescue StandardError => e
    Project_Hope::LoggerManager.log_error("Failed to archive results: #{e.message}")
    raise "Failed to archive results: #{e.message}"
  end

  def send_archive_in_background
    ArchiveSender.perform_async('results.zip', @config['email'])
  end
end

class ArchiveSender
  include Sidekiq::Worker

  def perform(archive_path, email)
      Pony.mail(
        to: email,
        subject: 'Results Archive',
        body: 'Please find the attached results archive.',
        attachments: { 'results.zip' => File.read(archive_path) }
      )
      Project_Hope::LoggerManager.log_processed_file("Archive sent to #{email}")
    rescue StandardError => e
      Project_Hope::LoggerManager.log_error("Failed to send archive: #{e.message}")
    raise "Failed to send archive: #{e.message}"
  end
end

# Приклад використання
# engine = Engine.new('config.yml')
# engine = Engine.new
# engine.run