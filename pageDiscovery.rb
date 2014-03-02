require 'mechanize'
require 'rubygems'
require 'uri'
require_relative 'inputValidation'
require_relative 'inputDiscovery'
require_relative 'customAuthentication'
require_relative 'displayResults'

$domain = ""
$agent

#
class PageDiscovery
	def self.linkDiscover( url )
		#Initialize the agent
		$agent = Mechanize.new{|a| a.ssl_version, a.verify_mode = 'SSLv3', 
		OpenSSL::SSL::VERIFY_NONE}
		
		#Initializes the structures to contain links
	
			#List of links found that will be traversed -- to be moved to main
			foundLinks = Array.new
			
			#List of links traversed --- to be moved to main
			visitedLinks = Array.new
		
		#Initializes structures to save page information / input 
		
			#use uri.query rename to linkqueries -- move to main
			linkQueries = Hash.new
			
			#standard inputs found on a page (i.e. username / pw fields, text boxes, etc..) -- move to main
			formInputs = Hash.new
			
			#cookies found on a page --rename to cookies -- move to main
			cookies = Array.new
	
		#Authenticate to given link -- move to main
		puts "\n\tCrawling <#{url}>\n"
		CustomAuthentication.authenticate($agent, url)
		mainPage = $agent.get(url)
		$domain = URI.split(url)
		
		
		foundLinks << mainPage.uri

		# Input here what the formating of the links being put in are for memory sake
		mainPage.links.each do |link|
			foundLinks << mainPage.uri.merge(link.uri)
		end

		begin
			foundLinks.each do |link|
				if not (filterOffSiteLinks(link) & (visitedLinks.include? link))
					visitedLinks << link
					puts link
					curPage = $agent.get(link)
					linkQueries = InputDiscovery.discoverQueries(curPage, linkQueries)
					formInputs = InputDiscovery.discoverForms(curPage, formInputs)

					curPage.links.each do |subLink|
						#if(curPage.link_with(:text => "/dvwa"))
							foundLinks << curPage.uri.merge(subLink.uri)
						#else	
						#	foundLinks << subLink.uri
						#end
					end
					#foundLinks.concat(guessPages(link))
					#Make sure no duplicate links are present just in case
					foundLinks = foundLinks.uniq
				end
				puts ""
			end
		rescue => e
			puts e.message
			#puts e.backtrace
		end
		cookies = InputDiscovery.discoverCookies($agent, cookies)

		displayResults.displayInputs(linkQueries)
		displayResults.displayForms(formInputs)
		displayResults.displayCookies(cookies)
	end

	# Remove links that go offsite from given array into corresponding array
	# We need to have a verify that this is actually doing what we think it is doing
	def self.filterOffSiteLinks(link)
		url = link
		url = url.to_s
		url = URI.split(url)
		return $domain[2] == url[2]
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