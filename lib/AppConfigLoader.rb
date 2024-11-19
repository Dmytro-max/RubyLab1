
class AppConfigLoader

  def self.load
    AppConfig.new
  end

  def config (str: config_path, str: yaml_directory)
    File.open(config_path, r)
    File.open(yaml_directory, r)
  end

end