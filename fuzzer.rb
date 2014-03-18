require_relative 'vectors'

class Fuzzer
	include ResultsOutput

	# 
	def initialize agent, linkQueries, formInputs, cookies, options
		@agent = agent
		@slow = options[:slow]
		@customAuth = options[:customAuth]
		@sensitiveFile = options[:sensitiveFile]
		@vectorFile = options[:vectorFile]

		@vectors = Vectors.new(@vectorFile)
		@sensitiveData = File.readlines(@sensitiveFile).map{|line| line.strip} 
		
		@sensitiveReport = Hash.new
		@sensitiveData.each do |data|
			@sensitiveReport[data] = 0
		end

		@linkQueries = linkQueries
		@formInputs = formInputs
		@cookies = cookies

		@possibleDOS = ["########\nPossible DOS in:\n##########\n"]
		@finalResultSanitization = ["Lack of Sanitization in:\n"]
		@finalResultSensitive = ["Sensitive Data in:\n"]
		@HTTPErrorCodes = ["#########\nHTTP ERROR CODES:\n############\n"]
	end

	# 
	def fuzz
		curSecurity = ["low", "medium", "high"]
		i = 0
		# For dvwa change cookie value, start with low, medium and then high.
		if @customAuth == "dvwa"
			while i < 3
				@cookies.each do |cookie|
					if cookie.name == "security"
						 cookie.value = curSecurity[i]
						 puts "################### SECURITY LEVEL :#{curSecurity[i]} ###################"
					end
				end
				puts "############# LINK QUERIES dvwa ######################"
				fuzzLinkQueries
				puts "############# FORM INPUTS dvwa ######################"
				fuzzFormInputs
				i += 1
			end
		else
			puts "############# LINK QUERIES bodgeit ######################"
			fuzzQueries
			puts "############# FORM INPUTS bodgeit ######################"
			fuzzInputs
		end
	end

	# 
	def fuzzLinkQueries
		# Check if there is a vector next in the vectorList
		while @vectors.has_next?
			# Get the next vector
			vector = @vectors.next_fuzzVector
			# Go through the list of queries with one specific vector
			@linkQueries.each_key do |link|
				testInput(true, link, vector)
			end
		end
		# After parsing reset the vector count.
		@vectors.reset_count!
	end

	# Check all the form inputs with fuzz vectors.
	def fuzzFormInputs
		# Check if there is a vector next in the vectorList
		while @vectors.has_next?
			# Get the next vector
			vector = @vectors.next_fuzzVector
			# Go through the list of inputs with one specific vector
			@formInputs.each_key do |link|
				testInput(false, link, vector)
			end
		end
		# After parsing reset the vector count.
		@vectors.reset_count!
	end

	#
	def checkSanitization(vector)
		if @agent.page.body.include?(vector.chomp)
			@finalResultSanitization << "Link: %s %s\n"
			%[page.uri.host, page.uri.path]
		end
	end

	#
	def checkSensitiveData
		@sensitiveData.each do |data|
			if @agent.page.content.include?(data)
				@finalResultSensitive << "Link: %s %s contains %s\n"
				%[page.uri.host, page.uri.path, data]
			end
		end
	end

	# This method is responsible for performing the actual tests
	def testInput(type, link, vector)
		formBool = true
		start_time = 0
		if type
			# Record the start_time
			start_time = Time.now
			@agent.post(link, vector) 		
		else
			# Get the page and the forms
			page = @agent.get( link )
			form = page.forms.first
			# If there is a form in the page
			if form != nil
				formBool == true
				# Input vector into the fields
				form.fields_with( :value => "").each do |field|
					field.value = vector
				end
				# Submit the form
				button = form.button_with(:value => /submit/)
				# Record the start_time
				start_time = Time.now
				begin
					@agent.submit(form, button)
				rescue => e
					@HTTPErrorCodes << e
				end
			else
				formBool = false
			end
		end

		if formBool == true
			# Check the time it took to complete the request.
			wait_time = Time.now - start_time

			# Check the sanitization of input.
			checkSanitization(vector)

			# Check whether any sensitive data is leaked.
			checkSensitiveData

			if wait_time * 1000 > @slow
				@possibleDOS << "Link: %s %s\n"
					%[@agent.page.uri.host, @agent.page.uri.path]
			end
		end
	end
end