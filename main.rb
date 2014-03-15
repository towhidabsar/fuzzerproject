require 'mechanize'
require 'rubygems'
require 'uri'
require_relative 'inputValidation'
require_relative 'inputDiscovery'
require_relative 'customAuthentication'
require_relative 'options'
require_relative 'displayResults'

commands = Hash.new { |hash, key| hash[key] = 
	"#{key} is not currently support." }
	

def main
	puts "Please enter: fuzz [discover | test] <url> OPTIONS"
	agent = 0
	while true
		input = gets.chomp
		input = input.split
		options = input[3..-1]
		cmdLineOptions = cmdlineparsing(options)
		if input[0] == "fuzz"
			case input[1]
				when /\Adiscover\z/i	
					# Initialize the agent
					agent = Mechanize.new{|a| a.ssl_version, 
							a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE}
					results = Options.fuzzDiscover( agent, input[2])
					DisplayResults.displayInputs(results[1])
					DisplayResults.displayForms(results[2])
					DisplayResults.displayCookies(results[3])
					
				when /\Atest\z/i
					agent = Mechanize.new{|a| a.ssl_version, 
							a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE}
					results = Options.fuzzDiscover( agent, input[2])
					
					Options.fuzzTest( agent, results[1], results[2], results[3])
					DisplayResults.displayInputs(results[1])
					DisplayResults.displayForms(results[2])
					DisplayResults.displayCookies(results[3])
			end
		else 
			puts " An invalid command."
		end
	end
end

def cmdlineparsing( options )
	results = [0,0,0,0,0]
	options.each do |command|
		if command.start_with?("--custom-auth=")
			stringarray = command.split("=")
			results[0] = stringarray[1]
		else if command.start_with?("--vectors=")
			stringarray = command.split("=")
			results[1] = stringarray[1]
		else if command.start_with?("--sensitive=")
			stringarray = command.split("=")
			results[2] = stringarray[1]
		else if command.start_with?("--random=")
			stringarray = command.split("=")
			results[3] = stringarray[1]
		else if command.start_with?("--slow=")
			stringarray = command.split("=")
			results[4] = stringarray[1]
		end
	end
	return results
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