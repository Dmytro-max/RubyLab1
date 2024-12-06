
configurator = Configurator.new
puts "Deffault config:"
puts configurator.config

puts 'Configuring...'
configurator.configure(
  run_website_parser: 1,      # Включити розбір сайту
  run_save_to_csv: 1,         # Включити збереження даних в CSV
  run_save_to_yaml: 1,        # Включити збереження даних в YAML
  run_save_to_sqlite: 1       # Включити збереження даних в базі даних SQLite
)

puts configurator.config

puts 'Available methods:'
puts Configurator.available_methods