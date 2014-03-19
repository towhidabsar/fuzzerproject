# 
module ResultsOutput extend self

	# Creates the arrays that are needed to hold the links
	def printQueries
		puts "\n##############################################"
		puts "\t\tQueries"
		puts "\n##############################################"
		@links.each do |key, value|
			puts "Base URL : #{key}"
			puts "Possible Inputs:"
			value.each do |input|
				puts input
			end
		end
	end

  	# 
	def printForms
		puts "\n##############################################"
		puts "\t\tForms"
		puts "\n##############################################"
		@forms.each do |key, value|
			puts "\nPage URL: #{key.to_s}"
			value.each do |input|
				puts "\tName: %s \n\t   Value: %s \n\t   Type:
				 %s" %[input.name, input.value, input.type]
			end
		end
	end

 	# 
	def printCookies
		puts "\n##############################################"
		puts "\t\tCookies"
		puts "\n##############################################"
		
		prevDom = ""

		@cookies.each do |cookie|
			if(cookie.domain != prevDom)
				puts "Domain Name: #{cookie.domain}"
				prevDom = cookie.domain
			end
			puts "\tName: %s \n\t   Value: %s" 
				%[cookie.name, cookie.value]
		end
	end

	#
	def writeLog
		File.open("output.txt", 'w') { |file| 
			@finalResultSanitization.each  do |line|
				file.write(line)
			end
			@finalResultSensitive.each do |line| 
				file.write(line)
				@sensitiveData.each do |data|
					if line.include? data
						@sensitiveReport[data] += 1 
					end
				end
			end
			@possibleDOS.each do|line| 
				file.write(line)
			end

	end

	#
	def writeReport 
		File.open("report.txt", 'w') do |file|
			file.write("Lack of Sanitization count: 
				#{(@finalResultSanitization.length - 1)}")

			file.write("\nSensitive Data Report:\n"
			@sensitiveReport.each_key do |data|
				file.write("\n %s found in %s instances")
				%[data, sensitiveReport[data]]
			end

			file.write("\nNumber of DOS Possibilities: 
				#{(@possibleDOS.length - 1)}\n")

			file.write("HTTP Error Codes:\n")
			file.write("\t%s found in %s instances\n")
				%[@HTTPErrorCodes.uniq, (@HTTPErrorCodes.length - 1)]
			puts "THE END"
		end
	end
end 