require 'mechanize'
require 'rubygems'
require 'uri'
require_relative 'inputValidation'
require_relative 'inputDiscovery'
require_relative 'customAuthentication'
require_relative 'displayResults'
require_relative 'pageDiscovery'
require_relative 'vectors'

class Options

	#This class variables store the final results of the fuzz.
	@@finalResultSanitization
	@@finalResultSensitive
	@@sensitveData
	@@possibleDOS
	@@HTTPErrorCodes
	def self.fuzzDiscover(agent, mainURL, customAuth)
		
		@@finalResultSanitization = Array.new
		@@finalResultSensitive = Array.new
		@@possibleDOS = Array.new
		@@finalResultSanitization[0] = "##########################################\nLack of Sanitization In:\n####################################\n"
		@@finalResultSensitive[0] = "####################################\nSensitive Data Found In:\n####################################\n"
		@@possibleDOS[0] = "####################################\nPossible Denial of Service attacks found in:\n####################################\n"
		@@HTTPErrorCodes = ["####################################\nHTTP ERROR CODES:\n####################################\n"]
		#Authenticate using the custom authentication string
		CustomAuthentication.authenticate(agent, mainURL, customAuth)
		
		#Initialize the required variables
		linkQueries = Hash.new
		formInputs = Hash.new
		
		# Get all the pages in the website.
		foundLinks = PageDiscovery.discoverPages(agent, mainURL)
		
		# Traverse each of the pages and find all the possible inputs.
		foundLinks.each do |link|
			# Get the current page for the link
			curPage = agent.get(link)
			
			# Get all the queries in the link
			linkQueries = InputDiscovery.discoverQueries(curPage, 
										linkQueries)
			
			# Get all the input forms in the page
			formInputs = InputDiscovery.discoverForms(curPage, formInputs)
		end
		
		cookies = InputDiscovery.discoverCookies(agent)
		
		return [foundLinks, linkQueries, formInputs, cookies] 
	end
	
	def self.fuzzTest(agent, mainURL, cmdLineOptions) 
		#Get all the required command line options
		customAuth = cmdLineOptions[0]
		vectorFile = cmdLineOptions[1]
		sensitiveFile = cmdLineOptions[2]
		puts sensitiveFile
		random = cmdLineOptions[3]
		@@slow = cmdLineOptions[4].to_i
		if vectorFile == 0
			vectorFile = "vectors-small.txt"
		end
		#The default slow time is 500
		if @@slow == 0
			@@slow = 500
		end
		#Create the vector object that contains the list of all the
		#vectors to be fuzzed.
		vectors = Vector.new(vectorFile)
		
		#Create the array of sensitive data.
		@@sensitiveData = File.readlines(sensitiveFile).map{|line| line.strip}
		
		#Run fuzz discover first, get all the inputs.
		inputs = fuzzDiscover( agent, mainURL, customAuth)
		linkQueries = inputs[1]
		formInputs = inputs[2]
		cookies = inputs[3]
		
		#This is custom for dvwa. It has been hard coded temporarily.
		#It will still work for other websites, but just go through
		#the same loop 3 times.
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
			fuzzLinkQueries(agent, linkQueries, vectors)
			puts "############# FORM INPUTS ######################"
			fuzzFormInputs(agent, formInputs, vectors)
		end
		
		#All the variables for generating a report are stored here.
		countSanitization = @@finalResultSanitization.length - 1
		sensitiveReport = Hash.new
		countDOS = @@possibleDOS.length - 1
		@@sensitiveData.each do |data|
			sensitiveReport[data] = 0
		end
		File.open("output.txt", 'w') { |file| 
			@@finalResultSanitization.each  do |line|
				file.write(line)
			end
			@@finalResultSensitive.each do |line| 
				file.write(line)
				@@sensitiveData.each do |data|
					if line.include? data
						sensitiveReport[data] += 1 
					end
				end
			end
			@@possibleDOS.each do|line| 
				file.write(line)
			end
			
		}
		File.open("report.txt",'w') do |file1|
			file1.write("Lack of Sanitization count:\n")
			file1.write("#{countSanitization}\n\n")
			file1.write("Sensitive Data Report:\n")
			sensitiveReport.each_key do |data|
				file1.write("\n #{data} found in #{sensitiveReport[data]} instances\n")
			end
			file1.write("\nNumber of Denial of Service Possibilities:\n")
			file1.write(countDOS)
			file1.write("\nHTTPErrorCodes:\n")
			numCode = @@HTTPErrorCodes.length - 1
			file1.write("#{@@HTTPErrorCodes.uniq} found in #{numCode} instances")
		puts "THE END"
		end
	end
	
	# Check all the link queries with fuzz vectors.
	def self.fuzzLinkQueries(agent, linkQueries, vectorList)
		#Check if there is a vector next in the vectorList
		while vectorList.has_next?
			#Get the next vector
			vector = vectorList.next_fuzzVector
			#Go through the list of queries with one specific vector
			linkQueries.each_key do |link|
				testInput( true, link, agent, vector)
			end
		end
		#After parsing reset the vector count.
		vectorList.reset_count!
	end
	
	# Check all the form inputs with fuzz vectors.
	def self.fuzzFormInputs(agent, formInputs, vectorList)
		#Check if there is a vector next in the vectorList
		while vectorList.has_next?
			#Get the next vector
			vector = vectorList.next_fuzzVector
			#Go through the list of inputs with one specific vector
			formInputs.each_key do |link|
				testInput( false, link, agent, vector)
			end
		end
		#After parsing reset the vector count.
		vectorList.reset_count!
	end
	
	

=begin
	This part deals with all the method responsible for checking
	if the output meets the required validation properties such
	as sanitized input, response time limits, sensitive data
	not leaked etc.
=end

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
		
	def self.checkSanitization( page, vector)
		if page.body.include?(vector.chomp)
			@@finalResultSanitization << "Link: #{page.uri.host}#{page.uri.path}\n"
		end
	end
	
	def self.checkSensitiveData(page)
		@@sensitiveData.each do |data|
			if page.content.include?(data)
				@@finalResultSensitive << "Link: #{page.uri.host}#{page.uri.path} contains #{data}\n"
			end
		end
	end
	
	def self.generateReport
	
	end
	
end