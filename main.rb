commands = Hash.new { |hash, key| hash[key] = 
	"#{key} is not currently support." }
	

def main
	puts "Please enter: fuzz [discover | test] <url> OPTIONS"
	while true
		input = gets.chomp.split

		if(input[0].downcase == "fuzz")
			case input[1]
				when  /\Adiscover\z/i
					test = false
				when  /\Atest\z/i
					test = true
				when  /\Aexit\z/i	
					exit
			end

			@options
			splitInput = input[3..-1]
			opts = optionsParsing(splitInput)

			crawler = Crawler.new(opts, input[2])
			crawler.crawl(test)
		else
			puts "Invalid Command #{input[0]}"
		end
	end
end

#
def optionsParsing(rawOptions)
	@options = {
		customAuth: "",
		vectorsFile: "vectors-small.txt",
		sensitiveFile: "sensitive-data.txt",
		slow: 500,
		random: 0
	}
	rawOptions.each do |command|
		case 
			when command.start_with?("--custom-auth=")
				notEmptyAdd(:customAuth, command)
			when command.start_with?("--vectors=")
				notEmptyAdd(:vectorsFile, command)
			when command.start_with?("--sensitive=")
				notEmptyAdd(:sensitiveFile, command)
			when command.start_with?("--random=")
				notEmptyAdd(:random, command)
			when command.start_with?("--slow=")
				notEmptyAdd(:slow, command)
		end
	end
end

# 
def notEmptyAdd sym, command
	splitCommand = command.split("=")
	if splitCommand[1] != nil || splitCommand[1] != ""
		@options[sym => splitCommand[1]]
	end
end

main
puts "THE END"