require 'mechanize'
require 'rubygems'

$listLinks = Array.new
$visitedLinks = Array.new
$linksFilter

def authentication
	

end
def linkDiscover( url )
#create a new Mechanize agent for crawling
	agent = Mechanize.new{|a| a.ssl_version, a.verify_mode = 'SSLv3', 
	OpenSSL::SSL::VERIFY_NONE}

	puts url

	page = agent.get(url)
	$listLinks = page.links
	$visitedLinks = []
	puts [].length
	puts $listLinks.length

	$listLinks.each do |link|
		if $visitedLinks.include? link
			
		else
			$visitedLinks << page
			puts link.uri
			puts page.links
			page = agent.get(link.uri)
			$listLinks << page.links
		end

	end
end

#Remove links that go offsite from given array into corresponding array
def linkOffsiteFilter

end

#Creates the arrays that are needed to hold the links
def createLinksArrs

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
					linkDiscover( command[2] )
			end
			#case command[1]
			#	when /\Atest\z/i
					#do something here, le hue
			#end
		else 
			puts command[0]+ " is an invalid command."
		end
	end
end

main

#.select or .findall
# .select takes in a block