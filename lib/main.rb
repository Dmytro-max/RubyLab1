require 'nokogiri'
require 'open-uri'

document = Nokogiri::HTML(URI.open('https://smartcinema.ua/'))
puts document.css('h2').text

puts(URI.open('https://smartcinema.ua/'))


require 'yaml'
require 'mechanize'
require 'logger'
require 'fileutils'
require 'nokogiri'
require 'open-uri'
require 'concurrent-ruby'

