module DisplayResults

	# Creates the arrays that are needed to hold the links
	def displayInputs
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
	def displayForms
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
	def displayCookies
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
				%[@cookie.name, @cookie.value]
		end
	end

	def displayTestResults

	end
end 

#/~bx5647/courses/plc/06-js