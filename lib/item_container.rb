require 'json'
require 'csv'
require 'faker'

module Project_Hope

  module ItemContainer
    def self.included(base)
      base.extend ClassMethods
      base.include InstanceMethods
    end

    module ClassMethods
      def class_info
        "Class: #{name}, Version: 1.0"
      end

      def object_count
        @object_count ||= 0
      end

      def increment_object_count
        @object_count = object_count + 1
      end
    end

    module InstanceMethods
      def add_item(item)
        @items << item
        LoggerManager.log_processed_file("Added item: #{item.inspect}")
      end

      def remove_item(item)
        @items.delete(item)
        LoggerManager.log_processed_file("Removed item: #{item.inspect}")
      end

      def delete_items
        @items.clear
        LoggerManager.log_processed_file("Deleted all items")
      end

      def method_missing(method_name, *arguments, &block)
        if method_name == :show_all_items
          @items.each { |item| puts item.inspect }
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        method_name == :show_all_items || super
      end
    end
  end

  class ItemCollection
    include ItemContainer
    include Enumerable

    attr_accessor :items

    def initialize
      @items = []
      self.class.increment_object_count
      LoggerManager.log_processed_file("Initialized ItemCollection")
    end

    def each(&block)
      @items.each(&block)
    end

    def save_to_file(directory)
      File.open(directory, 'w') do |file|
        @items.each { |item| file.puts item.inspect }
      end
      LoggerManager.log_processed_file("Saved items to #{directory}")
    end

    def save_to_json(directory = './catalogs')
      # puts "Directory: #{directory}"
      @items.each do |item|
        # puts "Item name: #{item[:name]}"
        File.open("#{directory}/#{item[:name]}.json", 'w') do |file|
          file.write(JSON.pretty_generate(item.to_h))
        end
      end
      # File.open("#{directory}/data.json", 'w') do |file|
      #   file.write(JSON.pretty_generate(item.to_h))
      # end
      LoggerManager.log_processed_file("Saved items to #{directory}")
    end

    def save_to_csv(directory = 'items.csv')
      # puts "save_to_csv"

      # csv = CSV.open(directory, 'w')
      @items.each do |item|
        CSV.open("#{directory}/#{item[:name]}.csv", 'w') do |csv|
          csv << ["name", "price", "description", "category", "image_path"]
          csv << [item[:name], item[:price], item[:description], item[:category], item[:image_path]]
        end
      end
      # CSV.open(directory, 'w') do |csv|
      #   csv << @items.first.to_h.keys
      #   @items.each { |item| csv << item.to_h.values }
      # end
      LoggerManager.log_processed_file("Saved items to #{directory}")
    end

    def save_to_yml(directory = 'items.yml')
      # puts "save_to_yml"

     @items.each do |item|
        File.open("#{directory}/#{item[:name]}.yml", 'w') do |file|
          file.write(item.to_h.to_yaml)
        end
      end
      LoggerManager.log_processed_file("Saved items to YAML files")
    end

    
    def generate_test_items(count)
      count.times do
        add_item(Item.generate_fake)
      end
    end

    # Enumerable methods
    def map(&block)
      @items.map(&block)
    end

    def select(&block)
      @items.select(&block)
    end

    def reject(&block)
      @items.reject(&block)
    end

    def find(&block)
      @items.find(&block)
    end

    def reduce(initial, &block)
      @items.reduce(initial, &block)
    end

    def all?(&block)
      @items.all?(&block)
    end

    def any?(&block)
      @items.any?(&block)
    end

    def none?(&block)
      @items.none?(&block)
    end

    def count(&block)
      @items.count(&block)
    end

    def sort(&block)
      @items.sort(&block)
    end

    def uniq(&block)
      @items.uniq(&block)
    end
  end
end



