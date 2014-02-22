require 'mechanize'
require 'rubygems'
require 'uri'
require File.join File.dirname(__FILE__), 'InputValidation'
require File.join File.dirname(__FILE__), 'InputDiscovery'
require File.join File.dirname(__FILE__), 'CustomAuthentication'
require File.join File.dirname(__FILE__), 'fuzzer'

commands = Hash.new { |hash, key| hash[key] = 
	"#{key} is not currently support." }
=begin
commands{"discover": PageDiscovery.linkDiscover,
		 #"test": ,
		 #"custom-auth": ,
		 #"common-words": ,
		 #"vectors": ,
		 #"sensitive": ,
		 "exit": die("Exiting Fuzzy.")
		}
=end
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
			end
			#case input[1]
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