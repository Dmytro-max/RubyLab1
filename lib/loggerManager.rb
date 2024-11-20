module MyApplicationName
  class LoggerManager
    class << self
      attr_reader :logger

      def initialize_logger(config)
        log_directory = config['directory']
        log_level = config['level']
        log_files = config['files']

        Dir.mkdir(log_directory) unless Dir.exist?(log_directory)

        application_log = File.join(log_directory, log_files['application_log'])
        error_log = File.join(log_directory, log_files['error_log'])

        @logger = Logger.new(application_log)
        @logger.level = Logger.const_get(log_level)

        error_logger = Logger.new(error_log)
        error_logger.level = Logger.const_get(log_level)

        @logger.extend(Module.new do
          define_method(:error) do |msg|
            super(msg)
            error_logger.error(msg)
          end
        end)
      end

      def log_processed_file(message)
        logger.info(message)
      end

      def log_error(message)
        logger.error(message)
      end
    end
  end
end

# # Приклад використання
# config = YAML.load_file('logger_config.yaml')
# MyApplicationName::LoggerManager.initialize_logger(config)
# MyApplicationName::LoggerManager.log_processed_file('This is an info message.')
# MyApplicationName::LoggerManager.log_error('This is an error message.')