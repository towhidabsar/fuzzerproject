require 'mechanize'
require 'rubygems'

def discover( url )
#create a new Mechanize agent for crawling
	agent = Mechanize.new

	puts url

	page = agent.get(url)



	page.links.each do |link|
		puts link.text
	end

end

puts "Welcome to Fuzz Web Application Testing Tool. Please enter - fuzz [discover | test] url OPTIONS"

while true

	command = gets.chomp
	command = command.split
	if command[0] == "fuzz"
		case command[1]
			when /\Adiscover\z/i
				discover( command[2] )
		end
	end
end