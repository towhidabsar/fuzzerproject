# 
module ResultsOutput extend self
	HASHTAGS = 50
	# Creates the arrays that are needed to hold the links
	def printQueries links
		puts "\n#{"#"*HASHTAGS}"
		puts "\t\t\tQueries"
		puts "#{"#"*42}"
		links.each do |key, value|
			puts "Base URL : #{key}"
			value.each do |input|
				if(input != nil)
					puts "\t#{input}"
				end
			end
		end
	end

  	# 
	def printForms forms
		puts "#{"#"*HASHTAGS}"
		puts "\t\t\tForms"
		puts "#{"#"*HASHTAGS}"
		forms.each do |key, value|
			puts "\nPage URL: #{key.to_s}"
			value.each do |input|
				puts "\tName: %s \n\t   Value: %s \n\t   Type: %s 
				"%[input.name, input.value, input.type]
			end
		end
	end

 	# 
	def printCookies cookies
		puts "#{"#"*HASHTAGS}"
		puts "\t\t\tCookies"
		puts "#{"#"*HASHTAGS}"
		
		prevDom = ""

		cookies.each do |cookie|
			if(cookie.domain != prevDom)
				puts "Domain Name: #{cookie.domain}"
				prevDom = cookie.domain
			end
			puts "\tName: %s \n\t   Value: %s
				"%[cookie.name, cookie.value]
		end
	end

	#
	def writeLog(sanitized, sensitive, senseData, report, posDOS)
		File.open("output.txt", 'w') { |file| 
			sanitized.each  do |line|
				file.write(line)
			end
			sensitive.each do |line| 
				file.write(line)
				sensData.each do |data|
					if line.include? data
						report[data] += 1 
					end
				end
			end
			posDOS.each do|line| 
				file.write(line)
			end
		}#return
	end

	#
	def writeReport(sanitized, report, posDOS, httpErrorCodes)
		File.open("report.txt", 'w') do |file|
			file.write("Lack of Sanitization count: 
				#{(sanitized.length - 1)}")

			file.write("\nSensitive Data Report:\n")
			report.each_key do |data|
				file.write("\n %s found in %s instances")
				%[data, report[data]]
			end

			file.write("\nNumber of DOS Possibilities: 
				#{(@posDOS.length - 1)}\n")

			file.write("HTTP Error Codes:\n")
			file.write("\t%s found in %s instances\n")
				%[httpErrorCodes.uniq, (httpErrorCodes.length - 1)]
			puts "THE END"
		end
	end
end 