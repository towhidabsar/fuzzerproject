require 'mechanize'
require 'rubygems'
require 'uri'
require File.join File.dirname(__FILE__), 'InputValidation'
require File.join File.dirname(__FILE__), 'InputDiscovery'
require File.join File.dirname(__FILE__), 'CustomAuthentication'
require File.join File.dirname(__FILE__), 'fuzzer'


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
					fuzzer.linkDiscover(command[2])
					puts "Displaying all the inputs of the system"
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