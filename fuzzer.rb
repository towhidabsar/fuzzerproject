require 'mechanize'
require 'rubygems'
require 'uri'

$listLinks = Array.new
$visitedLinks = Array.new
$filteredInputs = Hash.new
$domain = ""
$linksFilter

#Discovers all the inputs in the page.
def inputDiscover(page)
	#Get the URL of the current page.
	url = page.link.uri
	url = url.to_s
	url = url.split('?')
	puts "AA"
	link = url[0]
	puts link
	input = url[1]
	if not $filteredInputs.has_key? link
		$filteredInputs[link] = Array.new
	end
	if url.length > 1
		input = input.split('&')
		input.each do |x|
			$filteredInputs[link] << x
		end
	end
	#Get all the form parameters of the page
	inputForms = page.forms
	$filteredInputs[link] << inputForms
end

def linkDiscover( url )
#create a new Mechanize agent for crawling
	agent = Mechanize.new{|a| a.ssl_version, a.verify_mode = 'SSLv3', 
	OpenSSL::SSL::VERIFY_NONE}

	puts url
	
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


def main
	puts "Welcome to Fuzzy, the Web Applicadtion Testing Tool."
	puts "Please enter: fuzz [discover | test] <url> OPTIONS"

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