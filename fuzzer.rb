require 'mechanize'
require 'rubygems'
require 'uri'
require_relative 'InputValidation'
require_relative 'InputDiscovery'
require_relative 'CustomAuthentication'
 
$listLinks = Array.new
$visitedLinks = Array.new

$linkInputs = Hash.new
$formInputs = Hash.new
$cookieInputs = Hash.new

$domain = ""

class PageDiscovery
	def self.linkDiscover( url )
		agent = Mechanize.new{|a| a.ssl_version, a.verify_mode = 'SSLv3', 
		OpenSSL::SSL::VERIFY_NONE}

		puts "\n\tCrawling <#{url}>"
		
		mainPage = agent.get(url)
		$domain = URI.split(url)
		puts $domain
		mainPage.links.each do |link|
			$listLinks << link.uri
		end
		$visitedLinks = []
		
		$listLinks.each do |link|
			if not linkOffsiteFilter(link)
				if not $visitedLinks.include? link
					begin
						$visitedLinks << link
						currentPage = agent.get(link)
						puts currentPage.link
						$linkInputs = InputDiscovery.linkInputDiscover(currentPage, $linkInputs)
						$formInputs = InputDiscovery.formInputDiscover(currentPage, $formInputs)
						currentPage.links.each do |link|
							$listLinks << link.uri
						end
						#Make sure no duplicate links are present just in case
						$listLinks = $listLinks.uniq
					rescue => e
						puts e.message
						puts e.backtrace
					end
				end
			end
		end
		
		self.displayInputs
	end

	#Remove links that go offsite from given array into corresponding array
	def self.linkOffsiteFilter(link)
		url = link
		url = url.to_s
		url = URI.split(url)
		return $domain[2] == url[2]
	end

	#Creates the arrays that are needed to hold the links
	def self.displayInputs
		puts "Inputs via Links:"
		puts "##########################################################################"
		$linkInputs.each do |key, value|
			puts "Base URL : "+key
			puts "Possible Inputs:"
			value.each do |input|
				puts input
			end
		end
		puts "##########################################################################"
		
		puts "Inputs via Forms:"
		puts "##########################################################################"
		$formInputs.each do |key, value|
			puts "Page URL : " + key.to_s
			value.each do |input|
				puts input.to_s
			end
		end
	end
end

#.select or .findall
# .select takes in a block 

# this is a useless comment, please delete me