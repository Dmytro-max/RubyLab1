module MyApplicationName

    class SimpleWebsiteParser
      attr_accessor :config, :agent, :item_collection
  
      def initialize(config_file)
        @config = YAML.load_file(config_file)
        @agent = Mechanize.new
        @item_collection = []
        LoggerManager.log_processed_file("Initialized SimpleWebsiteParser with config: #{@config}")
      end
  
      def start_parse
        url = @config['start_url']
        if check_url_response(url)
          page = @agent.get(url)
          product_links = extract_products_links(page)
          threads = product_links.map do |link|
            Concurrent::Future.execute { parse_product_page(link) }
          end
          threads.each(&:wait)
        else
          LoggerManager.log_error("Start URL is not accessible: #{url}")
        end
      end
  
      def extract_products_links(page)
        page.links_with(href: @config['product_link_selector']).map(&:href)
      end
  
      def parse_product_page(product_link)
        if check_url_response(product_link)
          page = @agent.get(product_link)
          product = {
            name: extract_product_name(page),
            price: extract_product_price(page),
            description: extract_product_description(page),
            image: extract_product_image(page)
          }
          save_product_image(product[:image], product[:name])
          @item_collection << product
          LoggerManager.log_processed_file("Parsed product: #{product}")
        else
          LoggerManager.log_error("Product URL is not accessible: #{product_link}")
        end
      end
  
      def extract_product_name(page)
        page.at(@config['product_name_selector']).text.strip
      end
  
      def extract_product_price(page)
        page.at(@config['product_price_selector']).text.strip
      end
  
      def extract_product_description(page)
        page.at(@config['product_description_selector']).text.strip
      end
  
      def extract_product_image(page)
        page.at(@config['product_image_selector'])['src']
      end
  
      def check_url_response(url)
        response = @agent.head(url)
        response.code.to_i == 200
      rescue
        false
      end
  
      def save_product_image(image_url, product_name)
        category = @config['category']
        media_dir = File.join('media_dir', category)
        FileUtils.mkdir_p(media_dir)
        image_path = File.join(media_dir, "#{product_name}.jpg")
        File.open(image_path, 'wb') do |file|
          file.write(URI.open(image_url).read)
        end
        LoggerManager.log_processed_file("Saved image for product: #{product_name}")
      end
    end
  end
  
  # # Приклад використання
  # parser = MyApplicationName::SimpleWebsiteParser.new('config.yml')
  # parser.start_parse