require 'mechanize'
require 'rubygems'
require 'uri'
require_relative 'inputValidation'
require_relative 'inputDiscovery'
require_relative 'customAuthentication'
require_relative 'fuzzOptions'
require_relative 'displayResults'

commands = Hash.new { |hash, key| hash[key] = 
	"#{key} is not currently support." }
	
$results
$agent

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
					#Initialize the agent
					$agent = Mechanize.new{|a| a.ssl_version, 
							a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE}
					results = FuzzOptions.fuzzDiscover( $agent, input[2])
					DisplayResults.displayInputs(results[1])
					DisplayResults.displayForms(results[2])
					DisplayResults.displayCookies(results[3])
					
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