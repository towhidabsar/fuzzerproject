require 'mechanize'
require 'rubygems'
require 'uri'
require InputValidation.rb
require InputDiscovery.rb
require CustomAuthentication.rb
 
$listLinks = Array.new
$visitedLinks = Array.new
$filteredInputs = Hash.new
$domain = ""
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
					inputDiscover(currentPage) 
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

#
def main
	puts "Welcome to Fuzzy, the Web Applicadtion Testing Tool."
	puts "Please enter: fuzz [discover | test] <url> OPTIONS"
	puts "/tMore Options: -- "
	puts "/t/tcustom-auth="

	while true
		command = gets.chomp
		command = command.split

		if command[0] == "fuzz"
			case command[1]
				when /\Adiscover\z/i
					$listLinks = Array.new
					$visitedLinks = Array.new
					$filteredInputs = Hash.new
					$domain = ""
					linkDiscover( command[2] )
					puts "Displaying all the inputs of the system"
					displayInputs
			end
			#case command[1]
			#	when /\Atest\z/i
					#do something here, le hue
			#end
		else 
			puts " An invalid command."
		end
	end
end

main
puts "THE END"

#.select or .findall
# .select takes in a block