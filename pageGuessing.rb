require 'mechanize'
require_relative 'InputValidation.rb'

#Commented lines are used for testing purposes.

def guessPages(url)
	extensions = ['.php', '.jsp', '.txt', '.html', '.htm']
	words = Array.new
	testURLs = Array.new
	validURLs = Array.new
	
	#url = 'http://127.0.0.1'
	url = InputValidation.validateURL(url)	

	agent = Mechanize.new{|a| a.ssl_version, a.verify_mode = 'SSLv3', 
		OpenSSL::SSL::VERIFY_NONE}
	
	file = File.new("words.txt")
	file.each do |word|
		words << word.strip
	end

	words.each do |word|
		extensions.each do |ext|
			testURLs << url + '/' + word + ext
			
		end
	end
	
	testURLs.each do |test|
		begin
			agent.get(test) do |page|
			puts 'Page Found: ' + test
				validURLs << test
			end
		rescue
			puts 'No Page Found: ' + test
		end
	end
	
	#puts validURLs
	return validURLs	
end