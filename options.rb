require 'mechanize'
require 'rubygems'
require 'uri'
require_relative 'inputValidation'
require_relative 'inputDiscovery'
require_relative 'customAuthentication'
require_relative 'displayResults'
require_relative 'pageDiscovery'

class Options

	def self.fuzzDiscover(agent, mainURL)
	
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
			linkQueries = InputDiscovery.discoverQueries(curPage, linkQueries)
			
			# Get all the input forms in the page
			formInputs = InputDiscovery.discoverForms(curPage, formInputs)
		end
		
		cookies = InputDiscovery.discoverCookies(agent)
		
		return [foundLinks, linkQueries, formInputs, cookies] 
	end
	
	def self.fuzzTest(agent, mainURL) 
		results = fuzzDiscover( agent, mainURL)
		linkQueries = results[1]
		formInputs = results[2]
		cookies = results[3]
 
     curSecurity = ["low", "medium", "high"]
     i = 0
     #For dvwa change cookie value, start with low, medium and then high.
		while i<3
			cookies.each do |cookie|
				if cookie.name == "security"
					 cookie.value = curSecurity[i]
					 puts "################### SECURITY LEVEL : #{curSecurity[i]} ###################"
				end
			end
			puts "############# LINK QUERIES ######################"
			fuzzLinkQueries(agent, linkQueries, '<script>alert("XSS")</script>')
			puts "############# FORM INPUTS ######################"
			fuzzFormInputs(agent, formInputs, '<script>alert("XSS")</script>')
			i += 1
		end
	end
	
	# Check all the link inputs with fuzz vectors.
	def self.fuzzLinkQueries(agent, linkQueries, vector)	
		linkQueries.each_key do |link|
			puts link
			agent.post( link, vector) 		
			start_time = Time.now
			checkSanitization( agent.page, vector)
			wait_time = Time.now - start_time
		end
	end
	# Check all the form inputs
	def self.fuzzFormInputs(agent, formInputs, vector)
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
	
	def self.checkSanitization( page, vector)
		if page.body.include?(vector.chomp)
			puts "NO SANITIZATION"
		end
	end
	
	def self.checkSensitiveData
	
	end
end
