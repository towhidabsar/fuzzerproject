require 'mechanize'
require 'rubygems'
require 'uri'
require_relative 'inputValidation'
require_relative 'inputDiscovery'
require_relative 'customAuthentication'

class PageDiscovery

	def self.discoverPages(agent, url)
		# List of links found that will be traversed 
		foundLinks = Array.new
		
		# List of links already visited. Used to prevent repeated traversals.
		visitedLinks = Array.new
		#Show that the crawling started
		puts "\n\tCrawling <#{url}>\n"
		mainPage = agent.get(url)
		uriArray = URI.split(url)
		
		# Add the given page to the mainPage
		foundLinks << mainPage.uri 
		
		# Find all the links in the given page
		mainPage.links.each do |link|
			foundLinks << mainPage.uri.merge(link.uri)
		end
		
		begin
			foundLinks.each do |link|
				visitedLinks << link
				foundLinks.delete(link)
				
				curPage = agent.get(link)
				
				# Find all the links in the website
				curPage.links.each do |subLink|
					foundLinks << curPage.uri.merge(subLink.uri)
				end
				# Guess pages part goes here
				
				# Ensure no duplicates are in the list
				foundLinks = foundLinks.uniq
				foundLinks = filterOffSiteLinks(foundLinks, uriArray[2])
			end
		rescue => e
			puts e.message
		end
		
		return visitedLinks
	end
	
	# Check to see if the Remove links that go offsite from given array into corresponding 
	# array. We need to have a verify that this is actually doing what 
	# we think it is doing
	def self.filterOffSiteLinks(foundLinks, host)
		foundLinks.delete_if{ |link| 
			(URI.split(link.to_s))[2] != host
		 }
		 return foundLinks
	end

	# Should this just add in all the guessed pages into 
	# or also validate those pages?
	# or ??? (insert suggestions)
	def self.guessPages(url)
		extensions = ['.php', '.jsp', '.txt', '.html', '.htm']
		words = Array.new
		testURLs = Array.new
		validURLs = Array.new
		
		#url = 'http://127.0.0.1'
		#url = InputValidation.validateURL(url)	

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
end

#.select or .findall
# .select takes in a block 