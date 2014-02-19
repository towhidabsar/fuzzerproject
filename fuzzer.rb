require 'mechanize'
require 'rubygems'

listLinks = Array.new
visitedLinks = Array.new

def linkDiscover( url )
#create a new Mechanize agent for crawling
	agent = Mechanize.new

	puts url

	page = agent.get(url)
	listLinks.add(page.links)
	
	page.links.each do |link|
		linkDiscover(link.uri)
	end

end

puts "Welcome to Fuzz Web Application Testing Tool. Please enter - fuzz [discover | test] url OPTIONS"

while true

	command = gets.chomp
	command = command.split
	if command[0] == "fuzz"
		case command[1]
			when /\Adiscover\z/i
				linkDiscover( command[2] )
		end
	end
end