require 'mechanize'
require 'rubygems'
require 'uri'
require File.join File.dirname(__FILE__), 'InputValidation'
require File.join File.dirname(__FILE__), 'InputDiscovery'
require File.join File.dirname(__FILE__), 'CustomAuthentication'
require File.join File.dirname(__FILE__), 'PageDiscovery'

commands = Hash.new { |hash, key| hash[key] = 
	"#{key} is not currently support." }

def main
	#puts "Welcome to Fuzzy, the Web Applicadtion Testing Tool."
	puts "Please enter: fuzz [discover | test] <url> OPTIONS"
	#puts "/tMore Options: -- "
	#puts "/t/tcustom-auth="

	while true
		input = gets.chomp
		input = input.split

		if input[0] == "fuzz"
			case input[1]
				when /\Adiscover\z/i
					PageDiscovery.linkDiscover(input[2])
					puts "Displaying all the inputs of the system"
				when /\Atest\z/i
					puts "fuzz test has not been implemented yet"
			end
		else 
			puts " An invalid command."
		end
	end
end

# if customAuth option
# 	customAuth(link)
# linkDiscover(link)

#linkQueries = new Array ...
#formInputs = new..
#linkCookies = new...

#loop
# linkQueries = inputDiscovery.link
# formInputs = inputDiscovery.forms
# linkCookies = inputDiscovery.cookies

main
puts "THE END"