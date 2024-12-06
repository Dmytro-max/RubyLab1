
# module Project_Hope
    
collection = Project_Hope::ItemCollection.new
collection.generate_test_items(5)
collection.method_missing(:show_all_items)

puts "Saving"
collection.save_to_file('../output/items.txt')
collection.save_to_csv('../output/items.csv')
collection.save_to_json('../output/items')
collection.save_to_yml('../output/items')

puts "Mapping"
double_prices = collection.map { |item| item.price = item.price * 2; }
puts double_prices

puts "New collection"
new_collection = Project_Hope::ItemCollection.new
new_collection.generate_test_items(7)
new_collection.method_missing(:show_all_items)

puts "Enumerable methods"
puts new_collection.any? do |item| item.price > 1000 end
puts new_collection.all? do |item| item.price < 100 end
puts new_collection.count do |item| item.price < 100 end
garden_item = new_collection.find do |item| item.category == "Garden" end
puts garden_item

new_collection.remove_item(garden_item)
new_collection.method_missing(:show_all_items)
new_collection.delete_items()
new_collection.method_missing(:show_all_items)
new_collection.add_item(garden_item)
new_collection.method_missing(:show_all_items)
# end