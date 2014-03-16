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

	def self.fuzzDiscover(agent, mainURL, customAuth)
		
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
		random = cmdLineOptions[3]
		slow = cmdLineOptions[4]
		
		#Create the vector object that contains the list of all the
		#vectors to be fuzzed.
		vectors = Vector.new(vectorFile)
		
		#Run fuzz discover first, get all the results.
		results = fuzzDiscover( agent, mainURL, customAuth)
		linkQueries = results[1]
		formInputs = results[2]
		cookies = results[3]
		
		#This is custom for dvwa. It has been hard coded temporarily.
		#It will still work for other websites, but just go through
		#the same loop 3 times.
		curSecurity = ["low", "medium", "high"]
		i = 0
		
		#For dvwa change cookie value, start with low, medium and then high.
		while i<3
			cookies.each do |cookie|
				if cookie.name == "security"
					 cookie.value = curSecurity[i]
					 puts "################### SECURITY LEVEL :
					 #{curSecurity[i]} ###################"
				end
			end
			puts "############# LINK QUERIES ######################"
			fuzzLinkQueries(agent, linkQueries, vectors)
			puts "############# FORM INPUTS ######################"
			fuzzFormInputs(agent, formInputs, vectors)
			i += 1
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
				puts link
				agent.post( link, vector) 		
				start_time = Time.now
				checkSanitization( agent.page, vector)
				wait_time = Time.now - start_time
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
				puts link
				page = agent.get( link )
				form = page.forms.first
				if form != nil
					form.fields_with( :value => "").each do |field|
						field.value = vector
					end
					button = form.button_with( :value => /submit/)
					agent.submit( form, button)
					start_time = Time.now
					checkSanitization( agent.page, vector)
					wait_time = Time.now - start_time
				end
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
	def self.checkSanitization( page, vector)
		if page.body.include?(vector.chomp)
			puts "NO SANITIZATION"
		end
	end
	
	def self.checkSensitiveData
	
	end
end
