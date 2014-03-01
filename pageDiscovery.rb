require 'mechanize'
require 'rubygems'
require 'uri'
require_relative 'InputValidation'
require_relative 'InputDiscovery'
require_relative 'CustomAuthentication'

$domain = ""
$agent

class PageDiscovery
	def self.linkDiscover( url )
		#Initialize the agent
		$agent = Mechanize.new{|a| a.ssl_version, a.verify_mode = 'SSLv3', 
		OpenSSL::SSL::VERIFY_NONE}
		
		#Initializes the structures to contain links
	
			#List of links found that will be traversed -- to be moved to main
			listLinks = Array.new
			
			#List of links traversed --- to be moved to main
			visitedLinks = Array.new
		
		#Initializes structures to save page information / input 
		
			#use uri.query rename to linkqueries -- move to main
			linkInputs = Hash.new
			
			#standard inputs found on a page (i.e. username / pw fields, text boxes, etc..) -- move to main
			formInputs = Hash.new
			
			#cookies found on a page --rename to cookies -- move to main
			cookieInputs = Array.new
	
		#Authenticate to given link -- move to main
		puts "\n\tCrawling <#{url}>\n"
		CustomAuthentication.authenticate($agent, url)
		mainPage = $agent.get(url)
		$domain = URI.split(url)
		
		
		listLinks << mainPage.uri
		mainPage.links.each do |link|
			listLinks << mainPage.uri.merge(link.uri)
		end

		listLinks.each do |link|
			if not (linkOffsiteFilter(link) & (visitedLinks.include? link))
				begin
					visitedLinks << link
					puts link
					currentPage = $agent.get(link)
					linkInputs = InputDiscovery.linkInputDiscover(currentPage, linkInputs)
					formInputs = InputDiscovery.formInputDiscover(currentPage, formInputs)
					cookieInputs = InputDiscovery.cookieInputDiscover($agent, cookieInputs)
					currentPage.links.each do |subLink|
						#if(currentPage.link_with(:text => "/dvwa"))
							listLinks << currentPage.uri.merge(subLink.uri)
						#else	
						#	listLinks << subLink.uri
						#end
					end
					#listLinks.concat(guessPages(link))
					#Make sure no duplicate links are present just in case
					listLinks = listLinks.uniq
				rescue => e
					puts e.message
					#puts e.backtrace
				end
			end
			puts ""
		end
		displayInputs(linkInputs, formInputs, cookieInputs)
	end

	#Remove links that go offsite from given array into corresponding array
	def self.linkOffsiteFilter(link)
		url = link
		url = url.to_s
		url = URI.split(url)
		return $domain[2] == url[2]
	end
	
	#Creates the arrays that are needed to hold the links
	def self.displayInputs(links, forms, cookies)
		puts "\n##########################################################################"
		puts "\tInputs via Links:"
		puts "##########################################################################"
		links.each do |key, value|
			puts "Base URL : "+key
			puts "Possible Inputs:"
			value.each do |input|
				puts input
			end
		end

		puts "\n##########################################################################"
		puts "\tInputs via Forms:"
		puts "##########################################################################"
		forms.each do |key, value|
			puts "Page URL: #{key.to_s}"
			value.each do |input|
				puts "\t Name: #{input.name} - Value: #{input.value}"
				puts "\t\tType: #{input.type}"
			end
		end

		puts "\n##########################################################################"
		puts "\tInputs via Cookies:"
		puts "##########################################################################"
		
		cookies.each do |cookie|
			puts "Name: #{cookie.name} \tDomain Name: "+cookie.domain+"\tValue = "+cookie.value
		end
	end

	#Guess dem pages.
	def self.guessPages(url)
		extensions = ['.php', '.jsp', '.txt', '.html', '.htm']
		words = Array.new
		testURLs = Array.new
		validURLs = Array.new
		
		#url = 'http://127.0.0.1'
	#	url = InputValidation.validateURL(url)	

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

# this is a useless comment, please delete me