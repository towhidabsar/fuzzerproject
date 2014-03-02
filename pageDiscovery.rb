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
		$agent = Mechanize.new{|a| a.ssl_version, 
			a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE}
		
		# Initialize structs to contain links & save page info/input
		# All of this will be moved to main
	
			#List of links found that will be traversed 
			foundLinks = Array.new
			
			#List of links traversed
			visitedLinks = Array.new
		
			#use uri.query rename to linkqueries
			linkQueries = Hash.new
			
			#standard inputs found on a page
			formInputs = Hash.new
			
			#cookies found on a page
			cookies = Array.new
	
		#Authenticate to given link -- move to main
		puts "\n\tCrawling <#{url}>\n"
		CustomAuthentication.authenticate($agent, url)
		mainPage = $agent.get(url)
		$domain = URI.split(url)
		
		foundLinks << mainPage.uri # Add the given page to the mainPage

		# Put here format of added links
		mainPage.links.each do |link|
			foundLinks << mainPage.uri.merge(link.uri)
		end

		begin
			foundLinks.each do |link|
				if not (filterOffSiteLinks(link) & 
					(visitedLinks.include? link))
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
					#foundLinks.concat(guessPages(link)) or
					#foundLinks << guessPages(link) ???

					# Ensure no duplicates are in the list
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

	# Remove links that go offsite from given array into corresponding 
	# array. We need to have a verify that this is actually doing what 
	# we think it is doing
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