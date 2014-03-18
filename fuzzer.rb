require_relative 'vectors'

class Fuzzer
	include ResultsOutput

	def initialize vectorFile, sensitiveFile
		@vectors = Vectors.new(vectorFile)
		@sensitiveData = File.readlines(sensitiveFile).map{|line| line.strip} 
		
		@sensitiveReport = Hash.new
		@sensitiveData.each do |data|
			@sensitiveReport[data] = 0
		end

		@possibleDOS = ["########\nPossible DOS in:\n##########\n"]
		@finalResultSanitization = ["Lack of Sanitization in:\n"]
		@finalResultSensitive = ["Sensitive Data in:\n"]
		@HTTPErrorCodes  ["#########\nHTTP ERROR CODES:\n############\n"]

	end

	def fuzz
		curSecurity = ["low", "medium", "high"]
		i = 0
		#For dvwa change cookie value, start with low, medium and then high.
		if customAuth == "dvwa"
			while i<3
				cookies.each do |cookie|
					if cookie.name == "security"
						 cookie.value = curSecurity[i]
						 puts "################### SECURITY LEVEL :#{curSecurity[i]} ###################"
					end
				end
				puts "############# LINK QUERIES ######################"
				fuzzLinkQueries(agent, linkQueries, vectors)
				puts "############# FORM INPUTS ######################"
				fuzzFormInputs(agent, formInputs, vectors)
				i += 1
			end
		else
			puts "############# LINK QUERIES ######################"
			fuzzQueries
			puts "############# FORM INPUTS ######################"
			fuzzInputs
		end
	end
	def fuzzLinkQueries vectorList
		# Check if there is a vector next in the vectorList
		while @vectors.has_next?
			# Get the next vector
			vector = vectorList.next_fuzzVector
			# Go through the list of queries with one specific vector
			@linkQueries.each_key do |link|
				testInput( true, link, agent, vector)
			end
		end
		#After parsing reset the vector count.
		vectorList.reset_count!
	end

	# Check all the form inputs with fuzz vectors.
	def fuzzFormInputs vectorList
		# Check if there is a vector next in the vectorList
		while vectorList.has_next?
			# Get the next vector
			vector = vectorList.next_fuzzVector
			# Go through the list of inputs with one specific vector
			@formInputs.each_key do |link|
				testInput( false, link, agent, vector)
			end
		end
		#After parsing reset the vector count.
		vectorList.reset_count!
	end

	def self.checkSanitization(page, vector)
		if page.body.include?(vector.chomp)
			@@finalResultSanitization << "Link: #{page.uri.host}#{page.uri.path}\n"
		end
	end

	def self.checkSensitiveData(page)
		@sensitiveData.each do |data|
			if page.content.include?(data)
				@finalResultSensitive << "Link: #{page.uri.host}#{page.uri.path} contains #{data}\n"
			end
		end
	end

		#This method is responsible for performing the actual tests
	def self.testInput(type, link, agent, vector)

		formBool = true
		start_time = 0
		if type
			#Record the start_time
			start_time = Time.now
			agent.post( link, vector) 		
		else
			#Get the page and the forms
			page = agent.get( link )
			form = page.forms.first
			#If there is a form in the page
			if form != nil
				formBool == true
				#Input vector into the fields
				form.fields_with( :value => "").each do |field|
					field.value = vector
				end
				#Submit the form
				button = form.button_with( :value => /submit/)
				#Record the start_time
				start_time = Time.now
				begin
					agent.submit( form, button)
				rescue => e
					@@HTTPErrorCodes << e
				end
			else
				formBool = false
			end
		end

		if formBool == true
			#Check the time it took to complete the request.
			wait_time = Time.now - start_time

			#Check the sanitization of input.
			#Check whether any sensitive data is leaked.
			checkSanitization( agent.page, vector)
			checkSensitiveData( agent.page )

			if wait_time * 1000 > @@slow
				@@possibleDOS << "Link: #{agent.page.uri.host}#{agent.page.uri.path}\n"
			end
		end
	end
end