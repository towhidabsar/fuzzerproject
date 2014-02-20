require 'mechanize'
require 'rubygems'

listLinks = Array.new
visitedLinks = Array.new

def linkDiscover( url )
#create a new Mechanize agent for crawling
	agent = Mechanize.new{|a| a.ssl_version, a.verify_mode = 'SSLv3', 
	OpenSSL::SSL::VERIFY_NONE}

	puts url

	page = agent.get(url)
	listLinks = page.links
	visitedLinks = []
	
	listLinks.each do |link|
		visitedLinks << page
		#puts link.uri
		puts page.links
		page = agent.get(link.uri)
		listLinks << page.links
	end
end

puts "Welcome to Fuzzy, the Web Application Testing Tool."
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
	end
end