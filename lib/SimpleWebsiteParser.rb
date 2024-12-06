module Project_Hope

    class SimpleWebsiteParser
      attr_accessor :config, :agent, :item_collection
  
      def initialize(config)
        # @config = YAML.load_file(config_file)["web_scraping"]
        @config = config
        @agent = Mechanize.new
        @item_collection = ItemCollection.new
        LoggerManager.log_processed_file("Initialized SimpleWebsiteParser with config: #{@config}")
      end
  
      def start_parse
        # token = @config['api_token']
        # @agent.request_headers = { 'Authorization' => "Bearer #{token}"}
        # url = "https://example.com"
        # @agent.user_agent_alias = 'Windows Chrome'
        url = @config['start_page']
        if check_url_response(url)
          page = @agent.get(url)

          product_links = extract_products_links(page)
          
          threads = product_links.map do |link|
            Concurrent::Future.execute { parse_product_page(link) }
          end
          threads.each(&:wait)
          # puts "Parsed products: #{@item_collection.count}"
        else
          LoggerManager.log_error("Start URL is not accessible: #{url}")
        end
      end
  
      def extract_products_links(page)
        # page.links_with(href: @config['product_link_selector']).map(&:href)
        page.links_with(css: @config['product_link_selector']).map(&:href)
      end
  
      def parse_product_page(product_link)
        # puts "Parsing product page: #{product_link}"
        if check_url_response(product_link)
          page = @agent.get(product_link)

          name = extract_product_name(page)
          price = extract_product_price(page)
          description = extract_product_description(page)
          image_uri = extract_product_image(page)
          image_path = save_product_image(image_uri, name)

          product = {
            name: name,
            price: price,
            description: description,
            category: @config['product_category'],
            image_path: image_path
          }
          @item_collection.add_item(product)
          LoggerManager.log_processed_file("Parsed product: #{product}")
        else
          LoggerManager.log_error("Product URL is not accessible: #{product_link}")
        end
      end
  
      def extract_product_name(page)
        # puts "Product Name Selector: #{(page.search(@config['product_name_selector']).text.strip)}"
        name=page.search(@config['product_name_selector']).text.strip
      end
  
      def extract_product_price(page)
        price=page.at(@config['product_price_selector']).text.strip.gsub(' ', '_')
      end
  
      def extract_product_description(page)
        description=page.at(@config['product_parameters']).text.strip
        # puts "Desc: #{description}"
      end
  
      def extract_product_image(page)
        page.at(@config['product_image_selector'])['src']
      end
  
      def check_url_response(url)
        # puts "Checking URL response: #{url}"
        response = @agent.head(url)
        response.code.to_i == 200
      rescue
        puts "Start URL is not accessible, error: #{response.code.to_i}"
        false
      end
  
      def save_product_image(image_url, product_name)
        # puts "Saving image for product: #{product_name}"
        catalog = @config['media_catalog']
        category = @config['product_category']
        media_dir = File.join('./catalogs', catalog, category)
        # puts "Media dir: #{File.absolute_path(media_dir)}"
        unless Dir.exist?(media_dir)
          Dir.mkdir(media_dir)
        end
        
        image_path = File.join(media_dir, "#{product_name}.jpg")
        File.open(image_path, 'wb') do |file|
          file.write(URI.open(image_url).read)
        end
        return image_path
        LoggerManager.log_processed_file("Saved image for product: #{product_name}")
      end
    end
  end
  