require 'sqlite3'
require 'mongo'

module Project_Hope

    class DatabaseConnector
        attr_accessor :db

        def initialize(config)
            @config = config
            @db = nil
            LoggerManager.log_processed_file("Initialized DatabaseConnector with config: #{@config}")
        end


        def connect_to_database
            case @config['database_type']
            when 'sqlite'
                connect_to_sqlite
            when 'mongodb'
                connect_to_mongodb
            else
                LoggerManager.log_error("Unsupported database type: #{@config['database_type']}")
            raise "Unsupported database type: #{@config['database_type']}"
            end
        end

        def close_connection
            if @db
                @db.close if @config['database_type'] == 'sqlite'
                @db.close if @config['database_type'] == 'mongodb'
                LoggerManager.log_processed_file("Closed connection to #{@config['database_type']} database")
                @db = nil
            end
        end

        private

        def connect_to_sqlite
            @db = SQLite3::Database.new(@config['database_path'])
            LoggerManager.log_processed_file("Connected to SQLite database at #{@config['database_path']}")
        rescue SQLite3::Exception => e
            LoggerManager.log_error("Failed to connect to SQLite database: #{e.message}")
            raise "Failed to connect to SQLite database: #{e.message}"
        end

        def connect_to_mongodb
            client = Mongo::Client.new(@config['mongodb_uri'])
            @db = client.database
            LoggerManager.log_processed_file("Connected to MongoDB database at #{@config['mongodb_uri']}")
        rescue Mongo::Error => e
            LoggerManager.log_error("Failed to connect to MongoDB database: #{e.message}")
            raise "Failed to connect to MongoDB database: #{e.message}"
        end
    end
end

# # Приклад використання
# config_file = 'database_config.yaml'

# # Підключення до SQLite
# sqlite_connector = DatabaseConnector.new(config_file)
# sqlite_connector.connect_to_database
# sqlite_connector.close_connection

# # Підключення до MongoDB
# mongodb_connector = DatabaseConnector.new(config_file)
# mongodb_connector.connect_to_database
# mongodb_connector.close_connection