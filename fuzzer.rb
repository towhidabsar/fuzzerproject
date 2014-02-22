require 'mechanize'
require 'rubygems'
require 'uri'
require_relative 'InputValidation'
require_relative 'InputDiscovery'
require_relative 'CustomAuthentication'
 
$listLinks
$visitedLinks

$linkInputs
$formInputs
$cookieInputs

$domain
$linksFilter


def linkDiscover( url )
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
					inputDiscover(currentPage, $linkInputs, $formInputs, $cookieInputs) 
					currentPage.links.each do |link|
						$listLinks << link.uri
					end
					#Make sure no duplicate links are present just in case
					$listLinks = $listLinks.uniq
				rescue
					puts "There was an exception. It was ignored"
				end
			end
		end
	end
end

#Remove links that go offsite from given array into corresponding array
def linkOffsiteFilter(link)
	url = link
	url = url.to_s
	url = URI.split(url)
	return $domain[2] == url[2]
end

#Creates the arrays that are needed to hold the links
def displayInputs
	$filteredInputs.each do |link, array|
		puts "For <"+link+"> : Inputs"
		puts "#############################################################################"
		array.each do |input|
			puts input
		end
		puts "#############################################################################"
	end
end

#.select or .findall
# .select takes in a block 

# this is a useless comment, please delete me